# DEU-UMfragen
Collection of R scrpts for elections and election surveys in Germany

# Bundestagswahl.r

Collects the results from an election from the Web-Page of the [Bundeswahlleiter](https://www.bundeswahlleiter.de)

Currently the script collects the data for 2013, 2017 and 2021.

It draws the following diagrams

- seats for each party
- tbc

# Wahlumfragen.r

Collects the results from the latest election surveys of the institutes

- Allensbach
- Infratest dimap
- Kantar (Emnid)
- Forsa
- Forschungsgruppe Wahlen
- GMS (Gesellschaft für Markt- und Sozialforschung)
- INSA
- Ipsos
- YouGov

from the Web-Page of the [wahlrecht.de](https://www.wahlrecht.de/umfragen) and draws a diagram for each institute.

# Install

    * Download or clone repository from github.com to local disk
    * Change user and password in file ***SQL/setup.sql***
    * Create database **Umfragen** with scipt ***mysql -u root -p < SQL/setup.sql***
    * Restore database tables with ***mysql -u root -p Umfragen < data/dump.sql***
    * Make dirctory ***$HOME/R/sql.conf.d/***
    * Copy ***SQL/Umfragen.conf*** to ***$HOME/R/sql.conf.d/***
    * Change user and password ***$HOME/R/sql.conf.d/Umfragen.conf*** (as above)

# Update database

    * Go to ***R/*** 
    * Run ***rscript "Get Wahlumfragen.r"***
    * Copy ***data/Umfragen.csv*** to ***/tmp/***
    * Run ***mysql -u root -p < SQL/Umfragen.sql***

Still under construction