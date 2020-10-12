# ==============================================
# This is a file Carlton index algo explanation - utilities
# ==============================================

options(warn=-1)

print("Initialization done")
suppressMessages({
  library(DBI)
  library(RMySQL)
  library(foreach)
  library(doParallel)
  library(xts)
  library(PerformanceAnalytics)
  library(data.table)
})


EST_TIME_ZONE = "America/New_York" # supports DST time	
DEFAULT_DT_FORMAT = "%Y-%m-%d %H:%M:%S"

# =======================================
# Open a database. Returns a connection.
# =======================================
openDb = function() {
  dbConnect(MySQL(),user = "root",password = "heslolv88",dbname = "explore",host = "10.0.0.100")
}


readData = function(strategyId){
con <- openDb()
sql = sprintf("select dateTime, totalpl as value from c2ex_equity_daily where systemid = %s order by 1",strategyId)
dbData <- dbGetQuery(con, sql)
dbDisconnect(con)

return (dbData)
}

# =======================================
# Open a database. Returns a connection.
# =======================================
transformDataToTimeSeries = function(dbData){
  colnames(dbData) = c("DateTime","Close")
  posixlt = as.POSIXlt(dbData$DateTime, format = DEFAULT_DT_FORMAT,tz= EST_TIME_ZONE)
  result = xts(dbData$Close, posixlt )
  colnames(result) = c("Close")
  return (result)
}

# Bind data by Dates together
bindDataTogether = function(accountDaily,annReturn210,sd_time_win_annual) {
  accountDaily = data.table("date" = index(accountDaily), coredata(accountDaily))
  setkey(accountDaily,date)
  
  annReturn210Table = data.table("date" = index(annReturn210), coredata(annReturn210))
  setkey(annReturn210Table,date)
  
  sdTable = data.table("date" = index(sd_time_win_annual), coredata(sd_time_win_annual))
  setkey(sdTable,date)
  
  data = merge(accountDaily,annReturn210Table)
  data = merge(data,sdTable)
  setkey(data,date)
  
  return (data)
}
