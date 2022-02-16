source("global.R")

load("pgn.RData")

pool <- pgn[variant == "standard"]
pool <- pool[termination == "normal"]
pool <- pool[control != "correspondence"]
pool <- pool[utc >= with(global, start + window) & utc < global$end]
pool <- pool[white_title != "bot" & black_title != "bot"]
pool <- pool[!is.na(white_diff) & !is.na(black_diff)]

cut <-
  c(with(pool, abs(white_rating - black_rating)) %>% quantile(.95),
    with(pool, c(abs(white_diff), abs(black_diff))) %>% quantile(.95))

pool <- pool[abs(white_rating - black_rating) <= cut[1]]
pool <- pool[abs(white_diff) <= cut[2] & abs(black_diff) <= cut[2]]

games <- data.table(unique(with(pool, c(white, black))))
colnames(games) <- "player"

split_batch <- function(x, n) {
  split(x, ceiling(seq_along(x) / n))
}

batch <- split_batch(1:nrow(games), 5000)
tmp <- list()

for (i in 1:length(batch)) {
  Sys.time() %>% paste("loop", i) %>% message()
  registerDoParallel(global$cores)
  tmp[[i]] <- foreach(j = batch[[i]], .combine = c) %dopar% {
    p <- games[j]$player
    set.seed(j)
    c(pool[white == p]$id, pool[black == p]$id) %>%
      unique() %>%
      sample(1)
  }
  stopImplicitCluster()
}

games$id <- Reduce(c, tmp)

games <- left_join(games, pool, by = "id")

games <-
  mutate(
    games,
    side = ifelse(player == white, "white", "black"),
    rating = ifelse(player == white, white_rating, black_rating),
    opponent = ifelse(player == white, black, white),
    gap = ifelse(
      player == white,
      black_rating - white_rating,
      white_rating - black_rating
    ),
    result = ifelse(result == "1-0", "white", ifelse(result == "0-1", "black", "draw"))
  ) %>%
  mutate(score = ifelse(side == result, 1, ifelse(result == "draw", .5, 0)),
         white = as.integer(side == "white")) %>%
  select(id, utc, player, white, rating, opponent, gap, control, score)

variants <- unique(pgn$variant) %>% sort()

controls <-
  c("ultrabullet",
    "bullet",
    "blitz",
    "rapid",
    "classical",
    "correspondence")

count_exp <- function(x, t, c) {
  same <- c
  c <- which(controls == same)
  if (c > 1) {
    fast <- controls[1:(c - 1)]
  } else {
    fast <- NA
  }
  if (c < 6) {
    slow <- controls[(c + 1):6]
  } else {
    slow <- NA
  }
  window <- c(t - global$window, t)
  counts <- list()
  all <- rbind(pgn[white == x], pgn[black == x])
  week <- all[utc >= window[1] & utc < window[2]]
  variant <- as.integer(table(c(variants, week$variant)) - 1L)
  names(variant) <- variants
  control <- table(week$control)
  n_fast <- control[names(control) %in% fast] %>% sum()
  n_slow <- control[names(control) %in% slow] %>% sum()
  n_tot <- sum(variant)
  c(
    variant,
    faster = n_fast,
    slower = n_slow,
    total = n_tot
  )
}

batch <- split_batch(1:nrow(games), 500)
tmp <- list()

for (i in 1:length(batch)) {
  Sys.time() %>% paste("loop", i) %>% message()
  registerDoParallel(global$cores)
  tmp[[i]] <- foreach(j = batch[[i]], .combine = rbind) %dopar% {
    with(games[j], count_exp(player, utc, control))
  }
  stopImplicitCluster()
}

counts <- Reduce(rbind, tmp) %>% data.table()

games <- cbind(games, counts)

save(games, file = "games.RData")
