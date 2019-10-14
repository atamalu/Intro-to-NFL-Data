Storing and Loading Data in SQL
================

For this example, we will use data acquired via `nflscrapR` package

# Setup

``` r
library(DBI) # sql
library(RSQLite) # sql
library(dplyr) # data manipulation
library(nflscrapR) # data acquisition
```

To start, we need to set up a local SQLite database. SQL relational
databases are unsurprisingly used for storing large amounts of related
data.

To create a database named `NFL`, first enter `src_sqlite('NFL.sqlite',
create = TRUE)` into R. Then we can connect to the server we just made.

``` r
con <- dbConnect(SQLite(), 'NFL') # connect
```

# Grabbing Single Table

We can now gather the game ids and general information for all games in
the first week and store them in the server. This file will be called
“Schedule: Week 1”.

``` r
gids <- scrape_game_ids(2019, weeks = 1)
dbWriteTable(conn = con, name = 'Schedule: Week 1', value = gids, overwrite = TRUE)

glimpse(gids)
```

    ## Observations: 16
    ## Variables: 10
    ## $ type          <chr> "reg", "reg", "reg", "reg", "reg", "reg", "reg",...
    ## $ game_id       <fct> 2019090500, 2019090800, 2019090806, 2019090805, ...
    ## $ home_team     <fct> CHI, CAR, PHI, NYJ, MIN, MIA, JAX, CLE, LAC, SEA...
    ## $ away_team     <fct> GB, LA, WAS, BUF, ATL, BAL, KC, TEN, IND, CIN, S...
    ## $ week          <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    ## $ season        <dbl> 2019, 2019, 2019, 2019, 2019, 2019, 2019, 2019, ...
    ## $ state_of_game <fct> POST, POST, POST, POST, POST, POST, POST, POST, ...
    ## $ game_url      <chr> "http://www.nfl.com/liveupdate/game-center/20190...
    ## $ home_score    <dbl> 3, 27, 32, 16, 28, 10, 26, 13, 30, 21, 17, 35, 2...
    ## $ away_score    <dbl> 10, 30, 27, 17, 12, 59, 40, 43, 24, 20, 31, 17, ...

We can then use this information to individually scrape each game’s
play-by-play. To do this, we can use the function: `game_to_sql`.

``` r
source('Functions/game_to_sql.R')

game <- gids$game_id[1]

game_to_sql(game.id = game, 
            db.con = con,
            prefix = "Game:")
```

    ## [1] "Table \" Game: 2019090500 \" already exists."

The function is written to add a table for a single game to the
database. If a table for the game is already present, it simply returns
a message indicating that. There are 3 arguments:

  - `game.id` - id of the game to scrape
  - `db.con` - the SQL connection object
  - `prefix` (optional) - text to put before game id when writing to SQL
    database. Default is “Game:”

# Multiple Tables

The `game_to_sql` only outputs one game at a time. We can apply this
function across a vector of game ids from our table to download and save
info from all games.

``` r
gids <- dbReadTable(conn = con, 'Schedule: Week 1')
```

``` r
### apply across vector
sapply(gids$game_id, function(x){ game_to_sql(x, db.con = con)} )
```

# Loading Acquired Data

To stay organized and speed up future editing by explicitly putting the
variable names, you should make a vector of SQL table variable names
that you want to draw from the database.

``` r
##### SQL query params ---------------
myvars <- c('game_id', 'home_team', 'away_team',
            'posteam', 'posteam_type', 'defteam',
            'passer_player_id', 'passer_player_name',
            'play_type', 'yards_gained', 'touchdown', 'desc',
            'sack')
```

Let’s say we wanted to only get these variables for passing or rushing
plays from the “NFL” table.

``` r
##### Construct queries from R variabales ---------------
myvars.sql <- paste0('"', myvars, '"') # surround each in quotes
myvars.sql <- paste(myvars.sql, collapse = ', ') # make into list of vars for SQL

table.name <- paste0('"Game: ', game, '"') # format file name

cond1 <- 'play_type = "pass" OR play_type = "run"' # only pass or run plays

print(myvars.sql)
```

    ## [1] "\"game_id\", \"home_team\", \"away_team\", \"posteam\", \"posteam_type\", \"defteam\", \"passer_player_id\", \"passer_player_name\", \"play_type\", \"yards_gained\", \"touchdown\", \"desc\", \"sack\""

``` r
print(table.name)
```

    ## [1] "\"Game: 2019090500\""

