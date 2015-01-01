#!/bin/R

# ライブラリ
library(ggplot2)
library(scales)
library(bursts)

# 引数理解
args <- commandArgs(trailingOnly = TRUE)
if (length(args) !=5 ) {
  print("usage: Rscript plot.R [input_filename] [date_filename] [number_of_time_seqs] [number_of_series] [output_filename]")
  print("i.g.:  Rscript plot.R input.dat date.dat 22 30 output.pdf")
  quit()
}
input_filename <- args[1]
date_filename <- args[2]
number_of_time_seqs <- as.numeric(args[3])
number_of_series <- as.numeric(args[4])
output_filename <- args[5]

# ファイル読み込み
load_data <- read.table(input_filename, header=TRUE, row.names=1)
date_data <- read.csv(date_filename, header=TRUE)

# 日時データ変換
date_data$yearmonthday <- as.Date(date_data$yearmonthday, "%Y/%m/%d")

# 累積関数
accum <- function(vec) {
  ret <- c(vec[1])
  for (i in vec[2:length(vec)]) {
    ret <- c(ret, i + ret[length(ret)])
  }
  return(ret)
}

# 描画のためのデータ変換
# 詳細はこちらを参照： http://d.hatena.ne.jp/teramonagi/20120728/1343442608
x <- date_data$yearmonthday
y <- matrix(as.matrix(load_data), nrow=number_of_time_seqs, ncol=number_of_series)
bursts <- array()
for(topic_id in 1:number_of_series) {
  y[,topic_id] <- accum(y[,topic_id])
}
data.plotted <- data.frame(Date=rep(x,ncol(y)), Value=as.numeric(y), Series=rep(colnames(load_data), each=nrow(y)))

# グラフ描画
p <- ggplot(data.plotted, aes(Date, Value, group=Series)) + 
  geom_line(aes(colour = Series)) + 
  scale_x_date(labels = date_format("%Y")) + 
  xlab("Date") + 
  ylab("Propotion")
ggsave(output_filename, p, family="Japan1GothicBBB", width = 16, height = 9)
