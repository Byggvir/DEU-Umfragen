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

outdir <- 'png/dawum/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

citation <- paste( '© Thomas Arend, 2025\nQuelle: dawum.de, Stand', heute)

Parteien <- RunSQL( 'select * from Partei;')
Institute <- RunSQL( SQL = 'select * from Institute;' )

SQL = 'select * from LastSurveyResults where Parliament_ID = 0;'
umfragen <- RunSQL( SQL = SQL )


umfragen[, Institut := factor( Institute_ID, levels = Institute$Id, labels = Institute$Shortname) ]
umfragen[, Partei := factor( Party_ID, levels = Parteien$Id, labels = Parteien$Shortcut)]
umfragen[Institute_ID == 13, Result := hn_round(Result,100)/100]

umfragen %>% 
  filter( Result > 0 & Date > "2024-12-31") %>% 
  ggplot(
    aes ( x = '', y = Result, fill = Partei  )
    ) +
  geom_bar( stat="identity" , alpha = 1) +
  geom_label_repel(
    aes( label = paste( Result * 100,'%' ), colour = Partei ),
    position = position_stack( vjust = 0.5 ),
    #  fill = 'white' ,
    label.size = 0.1,
    size = 3,
    show.legend = FALSE ) +
  scale_colour_manual( values = Parteien$Color, breaks = Parteien$Shortcut ) +
  scale_fill_manual( breaks = Parteien$Shortcut, values = Parteien$Fill) +
  facet_wrap(vars(paste(Institut, Date, '\nBefragte:', Surveyed_Persons)), nrow = 2 ) +
  coord_polar( 'y', start = 0, direction = -1 ) +
  labs(  title = paste( "Sonntagsfrage zur Bundestagswahl - Prognosen" )
         , subtitle = 'Letzte Umfragen nach Institut'
         , colour  = "Partei"
         , x = ''
         , y = 'Ergebnis'
         , caption = citation ) +
  theme_minimal() +
  theme( axis.title.x=element_blank(),
         axis.text.x=element_blank(),
         axis.ticks.x=element_blank(),
         panel.border = element_blank(), 
         panel.grid.major = element_blank(),
         panel.grid.minor = element_blank()
  ) -> PieChart

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

  umfragen %>% filter( Result > 0 ) %>% ggplot(
    aes ( x = Institut , y = Result, fill = Partei )
  ) + 
    geom_bar( position = position_dodge2(), stat="identity" ) +
    geom_text( 
      aes( y = Result, label = paste( Result * 100,'%' ) ), 
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

  # Spanne <-  RunSQL('select * from Spanne;')
  # Spanne$Partei <- factor(Spanne$PId,levels = Parteien$Id, labels = Parteien$Partei)
  # 
  # Spanne %>% filter( Ergebnis > 0 ) %>% ggplot(
  #   aes ( x = Partei, y = Ergebnis, group = Spanne, fill = Partei )
  # ) + 
  #   geom_bar( position = position_dodge2(), stat="identity" ) +
  #   geom_hline( yintercept = 0.05, color = 'blue', linewidth = 1, linetype = 'dotted' ) +
  #   # geom_text(
  #   #   aes( y = Ergebnis, label = paste( Ergebnis * 100,'%' ) ),
  #   #   hjust = 0 ,
  #   #   vjust = 0.5 ,
  #   #   angle = 90,
  #   #   colour = 'blue',
  #   #   #fill = 'white',
  #   #   #label.size = 0.1,
  #   #   size = 3,
  #   #   show.legend = FALSE
  #   # 
  #   # ) +
  #   geom_text(
  #     aes( x = 0, y = 0.051, label = '5% Hürde' ),
  #     hjust = 0 ,
  #     vjust = 0 ,
  #     angle = 0 ,
  #     colour = 'blue',
  #     #fill = 'white',
  #     #label.size = 0.1,
  #     size = 3,
  #     show.legend = FALSE
  # 
  #   ) +
  # 
  #   expand_limits( y = 0.4 ) +
  #   scale_y_continuous( labels = scales::percent ) +
  #   scale_fill_manual( breaks = Parteien$Partei, values = Parteien$Fill) +
  #   labs(  title = paste( "Sonntagsfrage zum Bundestag" )
  #          , subtitle = 'Letzte Umfragen - Minumum und Maximum pro Partei'
  #          , colour  = "Partei"
  #          , x = 'Partei'
  #          , y = 'Ergebnis'
  #          , caption = citation ) +
  #   theme_ipsum() +
  #   theme(
  #     axis.text.x = element_text( angle = 90, vjust = 0.5, hjust = 1 )
  #   )       -> BarChart
  # 
  # ggsave(   filename = paste( outdir
  #                             , 'LetzteUmfrage-Spannen'
  #                             , '.png'
  #                             , sep='')
  #           , plot = BarChart
  #           , device = "png"
  #           , bg = "white"
  #           , width = 1920
  #           , height = 1080
  #           , units = "px"
  #           , dpi = 144
  # )
  # 
  # 
