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

citation <- paste( '© Thomas Arend, 2025\nQuelle: api.dawum.de\nStand', heute)

Parteien = RunSQL( SQL = 'select * from Partei;')

for ( w in c("2021-09-26", "2025-02-23") ) {

  Wahltag = as.Date(w)
  Jahr = year(Wahltag)

  SQL =  paste0 (
    'select count(*) as N from Surveys as S'
    , ' where'
    , ' S.Parliament_Id = 0'
    , ' and datediff("', Wahltag,'",S.`Date`) < 57'
    , ' and S.`Date` < "',Wahltag,'"'
    , ';'
  )
  
  Ab = Wahltag - 57
  
  AnzUmfragen = RunSQL(SQL = SQL)
  
  SQL =  paste (
    'select Party_ID, P.Shortcut, round(Result,2) as Result from Results as R'
    , 'join Surveys as S on S.Id = R.Survey_ID'
    , 'join Partei as P on P.Id = R.Party_ID'
    , 'where'
    , 'S.Parliament_Id = 0'
    , ' and datediff("', Wahltag,'",S.`Date`) < 57'
    , ' and S.`Date` < "',Wahltag,'"'
    , ';'
  )
  
  Results = RunSQL(SQL = SQL)
  
  Results %>% filter( Party_ID != 8 & Party_ID != 0 ) %>% ggplot(
      aes ( x = Result, fill = Shortcut, group = Shortcut)
      ) +
    geom_density( color = 'black', alpha = 0.7 ) +
    scale_x_percent( breaks = seq(0.01,0.5,0.01)) +
    scale_fill_manual( breaks = Parteien$Shortcut, values = Parteien$Fill) +
    #facet_wrap(vars(reorder(Shortcut, Party_ID)), scales = 'free_x', nrow = 2) +
    labs(  title = paste( "Verteilung der Umfragewerte vor der Bundestagswahl", Jahr )
             , subtitle = paste('Aus', AnzUmfragen[1,"N"], 'Umfragen nach dem', Ab )
             , colour  = "Partei"
             , x = 'Umfrageergebnis'
             , y = 'Dichte'
             , caption = citation ) +
    theme_ipsum() +
    theme( axis.text.x = element_text( angle = 90, vjust = 0.5 )) -> P1
  
    ggsave(   filename = paste( outdir
                               , 'Verteilung_Umfragewerte_'
                               , Jahr
                               , '.png'
                               , sep='')
              , plot = P1
              , device = "png"
              , bg = "white"
              , width = 1920
              , height = 1080
              , units = "px"
              , dpi = 144
    )
}
