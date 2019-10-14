nflplot.yards_allowed_week <- function(Dataframe){
  ## switch sf and sea, la and lac for graphing
  Dataframe$defteam <- ifelse(Dataframe$defteam == 'SF', 'SaF', Dataframe$defteam)
  Dataframe$defteam <- ifelse(Dataframe$defteam == 'LA', 'LAR', Dataframe$defteam)
  
  ##### Summarize data ---------------
  Dataframe.summ <- Dataframe %>%
    group_by(game_id, home_team, away_team, defteam) %>%
    summarize(yards_gained_total = sum(yards_gained)) %>%
    arrange(defteam)
  
  nfl_teamcolors <- teamcolors::teamcolors %>% 
    filter(league == "nfl") %>%
    select(name, primary, division) %>%
    arrange(name)
  
  Dataframe.summ$name <- nfl_teamcolors$name
  
  Dataframe.summ <- merge(Dataframe.summ, nfl_teamcolors, 
                   by = 'name')
  
  ##### Pass/Rush points ---------------
  Dataframe.summ2 <- Dataframe %>%
    group_by(game_id, home_team, away_team, defteam, play_type) %>%
    summarize(yards_gained_type = sum(yards_gained))
  
  Dataframe.summP <- Dataframe.summ2 %>%
    filter(play_type == 'pass') %>%
    rename(yards_gained_pass = yards_gained_type) %>%
    select(-play_type)
  
  Dataframe.summR <- Dataframe.summ2 %>%
    filter(play_type == 'run') %>%
    rename(yards_gained_rush = yards_gained_type) %>%
    select(-play_type)
  
  Dataframe.summ <- left_join(Dataframe.summ, Dataframe.summR)
  Dataframe.summ <- left_join(Dataframe.summ, Dataframe.summP)
  
  ##### Graph ---------------
  clrs <- Dataframe.summ[order(Dataframe.summ$name),]$primary
  p.title <- 'Rush/Pass Yards Allowed'
  
  ### Points 
  p <- ggplot(Dataframe.summ, aes(x = reorder(defteam, yards_gained_total))) +
    geom_point(aes(y = yards_gained_total), size = 1.75, color = clrs) +
    scale_shape_identity() +
    coord_flip()
  
  ### Labels and theme
  p2 <- p + 
    labs(title = p.title,
         x = '', y = '') +
    # rush yards
    geom_segment(aes(xend = reorder(defteam, yards_gained_total), 
                     y = 0, yend = yards_gained_rush), 
                 color = clrs, alpha = 0.5, size = 1.6) +
    # pass yards
    geom_segment(aes(xend = reorder(defteam, yards_gained_total), 
                     y = yards_gained_rush, yend = yards_gained_total), 
                 color = clrs, alpha = 0.4, size = 0.8) +
    scale_y_continuous(breaks = c(0, 100, 200, 300, 400, 500, 600)) +
    theme(panel.grid.minor = element_blank(),
          panel.grid.major = element_blank(),
          axis.ticks = element_blank(),
          panel.border = element_blank()
    )
  p2
}
