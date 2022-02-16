#!/bin/bash
pgn=${1%.bz2}
csv=${1%.pgn.bz2}.csv
echo "Unzipping"
bzip2 -dfkq $1
echo "Subsetting"
sed -i "/\\[Ev\|\\[Si\|\\[Wh\|\\[Bl\|\\[Re\|\\[UT\|\\[Ti\|\\[Te\|\\[Va/!d" $pgn
echo "Concatenating"
awk '/\[Ev/{if (x)print x;x="";}{x=(!x)?$0:x","$0;}END{print x;}' $pgn > $csv
echo "Normalizing"
sed -i "/BlackTitle/!{s/\\[Ti/\\[BlackTitle \"\"\\],\\[Ti/g}" $csv
sed -i "/WhiteTitle/!{s/\\[BlackTitle/\\[WhiteTitle \"\"\\],\\[BlackTitle/g}" $csv
sed -i "/BlackRatingDiff/!{s/\\[WhiteTitle/\\[BlackRatingDiff \"\"\\],\\[WhiteTitle/g}" $csv
sed -i "/WhiteRatingDiff/!{s/\\[BlackRatingDiff/\\[WhiteRatingDiff \"\"\\],\\[BlackRatingDiff/g}" $csv
echo "Formatting"
sed -i "s/\\[[^\"]*\(\"[^\"]*\"\)\\]/\1/g" $csv
sed -i '1i\"Event","Site","White","Black","Result","UTCDate","UTCTime","WhiteElo","BlackElo","WhiteRatingDiff","BlackRatingDiff","WhiteTitle","BlackTitle","TimeControl","Termination","Variant"' $csv
rm $pgn
echo "Done!"

