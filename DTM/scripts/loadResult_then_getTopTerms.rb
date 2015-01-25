#!/bin/ruby

#引数理解
if ARGV.size != 5
  print "usage: ruby #{__FILE__} [*-var-e-log-prob.dat dirname] [topic_id] [number_of_time_seqs] [number_of_outputs] [output_filename]\n"
  print "e.g.:  ruby #{__FILE__} ./dtm_output/sample/lda-seq 4 22 100 output.dat\n"
  exit
end
input_dirname = ARGV[0].to_s
topic_id = ARGV[1].to_i
number_of_times = ARGV[2].to_i # 入力の*-seq.datの行数-1であることに注意
number_of_outputs = ARGV[3].to_i
output_filename = ARGV[4]

#ファイル読み込み
filename = input_dirname + "/topic-" + sprintf("%03d", topic_id) + "-var-e-log-prob.dat"
value_array = []
line_counter = 0
term_times = []
File.open(filename, "r").each do |line|
  term_times = [] if line_counter % number_of_times == 0
  term_times << line.to_f
  value_array << term_times if line_counter % number_of_times == number_of_times - 1
  line_counter += 1
end

#読み込み妥当性確認
#value_array: [[term0_time1_propotion, term0_time2_propotion, ..., term0_timeT_propotion],
#              [term1_time1_propotion, term1_time2_propotion, ..., term1_timeT_propotion],
#              ...
#              [termN_time1_propotion, termN_time2_propotion, ..., termN_timeT_propotion]]
value_array.each do |value_line|
  if value_line.length != number_of_times
    print "error: loading file error at #{filename}.\n"
    exit 1
  end
end

#先頭要素の除外
# value_arrayはterm_idが0から開始となっている．
# しかし，mysqlで管理しているterm_idは1から開始している．
# したがって，value_arrayの0番要素は除外する必要がある．
value_array = value_array.drop(1)

#ソート
# 各行について（各termについて），対時刻最大値を取得
# [[5, 0.05], [1, 0.03], [10, 0.007]] # [term_id, 対時刻最大値]
# i+1:term_id, e:term_idにおける[time1_propotion, time2_propotion, ..., timeT_propotion]
termId_maxValue = value_array.each_with_index.map{|e,i| [i+1,e.max]}.sort{|a,b| b[1]<=>a[1]}

#出力
output_array = []
output_array << ["term"] + [*1..(number_of_times)].map{|i| "value_" + i.to_s}
termId_maxValue.each_with_index do |termId_propotion, index|
  break if index == number_of_outputs
  term_id = termId_propotion[0]
  propotion = Math.exp(termId_propotion[1])
  term = `mysql -A -N -uhatena -phatena -Dhatena_bookmark -e "select name from morpheme where id = #{term_id}" 2>/dev/null`.chomp.gsub(" ","_")
  print "topic:#{topic_id} -> ##{index+1} term:#{term}:#{term_id} value:#{propotion}\n"
  output_array << [sprintf("%03d",index+1) + "_" + term] + value_array[term_id-1].map{|e| Math.exp(e).to_s}
end

# 配列を転置
output_array = output_array.transpose

# 出力
File.open(output_filename, "w") do |file| 
  file.puts(output_array.map{|e| e.join(" ")}.join("\n"))
end
