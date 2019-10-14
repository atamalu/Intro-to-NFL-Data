##### Function ---------------
game_to_sql <- function(game.id, db.con, prefix = 'Game:'){
  
  file.name = paste(prefix, game.id)
  does.exist = dbExistsTable(conn = con, name = file.name) # returns T/F
  
  if(does.exist != TRUE){
    Dataframe <- scrape_json_play_by_play(game_id = game.id)
    Dataframe$Week <- '1'
    
    dbWriteTable(conn = db.con, name = file.name, value = Dataframe) # write to database
  } else {
    print(paste('Table "', file.name, '" already exists.'))
  }
  
}
