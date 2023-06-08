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

citation <- paste( '© Thomas Arend, 2022\nQuelle: © wahlrecht.de/umfragen / wahlkreisprognose.de\nStand', heute)

Parteien <- RunSQL( 'select * from Partei;')

umfragen <- RunSQL('select U.*,I.*,P.Id as PId, P.Color,P.Fill from Umfragen as U join ( select max(Datum) as Datum, IId from Umfragen group by IId ) as D on D.Datum=U.Datum and D.IId
= U.IId join Institute as I on I.Id = U.IId join Partei as P on P.Partei = U.Partei where U.Ergebnis > 0 order by I.Id, P.Id;')

umfragen$Institut <- factor( umfragen$IId, levels = Institute$Id, labels = Institute$Shortname) 
umfragen$Partei <- factor(umfragen$PId,levels = Parteien$Id, labels = Parteien$Partei)

umfragen %>% filter( Ergebnis > 0 ) %>% ggplot(
    aes ( x = '', y = Ergebnis, fill = Partei  )
    ) +
  geom_bar( stat="identity" ) +
  coord_polar( 'y', start = 0, direction = -1 ) +
  scale_fill_manual( breaks = Parteien$Partei, values = Parteien$Fill) +
  geom_label( 
    aes( label = paste( Ergebnis * 100,'%' ) ), 
    position = position_stack( vjust = 0.5 ),
    color = rep( c('white',rep('black',6)),nrow(umfragen)/7) ,
    label.size = 0.1,
    size = 3, 
    show.legend = FALSE ) +
  facet_wrap(vars(paste(Institut,Datum, '\nBefragte:', Befragte)), nrow = 2) +
  theme_void() +
  labs(  title = paste( "Umfragen Bundestag" )
           , subtitle = 'Letzte Umfragen nach Institut'
           , colour  = "Partei"
           , x = ''
           , y = 'Ergebnis'
           , caption = citation )  -> PieChart
  
  ggsave(   filename = paste( outdir
                             , 'LetzteUmfrage'
                             , '.png'
                             , sep='')
            , plot = PieChart
            , device = "png"
            , bg = "white"
            , width = 1920
            , height = 1080
            , units = "px"
            , dpi = 144
  )

  umfragen %>% filter( Ergebnis > 0 ) %>% ggplot(
    aes ( x = Shortname, y = Ergebnis, fill = Partei )
  ) + 
    geom_bar( position = position_dodge2(), stat="identity" ) +
    # coord_polar( 'y', start = 0, direction = -1 ) +
    geom_text( 
      aes( y = Ergebnis, label = paste( Ergebnis * 100,'%' ) ), 
      hjust = 0 ,
      vjust = 0.5 ,
      angle = 90,
      colour = 'blue',
      #fill = 'white',
      #label.size = 0.1,
      size = 3, 
      show.legend = FALSE

      ) +
    expand_limits( y = 0.4 ) +
    facet_wrap(vars(Partei), nrow = 2) +
    scale_y_continuous( labels = scales::percent ) +
    scale_fill_manual( breaks = Parteien$Partei, values = Parteien$Fill) +
    labs(  title = paste( "Umfragen Bundestag" )
           , subtitle = 'Letzte Umfragen nach Institut'
           , colour  = "Partei"
           , x = 'Institute'
           , y = 'Ergebnis'
           , caption = citation ) +
    theme_ipsum() +
    theme(
      axis.text.x = element_text( angle = 90, vjust = 0.5, hjust = 1 )
    )       -> PieChart
  
  ggsave(   filename = paste( outdir
                              , 'LetzteUmfrage-Partei'
                              , '.png'
                              , sep='')
            , plot = PieChart
            , device = "png"
            , bg = "white"
            , width = 1920
            , height = 1080
            , units = "px"
            , dpi = 144
  )

  Spanne <-  RunSQL('select * from Spanne;')
  Spanne$Partei <- factor(Spanne$PId,levels = Parteien$Id, labels = Parteien$Partei)
  
  Spanne %>% filter( Ergebnis > 0 ) %>% ggplot(
    aes ( x = Partei, y = Ergebnis, group = Spanne, fill = Partei )
  ) + 
    geom_bar( position = position_dodge2(), stat="identity" ) +
    geom_hline( yintercept = 0.05, color = 'blue', linewidth = 1, linetype = 'dotted' ) +
    # geom_text(
    #   aes( y = Ergebnis, label = paste( Ergebnis * 100,'%' ) ),
    #   hjust = 0 ,
    #   vjust = 0.5 ,
    #   angle = 90,
    #   colour = 'blue',
    #   #fill = 'white',
    #   #label.size = 0.1,
    #   size = 3,
    #   show.legend = FALSE
    # 
    # ) +
    geom_text(
      aes( x = 0, y = 0.051, label = '5% Hürde' ),
      hjust = 0 ,
      vjust = 0 ,
      angle = 0 ,
      colour = 'blue',
      #fill = 'white',
      #label.size = 0.1,
      size = 3,
      show.legend = FALSE
  
    ) +
  
    expand_limits( y = 0.4 ) +
    scale_y_continuous( labels = scales::percent ) +
    scale_fill_manual( breaks = Parteien$Partei, values = Parteien$Fill) +
    labs(  title = paste( "Sonntagsfrage zum Bundestag" )
           , subtitle = 'Letzte Umfragen - Minumum und Maximum pro Partei'
           , colour  = "Partei"
           , x = 'Partei'
           , y = 'Ergebnis'
           , caption = citation ) +
    theme_ipsum() +
    theme(
      axis.text.x = element_text( angle = 90, vjust = 0.5, hjust = 1 )
    )       -> BarChart
  
  ggsave(   filename = paste( outdir
                              , 'LetzteUmfrage-Spannen'
                              , '.png'
                              , sep='')
            , plot = BarChart
            , device = "png"
            , bg = "white"
            , width = 1920
            , height = 1080
            , units = "px"
            , dpi = 144
  )

  zusammenfassung <-  RunSQL('select * from Zusammenfassung;')
  write.table(zusammenfassung, file = "/tmp/zusammenfassung.csv", quote = FALSE, sep = "\t", row.names = FALSE)
  
