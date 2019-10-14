library(ggplot2)
theme_set(theme_bw())
source('Functions/FRplot_def_vs_pos.R')
source('Functions/FR_def_vs_pos.R')

##### Save to desktop automatically ---------------
user.name <- Sys.getenv('USERNAME')
save.to <- paste0('C:/Users/', user.name, '/Desktop/')

### check if Plots folder exists; create if not
if(!dir.exists(file.path(save.to, 'Plots'))){
  tryCatch(
    dir.create(file.path(save.to, 'Plots')),
    
    # if that doesn't work, just create folder in wd
    error = function(e){ 
      print(paste('Error... ', e))
      print('Proceeding..... ')
      
      dir.create(file.path(getwd(), 'Plots'))      
      }
  )
}

##### Edit weekly ---------------
Week <- 6

##### Get data from FR ---------------
df.QB <- FR_def_vs_pos('QB') %>% mutate(Pos = 'QB') %>% select(team, Pos, fanduel_points_per_game) 
df.WR <- FR_def_vs_pos('WR') %>% mutate(Pos = 'WR') %>% select(team, Pos, fanduel_points_per_game)
df.RB <- FR_def_vs_pos('RB') %>% mutate(Pos = 'RB') %>% select(team, Pos, fanduel_points_per_game)
df.TE <- FR_def_vs_pos('TE') %>% mutate(Pos = 'TE') %>% select(team, Pos, fanduel_points_per_game)

df <- rbind(df.QB, df.WR, df.RB, df.TE)

##### Add team colors ---------------
nfl_teamcolors <- teamcolors::teamcolors %>% 
  filter(league == "nfl") %>%
  select(name, primary, division)

df <- merge(df, nfl_teamcolors, 
            by.x = 'team', by.y = 'name') # add colors

##### Compact team names ---------------
df$team.plot <- stringr::word(df$team,-1)

##### Plot ---------------

### Make
All.plot <- FRplot_def_vs_pos(df, c('QB', 'WR', 'RB', 'TE'), scale = TRUE)
QB.plot <- FRplot_def_vs_pos(df, 'QB', scale = TRUE)
WR.plot <- FRplot_def_vs_pos(df, 'WR', scale = TRUE)
RB.plot <- FRplot_def_vs_pos(df, 'RB', scale = TRUE)
TE.plot <- FRplot_def_vs_pos(df, 'TE', scale = TRUE)

p.list <- list('All' = All.plot,
               'QB' = QB.plot,
               'WR' = WR.plot,
               'RB' = RB.plot,
               'TE' = TE.plot)

### Write
lapply(p.list, function(plt){
  
  f.name <- sprintf('%sPlots/Defense vs Position %s.jpeg', 
                    save.to,
                    paste(plt$plot_env$Positions, collapse = ' '))
  
  ggsave(filename = f.name, plot = plt, 
         device = 'jpg', units = 'in',
         width = 7, height = 7)
})
