#!/bin/sh

# コマンドライン引数理解
if [ $# -ne 4 ] ; then
  printf "usage: $0 [dtm_output_name] [number_of_topics] [number_of_top_terms] [number_of_top_topics]\n"
  printf "e.g.:  $0 ./dtm_output/sample 50 30 50\n"
  exit 1
fi
dtm_output_name=$1
number_of_topics=$2
number_of_top_terms=$3
number_of_top_topics=$4

# 可視化結果のディレクトリ生成
mkdir -p ${dtm_output_name}/visualize

# トピック割合について処理
echo "> plot the transition of topic propotion."
ruby ./scripts/parseGam.rb \
  ${dtm_output_name}/dtm_input-seq.dat \
  ${dtm_output_name}/lda-seq/gam.dat \
  $number_of_topics \
  ${dtm_output_name}/visualize/topic_propotion.dat \
  $number_of_top_topics
if [ $? -ne 0 ]; then
  echo "error at ./scripts/parseGam.rb"
  exit 1
fi
number_of_time_seqs=`head -1 ${dtm_output_name}/dtm_input-seq.dat`
Rscript ./scripts/plotTopicPropotion.R \
  ${dtm_output_name}/visualize/topic_propotion.dat \
  ${dtm_output_name}/dtm_input-date.dat \
  $number_of_time_seqs \
  $number_of_top_topics \
  ${dtm_output_name}/visualize/topic_propotion.pdf
if [ $? -ne 0 ]; then
  echo "error at ./scripts/plotTopicPropotion.R"
  exit 1
fi

# 各トピックについて処理
echo "> plot the transition of term propotion at each topics."
for((i=0; i<$number_of_topics; i++)); do
  printf "topic:$i\n"
  ruby ./scripts/loadResult_then_getTopTerms.rb \
    ${dtm_output_name}/lda-seq/ \
    $i \
    $number_of_time_seqs \
    $number_of_top_terms \
    ${dtm_output_name}/visualize/`printf "topic%03d_topTerm.dat" $i`
  if [ $? -ne 0 ]; then
    echo "error at ./scripts/loadResult_then_getTopTerms.rb"
    exit 1
  fi
  Rscript ./scripts/plotEachTopicTermPropotion.R \
    ${dtm_output_name}/visualize/`printf "topic%03d_topTerm.dat" $i` \
    ${dtm_output_name}/dtm_input-date.dat \
    $number_of_time_seqs \
    $number_of_top_terms \
    ${dtm_output_name}/visualize/`printf "topic%03d_topTerm.pdf" $i`
  if [ $? -ne 0 ]; then
    echo "error at ./scripts/plotEachTopicTermPropotion.R"
    exit 1
  fi
done

echo "> finished!!"
