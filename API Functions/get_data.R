library(httr)
library(xml2)
library(jsonlite)
library(dplyr)
library(plyr)

Data.type <- 'playerstats'
Params <- list(count = 50,
               format = 'json',
               position = 'K')

get_data <- function(Data.type, Params = list(format = 'json')){
  
  ##### Load general info ---------------
  q.info <- fromJSON('Queries/Params.json')
  q.info <- q.info[[Data.type]]
  
  ##### Get info using params ---------------
  pg <- GET(url = q.info$baseurl, 
            query = Params)
  
  pg <- content(pg, 'text', encoding = "UTF-8")
  pg <- jsonlite::fromJSON(pg, flatten = TRUE)
  
  pg.names <- lapply(pg, is.list) # always a list item
  pg.names <- which(pg.names == TRUE)
  
  df <- pg[[pg.names]]
  
  ##### Formatting ---------------
  
  ### if it gives list of lists instead of df
  if(!is.data.frame(df)){
    df <- plyr::rbind.fill(df)
  }
  
  ### to numeric
  Format.data <- as.logical(q.info$formatnum)
  
  if(Format.data == TRUE){
    rm.words <- c('team', 'player', 'name', 'position', 'esbid')
    rm.words <- matches(paste(rm.words, collapse = '|'), 
                        vars = colnames(df))
    
    df <- df %>%
      mutate_at(-rm.words, as.numeric)
  }
  
  return(df)
  
}

helper_get_data <- function(){
  
}

a <- get_data(Data.type = Data.type, Params = Params)
