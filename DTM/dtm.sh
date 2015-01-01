#!/bin/sh

# 引数理解
if [ $# -ne 3 ]; then
  echo "usage: $0 [dtm_input_name] [dtm_output_name] [number_of_topics]"
  echo "i.g.:  $0 ./dtm_input/sample ./dtm_output/sample 50"
  exit 1
fi
dtm_input_name=$1
dtm_output_name=$2
nof_topics=$3

# 入力ファイルのコピー
mkdir -p ${dtm_output_name}
cp ${dtm_input_name}-mult.dat ${dtm_output_name}/dtm_input-mult.dat
cp ${dtm_input_name}-seq.dat ${dtm_output_name}/dtm_input-seq.dat
cp ${dtm_input_name}-date.dat ${dtm_output_name}/dtm_input-date.dat

# DTM実行
# ただし，本shを実行する前に，mkdtminput.shを実行し，
# 入力データ(${dtm_input_name}-seq.dat,${dtm_input_name}-mult.dat)を
# 準備しておくこと．
./main \
  --ntopics=$nof_topics \
  --mode=fit \
  --rng_seed=0 \
  --initialize_lda=true \
  --corpus_prefix=$dtm_input_name \
  --outname=$dtm_output_name \
  --top_chain_var=0.005 \
  --alpha=0.01 \
  --lda_sequence_min_iter=6 \
  --lda_sequence_max_iter=20 \
  --lda_max_em_iter=10
