#!/usr/bin/env Rscript

options(OutDec=',')

MyScriptName <- "GetWahlumfragen"

require(data.table)
library(tidyverse)
library(grid)
library(gridExtra)
library(gtable)
library(lubridate)
library(ggplot2)
library(viridis)
library(hrbrthemes)
library(scales)
library(Cairo)
library(XML)
library(RCurl)
library(rlist)
library(stringr)
library(argparser)

# Set Working directory to git root

if (rstudioapi::isAvailable()){
  
  # When called in RStudio
  SD <- unlist(str_split(dirname(rstudioapi::getSourceEditorContext()$path),'/'))
  
} else {
  
  #  When called from command line 
  SD = (function() return( if(length(sys.parents())==1) getwd() else dirname(sys.frame(1)$ofile) ))()
  SD <- unlist(str_split(SD,'/'))
  
}

WD <- paste(SD[1:(length(SD)-1)],collapse='/')
setwd(WD)

source("R/lib/sql.r")
source("R/lib/Institute.r")

Institute <- RunSQL( 'select * from Institute;')
Parteien <- RunSQL( 'select * from Partei;' )

CSVOUT1 <- '/tmp/Ergebnisse.csv'
CSVOUT2 <- '/tmp/Umfragen.csv'

if (file.exists(CSVOUT1)) {

  unlink(CSVOUT1)

}
if (file.exists(CSVOUT2)) {
  
  unlink(CSVOUT2)
  
}

for (INo in 1:nrow(Institute)) {

  if ( Institute$autoupdate[INo] > 0 ) {
  print( Institute$Name[INo] )
  
  HTML <- getURL( Institute$url[INo]
                  , .opts = list( ssl.verifypeer = FALSE )
                  , .encoding = 'UTF-8' )

  tables <- readHTMLTable(HTML)

  umfragen <- tables[[2]]
  umfragen[,2] <- NULL
  
  namen <- colnames(umfragen)
  namen[1] <- 'Datum'
  namen[2] <- 'CDU/CSU'
  colnames( umfragen ) <- namen
  NoParteien <- match( 'Sonstige'
                       , namen )

  umfragen[, NoParteien + 1] <- NULL
  umfragen[, 1] <- as.Date( umfragen[,1], "%d.%m.%Y" )
  
  namen <- colnames( umfragen )
  
  for (i in 2:(NoParteien - 1) ) {
      
      umfragen[, i] <- as.numeric( 
                          str_replace(
                            str_replace(
                              str_replace_all(
                                str_replace_all(
                                  umfragen[, i]
                                  , " %"
                                  , "" )
                                , "%"
                                , "" )
                              , ","
                              , "."
                              )
                            , '(–-?)'
                            , "0" 
                            ) 
                          )
      
      umfragen[is.na(umfragen[, i]), i] <- 0.0
  } # end for

  umfragen[,NoParteien] <- 100 - rowSums( umfragen[, 2:(NoParteien - 1) ])
  umfragen$Befragte[ umfragen$Befragte == 'Bundestagswahl' ] <- -1

  umfragen$Befragte <- as.numeric(
                          str_remove(
                            str_remove(
                              umfragen$Befragte
                              , '.* '
                              )
                            , '\\.'
                            )
                          )
  
  Datum <- as.Date( NULL )
  Ergebnis <- as.numeric( NULL )
  Parteiname <- NULL
  PId <- NULL
  Befragte <- as.numeric( NULL )
  
  for ( i in 2:NoParteien ) {
  
    Datum <- c( Datum, umfragen$Datum )    
    PId <- c( PId, rep( Parteien$Id[match(colnames( umfragen )[i], Parteien$Shortcut)], nrow( umfragen ) ) )
#    Parteiname <- c( Parteiname, rep( colnames( umfragen )[i], nrow( umfragen ) ) )
    Ergebnis <- c( Ergebnis, umfragen[, i]/100)
    
  }
  
  write.table( data.table(
    Datum = umfragen$Datum
    , Institut = rep( Institute$Id[ INo ], nrow(umfragen) )
    , Parliament_ID = 0
    , Befragte = umfragen$Befragte
  )
  , file = CSVOUT2
  , append = TRUE
  , sep = ';'
  , dec = '.'
  , quote = FALSE
  , row.names = FALSE
  , col.names = FALSE
  )
  
  write.table( data.table(
      Datum = Datum
      , Institut = rep( Institute$Id[ INo ], length( Datum ) )
      , PId = PId
#      , Parteiname = Parteiname
      , Ergebnis = Ergebnis
    )
    , file = CSVOUT1
    , append = TRUE
    , sep = ';'
    , dec = '.'
    , quote = FALSE
    , row.names = FALSE
    , col.names = FALSE
  )
  
  }
}

system('/data/git/R/DEU-Umfragen/bash/wahlkreisprognose')
