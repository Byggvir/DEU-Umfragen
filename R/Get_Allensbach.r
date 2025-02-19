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
library(XML)
library(RCurl)
library(rlist)
library(stringr)
library(argparser)
library(rjson)

library(rvest)


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

url <-  "https://www.ifd-allensbach.de/studien-und-berichte/sonntagsfrage/gesamt.html"

df <- url %>% 
  read_html() %>% 
  html_elements("table") %>% 
  html_table(fill = TRUE) %>% 
  lapply(., function(x) setNames(x, c("Zeitraum"
                                      , "CDU/CSU"
                                      , "SPD"
                                      , "FDP"
                                      , "Grüne"
                                      , "Linke"
                                      , "AfD"
                                      , "BSW"
                                      , "Sonstige")))

dt = as.data.table(df[[1]])
# dt[,2:9] = as.numeric(dt[,2:9])
