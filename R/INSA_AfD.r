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

outdir <- 'png/Vergleich/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

citation <- paste( '© Thomas Arend, 2022\nQuelle: © wahlrecht.de/umfragen\nStand', heute)

Institute <- RunSQL( 'select * from Institute;')
Parteien <- RunSQL( 'select distinct P.* from Partei as P join Ergebnisse as E on P.Id = E.Partei_ID;')

umfragen <- RunSQL('select * from UmfrageErgebnisse where Partei_ID = 7 and year(Datum) > 2017;')

umfragen$Institut <- factor( umfragen$Institute_ID, levels = Institute$Id, labels = Institute$Shortname) 
umfragen$Partei <- factor( umfragen$Partei_ID, levels = Parteien$Id, labels = Parteien$Shortcut)

  umfragen %>% ggplot( ) + 
    geom_smooth( data = umfragen %>% filter(Institute_ID == 3), aes( x = Datum, y = Ergebnis, colour = Institut ), linewidth = 1 ) + 
    geom_smooth( data = umfragen %>% filter(Institute_ID == 8), aes( x = Datum, y = Ergebnis, colour = Institut   ), linewidth = 1 ) +
    geom_point ( data = umfragen %>% filter(Institute_ID == 3), aes( x = Datum, y = Ergebnis, colour = Institut   ), size = 1 ) +
    geom_point ( data = umfragen %>% filter(Institute_ID == 8), aes( x = Datum, y = Ergebnis, colour = Institut   ), size = 2 ) +
    scale_x_date( date_labels = "%Y" ) +
    scale_y_continuous( labels = scales::percent ) +
  theme_ipsum() +
    theme(
      axis.text.x = element_text( angle = 90)
    ) +
    labs(  title = paste( "Vergleich Umfrageergebnisse INSA vs andere Institute" )
           , subtitle = ''
           , colour  = "Institut"
           , x = "Datum"
           , y = "Ergebnis"
           , caption = citation )  -> PI
  
  ggsave(   filename = paste( outdir
                             , 'Vergleich AfD INSA.png'
                             , sep='')
            , plot = PI
            , device = "png"
            , bg = "white"
            , width = 1920
            , height = 1080
            , units = "px"
            , dpi = 144
  )

KreuzTab <- RunSQL( SQL = 'select u1.Datum as Datum, u2.Institute_ID as Institute_ID, u1.Ergebnis as INSA, u2.Ergebnis as Anderes from UmfrageErgebnisse as u1 join UmfrageErgebnisse as u2 on abs(datediff(u1.Datum , u2.Datum)) < 8 and u1.Partei_ID = u2.Partei_ID where u1.Institute_ID = 8 and u2.Institute_ID <> 8 and u1.Partei_ID = 7;')
KreuzTab$Institut <- factor( KreuzTab$Institute_ID, levels = Institute$Id, labels = Institute$Shortname) 

KreuzTab %>% ggplot( ) + 
  geom_smooth ( aes( x = INSA, y = Anderes, colour = Institut   ), method = 'glm' ) +
  geom_abline( intercept = 0 , slope = 1, color = 'black') +
  geom_point ( aes( x = INSA, y = Anderes, colour = Institut   ), alpha = 0.3) +
  coord_fixed() +
  facet_wrap(~Institut) +
  scale_x_continuous( labels = scales::percent ) +
  scale_y_continuous( labels = scales::percent ) +
  theme_ipsum() +
  theme(
    axis.text.x = element_text( angle = 90)
  ) +
  labs(  title = paste( "Kreuzvergleich Umfrageergebnisse AfD" )
         , subtitle = 'INSA vs 9 andere Institute '
         , colour  = "Institut"
         , x = "INSA"
         , y = "Anderes Institut"
         , caption = citation )  -> PI

ggsave(   filename = paste( outdir
                            , 'Kreuzvergleich AfD INSA.png'
                            , sep='')
          , plot = PI
          , device = "png"
          , bg = "white"
          , width = 1920 * 2
          , height = 1080 * 2
          , units = "px"
          , dpi = 144
)

for (I in Institute$Id) { 
  
  if (I != 8) {
    ra = glm ( data = KreuzTab %>% filter( Institute_ID == I), formula = Anderes ~ INSA)
    ci = confint(ra)
    print(c(Institute$Shortname[I],ci[2,]))
  }  
}
