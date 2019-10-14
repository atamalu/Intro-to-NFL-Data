nflplot_sack_total <- function(Dataframe){
  
  ##### Summarize data ---------------
  Dataframe.summ <- Dataframe %>%
    group_by(game_id, home_team, away_team, defteam) %>%
    summarize(sack_total = sum(sack)) %>%
    arrange(defteam)
  
  nfl_teamcolors <- teamcolors::teamcolors %>% 
    filter(league == "nfl") %>%
    select(name, primary, division) %>%
    arrange(name)
  
  Dataframe.summ$name <- nfl_teamcolors$name
  
  Dataframe.summ <- merge(Dataframe.summ, nfl_teamcolors, 
                   by = 'name')
  
  ##### Graph ---------------
  clrs <- Dataframe.summ[order(Dataframe.summ$name),]$primary
  
  p <- ggplot(Dataframe.summ, aes(x = reorder(defteam, sack_total))) +
    geom_point(aes(y = sack_total), size = 1.75, color = clrs) +
    scale_y_continuous(breaks = seq(min(Dataframe.summ$sack_total), max(Dataframe.summ$sack_total), 1)) +
    coord_flip()
  
  ### Labels and theme
  p2 <- p +
    labs(title = 'Total Sacks by Team',
         x = '', y = 'Sacks') +
    theme(panel.grid.minor = element_blank(),
          panel.grid.major.x = element_blank(),
          panel.grid.major.y = element_line(color = 'grey90', linetype = 'dashed'),
          axis.ticks = element_blank(),
          panel.border = element_blank(),
          axis.title.y = element_text(vjust = -.5)
    )
  
  p2
  
}
