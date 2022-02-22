source("global.R")

load("logit.RData")

# predict probabilities of winning

sim <- data.table(
  rating = 1500,
  gap = c(0, 25),
  white = 1,
  total = 20,
  faster = 0,
  slower = 0,
  antichess = 0,
  atomic = 0,
  chess960 = 0,
  crazyhouse = 0,
  horde = 0,
  kingofthehill = 0,
  racingkings = 0,
  threecheck = 0
)

sim$fit <-
  predict(logit$fit, sim, se.fit = T, type = "response")$fit
sim$se <-
  predict(logit$fit, sim, se.fit = T, type = "response")$se.fit
sim$ci1 <- with(sim, fit - 1.96 * se)
sim$ci2 <- with(sim, fit + 1.96 * se)

# compare empirical and expected scores

load("pgn.RData")

pgn$gap <- with(pgn, black_rating - white_rating)

emp_score <- function(x) {
  results <- pgn[gap == x]$result
  results <- table(results)[c("0-1", "1-0", "1/2-1/2")]
  wins <- as.integer(results["1-0"])
  draws <- as.integer(results["1/2-1/2"])
  (wins + .5 * draws) / sum(results)
}

exp_score <- function(x) {
  z <- x / 400
  1 / (1 + 10 ^ z)
}

score <- data.table(gap = seq(-1000, 1000, 10))

score$emp <- mcmapply(emp_score, score$gap, mc.cores = 16L)
score$exp <- mcmapply(exp_score, score$gap, mc.cores = 16L)

score <-
  with(score, data.table(
    gap = rep(gap, 2),
    type = c(rep("Empirical", 201), rep("Expected", 201)),
    score = c(emp, exp)
  ))

scheme <-
  list(
    cultured = "#f5f5f5",
    sumi = "#27221f"
  )

custom_theme <-
  theme(
    plot.margin = unit(c(8, 8, 8, 8), units = "points"),
    plot.background = element_rect(fill = scheme$cultured),
    panel.background = element_rect(fill = scheme$cultured),
    panel.grid.major = element_line(
      color = scheme$sumi,
      size = .1,
      lineend = "round"
    ),
    panel.grid.minor = element_line(
      color = scheme$sumi,
      size = .1,
      lineend = "round"
    ),
    axis.ticks.x = element_blank(),
    axis.ticks.y = element_blank(),
    legend.background = element_rect(fill = scheme$cultured),
    legend.key = element_rect(color = scheme$cultured),
    text = element_text(size = 14, color = scheme$sumi)
  )

gap <- ggplot(score) +
  geom_line(aes(gap, score, group = type, linetype = type)) +
  scale_x_continuous(breaks = seq(-1000, 1000, 200)) +
  scale_y_continuous(breaks = seq(0, 1, .1)) +
  labs(x = "Opponent rating minus player rating", y = "Score", linetype = NULL) +
  custom_theme

ggsave(
  gap,
  filename = "expectedscore.jpg",
  height = 1024,
  width = 1280,
  units = "px",
  dpi = 150
)

# check interactions with player rating

logit$fit2 <-
  glm(
    win ~ rating + gap + white + total + faster + slower + antichess + atomic * rating +
      chess960 + crazyhouse + horde + kingofthehill + racingkings + threecheck,
    data = logit$fit$data,
    family = binomial(link = "logit")
  )

sim <- data.table(
  rating = quantile(logit$fit$data$rating, c(.04, .5, .96)) %>%
    round(-2) %>%
    rep(each = 11),
  gap = 0,
  white = 1,
  total = 20,
  faster = 0,
  slower = 0,
  antichess = 0,
  atomic = seq(0, 1, .1) %>% rep(3),
  chess960 = 0,
  crazyhouse = 0,
  horde = 0,
  kingofthehill = 0,
  racingkings = 0,
  threecheck = 0
)

sim$fit <-
  predict(logit$fit2, sim, se.fit = T, type = "response")$fit
sim$se <-
  predict(logit$fit2, sim, se.fit = T, type = "response")$se.fit
sim$ci1 <- with(sim, fit - 1.96 * se)
sim$ci2 <- with(sim, fit + 1.96 * se)

atomic <- ggplot(sim) +
  geom_line(aes(atomic, fit, group = rating, lty = factor(rating))) +
  geom_ribbon(aes(
    atomic,
    ymin = ci1,
    ymax = ci2,
    group = rating
  ), alpha = .2) +
  scale_x_continuous(breaks = seq(0, 1, .2), labels = paste0(100 * seq(0, 1, .2), "%")) +
  scale_y_continuous(
    limits = c(.2, .6),
    breaks = seq(.2, .6, .05),
    labels = paste0(100 * seq(.2, .6, .05), "%")
  ) +
  labs(x = "Share of games played in Atomic", y = "Probability of winning", lty = "Player rating") +
  custom_theme

ggsave(
  atomic,
  filename = "atomicrating.jpg",
  height = 1024,
  width = 1280,
  units = "px",
  dpi = 150
)
