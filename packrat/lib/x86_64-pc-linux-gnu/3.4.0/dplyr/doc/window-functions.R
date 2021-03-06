## ---- echo = FALSE, message = FALSE--------------------------------------
knitr::opts_chunk$set(collapse = T, comment = "#>")
options(tibble.print_min = 4L, tibble.print_max = 4L)
library(dplyr)

## ---- results = "hide"---------------------------------------------------
library(Lahman)
batting <- select(tbl_df(Batting), playerID, yearID, teamID, G, AB:H) 
batting <- arrange(batting, playerID, yearID, teamID)
players <- group_by(batting, playerID)

# For each player, find the two years with most hits
filter(players, min_rank(desc(H)) <= 2 & H > 0)
# Within each player, rank each year by the number of games played
mutate(players, G_rank = min_rank(G))

# For each player, find every year that was better than the previous year
filter(players, G > lag(G))
# For each player, compute avg change in games played per year
mutate(players, G_change = (G - lag(G)) / (yearID - lag(yearID)))

# For each player, find all where they played more games than average
filter(players, G > mean(G))
# For each, player compute a z score based on number of games played
mutate(players, G_z = (G - mean(G)) / sd(G))

## ------------------------------------------------------------------------
x <- c(1, 1, 2, 2, 2)

row_number(x)
min_rank(x)
dense_rank(x)

## ------------------------------------------------------------------------
cume_dist(x)
percent_rank(x)

## ---- results = 'hide'---------------------------------------------------
# Selects best two years
filter(players, min_rank(desc(G)) < 2)

# Selects best 10% of years
filter(players, cume_dist(desc(G)) < 0.1)

## ------------------------------------------------------------------------
by_team_player <- group_by(batting, teamID, playerID)
by_team <- summarise(by_team_player, G = sum(G))
by_team_quartile <- group_by(by_team, quartile = ntile(G, 4))
summarise(by_team_quartile, mean(G))

## ------------------------------------------------------------------------
x <- 1:5
lead(x)
lag(x)

## ---- results = "hide"---------------------------------------------------
# Compute the relative change in games played
mutate(players, G_delta = G - lag(G))

## ---- results = "hide"---------------------------------------------------
# Find when a player changed teams
filter(players, teamID != lag(teamID))

## ------------------------------------------------------------------------
df <- data.frame(year = 2000:2005, value = (0:5) ^ 2)
scrambled <- df[sample(nrow(df)), ]

wrong <- mutate(scrambled, running = cumsum(value))
arrange(wrong, year)

right <- mutate(scrambled, running = order_by(year, cumsum(value)))
arrange(right, year)

## ---- results = "hide"---------------------------------------------------
filter(players, cumany(G > 150))

## ------------------------------------------------------------------------
x <- 1:10
y <- 10:1
order_by(y, cumsum(x))

## ---- results = "hide"---------------------------------------------------
filter(players, G > mean(G))
filter(players, G < median(G))

## ---- results = "hide"---------------------------------------------------
filter(players, ntile(G, 2) == 2)

## ------------------------------------------------------------------------
mutate(players, career_year = yearID - min(yearID) + 1)

## ------------------------------------------------------------------------
mutate(players, G_z = (G - mean(G)) / sd(G))

## ---- message = FALSE----------------------------------------------------
if (has_lahman("postgres")) {
  players_db <- group_by(tbl(lahman_postgres(), "Batting"), playerID)
  
  print(translate_sql(mean(G), tbl = players_db, window = TRUE))
  print(translate_sql(cummean(G), tbl = players_db, window = TRUE))
  print(translate_sql(rank(G), tbl = players_db, window = TRUE))
  print(translate_sql(ntile(G, 2), tbl = players_db, window = TRUE))
  print(translate_sql(lag(G), tbl = players_db, window = TRUE))
}

## ---- message = FALSE----------------------------------------------------
if (has_lahman("postgres")) {
  players_by_year <- arrange(players_db, yearID)
  print(translate_sql(cummean(G), tbl = players_by_year, window = TRUE))
  print(translate_sql(rank(), tbl = players_by_year, window = TRUE))
  print(translate_sql(lag(G), tbl = players_by_year, window = TRUE))
}

## ---- eval = FALSE-------------------------------------------------------
#  mutate(players,
#    min_rank(yearID),
#    order_by(yearID, cumsum(G)),
#    lead(order_by = yearID, G)
#  )

## ---- eval = FALSE-------------------------------------------------------
#  filter(players, rank(G) == 1)

