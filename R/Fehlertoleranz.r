#!/usr/bin/env Rscript

options(OutDec=',')

require(data.table)
library(tidyverse)
library(grid)
library(gridExtra)
library(gtable)
library(lubridate)
library(ggplot2)
library(ggrepel)
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

outdir <- 'png/Umfragen/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

citation <- paste( '© Thomas Arend, 2024\nQuelle: © wahlrecht.de/umfragen / wahlkreisprognose.de\nStand', heute)

Befragte = data.table (
  N = seq( from=1000, to=3000, by = 500 )
)

Befragte[,f:=factor(N)]

z = qnorm (0.975)

ggplot( ) +
    geom_function( fun = function (x) { z * sqrt (x *(1-x) / Befragte[1,N] ) }
                   , aes (colour = Befragte[1,f]) ) +
    geom_function( fun = function (x) { z * sqrt (x *(1-x) / Befragte[2,N] ) }
                   , aes (colour = Befragte[2,f]) ) +
    geom_function( fun = function (x) { z * sqrt (x *(1-x) / Befragte[3,N] ) }
                   , aes (colour = Befragte[3,f]) ) +
    geom_function( fun = function (x) { z * sqrt (x *(1-x) / Befragte[4,N] ) }
                   , aes (colour = Befragte[4,f]) ) +
    geom_function( fun = function (x) { z * sqrt (x *(1-x) / Befragte[5,N] ) }
                   , aes (colour = Befragte[5,f]) ) +
    scale_x_continuous( limits = c(0.001,0.05), labels = scales::percent ) +
    scale_y_continuous( labels = scales::percent ) +
    labs(  title = paste( "Fehlertoleranz einer Umfrage" )
           , subtitle = 'Fehler nach Anzahl der Befragen und Ergebnis für Parteien < 5 %'
           , colour  = "Befragte"
           , x = 'Ergebis [%]'
           , y = 'Fehler [%-Punkte]'
           , caption = citation ) +

    theme_ipsum() +
    theme() -> p
    
  ggsave(   filename = paste( outdir
                              , 'Fehlertoleranz'
                              , '.png'
                              , sep='')
            , plot = p
            , device = "png"
            , bg = "white"
            , width = 1920
            , height = 1080
            , units = "px"
            , dpi = 144
  )

