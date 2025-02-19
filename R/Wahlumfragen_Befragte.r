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

citation <- paste( '© Thomas Arend, 2025\nQuelle: © wahlrecht.de/umfragen\nStand', heute)

  Befragte <- RunSQL ('select I.Shortname as Institut, U.Befragte as Befragte from Umfragen as U join Institute as I on U.Institute_ID = I.`Id`;')
  Befragte %>% filter( ! is.na(Befragte) & Befragte > 0 )  %>% ggplot(
    aes ( x = Institut, y = Befragte )
  ) +
    geom_boxplot(  ) +
    expand_limits( y = 0 ) +
   labs(  title = paste( "Befragte nach Institut" )
           , subtitle = ''
           , colour  = "Institut"
           , x = "Institut"
           , y = "Befragte"
           , caption = citation ) +
  theme_ipsum() +
    theme (
      axis.text.x = element_text(angle = 90)
    ) -> IB
  
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
