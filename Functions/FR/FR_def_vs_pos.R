library(rvest)
library(dplyr)

FR_def_vs_pos <- function(Pos, Year = 2019){
  
  ##### Get data --------------
  
  url <- sprintf('https://www.pro-football-reference.com/years/%i/fantasy-points-against-%s.htm', Year, Pos)
  
  ### webpage
  pg <- url %>%
    read_html() 
  
  ### headers
  name.cols <- pg %>%
    html_nodes('th') %>%
    html_attr('data-stat') # they even made column names for us!
  
  # get everything from team column (first) up to team labels (1 after last)
  strt <- which(name.cols == 'team')[1]
  stp <- which(name.cols == 'team')[2] - 1
  
  name.cols <- name.cols[strt:stp]
  
  ### actual dataframe
  df <- pg %>%
    html_nodes('table') %>%
    html_table()
  
  df <- df[[1]]
  colnames(df) <- name.cols
  
  ##### Format data --------------
  df <- df %>% filter(team != 'Tm') # remove extra col labels
  
  firstvar.name <- 'g'
  lastvar.name <- colnames(df)[ncol(df)]
  
  df <- df %>%
    mutate_at(vars(firstvar.name:lastvar.name), as.numeric) # make columns numeric
  
  return(df)
  
}
