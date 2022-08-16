#!/usr/bin/env Rscript

options(OutDec=',')
MyScriptName <- "Wahlumfragen"

require(data.table)
library(tidyverse)
# library(REST)
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

#library(extrafont)
#extrafont::loadfonts()

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

args = commandArgs(trailingOnly=TRUE)

if (length(args) == 0) {
  FromDay <- NA
  
} else if (length(args) == 1) {
  FromDay <- as.Date(args[1])
}

Institute <- data.frame(
  Name = c(
      'Allensbach'
    , 'Infratest dimap'
    , 'Kantar (Emnid)'
    , 'Forsa'
    , 'Forschungsgruppe Wahlen'
    , 'GMS (Gesellschaft für Markt- und Sozialforschung)'
    , 'INSA'
    , 'YouGov'
    )
  , url = c(
      'https://www.wahlrecht.de/umfragen/allensbach.htm'
    , 'https://www.wahlrecht.de/umfragen/dimap.htm'
    , 'https://www.wahlrecht.de/umfragen/emnid.htm'
    , 'https://www.wahlrecht.de/umfragen/forsa.htm'
    , 'https://www.wahlrecht.de/umfragen/politbarometer.htm'
    , 'https://www.wahlrecht.de/umfragen/gms.htm'
    , 'https://www.wahlrecht.de/umfragen/insa.htm'
    , 'https://www.wahlrecht.de/umfragen/yougov.htm'
    )
)

ParteiFarbe <- data.frame(
  Name = c('AfD', 'CDU_CSU', 'LINKE', 'FDP', 'FW','GRÜNE', 'PDS', 'PIRATEN', 'REP', 'SPD', 'SSW', 'Sonstige')
  , Color = c('brown', 'black', 'purple', 'yellow', 'cyan', 'green', 'purple', 'grey', 'brown', 'red', 'blue', 'orange')
)

for (INo in 1:nrow(Institute)) {

  print (Institute$Name[INo])
  
  png( paste( 
      "png/"
    , MyScriptName
    , '_'
    , Institute$Name[INo]
    , '.png'
    , sep = ""
    )
    , width = 1980
    , height = 1080
  )
  par( mar = c(10,5,5,5))
 
  HTML <- getURL(Institute$url[INo],.opts = list(ssl.verifypeer = FALSE), .encoding = 'UTF-8' )

  tables <- readHTMLTable(HTML)

  umfragen <- tables[[2]]
  umfragen[,2] <- NULL
  namen <- colnames(umfragen)
  namen[1] <- 'Datum'
  namen[2] <- 'CDU_CSU'
  colnames(umfragen) <- namen
  NoParteien <- match('Sonstige',namen)

  umfragen[,NoParteien+1] <- NULL
  umfragen[,1] <- as.Date(umfragen[,1],"%d.%m.%Y")
  
  namen <- colnames(umfragen)
  
  for (i in 2:(NoParteien-1)) {
    umfragen[,i] <- as.numeric(str_replace(str_replace(str_replace_all(umfragen[,i]," %", ""),",","."),'(–-?)',"0"))
  }

  umfragen[,NoParteien] <- 100 - rowSums(umfragen[,2:(NoParteien-1)])
  umfragen$Befragte[umfragen$Befragte=='Bundestagswahl'] <- 60000000

  umfragen$Befragte <- as.numeric(str_remove(str_remove(umfragen$Befragte, '.* '), '\\.'))
  
  col <- ParteiFarbe$Color[match(namen[2:NoParteien],ParteiFarbe$Name)]
  print(col)
  
  if (! is.na(FromDay) ) {
    umfragen <- umfragen[umfragen$Datum >= FromDay,]
  }
  
  plot( 
      umfragen[,1]
    , rep(NA,nrow(umfragen))
    , type='l'
    , lwd = 5
    , col = col[1]
    , main = Institute$Name[INo]
    , sub = ''
    , xlab = 'Datum'
    , ylab = 'Anteil [%]'
    , cex.main = 4
    , cex.sub = 1
    , ylim = c(0,60)
  )

  title ( 
      sub = 'Wenn am kommenden Sonntag Bundestagswahl wäre ...'
    , line = 5
    , cex.sub = 3
  )

  legend( 
      'topright'
    , title = ' Parteien'
    , legend = str_replace_all(colnames(umfragen[,2:NoParteien]),'_','/')
    , lty = 1
    , lwd = 2
    , col = col
    , cex = 2
    , inset = 0.05

  )
  legend( 
    'topleft'
    , title = 'Bundestagswahlen'
    , legend = 'Wahlergebnis'
    , pch = 19
    , lty = 1
    , lwd = 2
    , col = 'black'
    , cex = 2
    , inset = 0.05
  )
  

  for ( i in 2:NoParteien ) {
      lines(
        umfragen[,1]
      , umfragen[,i]
      , type='l'
      , lwd = 5
      , col = col[i-1]
    )

    points(
        umfragen[umfragen$Befragte==60000000,1]
      , umfragen[umfragen$Befragte==60000000,i]
      , type = 'p'
      , pch = 19
      , col = col[i-1]
      , lwd = 20
    )
  
    f <- as.formula(paste( namen[i], "~", "Datum"))
  
    ra <- lm( f, data = umfragen)
    print(namen[i])
    print(ra$coefficients[1]+as.numeric(today)*ra$coefficients[2])
    
    abline( 
        coef = ra$coefficients
      , col = col[i-1]
      , lty = 2
      , lwd = 5
    )
  
  }

  grid()

  dev.off()

}
