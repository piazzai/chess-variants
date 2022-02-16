# chessvariants

This repository contains the code necessary to reproduce the results reported in [this study](https://lichess.org/@/piazzai/blog/do-variants-help-you-play-better-chess-statistical-evidence/0tAPXnqH) about the effects of variant play on Lichess users' odds of winning standard chess games.

To replicate the analysis, download the January 2022 data dumps from the [Lichess database](https://database.lichess.org) that include teh PGN records of standard games and of games in each variant. Place `pgn2bash.sh` in the same folder, and run this script in shell by typing `bash pgn2bash.sh <dump name>.pgn.bz2`. This will convert the PGN dumps to much lighter CSV files. Provide the path to the CSV files in `global.R`.

Afterward, run the R scripts in this order: `pgn.R`, `games.R`, `logit.R`, and if you are interested in replicating the graphs, `plots.R`. Each script reads from disk the output of the previous script in the sequence (if any), and saves its own output to disk. Be aware that some of the scripts deal with very large files and take several hours to run, even with parallelization.
