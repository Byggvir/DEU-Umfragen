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

outdir <- 'png/Umfragen/Institute/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

citation <- paste( '© Thomas Arend, 2025\nQuelle: © wahlrecht.de/umfragen\nStand', heute)

Parteien <- RunSQL( 'select distinct P.* from Partei as P join Ergebnisse as E on P.Id = E.Partei_ID;')

umfragen <- RunSQL('select * from UmfrageErgebnisse;')

umfragen[, Institut := factor( Institute_ID, levels = Institute$Id, labels = Institute$Shortname) ]
umfragen[, Partei := factor( Partei_ID, levels = Parteien$Id, labels = Parteien$Shortcut) ]

for (I in unique(umfragen$Institut) ) {
  
  cat("---", I, "---\n\n")
  
  umfragen %>% filter( Institut == I ) %>% ggplot(
    aes ( x = Datum, y = Ergebnis, colour = Partei )
    ) + 
    geom_smooth( aes(fill = Partei), method = 'glm', formula = y ~ x, show.legend = FALSE ) + 
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
