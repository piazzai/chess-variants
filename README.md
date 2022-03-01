# chess-variants

This repository contains code to reproduce the results reported in [this study](https://lichess.org/@/piazzai/blog/do-variants-help-you-play-better-chess-statistical-evidence/0tAPXnqH) about the effects of spending time on variants on Lichess users' odds of winning standard chess games.

Before running the code, download the January 2022 data dumps from the [Lichess database](https://database.lichess.org).

-   [Standard](https://database.lichess.org/standard/lichess_db_standard_rated_2022-01.pgn.bz2)
-   [Antichess](https://database.lichess.org/antichess/lichess_db_antichess_rated_2022-01.pgn.bz2)
-   [Atomic](https://database.lichess.org/atomic/lichess_db_atomic_rated_2022-01.pgn.bz2)
-   [Chess960](https://database.lichess.org/chess960/lichess_db_chess960_rated_2022-01.pgn.bz2)
-   [Crazyhouse](https://database.lichess.org/crazyhouse/lichess_db_crazyhouse_rated_2022-01.pgn.bz2)
-   [Horde](https://database.lichess.org/horde/lichess_db_horde_rated_2022-01.pgn.bz2)
-   [King of the Hill](https://database.lichess.org/kingOfTheHill/lichess_db_kingOfTheHill_rated_2022-01.pgn.bz2)
-   [Racing Kings](https://database.lichess.org/racingKings/lichess_db_racingKings_rated_2022-01.pgn.bz2)
-   [Three-Check](https://database.lichess.org/threeCheck/lichess_db_threeCheck_rated_2022-01.pgn.bz2)

Place `pgn2csv.sh` in the same folder as the data dumps. Run this bash script on each data dump to unzip it and convert its PGN content into a much lighter CSV file. Provide the path to the CSV files in `global.R`.

Afterward, run the R scripts in this order: `pgn.R`, `games.R`, `logit.R`, `plots.R`. Each script reads the output of the previous (if any) and saves its own output to disk. Be aware that some of the scripts deal with very large files and take several hours to run, even with parallelization.

## Model results

After running the R scripts, it only takes a few commands to print the analysis results.

```r
load("logit.RData")       # loads the model object
max(logit$cond$condindx)  # prints the condition number of the data matrix
summary(logit$fit)        # prints model estimates
```

Estimates can be easily converted to odds ratios and printed along with their 95% confidence intervals.

```r
with(
  summary(logit$fit),
  data.table(
    predictor = rownames(coefficients)[-1],
    odds_ratio = exp(coefficients[-1, "Estimate"]),
    ci_lower = exp(coefficients[-1, "Estimate"] - 1.96 * coefficients[-1, "Std. Error"]),
    ci_upper = exp(coefficients[-1, "Estimate"] + 1.96 * coefficients[-1, "Std. Error"])
  )
)
```

Here is the output:

| Predictor variable                  | Odds ratio | Confidence interval |
| ----------------------------------- | ---------- | ------------------- |
| Player rating                       | 1.0001736  | 1.0001633—1.0001839 |
| Player rating minus opponent rating | 0.9924233  | 0.9923669—0.9924796 |
| Playing as white                    | 1.1971876  | 1.1881737—1.2062699 |
| Total number of games played        | 1.0010999  | 1.0010463—1.0011536 |
| Share of games at faster controls   | 0.8788922  | 0.8609969—0.8971594 |
| Share of games at slower controls   | 0.8725062  | 0.8520389—0.8934651 |
| Share of Antichess games            | 0.7121424  | 0.6038492—0.8398567 |
| Share of Atomic games               | 0.6383595  | 0.5416142—0.7523859 |
| Share of Chess960 games             | 0.8830630  | 0.7552096—1.0325615 |
| Share of Crazyhouse games           | 0.8362861  | 0.7108098—0.9839123 |
| Share of Horde games                | 0.6676855  | 0.4662084—0.9562334 |
| Share of King of the Hill games     | 0.6957822  | 0.4963507—0.9753446 |
| Share of Racing Kings games         | 0.4729084  | 0.3213880—0.6958640 |
| Share of Three-Check games          | 0.4782089  | 0.3657699—0.6252121 |
