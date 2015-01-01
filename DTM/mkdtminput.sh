#!/bin/sh

# 引数理解
if [ $# -ne 4 ]; then
  echo "usage: $0 [from_date] [to_date] [interval_month] [dtm_input_name]"
  echo "i.g.:  $0 2008-04-01 2014-05-01 3 ./dtm_input/sample"
  exit 1
fi
from_date=$1
to_date=$2
interval_month=$3
dtm_input_name=$4

# 書き出しディレクトリの生成
mkdir ./dtm_input

# *-seq.datファイルの書き出し
echo "making ${dtm_input_name}-seq.dat and ${dtm_input_name}-date.dat is started."
./scripts/mkdtminput_seq.sh $from_date $to_date $interval_month ${dtm_input_name}-date.dat > "${dtm_input_name}-seq.dat"
if [ $? -ne 0 ]; then
  echo "error at ./mkdtminput_seq.sh"
  exit 1
fi
echo "making ${dtm_input_name}-seq.dat and ${dtm_input_name}-date.dat is finished."

# *-mult.datファイルの書き出し
echo "making ${dtm_input_name}-mult.dat is started."
./scripts/mkdtminput_mult.sh $from_date $to_date > "${dtm_input_name}-mult.dat"
if [ $? -ne 0 ]; then
  echo "error at ./mkdtminput_mult.sh"
  exit 1
fi
echo "making ${dtm_input_name}-mult.dat is finished."

echo "finished!!"
