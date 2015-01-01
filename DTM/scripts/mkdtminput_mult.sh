#!/bin/sh

# 引数理解
if [ $# -ne 2 ]; then
  echo "usage: $0 [from_date] [to_date]"
  echo "i.g.:  $0 2008-04-01 2014-05-01"
  exit 1
fi
from=$1
to=$2

# グローバル変数書き換え
# 以降のSQL文にて，group_concatの返却文字列長上限がネックになるため．
mysql -A -N -uhatena -phatena -e "set global group_concat_max_len=100000;"

# 下記のような形式で標準出力
# number_of_morphemes morpheme_id:morpheme_count morpheme_id:morpheme_count ... 
mysql -A -N -uhatena -phatena -Dhatena_bookmark -e "
  SELECT 
    concat(
      count(*), 
      ' ', 
      group_concat(
        concat(url_morpheme.morpheme_id, ':', url_morpheme.morpheme_count) 
        separator ' '
      )
    ) 
  FROM url_morpheme 
    LEFT JOIN url ON url_morpheme.url_id = url.id 
  WHERE url.update_date BETWEEN '$from' AND '$to' 
    AND NOT EXISTS (SELECT 1 FROM stoplist WHERE stoplist.morpheme_id = url_morpheme.morpheme_id) 
  GROUP BY url.id 
  ORDER BY url.id DESC;"
