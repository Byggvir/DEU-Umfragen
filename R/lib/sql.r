library(bit64)
library(RMariaDB)
library(data.table)

RunSQL <- function (
  SQL = 'select * from Faelle;'
  , prepare="set @i := 1;") {
  
  rmariadb.settingsfile <- path.expand('~/R/sql.conf.d/Umfragen.conf')
  
  rmariadb.db <- "Umfragen"
  
  DB <- dbConnect(
    RMariaDB::MariaDB()
    , default.file=rmariadb.settingsfile
    , group=rmariadb.db
    , bigint="numeric"
  )
  dbExecute(DB, prepare)
  rsQuery <- dbSendQuery(DB, SQL)
  dbRows<-dbFetch(rsQuery)

  # Clear the result.
  
  dbClearResult(rsQuery)
  
  dbDisconnect(DB)
  
  return(as.data.table(dbRows))
}

ExecSQL <- function (
  SQL 
) {
  
  rmariadb.settingsfile <- path.expand('~/R/sql.conf.d/Umfragen.conf')
  
  rmariadb.db <- "Umfragen"
  
  DB <- dbConnect(
    RMariaDB::MariaDB()
    , default.file=rmariadb.settingsfile
    , group=rmariadb.db
    , bigint="numeric"
  )
  
  count <- dbExecute(DB, SQL)

  dbDisconnect(DB)
  
  return (count)
  
}
