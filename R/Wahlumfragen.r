#!/usr/bin/env Rscript

options(OutDec=',')

MyScriptName <- "Wahlumfragen"

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

outdir <- 'png/Umfragen/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

citation <- paste( '© Thomas Arend, 2022\nQuelle: © wahlrecht.de/umfragen\nStand', heute)

Parteien <- RunSQL( 'select distinct P.* from Partei as P join Ergebnisse as E on P.Id = E.Partei_ID;')

umfragen <- RunSQL('select * from UmfrageErgebnisse;')

umfragen$Institut <- factor( umfragen$Institute_ID, levels = Institute$Id, labels = Institute$Shortname) 
umfragen$Partei <- factor( umfragen$Partei_ID, levels = Parteien$Id, labels = Parteien$Shortcut)

for (I in unique(umfragen$Institut) ) {
  
  # cat("---", I, "---\n\n")
  
  umfragen %>% filter( Institut == I ) %>% ggplot(
    aes ( x = Datum, y = Ergebnis, colour = Partei )
    ) + 
    geom_smooth( aes(fill = Partei), method = 'glm', formula = y ~ x ) + 
    geom_line( aes(colour = Partei)) +
    geom_point( data = umfragen %>% filter( is.na(Befragte) & Institut == I ), size = 3 )+
    geom_hline(yintercept = 0.05, color = 'red' , linetype = 'dotted') +
    scale_x_date( date_labels = "%Y" ) +
    scale_y_continuous( labels = scales::percent ) +
    scale_color_manual( breaks = Parteien$Shortcut, values = Parteien$Fill ) +
    expand_limits( y = 0 ) +
    facet_wrap(vars(Partei)) +
    theme_ipsum() +
    theme(
      axis.text.x = element_text( angle = 90)
    ) +
    labs(  title = paste( "Umfragen und Wahlergebnisse Bundestag" )
           , subtitle = paste( I )
           , colour  = "Partei"
           , x = "Datum"
           , y = "Ergebnis"
           , caption = citation )  -> PI
  
  ggsave(   filename = paste( outdir
                             , 'Institut_'
                             , I
                             , '.png'
                             , sep='')
            , plot = PI
            , device = "png"
            , bg = "white"
            , width = 1920
            , height = 1080
            , units = "px"
            , dpi = 144
  )

}


BTW <- RunSQL(SQL = 'select max(Datum) as Datum from Bundestagswahl;')

BTW$Datum <- as.Date('2021-01-01')

for (P in unique(Parteien$Shortcut ) ) {
  
  cat('\n---', P, '---\n\n')
  
  umfragen %>% filter( Partei == P & Datum >= BTW$Datum ) %>% ggplot(
    aes ( x = Datum, y = Ergebnis )
  ) +
#    geom_smooth( aes(fill = Partei), method = 'glm', formula = y ~ x) +
    geom_line( aes(colour = Partei) ) +
    geom_hline(yintercept = 0.05, color = 'red' , linetype = 'dotted') +
#    geom_point( data = umfragen %>% filter( is.na(Befragte) & Partei_ID == P ), size = 3 )+
    scale_x_date( date_labels = "%Y-%b" ) +
    scale_y_continuous( labels = scales::percent ) +
    scale_color_manual( breaks = Parteien$Shortcut, values = Parteien$Fill ) +
    expand_limits( y = 0 ) +
    facet_wrap(vars(Institut)) +
    theme_ipsum() +
    theme(
      axis.text.x = element_text( angle = 90)
    ) +
    labs(  title = paste( "Umfragen und Wahlergebnisse Bundestag" )
           , subtitle = paste( P )
           , colour  = "Partei"
           , x = "Datum"
           , y = "Ergebnis"
           , caption = citation )  -> PT

  ggsave(   filename = paste( outdir
                              , 'Partei_'
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
    aes ( x = Datum, y = Ergebnis )
  ) +
    geom_line( aes(colour = Partei)) +
    geom_hline(yintercept = 0.05, color = 'red' , linetype = 'dotted') +
    geom_point( data = umfragen %>% filter( is.na(Befragte) & Partei == P ), size = 3 )+
    scale_x_date( date_labels = "%Y-%b" ) +
    scale_y_continuous( labels = scales::percent ) +
    scale_color_manual( breaks = Parteien$Shortcut, values = Parteien$Fill ) +
    expand_limits( y = 0 ) +
    facet_wrap(vars(Institut)) +
    theme_ipsum() +
    labs(  title = paste( "Umfragen und Wahlergebnisse Bundestag" )
           , subtitle = paste( P )
           , colour  = "Partei"
           , x = "Datum"
           , y = "Ergebnis"
           , caption = citation )  -> PT
  
  ggsave(   filename = paste( outdir
                              , 'Partei_'
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

  Befragte <- RunSQL ('select I.Shortname as Institut, U.Befragte as Befragte from Umfragen as U join Institute as I on U.Institute_ID = I.`Id`;')
  Befragte %>% filter( ! is.na(Befragte) & Befragte > 0 )  %>% ggplot(
    aes ( x = Institut, y = Befragte )
  ) +
    geom_boxplot(  ) +
    expand_limits( y = 0 ) +
    theme_ipsum() +
    theme (
      axis.text.x = element_text(angle = 90)
    ) +
    labs(  title = paste( "Befragte nach Institut" )
           , subtitle = ''
           , colour  = "Institut"
           , x = "Institut"
           , y = "Befragte"
           , caption = citation )  -> IB
  
  ggsave(   filename = paste( outdir
                              , 'Befragte' 
                              , '.png'
                              , sep='')
            , plot = IB
            , device = "png"
            , bg = "white"
            , width = 1920
            , height = 1080
            , units = "px"
            , dpi = 144
  )
