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

ParteiFarbe <- data.frame(
  Name = c(    'CDU/CSU', 'SPD', 'FDP',    'FW',   'GRÜNE', 'LINKE',  'PDS',    'PIRATEN', 'REP',   'SSW',  'AfD',   'Sonstige')
  , Color = c( 'black',   'red', 'yellow', 'cyan', 'green', 'purple', 'purple', 'grey',    'brown', 'blue', 'brown', 'orange'  )
)

umfragen <- RunSQL('select * from Umfragen as U join Institute as I on U.IId = I.Id;')

umfragen$Partei <- factor( umfragen$Partei, levels = ParteiFarbe$Name, labels = ParteiFarbe$Name) 

umfragen$Institut <- factor( umfragen$IId, levels = Institute$Id, labels = Institute$Shortname) 

for (I in unique(umfragen$Institut) ) {
  
  umfragen %>% filter( Institut == I ) %>% ggplot(
    aes ( x = Datum, y = Ergebnis, colour = Partei )
    ) + 
    geom_smooth( aes(fill = Partei), method = 'glm' ) + 
    geom_line( aes(colour = Partei)) +
    geom_point( data = umfragen %>% filter( is.na(Befragte) & Institut == I ), size = 3 )+
    geom_hline(yintercept = 0.05, color = 'red' , linetype = 'dotted') +
    scale_x_date( date_labels = "%Y" ) +
    scale_y_continuous( labels = scales::percent ) +
    scale_color_manual( values = ParteiFarbe$Color, breaks = ParteiFarbe$Name) +
    expand_limits( y = 0 ) +
    facet_wrap(vars(Partei)) +
    theme_ipsum() +
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

for (P in unique(umfragen$Partei ) ) {

  umfragen %>% filter( Partei == P & Datum > as.Date('2021-12-31') ) %>% ggplot(
    aes ( x = Datum, y = Ergebnis )
  ) +
    geom_smooth( aes(fill = Partei), method = 'glm' ) +
    geom_line( aes(colour = Partei)) +
    geom_hline(yintercept = 0.05, color = 'red' , linetype = 'dotted') +
    geom_point( data = umfragen %>% filter( is.na(Befragte) & Partei == P ), size = 3 )+
    scale_x_date( date_labels = "%Y-%b" ) +
    scale_y_continuous( labels = scales::percent ) +
    scale_color_manual( values = ParteiFarbe$Color, breaks = ParteiFarbe$Name) +
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
                              , '-S.png'
                              , sep='')
            , plot = PT
            , device = "png"
            , bg = "lightgrey"
            , width = 1920
            , height = 1080
            , units = "px"
            , dpi = 144
  )
  
  umfragen %>% filter( Partei == P ) %>% ggplot(
    aes ( x = Datum, y = Ergebnis )
  ) +
    geom_smooth( aes(fill = Partei), method = 'glm' ) +
    geom_line( aes(colour = Partei)) +
    geom_hline(yintercept = 0.05, color = 'red' , linetype = 'dotted') +
    geom_point( data = umfragen %>% filter( is.na(Befragte) & Partei == P ), size = 3 )+
    scale_x_date( date_labels = "%Y-%b" ) +
    scale_y_continuous( labels = scales::percent ) +
    scale_color_manual( values = ParteiFarbe$Color, breaks = ParteiFarbe$Name) +
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
            , bg = "lightgrey"
            , width = 1920
            , height = 1080
            , units = "px"
            , dpi = 144
  )
  
}

  
  umfragen %>% filter( ! is.na(Befragte) )  %>% ggplot(
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
  
