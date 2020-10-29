# ===============================================
# Leverage data
# ===============================================

source("JupyterUtils.R")
library(PerformanceAnalytics)
library(data.table)

getLeveragedataStats = function(){
  
  # Db connection
  con <- openC2Db()
  on.exit(dbDisconnect(con))
  
  levMaxSql = "select count(distinct(systemid)) as Count from leverage_max_daily"   
  suppressWarnings( levMax_SystemsCount <- dbGetQuery(con, levMaxSql) )
  cat(sprintf("A number of systems in the 'leverage_max_daily' table: %d\n", levMax_SystemsCount$Count))
  
  levWeightedSql = "select count(distinct(systemid)) as Count from leverage_weighted_max_daily"
  suppressWarnings( levWeighted_SystemsCount <- dbGetQuery(con, levWeightedSql) )
  cat(sprintf("A number of systems in the 'leverage_weighted_max_daily' table: %d\n", levWeighted_SystemsCount$Count))
  
  levMaxSqlSystems = "select distinct(systemid) as SystemId from leverage_max_daily"   
  suppressWarnings( levMaxSystems <- dbGetQuery(con, levMaxSqlSystems) )
  #print(head(levMaxSystems))
  
  levWeightedSqlSystems = "select distinct(systemid) as SystemId from leverage_weighted_max_daily"   
  suppressWarnings( levWeightedSystems <- dbGetQuery(con, levWeightedSqlSystems) )
  #print(head(levWeightedSystems))
  
  inter = intersect(levMaxSystems$SystemId, levWeightedSystems$SystemId)
  #  print(length(inter))
  cat( sprintf("A number of systems in the intersection: %d\n", length(inter) ))

  diff = setdiff(levMaxSystems$SystemId, levWeightedSystems$SystemId)
  cat( sprintf("Systems in 'leverage_max_daily' not found in 'leverage_weighted_max_daily': %d\n", length(diff) ))

  diff = setdiff(levWeightedSystems$SystemId,levMaxSystems$SystemId)
  cat( sprintf("Systems in 'leverage_weighted_max_daily' not found in 'leverage_max_daily': %d\n", length(diff) ))
  
  #print(diff)
}

# getLeveragedataStats()

getLeveragedata = function(){
  
  # Db connection
  con <- openC2Db()
  on.exit(dbDisconnect(con))
  
  # Joined data overview last 3 days
  overviewByDateSql = "select  
  m.YYYYMMDD, 
  m.systemid, 
  m.equityAtStartOfPeriod as Equity,
  m.sumValueOfPositionsAtTime as Position,
  m.leverage as Leverage,
  w.equityAtStartOfPeriod as WEquity,
  w.sumValueOfPositionsAtTime as WPosition,
  w.leverage as WLeverage
  from leverage_max_daily m
  join leverage_weighted_max_daily w on  m.systemid = w.systemid and m.YYYYMMDD = w.YYYYMMDD
  where m.YYYYMMDD >= 20201026
  order by 1,2
  limit 10000;"
  
#   suppressWarnings( overviewByDate <- dbGetQuery(con, overviewByDateSql) )
  overviewByDate = getC2DbData(overviewByDateSql)
  print(overviewByDate)
  
  overviewBySystemSql = "select  
  m.systemid, 
  m.YYYYMMDD, 
  m.equityAtStartOfPeriod as Equity,
  m.sumValueOfPositionsAtTime as Position,
  m.leverage as Leverage,
  w.equityAtStartOfPeriod as WEquity,
  w.sumValueOfPositionsAtTime as WPosition,
  w.leverage as WLeverage
  from leverage_max_daily m
  join leverage_weighted_max_daily w on  m.systemid = w.systemid and m.YYYYMMDD = w.YYYYMMDD
  where m.YYYYMMDD >= 20201026
  order by 2,1
  limit 10000;"
  
#  suppressWarnings( overviewBySystem <- dbGetQuery(con, overviewBySystemSql) )
  overviewBySystem = getC2DbData(overviewBySystemSql)
  
  print(overviewBySystem)
  
}

# getLeveragedata()


showSystems = function(systemsIds){
  # Db connection
  con <- openC2Db()
  on.exit(dbDisconnect(con))
  
  
  inClause = paste(systemsIds, collapse = ",")
  
  sql = paste0("",valuesClause,";")
  
  if(!skipdb){
    rs <- dbSendQuery(con, sql)
    dbClearResult(rs)
  }
  
  systemsIds
  
  levMaxSql = "select count(distinct(systemid)) as Count from leverage_max_daily"   
  suppressWarnings( levMax_SystemsCount <- dbGetQuery(con, levMaxSql) )
  print(sprintf("A number of systems in leverage_max_daily: %d", levMax_SystemsCount$Count))
  
}
