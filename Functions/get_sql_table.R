### The `get_sql_table` function loads a single table and takes 3 arguments:
# 1. `vars.to.get` - a vector of variable names
# 2. `game.id` - identifier of a specific game
# 3. `db.con` - object of connection to SQL database

get_sql_table <- function(game.id, vars.to.get, db.con){
  
  ##### SQL query params ---------------
  vars.to.get <- paste0('"', vars.to.get, '"') # add ""
  vars.to.get <- paste(vars.to.get, collapse = ', ') # add ,
  
  table.name <- paste0('"Game: ', game.id, '"')
  
  ### Add condition
  cond1 <- 'play_type = "pass" OR play_type = "run"'
  
  ##### Full query --------------
  sql.state <- paste('SELECT', vars.to.get,
                     'FROM', table.name,
                     'WHERE', cond1) 
  
  ##### Run query/get table ---------------
  Dataframe <- dbGetQuery(db.con, sql.state)
  
  return(Dataframe)
  
}
