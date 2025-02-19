#!/usr/bin/env Rscript

options(OutDec='.')

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
library(ragg)
library(XML)
library(RCurl)
library(rlist)
library(stringr)
library(argparser)
library(jsonlite)

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

setwd( paste0( WD, '/bash') )

system( '/data/git/R/DEU-Umfragen/bash/civey' )
setwd(WD)

sqlTS <- function ( TS ) {
  
  return( gsub( 'T', ' ', gsub('Z', '', TS ) ) )
  
}

Parteien = RunSQL ( 'select * from Partei;')

CIVEY <- fromJSON( paste0(WD,'/data/civey.json') )

Poll = CIVEY$props$pageProps$poll

Results = Poll$representativeResult

Parties = as.data.table(CIVEY$props$pageProps$poll$answers)

#
# Update the civeyParties with Party_ID of civey
#

updateParties <- function () {
  
  for (i in 1:nrow(Parties) ) {
    
    SQL = paste0( 'update civeyParties '
                  , 'set CId = '
                  , Parties[i, "id"]
                  , ', `text` ="'
                  , Parties[i, "text"]
                  , '" where `label` = "'
                  , Parties[i, "label"]
                  , '";'
    )
  
    ExecSQL( SQL = SQL)
    
  }
  
}

#
# End
#

#
# Insert survey into database
#

SQL = paste0( 'insert into civeySurveys values ( NULL'
  ,',"'
  , sqlTS( Results$date )
  , '","'
  , sqlTS( Results$timeframeFrom )
  , '","'
  , sqlTS( Results$timeframeTo )
  , '","'
  , sqlTS( Poll$firstVoteAt )
  , '","'
  , sqlTS( Poll$lastVoteAt )
  , '",'
  , Poll$sampleSize
  , ','
  , Poll$errorMargin
  , ');'
)

ExecSQL(SQL = SQL)

SQL = paste0('select * from civeySurveys where `date` ="',sqlTS( Results$date ),'";' )
LastSurvey = RunSQL( SQL = SQL )


# Ergebnisse der Parteien in Datenbank eintragen

Party_IDs = as.numeric(names(Results$resultRatios))
Party_Results = unlist(Results$resultRatios)

for ( p in 1:length(Party_IDs) ) {
  
  SQL = paste0( 'insert into civeyResults values ('
                , LastSurvey[1,"Id"] 
                , ','
                , Party_IDs[p] 
                , ','
                , Party_Results[p]
                , ');'
  )
  ExecSQL( SQL = SQL )
  
}
