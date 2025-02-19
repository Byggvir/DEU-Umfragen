#!/usr/bin/env Rscript

options(OutDec=',')

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
library(XML)
library(RCurl)
library(rlist)
library(stringr)
library(argparser)

library(rjson)

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

#DAWUM <- fromJSON( 'data/dawum.json')
DAWUM <- fromJSON( 'https://api.dawum.de')

print(DAWUM$Database$Last_Update)

#
# Liste der Parlamente als Tabelle
#

get_parliaments <- function ( data ) {
  
  pnames = as.numeric(names(data))
  dt = data.table(
    Id = rep(0,length(pnames))
    , Shortcut = rep('',length(pnames))
    , Name = rep('',length(pnames))
    , Election = rep('',length(pnames))
  )
  
  j = 1
  
  for ( i in data ) {
    
    dt$Id[j] = pnames[j]
    dt$Shortcut[j] = i$Shortcut
    dt$Name[j] = i$Name
    dt$Election[j] = i$Election
    j = j + 1
  }
  
  return (dt)
  
}

#
# Liste der Parteien als Tabelle
#

get_parties <- function ( data ) {
  
  pnames = as.numeric(names(data))
  dt = data.table(
    Id = rep(0,length(pnames))
    , Shortcut = rep('',length(pnames))
    , Name = rep('',length(pnames))
  )
  
  j = 1
  
  for ( i in data ) {
    
    dt$Id[j] = pnames[j]
    dt$Shortcut[j] = i$Shortcut
    dt$Name[j] = i$Name
    j = j + 1
  }

  return (dt)

}

#
# Liste, die nur Namen enthält als Tabelle
#

get_names <- function ( data ) {
  
  pnames = as.numeric(names(data))
  dt = data.table(
    Id = rep(0,length(pnames))
    , Name = rep('',length(pnames))
  )
  
  j = 1
  
  for ( i in data ) {
    
    dt$Id[j] = pnames[j]
    dt$Name[j] = i$Name
    j = j + 1
  }
  
  return (dt)
  
}

#
# Liste der Umfragen als Tabelle 
#

get_surveys <- function ( data ) {
  
  pnames = as.numeric(names(data))
  l = length(pnames)
  dt = data.table(
    Id = rep(0,l)
    , Date = rep(as.Date("1900-01-01"),l)
    , Survey_Start = rep(as.Date("1900-01-01"),l)
    , Survey_End = rep(as.Date("1900-01-01"),l)
    , Surveyed_Persons = rep(0,l)
    , Parliament_ID = rep(0,l)
    , Institute_ID = rep(0,l)
    , Tasker_ID = rep(0,l)
    , Method_ID = rep(0,l)
    , NoParties = rep(0,l)
  )
  
  j = 1
  
  for ( Survey in data ) {
    
    dt$Id[j] = pnames[j]
    dt$Date[j] = Survey$Date
    dt$Survey_Start[j] = Survey$Survey_Period$Date_Start
    dt$Survey_End[j] = Survey$Survey_Period$Date_End
    dt$Surveyed_Persons[j] = Survey$Surveyed_Persons
    dt$Parliament_ID[j] = Survey$Parliament_ID
    dt$Institute_ID[j] = Survey$Institute_ID
    dt$Tasker_ID[j] = Survey$Tasker_ID
    dt$Method_ID[j] = Survey$Method_ID
    dt$NoParties[j] = length(Survey$Results)
    j = j + 1
  }
  
  
  return (dt)
  
}

#
# Ergebnisse der Umfragen als Tabelle
#

get_survey_results <- function ( data , max_results = 10000) {
  
  rnames = as.numeric(names(data))
  l = length(rnames)
  
  dt = data.table(
    Id = rep(0, max_results)
    , PId = rep(0, max_results)
    , Result = rep(0, max_results)
  )
  
  j = 1
  r = 1
  
  for ( Survey in data ) {
    
    pnames = as.numeric(names(Survey$Results))

    for ( k in 1:length(Survey$Results)) {
      dt[j,] = c( rnames[r], pnames[k], Survey$Results[k] )
      j = j + 1
    }
    
    r = r + 1 
  }
  
  dt$Result = dt$Result / 100
  return (dt)
  
}

# "Database"    

write.csv( DAWUM$Database, file = 'data/dawum/Database.csv'
 )

# "Parliaments" 

write.csv( get_parliaments(DAWUM$Parliaments)
           , file = 'data/dawum/Parliaments.csv'
           , row.names = FALSE
 )

# "Institutes"  

write.csv( get_names(DAWUM$Institutes)
           , file = 'data/dawum/Institutes.csv'
           , row.names = FALSE 
 )

# "Taskers"     

write.csv( get_names(DAWUM$Taskers)
           , file = 'data/dawum/Taskers.csv'
           , row.names = FALSE
 )

# "Methods"     

write.csv( get_names(DAWUM$Methods)
           , file = 'data/dawum/Methods.csv'
           , row.names = FALSE
 )

# "Parties"     

write.csv2( get_parties(DAWUM$Parties)
           , file = 'data/dawum/Parties.csv'
           , row.names = FALSE

 )

# "Surveys"

S = get_surveys(DAWUM$Surveys)
print(S[,.(Datum = max(Date), Von = max(Survey_Start), Bis = max(Survey_End))])

write.csv( S
           , file = 'data/dawum/Surveys.csv'
           , row.names = FALSE
 )

# "Surveys" Results

write.csv( get_survey_results(DAWUM$Surveys, max_results = sum(S$NoParties))
           , file = 'data/dawum/Results.csv'
           , row.names = FALSE
 )
