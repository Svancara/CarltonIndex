# ==============================================
# This is a file Carlton index algo explanation - utilities
# ==============================================

options(warn=-1)


MINIMUM_NEEDED_DAYS = 210
REURNS_MONTHLY_DAYS = 30
MIN_AGE = MINIMUM_NEEDED_DAYS + REURNS_MONTHLY_DAYS

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
  dbConnect(MySQL(),user = "root",password = Sys.getenv("MySqlLocalPassword"),dbname = "explore",host = "10.0.0.100")
}


openC2Db = function() {
  dbConnect(MySQL(),user = "bob",password = Sys.getenv("MySqlC2PasswordBob"), dbname = "collective2",host = "homonea.collective2.com")
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

# ==========================================================================
#  Sime numbers from Collective2 database
# ==========================================================================
c2DatabaseStats = function(minAgeDays = MINIMUM_NEEDED_DAYS + REURNS_MONTHLY_DAYS){
  # minAgeDays = as.integer(minAgeDays)

    result = list()

  # ----------------------------------
  # COLLECTIVE2 (source) database
  # ----------------------------------
  conC2 = openC2Db()
  on.exit(dbDisconnect(conC2)) 
  
  # --------------------  
  sql <- "select count(distinct(systemid)) as systems_providerCreditsPackages from providerCreditsPackages"
  suppressWarnings( data <- dbGetQuery(conC2, sql) )
  result$systems_providerCreditsPackages = as.integer(data)

  sql = "select count(*) from (
        SELECT 
        pcp.systemid
        FROM providerCreditsPackages pcp 
            join trades on trades.systemid = pcp.systemid
            WHERE pcp.package <> 'basic_trial' AND (pcp.disposition IS NULL OR pcp.disposition <> 'archivedTrial')
        GROUP BY pcp.systemid
        HAVING COUNT(trades.guid) > 4
        ) sub;"
  suppressWarnings( data <- dbGetQuery(conC2, sql) )
  result$systems_pcp_ge_4_trades = as.integer(data)

  # --------------------  
  sql <- "select count(distinct(systemid)) as systems_killed from systems_killed;"
  suppressWarnings( data <- dbGetQuery(conC2, sql) )
  result$systems_killed = as.integer(data)
  
  # --------------------  
  sql <- "select count(distinct(systemid)) as systems_killed_soft from systems_killed_soft"
  suppressWarnings( data <- dbGetQuery(conC2, sql) )
  result$systems_killed_soft = as.integer(data)

  
  # ----------------------------------
  # LOCAL database
  # ----------------------------------
  conLocal = openDb()
  on.exit(dbDisconnect(conLocal)) 

  # ----------------------------------
  # Average life span of the system
  sql = "SELECT avg(diff) from (
	  SELECT max(`datetime`), min(`datetime`), DATEDIFF(max(`datetime`),min(`datetime`)) as diff
	    FROM explore.c2ex_equity_daily
	    group by systemid
    ) sub;"
  suppressWarnings( data <- dbGetQuery(conLocal, sql) )
  result$avg_life_span = data
  
  # ----------------------------------
  # Systems live at least MIN_AGE days
  sql = sprintf("select count(*) from (
    SELECT systemid
    	FROM explore.c2ex_equity_daily
    	group by systemid
    -- having diff < 210 -- 4599
    having DATEDIFF(max(`datetime`),min(`datetime`)) >= %d + 1
    ) sub;",minAgeDays)
  suppressWarnings( data <- dbGetQuery(conLocal, sql) )
  result$live_ge_240_days = as.integer(data)
  
  # ----------------------------------
  # Systems live at least MIN_AGE days - AGE stats
  sql = sprintf("select age from (
    SELECT DATEDIFF(max(`datetime`),min(`datetime`)) as age
    	FROM explore.c2ex_equity_daily
    	group by systemid
    having DATEDIFF(max(`datetime`),min(`datetime`)) >= %d + 1
    ) sub;",minAgeDays)
  suppressWarnings( data <- dbGetQuery(conLocal, sql) )
  result$live_ge_240_days_ages = data$age
  
  return (result)  
}


#stats = c2DatabaseStats()
#summary(stats$live_ge_210_days_ages) 

carltonResults = function(){
  conLocal = openDb()
  on.exit(dbDisconnect(conLocal)) 
  
  
}


# ------------- Sourcing message ----------------
print("Initialization done")
