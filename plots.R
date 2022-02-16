source("global.R")

load("games.RData")
load("logit.RData")

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

rating <- ggplot(games) +
  geom_histogram(
    aes(rating),
    binwidth = 15,
    fill = scheme$sumi,
    col = scheme$sumi
  ) +
  scale_y_continuous(limits = c(0, 20000),
                     breaks = seq(0, 20000, length.out = 5)) +
  scale_x_continuous(limits = c(600, 3300),
                     breaks = seq(600, 3300, length.out = 13)) +
  labs(x = "Player rating", y = "Number of games") +
  custom_theme

gap <- ggplot(games) +
  geom_histogram(
    aes(gap),
    binwidth = 3,
    fill = scheme$sumi,
    col = scheme$sumi
  ) +
  scale_y_continuous(limits = c(0, 45000),
                     breaks = seq(0, 45000, length.out = 5)) +
  scale_x_continuous(limits = c(-270, 270),
                     breaks = seq(-270, 270, length.out = 13)) +
  labs(x = "Opponent rating minus player rating", y = "Number of games") +
  custom_theme +
  theme(text = element_text(size = 14))

control <- ggplot(games) +
  geom_bar(aes(control), fill = scheme$sumi, col = scheme$sumi) +
  scale_y_continuous(limits = c(0, 650000),
                     breaks = seq(0, 650000, length.out = 5)) +
  scale_x_discrete(
    limits = c("ultrabullet", "bullet", "blitz", "rapid", "classical"),
    labels = c("Ultra", "Bullet", "Blitz", "Rapid", "Classical")
  ) +
  labs(x = "Time controls", y = "Number of games") +
  custom_theme

score <- ggplot(games) +
  geom_bar(aes(factor(score), fill = factor(white)),
           col = scheme$sumi,
           size = 1) +
  scale_y_continuous(limits = c(0, 650000),
                     breaks = seq(0, 650000, length.out = 5)) +
  scale_x_discrete(labels = c("Loss", "Draw", "Win")) +
  scale_fill_manual(
    breaks = c(1, 0),
    values = c(scheme$cultured, scheme$sumi),
    labels = c("White", "Black")
  ) +
  labs(x = "Game result", y = NULL, fill = "Playing as") +
  custom_theme

plot_grid(ncol = 1, rating, gap, plot_grid(control, score, nrow = 1)) %>%
  ggsave(
    filename = "sample.jpg",
    height = 1024,
    width = 1280,
    units = "px",
    dpi = 150
  )

est <- ggplot(logit$est) +
  geom_vline(aes(xintercept = 1),
             col = scheme$cultured,
             size = .75) +
  geom_vline(
    aes(xintercept = 1),
    col = scheme$sumi,
    linetype = "dashed",
    size = .75
  ) +
  annotate(
    "text",
    x = 1.02,
    y = 3,
    label = "Odds when playing only standard",
    angle = 90,
    size = 5.5,
    col = scheme$sumi
  ) +
  geom_linerange(aes(y = variant, xmin = ci1, xmax = ci2),
                 col = scheme$sumi,
                 size = 14) +
  geom_point(
    aes(or, variant),
    col = scheme$cultured,
    size = 6,
    pch = 18
  ) +
  scale_y_discrete(
    limits = rev,
    labels = c(
      "Three-Check",
      "Racing Kings",
      "King of the Hill",
      "Horde",
      "Crazyhouse",
      "Chess960",
      "Atomic",
      "Antichess"
    )
  ) +
  scale_x_continuous(limits = c(.3, 1.10),
                     breaks = seq(.3, 1.10, .1)) +
  labs(x = "Odds ratio",
       y = NULL) +
  custom_theme +
  theme(text = element_text(size = 18))

ggsave(
  est,
  filename = "estimates.jpg",
  height = 1024,
  width = 1280,
  units = "px",
  dpi = 150
)
