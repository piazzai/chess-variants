library(dplyr)
library(stringr)
library(data.table)
library(doParallel)
library(ggplot2)
library(cowplot)
library(perturb)

global <-
  list(
    path = "/media/piazzai/Data/lichess",
    dump = "2022-01",
    start = ISOdate(2022, 1, 3, 0, 0, 0) %>% as.numeric(),
    end = ISOdate(2022, 1, 31, 0, 0, 0) %>% as.numeric(),
    window = 604800L,
    cores = 16L
  )
