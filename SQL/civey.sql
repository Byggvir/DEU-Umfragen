use Umfragen;


-- Create Table with parties for civey

DROP TABLE IF EXISTS `civeyParties`;

CREATE TABLE `civeyParties` (
  `Id` int (11) DEFAULT NULL
  , CId int(11) DEFAULT 0
  , `text` char(255) DEFAULT NULL
  , `label` char(255) DEFAULT NULL
  , PRIMARY KEY (`Id`)
  , INDEX ( `text`)
  , INDEX ( `label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

LOAD DATA LOCAL 
  INFILE '/data/git/R/DEU-Umfragen/data/civey_Parteien.csv'      
INTO TABLE `civeyParties`
  FIELDS TERMINATED BY ';'
  IGNORE 1 ROWS;

DROP TABLE IF EXISTS `civeySurveys`;

CREATE TABLE `civeySurveys` (
  `Id` BIGINT (10) AUTO_INCREMENT
  , `date` DATETIME DEFAULT NULL
  , `timeFrameFrom` DATETIME DEFAULT NULL
  , `timeFrameTo` DATETIME DEFAULT NULL
  , `firstVoteAt` DATETIME DEFAULT NULL
  , `lastVoteAt` DATETIME DEFAULT NULL
  , `sampleSize` BIGINT(6) DEFAULT NULL
  , `errorMargin` DOUBLE(6,3) DEFAULT 1

  , PRIMARY KEY (`Id`)
  , INDEX ( `date`)
  , INDEX ( `timeFrameFrom`)
  , INDEX ( `timeFrameTo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;


DROP TABLE IF EXISTS `civeyResults`;

CREATE TABLE `civeyResults` (
  `Survey_ID` BIGINT(10) DEFAULT 0
  , `Party_ID` BIGINT(10) DEFAULT 0
  , `Result` DOUBLE(6,3) DEFAULT 0
  , PRIMARY KEY (`Survey_ID`, `Party_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

