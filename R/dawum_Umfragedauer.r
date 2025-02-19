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
library(ragg)
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

source("R/lib/myfunctions.r")
source("R/lib/copyright.r")
source("R/lib/sql.r")

Institute <- RunSQL('select * from Institute;')

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

args = commandArgs(trailingOnly=TRUE)

if (length(args) == 0) {
  FromDay <- NA
} else if (length(args) == 1) {
  FromDay <- as.Date(args[1])
}

outdir <- 'png/dawum/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

citation <- paste( '© Thomas Arend, 2025\nQuelle: api.dawum.de\nStand', heute)

SQL =  paste (
      'select I.Name as Name'
    , ', Surveyed_Persons as Persons'
    , ', datediff(Date, Survey_End) as PublishDuration'
    , ', datediff(Survey_End, Survey_Start) as SurveyDuration'
    , ', datediff(Date, Survey_Start) as Duration'
    , 'from Surveys as S join ssInstitutes as I on S.Institute_Id = I.Id'
    , 'where Top and Parliament_Id = 0'
)


Dauer = RunSQL( SQL = SQL)
Labels = Dauer[, .(n = .N, d = round(mean(Duration),1), s = round(sd(Duration),1)), by = Name]

m = max(Dauer[,Duration])

Dauer %>% ggplot(
    aes ( x = Name, y = Duration )
    ) +
  geom_boxplot( color = 'black', fill = 'cyan' ) +
  geom_label( data = Labels, aes( y = m, label = paste0( 'n=', n, '\nmean=', d, '\ns=±', s)), vjust = 1  ) +
  labs(  title = paste( "Umfragedauer vom Beginn bis zur Veröffentlichung" )
           , subtitle = 'Nach Institut'
           , colour  = "Institut"
           , x = 'Institut'
           , y = 'Dauer [Tage]'
           , caption = citation ) +
  theme_ipsum() +
  theme( axis.text.x = element_text( angle = 90 )) -> P1

  ggsave(   filename = paste( outdir
                             , 'Duration'
                             , '.png'
                             , sep='')
            , plot = P1
            , device = "png"
            , bg = "white"
            , width = 1920
            , height = 1080
            , units = "px"
            , dpi = 144
  )

  Labels = Dauer[, .(n = .N, d = round(mean(SurveyDuration),1), s = round(sd(SurveyDuration),1)), by = Name]
  m = max(Dauer[,SurveyDuration])

  Dauer %>% ggplot(
      aes ( x = Name, y = SurveyDuration )
    ) +
    geom_boxplot( color = 'black', fill = 'cyan' ) +
    geom_label( data = Labels, aes( y = m, label = paste0( 'n=', n, '\nmean=', d, '\ns=±', s)), vjust = 1  ) +
    labs(  title = paste( "Dauer vom Beginn bis zum Ende einer Umfrage" )
           , subtitle = 'Nach Institut'
           , colour  = "Institut"
           , x = 'Institut'
           , y = 'Dauer [Tage]'
           , caption = citation ) +
    theme_ipsum() +
    theme( axis.text.x = element_text( angle = 90 )) -> P1
  
  ggsave(   filename = paste( outdir
                              , 'SurveyDuration'
                              , '.png'
                              , sep='')
            , plot = P1
            , device = "png"
            , bg = "white"
            , width = 1920
            , height = 1080
            , units = "px"
            , dpi = 144
  )

  Labels = Dauer[, .(n = .N, d = round(mean(PublishDuration),1), s = round(sd(PublishDuration),1)), by = Name]
  m = max(Dauer[, PublishDuration])
  
  Dauer %>% ggplot(
    aes ( x = Name, y = PublishDuration )
  ) +
    geom_boxplot( color = 'black', fill = 'cyan' ) +
    geom_label( data = Labels, aes( y = m, label = paste0( 'n=', n, '\nmean=', d, '\ns=±', s)), vjust = 1  ) +
    labs(  title = paste( "Dauer vom Ende der Umfrage bis zur Veröffentlichung" )
           , subtitle = 'Nach Institut'
           , colour  = "Institut"
           , x = 'Institut'
           , y = 'Dauer [Tage]'
           , caption = citation ) +
    theme_ipsum() +
    theme( axis.text.x = element_text( angle = 90 )) -> P1
  
  ggsave(   filename = paste( outdir
                              , 'PublishDuration'
                              , '.png'
                              , sep='')
            , plot = P1
            , device = "png"
            , bg = "white"
            , width = 1920
            , height = 1080
            , units = "px"
            , dpi = 144
  )
  
  Labels = Dauer[, .(n = .N, d = round(mean(Persons),1), s = round(sd(Persons),1)), by = Name]
  m = max(Dauer[,Persons])
  
  Dauer %>% ggplot(
    aes ( x = Name, y = Persons )
  ) +
    geom_label( data = Labels, aes( y = 0, label = paste0( 'n=', n, '\nmean=', d, '\ns=±', s)), vjust = 0  ) +
    geom_boxplot( color = 'black', fill = 'cyan' ) +
    expand_limits( y = 0 ) +
    labs(  title = paste( "Zahl der Befragten in einer Umfrage" )
           , subtitle = 'Nach Institut'
           , colour  = "Institut"
           , x = 'Institut'
           , y = 'Befragte'
           , caption = citation ) +
    theme_ipsum() +
    theme( axis.text.x = element_text( angle = 90 )) -> P1
  
  ggsave(   filename = paste( outdir
                              , 'Surveyed_Persons'
                              , '.png'
                              , sep='')
            , plot = P1
            , device = "png"
            , bg = "white"
            , width = 1920
            , height = 1080
            , units = "px"
            , dpi = 144
  )
  
