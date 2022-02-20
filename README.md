# chessvariants

This repository contains code that reproduces the results reported in [this study](https://lichess.org/@/piazzai/blog/do-variants-help-you-play-better-chess-statistical-evidence/0tAPXnqH) about the effects of variant play on Lichess users' odds of winning standard chess games.

To replicate the analysis, download the January 2022 data dumps from the [Lichess database](https://database.lichess.org) that include the PGN records of standard and variant games. Here are direct links to the necessary dumps:

-   <https://database.lichess.org/standard/lichess_db_standard_rated_2022-01.pgn.bz2>
-   <https://database.lichess.org/antichess/lichess_db_antichess_rated_2022-01.pgn.bz2>
-   <https://database.lichess.org/atomic/lichess_db_atomic_rated_2022-01.pgn.bz2>
-   <https://database.lichess.org/chess960/lichess_db_chess960_rated_2022-01.pgn.bz2>
-   <https://database.lichess.org/crazyhouse/lichess_db_crazyhouse_rated_2022-01.pgn.bz2>
-   <https://database.lichess.org/horde/lichess_db_horde_rated_2022-01.pgn.bz2>
-   <https://database.lichess.org/kingOfTheHill/lichess_db_kingOfTheHill_rated_2022-01.pgn.bz2>
-   <https://database.lichess.org/racingKings/lichess_db_racingKings_rated_2022-01.pgn.bz2>
-   <https://database.lichess.org/threeCheck/lichess_db_threeCheck_rated_2022-01.pgn.bz2>

Place `pgn2csv.sh` in the same folder as the data dumps, Run this script in shell to unzip the dumps and convert the PGN into much lighter CSV files. Provide the path to the CSV files in `global.R`.

Afterward, run the R scripts in this order: `pgn.R`, `games.R`, `logit.R`, `plots.R`. Each script reads the output of the previous (if any) and saves its own output to disk. Be aware that some of the scripts deal with very large files and take several hours to run, even with parallelization.

The R notebook `comments.nb.html` includes the commented code of the R scripts. The notebook `model.nb.html` contains additional details about the regression model, including pairwise correlations of regression variables, conditioning diagnostics, and the table of estimates.
