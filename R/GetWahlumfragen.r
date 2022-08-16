#!/usr/bin/env Rscript

options(OutDec=',')

MyScriptName <- "GetWahlumfragen"

require(data.table)
library(tidyverse)
#library(REST)
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

Institute <- RunSQL('select * from Institute;')

CSVOUT <- '/tmp/Umfragen.csv'

if (file.exists(CSVOUT)) {
  unlink(CSVOUT)
}

for (INo in 1:nrow(Institute)) {

  print (Institute$Name[INo])
  
  HTML <- getURL(Institute$url[INo],.opts = list(ssl.verifypeer = FALSE), .encoding = 'UTF-8' )

  tables <- readHTMLTable(HTML)

  umfragen <- tables[[2]]
  umfragen[,2] <- NULL
  namen <- colnames(umfragen)
  namen[1] <- 'Datum'
  namen[2] <- 'CDU/CSU'
  colnames(umfragen) <- namen
  NoParteien <- match('Sonstige',namen)

  umfragen[,NoParteien+1] <- NULL
  umfragen[,1] <- as.Date(umfragen[,1],"%d.%m.%Y")
  
  namen <- colnames(umfragen)
  
  for (i in 2:(NoParteien-1)) {
    umfragen[,i] <- as.numeric(str_replace(str_replace(str_replace_all(umfragen[,i]," %", ""),",","."),'(–-?)',"0"))
  }

  umfragen[,NoParteien] <- 100 - rowSums(umfragen[,2:(NoParteien-1)])
  umfragen$Befragte[umfragen$Befragte=='Bundestagswahl'] <- NA

  umfragen$Befragte <- as.numeric(str_remove(str_remove(umfragen$Befragte, '.* '), '\\.'))
  

Datum <- as.Date(NULL)
Ergebnis <- as.numeric(NULL)
Parteiname <- NULL
Befragte <- as.numeric(NULL)              
  for ( i in 2:NoParteien ) {
    Datum <- c(Datum,umfragen$Datum)    
    Ergebnis <- c(Ergebnis,umfragen[,i]/100)
    Parteiname <- c(Parteiname,rep(colnames(umfragen)[i],nrow(umfragen)))
    Befragte <- c(Befragte,umfragen$Befragte)
  
  }

  umfragen2 <- data.table(
    Datum = Datum
    , Institut = rep(Institute$Name[INo],length(Datum))
    , Partei = Parteiname
    , Ergebnis = Ergebnis
    , Befragte = Befragte
  )
  
  write.table( umfragen2, file = CSVOUT, append = TRUE, sep = ',' , dec = '.', quote = FALSE , row.names = FALSE, col.names = FALSE)
  
}
