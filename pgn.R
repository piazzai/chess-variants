source("global.R")

variants <- list.files(global$path) %>%
  str_subset(global$dump) %>%
  str_extract("db_[[:alnum:]]*") %>%
  str_remove_all("db_") %>%
  unique()

pgn <- foreach(i = variants, .combine = rbind) %do% {
  Sys.time() %>% paste("importing", i) %>% message()
  list.files(global$path, full.names = T) %>%
    str_subset(global$dump) %>%
    str_subset("csv$") %>%
    str_subset(i) %>%
    read.csv() %>%
    data.table()
}

pgn[is.na(Variant)]$Variant <- "standard"

pgn <-
  mutate(
    pgn,
    id = str_extract(Site, "[[:alnum:]]{8}$"),
    utc = paste(UTCDate, UTCTime) %>%
      strptime(format = "%Y.%m.%d %H:%M:%S", tz = "UTC") %>% as.numeric(),
    white_title = ifelse(WhiteTitle == "", "none", WhiteTitle) %>% tolower(),
    black_title = ifelse(BlackTitle == "", "none", BlackTitle) %>% tolower(),
    termination = str_extract(Termination, "[[:alpha:]]*$") %>% tolower(),
    control = str_extract(Event, "Rated [[:alpha:]]*") %>%
      str_remove("Rated ") %>% tolower(),
    variant = ifelse(
      is.na(Variant),
      "standard",
      str_remove_all(Variant, "[^[:alnum:]]")
    ) %>% tolower()
  ) %>%
  select(
    id,
    utc,
    white = White,
    white_rating = WhiteElo,
    white_title,
    white_diff = WhiteRatingDiff,
    black = Black,
    black_rating = BlackElo,
    black_title,
    black_diff = BlackRatingDiff,
    result = Result,
    termination,
    clock = TimeControl,
    control,
    variant
  )

controls <- pgn[variant == "standard", c("control", "clock")] %>%
  distinct()

controls <- distinct(pgn[, "clock"]) %>%
  left_join(controls, by = "clock") %>%
  mutate(control = ifelse(is.na(control), "classical", control))

pgn <- left_join(pgn[, -c("control")], controls, by = "clock")

save(pgn, file = "pgn.RData")
