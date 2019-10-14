library(httr)
library(xml2)
library(jsonlite)
library(dplyr)

Data.type <- 'stattypes'
Params <- list(count = 50,
               format = 'json')

get_data <- function(Data.type, Params = list(format = 'json')){
  
  ##### Load general info ---------------
  q.info <- fromJSON('Queries/Params.json')
  q.info <- q.info[[Data.type]]
  
  ##### Get info using params ---------------
  pg <- GET(url = q.info$baseurl, 
            query = Params)
  
  pg <- content(pg, 'text', encoding = "UTF-8")
  pg <- jsonlite::fromJSON(pg, flatten = TRUE)
  
  ##### Formatting ---------------
  df <- pg[[2]]
  
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

a <- get_data(Data.type = Data.type, Params = Params)