``` r
print(cond1)
```

    ## [1] "play_type = \"pass\" OR play_type = \"run\""

``` r
##### Full query --------------
sql.state <- paste('SELECT', myvars.sql, 
                   'FROM', table.name,
                   'WHERE', cond1) # SELECT variables FROM table WHERE condition is true

##### Run query/get table ---------------
df <- dbGetQuery(con, sql.state)
glimpse(df)
```

    ## Observations: 120
    ## Variables: 13
    ## $ game_id            <chr> "2019090500", "2019090500", "2019090500", "...
    ## $ home_team          <chr> "CHI", "CHI", "CHI", "CHI", "CHI", "CHI", "...
    ## $ away_team          <chr> "GB", "GB", "GB", "GB", "GB", "GB", "GB", "...
    ## $ posteam            <chr> "GB", "GB", "GB", "CHI", "CHI", "CHI", "CHI...
    ## $ posteam_type       <chr> "away", "away", "away", "home", "home", "ho...
    ## $ defteam            <chr> "CHI", "CHI", "CHI", "GB", "GB", "GB", "GB"...
    ## $ passer_player_id   <chr> NA, "00-0023459", "00-0023459", NA, "00-003...
    ## $ passer_player_name <chr> NA, "A.Rodgers", "A.Rodgers", NA, "M.Trubis...
    ## $ play_type          <chr> "run", "pass", "pass", "run", "pass", "run"...
    ## $ yards_gained       <dbl> 0, 0, -10, 5, 0, 7, 0, 1, -6, 0, 0, -7, 4, ...
    ## $ touchdown          <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0...
    ## $ desc               <chr> "(15:00) A.Jones left tackle to GB 25 for n...
    ## $ sack               <dbl> 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0...

From this bit of SQL, we have selectively loaded information from the
first game. To apply this to get data for all games, we can put some of
the above code into a function.

``` r
get_sql_table <- function(game.id, vars.to.get, db.con){
  
  ##### SQL query params ---------------
  vars.to.get <- paste0('"', vars.to.get, '"') # add ""
  vars.to.get <- paste(vars.to.get, collapse = ', ') # add ,
  
  table.name <- paste0('"Game: ', game.id, '"')
  
  ### Add condition
  cond1 <- 'play_type = "pass" OR play_type = "run"'
  
  ##### Full query --------------
  sql.state <- paste('SELECT', vars.to.get,
                     'FROM', table.name,
                     'WHERE', cond1) 
  
  ##### Run query/get table ---------------
  Dataframe <- dbGetQuery(db.con, sql.state)
  
  return(Dataframe)

}
```

The `get_sql_table` function works exactly like combining most of the
preceding code. It loads a single table and takes 2 arguments:

  - `vars.to.get` - a vector of variable names
  - `game.id` - identifier of a specific game

Now we easily get all of the data where we need it, and stack it.

``` r
large.list <- lapply(gids$game_id, get_sql_table, myvars, con) # load all games into a list 
df <- do.call(rbind, large.list) # combine list items

glimpse(df)
```

    ## Observations: 1,974
    ## Variables: 13
    ## $ game_id            <chr> "2019090500", "2019090500", "2019090500", "...
    ## $ home_team          <chr> "CHI", "CHI", "CHI", "CHI", "CHI", "CHI", "...
    ## $ away_team          <chr> "GB", "GB", "GB", "GB", "GB", "GB", "GB", "...
    ## $ posteam            <chr> "GB", "GB", "GB", "CHI", "CHI", "CHI", "CHI...
    ## $ posteam_type       <chr> "away", "away", "away", "home", "home", "ho...
    ## $ defteam            <chr> "CHI", "CHI", "CHI", "GB", "GB", "GB", "GB"...
    ## $ passer_player_id   <chr> NA, "00-0023459", "00-0023459", NA, "00-003...
    ## $ passer_player_name <chr> NA, "A.Rodgers", "A.Rodgers", NA, "M.Trubis...
    ## $ play_type          <chr> "run", "pass", "pass", "run", "pass", "run"...
    ## $ yards_gained       <dbl> 0, 0, -10, 5, 0, 7, 0, 1, -6, 0, 0, -7, 4, ...
    ## $ touchdown          <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0...
    ## $ desc               <chr> "(15:00) A.Jones left tackle to GB 25 for n...
    ## $ sack               <dbl> 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0...

We now have all run and pass plays from week 1 in a single data frame.
This process can be repeated across weeks. The `game_to_sql` and
`get_sql_table` functions are available in the included “Functions”
folder.
