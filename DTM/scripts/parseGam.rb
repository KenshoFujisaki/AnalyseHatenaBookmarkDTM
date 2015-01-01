#!/usr/local/bin/ruby

#コマンドライン引数理解
if ARGV.size != 5
  print "usage: ruby #{__FILE__} [*-seq.dat filepath] [gam.dat filepath] [number_of_topics] [output_filename] [number_of_outputs]\n"
  print "e.g.:  ruby #{__FILE__} ./dtm_output/sample/dtm_input-seq.dat ./dtm_output/sample/lda-seq/gam.dat 50 ./dtm_output/sample/visualize/topic_propotion.dat 10\n"
  exit
end
seq_filename = ARGV[0].to_s
gam_filename = ARGV[1].to_s
number_of_topics = ARGV[2].to_i
output_filename = ARGV[3].to_s
number_of_outputs = ARGV[4].to_i

#*-seq.dat読み込み
seq_array = []
File.open(seq_filename, "r").each_with_index do |line, index|
  next if index == 0
  seq_array << line.to_i
end
number_of_docs = seq_array.inject(0){|e, sum| sum += e}
number_of_timesegs = seq_array.length

#gam.dat読み込み
#gam.datの構造
# topic1_doc1_propotion
# topic1_doc2_propotion
# ...
# topic1_docN_propotion # N==nuber_of_docs
# topic2_doc1_propotion
# topic2_doc2_propotion
# ...
# topic2_docN_propotion
# ...
# topicK_docN_propotion # K==number_of_topics
#gam_arrayの構造
# gam_array: [[topic1_doc1, topic1_doc2, ..., topic1_docN],
#             [topic2_doc1, topic2_doc2, ..., topic2_docN],
#             ...
#             [topicK_doc1, topicK_doc2, ..., topicK_docN]]
gam_array = []
topic_docs = []
File.open(gam_filename, "r").each_with_index do |line, index|
  topic_docs << line.chomp.to_f
  if index % number_of_docs == number_of_docs - 1 and index != 0
    gam_array << topic_docs
    topic_docs = []
  end
end
#読み込み妥当性確認
if gam_array.length != number_of_topics
  print "error: loading file error at #{gam_filename}.\n"
  exit 1
end
gam_array.each do |docs|
  if docs.length != number_of_docs
    print "error: loading file error at #{gam_filename}.\n"
    exit 1
  end
end

#各時刻区間についてトピック確率を集計
#topic_propotioni_array: [[topic1_timesegment1, ..., topic1_timesegmentT],
#                          [topic2_timesegment1, ..., topic2_timesegmentT],
#                         ...
#                         [topicK_timesegment1, ..., topicK_timesegmentT]]
topic_propotion_array = []
gam_array.each do |docs_of_the_topic|
  topic_propotions = []
  start_index = 0
  seq_array.each do |number_of_docs_of_the_timeseg|
    topic_propotions << docs_of_the_topic.slice(start_index, number_of_docs_of_the_timeseg).inject(0){|e,sum| sum += e}
    start_index += number_of_docs_of_the_timeseg
  end
  topic_propotion_array << topic_propotions
end
#正規化
topic_propotion_array_trans = topic_propotion_array.transpose
topic_propotion_array_trans.each do |topics_of_the_timesegment|
  sum_propotion = topics_of_the_timesegment.inject(0){|e,sum| sum += e}
  topics_of_the_timesegment.map!{|e| e / sum_propotion}
end
topic_propotion_array = topic_propotion_array_trans.transpose

#ソート
tmp = topic_propotion_array.each_with_index.sort{|a,b| b[0].max<=>a[0].max}
topic_propotion_array = tmp.map{|e| e[0]}

#妥当性確認
#[*0..(number_of_timesegs-1)].each do |timeseg|
#  p timeseg.to_s + ":" + (topic_propotion_array.map{|e| e[timeseg]}.inject(0){|e,sum| sum+=e}).to_s
#end

#出力
output_array = []
output_array << ["topic"] + [*1..(number_of_timesegs)].map{|i| "value_" + i.to_s}
topic_propotion_array.each_with_index do |propotions_of_the_topic, index|
  break if index == number_of_outputs
  output_array << [sprintf("%02d.topic%02d",index, tmp[index][1])] + propotions_of_the_topic.map{|e| e.to_s}
end

# 配列を転置
output_array = output_array.transpose

# 出力
File.open(output_filename, "w") do |file| 
  file.puts(output_array.map{|e| e.join(" ")}.join("\n"))
end
