library(httr)
library(jsonlite)
library(dplyr)
library(plyr)

##### Data info --------------
data.info <- data.frame(
  Type = c('editordraftranks', 'userdraftranks', 
           'researchinfo', 'news', 'scoringleaders', 
           'stats', 'details', 'advanced'),
  Format.num = c(TRUE, TRUE,  
                 TRUE, FALSE, TRUE, 
                 TRUE, FALSE, FALSE)
)

Data.type = 'news'

get_data <- function(Data.type, Params = list()){
  
  ##### Function breaks if json format isn't specified ---------------
  if(!'format' %in% Params){
    Params[['format']] <- 'json'
  }
  
  ##### Helper ---------------
  if(!Data.type %in% data.info$Type){
    stp.txt = sprintf('Invalid data type. Please use one of the following:\n %s',
                       paste(data.info$Type, collapse = ', '))
    stop(stp.txt)
  }
  
  ##### Load general info ---------------
  base.url <- 'http://api.fantasy.nfl.com/v1/players/'
  
  ##### Get info using params ---------------
  pg <- httr::GET(url = paste0(base.url, Data.type), 
            query = Params)
  
  pg <- httr::content(pg, 'text', encoding = "UTF-8")
  pg <- jsonlite::fromJSON(pg, flatten = TRUE)
  
  pg.names <- lapply(pg, is.list) # always a list item
  pg.names <- which(pg.names == TRUE)
  
  df <- pg[pg.names]
  
  ##### Formatting ---------------
  
  ### if it gives list of lists instead of df, keep unpacking
  while(!is.data.frame(df)){
    if(length(df) > 1){
      df <- plyr::rbind.fill(df)
    } else if(length(df) == 1){
      df <- df[[1]]
    }
  }
  
  ### to numeric
  Format.data <- data.info$Format.num[data.info$Type == Data.type]
  
  if(Format.data == TRUE){
    rm.words <- c('team', 'player', 'name', 'position', 
                  'esbid', 'stock', 'status', 'statsLine')
    rm.words <- dplyr::matches(paste(rm.words, collapse = '|'), 
                        vars = colnames(df))
    
    df <- dplyr::mutate_at(df, -rm.words, as.numeric)
  }
  
  return(df)
  
}
