use Umfragen;

/*
  Database
  Parliaments
  Institutes
  Taskers
  Methods
  Parties
  Surveys
  
*/

/* Create and load data set of database */

drop table if exists `db`;
create table if not exists `db`
  ( `Id` INT(11) 
  , `License.Name` CHAR(255)
  , `License.Shortcut` CHAR(255)
  , `License.Link` CHAR(255)
  , `Publisher` CHAR(255)
  , `Author` CHAR(255)
  , `Last_Update` DATETIME
  , primary key (`Id`)
  ) 
;

LOAD DATA LOCAL 
INFILE '/data/git/R/DEU-Umfragen/data/dawum/Database.csv'      
INTO TABLE `db`
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
IGNORE 1 ROWS;

/* Create and load data set of Parliaments */

drop table if exists `Parliaments`;
create table if not exists `Parliaments`
  ( `Id` BIGINT(11) 
  , `Shortcut` CHAR(255)
  , `Name` CHAR(255)
  , `Election` CHAR(255)
  , index ( `Shortcut` )
  , index ( `Name` )
  ) 
;

LOAD DATA LOCAL 
INFILE '/data/git/R/DEU-Umfragen/data/dawum/Parliaments.csv'      
INTO TABLE `Parliaments`
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
IGNORE 1 ROWS;

/* Create and load  data set of Institutes */

drop table if exists `Institutes`;
create table if not exists `Institutes`
  ( `Id` BIGINT(11) 
  , `Name` CHAR(255)
  , primary key ( `Id` )
  , index ( `Name` )
  ) 
;

LOAD DATA LOCAL 
INFILE '/data/git/R/DEU-Umfragen/data/dawum/Institutes.csv'      
INTO TABLE `Institutes`
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
IGNORE 1 ROWS;

/* Create and load  data set of Taskers */

drop table if exists `Taskers`;
create table if not exists `Taskers`
  ( `Id` BIGINT(11) 
  , `Name` CHAR(255)
  , primary key ( `Id` )
  , index ( `Name` )
  ) 
;

LOAD DATA LOCAL 
INFILE '/data/git/R/DEU-Umfragen/data/dawum/Taskers.csv'      
INTO TABLE `Taskers`
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
IGNORE 1 ROWS;

/* Create and load data set of Taskers */

drop table if exists `Methods`;
create table if not exists `Methods`
  ( `Id` BIGINT(11) 
  , `Name` CHAR(255)
  , primary key ( `Id` )
  , index ( `Name` )
  ) 
;

LOAD DATA LOCAL 
INFILE '/data/git/R/DEU-Umfragen/data/dawum/Methods.csv'      
INTO TABLE `Methods`
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
IGNORE 1 ROWS;

/* Create and load data set of Parties */

drop table if exists `Parties`;
create table if not exists `Parties`
  ( `Id` BIGINT(11) 
  , `Name` CHAR(255)
  , primary key ( `Id` )
  , index ( `Name` )
  ) 
;

LOAD DATA LOCAL 
INFILE '/data/git/R/DEU-Umfragen/data/dawum/Parties.csv'      
INTO TABLE `Parties`
FIELDS TERMINATED BY ';' ENCLOSED BY '"'
IGNORE 1 ROWS;

/* Create and load data set of Surveys */

drop table if exists `Surveys`;
create table if not exists `Surveys`
  ( 
      `Id` BIGINT(11) 
    , `Date` DATE
    , `Survey_Start` DATE
    , `Survey_End` DATE
    , `Surveyed_Persons` INT(11)
    , `Parliament_ID` INT(11)
    , `Institute_ID` INT(11)
    , `Tasker_ID` INT(11)
    , `Method_ID` INT(11)
    , `NoParties` INT(11)
    , primary key ( `Id` )
    , index ( `Survey_Start` )
    , index ( `Survey_End` )
    , index ( `Parliament_ID` )
    , index ( `Institute_ID` )
    , index ( `Tasker_ID` )
    
  ) 
;

LOAD DATA LOCAL 
INFILE '/data/git/R/DEU-Umfragen/data/dawum/Surveys.csv'      
INTO TABLE `Surveys`
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
IGNORE 1 ROWS;

/* Create and load data set of Results */

drop table if exists `Results`;
create table if not exists `Results`
  ( `Survey_ID` INT(11) 
  , `Party_ID` INT(11)
  , `Result` DOUBLE
  , primary key ( `Survey_ID`, `Party_ID` )
  ) 
;

LOAD DATA LOCAL 
INFILE '/data/git/R/DEU-Umfragen/data/dawum/Results.csv'      
INTO TABLE `Results`
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
IGNORE 1 ROWS;
