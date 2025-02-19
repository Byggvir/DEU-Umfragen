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

citation <- paste( '© Thomas Arend, 2025\nQuelle: https://www.volksverpetzer.de\nStand', heute)

w <- function (x) {
  
  return (10/(0.1554*x+7.6449)/(x+5)^2)
  
}

f = c(0.75, 0.8)

ggplot( ) +
    geom_function( fun = w 
                   , aes(colour = 'Volksverpetzer w(t)')
                   , linewidth = 2 ) +
    geom_function( fun = function(x) { return (w(1)*f[1]^(x-1)) }
                   , aes (colour = paste0('u(t) = w(1)*',f[1],'^(t-1)' ) )
                   , linewidth = 2) +
  #   geom_function( fun = function(x) { return (w(1)*f[2]^(x-1)) }
  #                  , aes (colour = paste0('u(t) = w(1)*',f[2],'^(t-1)' ) )
  #                  , linewidth = 2) +
    scale_x_continuous( limits = c(1,31) ) +
    scale_y_continuous( ) +
    labs(  title = paste( "Gewichtung der Umfrageergebnisse nach Alter")
           , subtitle = 'Volksverpetzer w(t) im Vergleich exponentiellen Gewichtung'
           , x = 't [Tage]'
           , y = 'Gewichtung'
           , caption = citation 
           , colour = 'Gewichtungsfunktion') +

    theme_ipsum() +
    theme() -> p
    
  ggsave(   filename = paste( outdir
                              , 'Volksverpetzer'
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

