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

Parteien <- RunSQL( 'select distinct P.*, P2.Shortcut, P2.Fill, P2.Color from Parties as P join Partei as P2 on P.Id = P2.Id join Results as R on P.Id = R.Party_Id join BTSurvey as S on S.Id = R.Survey_Id;')

SQL =  paste (
      'select'
      , '*'
      , 'from TrendAnalyse as T'
      , 'join Parties as P'
      , 'on T.PId = P.Id;'
)


Trend = RunSQL( SQL = SQL)
#Trend[, Anteil := hn_round(Result,200)/2]
#Trend[, RohAnteil := hn_round(RawResult,200)/2]
Trend[, Anteil := hn_round(Result,1000)/10]
Trend[, RohAnteil := hn_round(RawResult,1000)/10]
#Trend[, Anteil := round(100*Result,2)]
#Trend[, RohAnteil := round(100*RawResult,2)]

setorder(Trend, -Result)


Trend %>% ggplot(
    aes ( x = reorder(Name, -Result), y = Anteil  ) 
    ) +
    geom_bar( aes(fill = Name ),  stat = "identity" ) +
    geom_label( aes( y = 1, label = Anteil ), stat = "identity", vjust = 0 , size = 5)+
    geom_hline( yintercept = 5, color = 'blue', linetype = 'dotted' ) +
    expand_limits( y = 0 ) +
    scale_color_manual( breaks = Parteien$Name, values = Parteien$Color ) +
    scale_fill_manual( breaks = Parteien$Name, values = Parteien$Fill ) +
    labs(  title = paste( "Umfragetrend zur Bundestagswahl 2025" )
           , subtitle = "Nach Alter und Befragte gewichteter Trend der Wahlumfragen"
           , colour  = "Partei"
           , x = 'Partei'
           , y = 'Vorhersage [%]'
           , caption = citation ) +
    theme_ipsum() +
    theme( axis.text.x = element_text( angle = 90 )) -> P1

  ggsave(   filename = paste( outdir
                              , 'Trend'
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

write.table(  Trend[, .(Name, Anteil)]
          , file = "/tmp/Trend.csv"
          , row.names = FALSE
          , quote = FALSE
          , sep = '\t' )

print(Trend[,.(sum(Result),sum(RawResult))])

# ----

SQL = 'select I.`Id` as `Id`,I.Name as `Name`, sum(W.weight) as Weight, sum(Surveyed_Persons) as Persons, count(*) as Anzahl from WeightedSurveys as W join Institutes as I on W.Institute_ID = I.Id group by I.`Id`;'
Weight = RunSQL(SQL = SQL)

Report = Weight[,.( Gesamtgewicht = round(sum(Weight),1)
                    , Befragte = sum(Persons)
                    , Umfragen = sum(Anzahl))]

Weight %>% ggplot(
  aes ( x = Name, y = Weight  ) 
) +
  geom_bar( aes(fill = Name )
            ,  stat = "identity"
            , show.legend = FALSE ) +
  geom_label( aes( y = 1, label = paste(round(Weight,1),'\naus', Anzahl, sep = ' ' ) )
              , stat = "identity"
              , vjust = 0 
              , size = 3
              , show.legend = FALSE ) +
  annotate( "label"
            , x = min(Weight$Name)
            , y = max(Weight$Weight)
            , fill = NA
            , hjust = 0
            , vjust = 1
            , label = paste( 'Σ Gewichte:', Report[1,"Gesamtgewicht"]
                             , '\nΣ Befragte:', Report[1,"Befragte"]
                            , '\nUmfragen:',Report[1,"Umfragen"] ) 
            ) +
  labs(  title = paste( "Umfragetrend zur Bundestagswahl 2025" )
         , subtitle = "Gewichte der Institute im Trend mit Anzahl der Umfragen"
         , colour  = "Institute"
         , x = 'Institute'
         , y = 'Gewichtung'
         , caption = citation ) +
  theme_ipsum() +
  theme( axis.text.x = element_text( angle = 90 )) -> P1

ggsave(   filename = paste( outdir
                            , 'Trend_Institute'
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
