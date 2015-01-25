#!/bin/sh

#引数理解
if [ $# -ne 4 ]; then
  echo "usage: $0 [from_date] [to_date] [interval_month] [date_filename]"
  echo "i.g.:  $0 2008-04-01 2014-05-01 3 ./date.dat"
  exit 1
fi
from_date=$1
to_date=$2
interval_month=$3
date_filename=$4

#開始時刻，終了時刻のymd分解
from_date_ymd=(`ruby -e 'puts "'$from_date'".split("-").join(" ")'`)
to_date_ymd=(`ruby -e 'puts "'$to_date'".split("-").join(" ")'`)
diff_month_max=$(( (${to_date_ymd[0]} - ${from_date_ymd[0]}) * 12 + (${to_date_ymd[1]} - ${from_date_ymd[1]}) ))

#時刻区間数の書き出し
number_of_timestamps=$(( $diff_month_max / $interval_month ))
if [ $(( $diff_month_max % $interval_month )) -ne 0 ]; then
  number_of_timestamps=$(( $number_of_timestamps + 1 ))
fi
echo "$number_of_timestamps"

#各時刻区間における文書数を出力
echo "yearmonthday" > $date_filename
for ((diff_m=0; diff_m<$diff_month_max; diff_m += $interval_month)); do

  #時刻区間の算出
  from="$(( ${from_date_ymd[0]} + (${from_date_ymd[1]} + $diff_m) / 12 ))-$(( (${from_date_ymd[1]} + $diff_m) % 12 ))-$(( ${from_date_ymd[2]})) 00:00:00" 
  to="$(( ${from_date_ymd[0]} + (${from_date_ymd[1]} + $diff_m + $interval_month) / 12 ))-$(( (${from_date_ymd[1]} + $diff_m + $interval_month) % 12 ))-${from_date_ymd[2]} 00:00:00"

  #時刻の書き出し
  if [ `date -j -f "%Y-%m-%d %T" "$to" +%s` -gt `date -j -f "%Y-%m-%d %T" "$to_date 00:00:00" +%s` ]; then
    to=$to_date
  fi
  echo "${from//\-//}-${to//\-//}" >> $date_filename

  #文書数の取得
  mysql -A -N -uhatena -phatena -Dhatena_bookmark -e "
    # group_concatの上限値を引き上げ
    # ref: http://blog.katty.in/3915
    SET group_concat_max_len = 10000000;

    # データの取得
    SELECT url.id 
    FROM url_morpheme 
      LEFT JOIN url ON url_morpheme.url_id = url.id 
      LEFT JOIN morpheme ON url_morpheme.morpheme_id = morpheme.id 
    WHERE url.update_date BETWEEN '$from' AND '$to' 
      AND NOT url.update_date = '$to'
      AND NOT EXISTS (SELECT 1 FROM stoplist WHERE stoplist.morpheme_id = url_morpheme.morpheme_id) 
    GROUP BY url.id;" 2> /dev/null | \
  wc -l | awk '{print $1}'
done
