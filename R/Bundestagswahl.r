#!/usr/bin/env Rscript

options( OutDec = ',' )
MyScriptName <- "Umfragen"

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

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

ParteiFarbe <- data.frame(
    Name = c('AfD','CDU','CSU','DIE LINKE','FDP','GRÜNE','SPD','SSW','Sonstige')
  , Color = c('brown','black','darkgrey','purple','yellow', 'green', 'red','blue', 'orange')
)

for (wahljahr in c(2013,2017,2021)) {
  
  par( mar = c(10,5,5,5))
 
  HTML <- getURL(paste('https://www.bundeswahlleiterin.de/bundestagswahlen/',wahljahr,'/ergebnisse/bund-99.html', sep=''),.opts = list(ssl.verifypeer = FALSE), .encoding = 'UTF-8' )
  HTML <- str_replace(HTML,'</tbody><tbody>','</tbody></table><table><tbody>')
  
  tables <- readHTMLTable(HTML)

  # Auswertung der Sitzverteilung
  
  erg_sitze <- tables[[1]]
  erg_sitze <- data.frame(
    Partei = factor(erg_sitze[[1]], levels = erg_sitze[[1]])
    , Sitze = as.numeric(erg_sitze[[2]])
    , Diff = as.numeric(erg_sitze[[3]])
  )
  
  col <- ParteiFarbe$Color[match(erg_sitze$Partei,ParteiFarbe$Name)]
  print(col)
  
  pp <- ggplot(data=erg_sitze, aes(x=Partei, y=Sitze, fill=Partei)) +
    geom_bar(stat="identity") +
    scale_fill_manual(values = col) +
    geom_text(  aes(label = Sitze)
              , vjust = -0.1
              , color = "black"
              , position = position_dodge(0.9)
              , size = 6 ) +
    labs(title = paste('Bundestagswahl',wahljahr,'Sitzverteilung') 
        , x = "Partei"
        , y = "Sitze"
    ) +
    theme_minimal()
  
  ggsave(
    paste('png/BTW', wahljahr, 'Sitze.png', sep='')
    , plot = pp
    , device = 'png'
    , bg = "white"
    , width = 1920
    , height = 1080
    , units = "px"
    , dpi = 144
  )
  

  # Auswerung der Wahlbeteiligung
  
  erg_beteiligung <- tables[[2]]
  
  # Auswertung der Stimmverteilung
  
  ep <- tables[[3]]
  
  erg_parteien <- data.frame(
    Partei = factor(ep[[1]], levels = ep[[1]])
    , ErstStimmen = as.numeric(str_remove_all(str_replace_all(ep[[2]], '([-–])', '0'), '\\.'))
    , ZweitStimmen = as.numeric(str_remove_all(str_replace_all(ep[[5]], '([-–])', '0'), '\\.'))
  )
}
