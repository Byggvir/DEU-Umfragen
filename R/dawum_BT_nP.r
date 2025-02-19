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

source("R/lib/copyright.r")
source("R/lib/sql.r")

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

args = commandArgs(trailingOnly=TRUE)

if (length(args) == 0) {
  FromDay <- NA
  
} else if (length(args) == 1) {
  FromDay <- as.Date(args[1])
}

outdir <- 'png/dawum/Parteien/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

# ----
# - Ende Vorspann
# ----

citation <- paste( '© Thomas Arend, 2025\nQuelle: api.dawum.de\nStand', heute)

Institute <- RunSQL('select * from Institutes;')
Parteien <- RunSQL( 'select distinct P.* from Partei as P join Results as R on P.Id = R.Party_Id join BTSurvey as S on S.Id = R.Survey_Id;')


SQL = paste ('select S.Id as Survey_Id' 
             , ', S.Date as Datum'
             , ', S.Survey_Start as Von'
             , ', S.Survey_End as Bis'
             , ', R.Result as Result'
             , ', P.Id as PId'
             , ', I.Id as IId'
             , 'from Surveys as S'
             , 'join Institutes as I'
             , 'on S.Institute_Id = I.Id'
             , 'join Results as R'
             , 'on R.Survey_Id = S.Id'
             , 'join Partei as P'
             , 'on R.Party_Id = P.Id'
             , 'where S.Parliament_Id = 0; ' )

umfragen = RunSQL( SQL = SQL)

umfragen[, Institut := factor( IId, levels = Institute$Id, labels = Institute$Name) ]
umfragen[, Partei := factor( PId, levels = Parteien$Id, labels = Parteien$Shortcut) ]

BTW <- RunSQL(SQL = 'select max(Datum) as Datum from Bundestagswahl;')
BTW[, Datum := as.Date('2021-01-01')]

for ( p in 1:nrow(Parteien) ) {
  
  P = Parteien$Shortcut[p]
  cat('\n---',P, '---\n\n')
  
  # umfragen %>% filter( Partei == Parteien[p,"Shortcut"] & Datum >= BTW$Datum ) %>% ggplot(

  umfragen %>% filter( Partei == P & Datum >= "2022-12-31" & Result > 0 ) %>% ggplot(
    aes ( x = Bis, y = Result )
  ) +
    geom_smooth( method = 'loess'
                 , formula = y ~ x
                 , color = Parteien$Fill[p]
                 , span = 0.3
                 , show.legend = FALSE) +
    geom_point( aes( colour = Institut ), alpha = 0.5 ) +
    scale_x_date( date_labels = "%Y-%b" ) +
    scale_y_continuous( labels = scales::percent ) +
    labs(  title = paste( "Umfragen und Wahlergebnisse Bundestag" )
           , subtitle = paste( P )
           , colour  = "Institut"
           , x = "Datum"
           , y = "Ergebnis"
           , caption = citation )  +
    theme_ipsum() +
    theme(
      axis.text.x = element_text( angle = 90)
    ) -> PT

  ggsave(   filename = paste( outdir
                              , str_replace(P, '/' , '_' )
                              , '-S.png'
                              , sep='')
            , plot = PT
            , device = "png"
            , bg = "white"
            , width = 1920
            , height = 1080
            , units = "px"
            , dpi = 144
  )
  
  umfragen %>% filter( Partei == P ) %>% ggplot(
    aes ( x = Bis, y = Result )
  ) +
    geom_line( aes(colour = Partei)) +
    geom_hline(yintercept = 0.05, color = 'red' , linetype = 'dotted') +
#    geom_point( data = umfragen %>% filter( is.na(Befragte) & Partei == P ), size = 3 )+
    scale_x_date( date_labels = "%Y-%b" ) +
    scale_y_continuous( labels = scales::percent ) +
    scale_color_manual( breaks = Parteien$Shortcut, values = Parteien$Fill ) +
    expand_limits( y = 0 ) +
    facet_wrap(vars(Institut)) +
    labs(  title = paste( "Umfragen und Wahlergebnisse Bundestag" )
           , subtitle = paste( P )
           , colour  = "Partei"
           , x = "Datum"
           , y = "Ergebnis"
           , caption = citation ) + 
  theme() +
  theme_ipsum()  -> PT
  
  ggsave(   filename = paste( outdir
                              , str_replace(P, '/' , '_' )
                              , '-L.png'
                              , sep='')
            , plot = PT
            , device = "png"
            , bg = "white"
            , width = 1920
            , height = 1080
            , units = "px"
            , dpi = 144
  )
  
}

umfragen %>% 
  filter( Datum >= "2022-12-31" & Result > 0  & PId > 0  & PId != 8) %>%
    ggplot(
      aes ( x = Bis, y = Result, colour = Partei )
    ) +
    geom_point( alpha = 0.5 ) +
    geom_smooth(   aes(colour = Partei)
                 , method = 'loess'
                 , formula = y ~ x
                 , span = 0.3
                 , show.legend = FALSE) +
   # facet_wrap(vars(Partei), scales = 'free_y') +
    scale_x_date( date_labels = "%Y-%b" ) +
    scale_y_continuous( labels = scales::percent ) +
    scale_colour_manual( breaks = Parteien$Shortcut, values = Parteien$Fill ) +
    
    labs(  title = paste( "Sonntagsfrage zum Bundestag" )
           , subtitle = 'Seit 01.01.2023'
           , colour  = "Institut"
           , x = "Datum"
           , y = "Ergebnis"
           , caption = citation )  +
    theme_ipsum() +
    theme(
      axis.text.x = element_text( angle = 90)
    ) -> PT

ggsave(   filename = paste( outdir
                            , 'Alle.png'
                            , sep='')
          , plot = PT
          , device = "png"
          , bg = "white"
          , width = 1920
          , height = 1080
          , units = "px"
          , dpi = 96
)
