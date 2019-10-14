library(rvest)
library(dplyr)

FR_players_fantasy <- function(Year = 2019, Per.game = FALSE){
  url <- sprintf('https://www.pro-football-reference.com/years/%i/fantasy.htm', Year)
  
  ### webpage
  pg <- url %>%
    read_html()
  
  ### headers
  name.cols <- pg %>%
    html_nodes('th') %>%
    html_attr('data-stat')
  
  # get everything from rank column (first) up to duplicates
  strt <- which(name.cols == 'ranker')[1]
  stp <- which(name.cols == 'ranker')[2] - 1
  
  name.cols <- name.cols[strt:stp]
  
  ### table
  df <- pg %>% 
    html_nodes('table') %>%
    html_table()
  
  df <- df[[1]] 
  colnames(df) <- name.cols
  
  ##### Format data --------------
  df <- df %>% filter(ranker != 'Rk') # remove extra col labels
  
  firstvar.name <- 'age'
  lastvar.name <- colnames(df)[ncol(df)]
  
  df <- df %>%
    mutate_at(vars(firstvar.name:lastvar.name), as.numeric) # make columns numeric
  
  ### Optionally transform stats into numbers per game
  if(Per.game == TRUE){
    df <- df %>%
      mutate_if(is.numeric, function(x) { x / df$g }) 
  }
  
  return(df)
  
}
