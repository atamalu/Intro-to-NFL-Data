library(ggplot2)
library(dplyr)

z_score <- function(x){ (x - mean(x)) / sd(x) }

FRplot_def_vs_pos <- function(Dataframe, Positions, scale = FALSE){
  
  Dataframe <- Dataframe[Dataframe$Pos %in% Positions,]
  
  ##### Options ---------------
  
  if(scale == TRUE){
    Dataframe <- Dataframe %>%
      group_by(Pos) %>%
      mutate(fanduel_points_per_game = z_score(fanduel_points_per_game))
    
    ylims = c(round(min(Dataframe$fanduel_points_per_game) - 0.5),
              round(max(Dataframe$fanduel_points_per_game) + 0.5))
    brks = seq(round(min(Dataframe$fanduel_points_per_game)),
               round(max(Dataframe$fanduel_points_per_game)), by = 0.5)
    
  } else {
    brks = c(0, 10, 20, 30)
    ylims = c(0, max(Dataframe$fanduel_points_per_game) + 1)
  }
  
  p <- ggplot(Dataframe) +
    geom_text(aes(x = reorder(team.plot, fanduel_points_per_game), y = fanduel_points_per_game, label = Pos),
              stat = 'identity', 
              color = Dataframe[order(Dataframe$team),]$primary,
              size = 4, fontface = 2) +
    coord_flip() +
    scale_y_continuous(limits = ylims,
                       breaks = brks)
  
  p2 <- p +
    labs(title = 'Opponent Fantasy Points per Game',
         x = '', y = '') +
    theme(panel.grid.minor = element_blank(),
          panel.grid.major.x = element_blank(),
          panel.grid.major.y = element_line(color = 'grey92', linetype = 'dashed'),
          axis.ticks = element_blank(),
          panel.border = element_blank(),
          axis.text.y = element_text(size = 12, face = 'bold'),
          axis.text.x = element_text(face = 'bold', size = 12),
          plot.title = element_text(size = 14)
    )
  p2
}
