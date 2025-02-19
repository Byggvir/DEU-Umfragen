use Umfragen;

DROP TABLE IF EXISTS `civeyPartei`;

CREATE TABLE `civeyPartei` (
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
INTO TABLE `civeyPartei`
  FIELDS TERMINATED BY ';'
  IGNORE 1 ROWS;

DROP TABLE IF EXISTS `civeyUmfrage`;

CREATE TABLE `civeyUmfrage` (
  `Id` int (11) AUTO_INCREMENT
  , `date` DATETIME DEFAULT NULL
  , `timeFrameFrom` DATETIME DEFAULT NULL
  , `timeFrameTo` DATETIME DEFAULT NULL
  , `firstVoteAt` DATETIME DEFAULT NULL
  , `lastVoteAt` DATETIME DEFAULT NULL
  , `sampleSize` INT(6) DEFAULT NULL
  , `errorMargin` DOUBLE(6,3) DEFAULT 1

  , PRIMARY KEY (`Id`)
  , INDEX ( `timeFrameFrom`)
  , INDEX ( `timeFrameTo`)
  , INDEX ( `date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

