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

citation <- paste( '© Thomas Arend, 2022\nQuelle: © wahlrecht.de/umfragen & wahlkreisprognose.de\nStand', heute)

Institute <- RunSQL( 'select * from Institute;')
Parteien <- RunSQL( 'select distinct P.* from Partei as P join Ergebnisse as E on P.Id = E.Partei_ID ;')

SQL = paste0( 'select * from KreuzVergleich where Datum <> "2013-09-22" and Datum <> "2017-09-24" and Datum <> "2021-09-26";' ) 
KreuzTab <- RunSQL( SQL = SQL )

KreuzTab[,Name1 := factor( IId1, levels = Institute$Id, labels = Institute$Shortname) ] 
KreuzTab[,Name2 := factor( IId2, levels = Institute$Id, labels = Institute$Shortname) ] 

# KreuzTab %>% ggplot() +
#   geom_boxplot( aes( y = Ergebnis_x / Ergebnis_y , fill = Name2 ) ) +
#   facet_wrap(vars(Partei_ID)) +
#   #  scale_x_continuous( labels = scales::percent ) +
#   scale_y_continuous( ) +
#   theme_ipsum() +
#   theme(
#     axis.text.x = element_text( angle = 90)
#   ) +
#   labs(  title = paste( 'Kreuzvergleich Umfrageergebnisse' )
#          , subtitle = paste( 'vs 9 andere Institute' )
#          , colour  = 'Institut'
#          , x = 'Institut'
#          , y = Institute$Shortname[I]
#          , caption = citation )  -> PI
# 
# ggsave(   filename = paste( outdir
#                             , 'Boxplott.png'
#                             , sep='')
#           , plot = PI
#           , device = "png"
#           , bg = "white"
#           , width = 1920 * 2
#           , height = 1080 *2
#           , units = "px"
#           , dpi = 144
# )
# 

for ( I in 1:nrow(Institute)) {
  for ( P in 1:nrow(Parteien)) {
    
    cat (Parteien$Name[P],'\n\n')
    KT = KreuzTab %>% filter( IId1 == Institute$Id[I] & Partei_ID == Parteien$Id[P] )
    if (nrow(KT) > 0) {
      
      KT %>% ggplot( ) + 
        geom_smooth ( aes( x = Ergebnis_y, y = Ergebnis_x, colour = Name2 )
                      , method = 'glm', formula = 'y ~ x'
                      , show.legend = FALSE ) +
        geom_abline( intercept = 0 , slope = 1, color = 'black') +
        geom_point ( aes( x = Ergebnis_y, y = Ergebnis_x, colour = Name2 ), alpha = 0.3) +
        coord_fixed() +
        facet_wrap(~Name2) +
        scale_x_continuous( labels = scales::percent ) +
        scale_y_continuous( labels = scales::percent ) +
        labs(  title = paste( 'Kreuzvergleich Umfrageergebnisse', Institute$Shortname[I], 'für', Parteien$Shortcut[P] )
               , subtitle = paste( 'vs 9 andere Institute' )
               , colour  = 'Institut'
               , x = 'Institut'
               , y = Institute$Shortname[I]
               , caption = citation ) +
      theme_ipsum() +
        theme(
          axis.text.x = element_text( angle = 90)
        )  -> PI
        
      ggsave(   filename = paste( outdir
                                  , 'Kreuzvergleich_',I,'_',P,'_', Institute$Shortname[I], '_', str_replace(Parteien$Shortcut[P],'/','_'),'.png'
                                  , sep='')
                , plot = PI
                , device = "png"
                , bg = "white"
                , width = 1920
                , height = 1080
                , units = "px"
                , dpi = 144
      )
  
      for (J in Institute$Id) { 
        
        cat ('\n', Institute$Shortname[J], '\n' )
        
        if (J != I) {
          ra = glm ( data = KreuzTab %>% filter( IId2 == J), formula = Ergebnis_y ~ Ergebnis_x )
          ci = confint(ra)
          cat( Institute$Shortname[J],ci[2,], '\n' )
        } 
      }      
    }
    
  }
  
}

