source("global.R")

load("games.RData")

games <-
  mutate(
    games,
    faster = ifelse(total > 0, faster / total, 0),
    slower = ifelse(total > 0, slower / total, 0),
    antichess = ifelse(total > 0, antichess / total, 0),
    atomic = ifelse(total > 0, atomic / total, 0),
    chess960 = ifelse(total > 0, chess960 / total, 0),
    crazyhouse = ifelse(total > 0, crazyhouse / total, 0),
    horde = ifelse(total > 0, horde / total, 0),
    kingofthehill = ifelse(total > 0, kingofthehill / total, 0),
    racingkings = ifelse(total > 0, racingkings / total, 0),
    standard = ifelse(total > 0, standard / total, 0),
    threecheck = ifelse(total > 0, threecheck / total, 0),
    win = ifelse(score == 1, T, F)
  ) %>%
  select(
    win,
    rating,
    gap,
    white,
    total,
    faster,
    slower,
    antichess,
    atomic,
    chess960,
    crazyhouse,
    horde,
    kingofthehill,
    racingkings,
    threecheck
  )

iv <- colnames(games)[-1]

cond <- colldiag(games[, ..iv])

fit <-
  glm(
    win ~ rating + gap + white + total + faster + slower + antichess + atomic +
      chess960 + crazyhouse + horde + kingofthehill + racingkings + threecheck,
    data = games,
    family = binomial(link = "logit")
  )

coef <- summary(fit)$coefficients[8:15, 1]
se <- summary(fit)$coefficients[8:15, 2]

est <-
  data.table(
    variant = names(coef),
    or = exp(coef),
    ci1 = exp(coef - 1.96 * se),
    ci2 = exp(coef + 1.96 * se)
  )

logit <-
  list(
    fit = fit,
    cond = cond,
    est = est
  )

save(logit, file = "logit.RData")
