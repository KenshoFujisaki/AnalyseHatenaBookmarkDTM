AnalyseHatenaBookmarkDTM
========================

[はてブ記事を用いた興味分析](http://d.hatena.ne.jp/ni66ling/20141223/1419323806 "はてブ記事を用いた興味分析")の
DTMによるトピック解析のためのスクリプトです．  
事前に[データの準備](https://github.com/KenshoFujisaki/CreateHatenaBookmarkLogDB "データ準備")が完了していることを前提とします．

本スクリプトにより，これまでに自身が登録したはてブについて，以下のような時系列トピック解析結果を出力できます．
+ トピック割合の時系列推移(積み上げ)．対象トピックに対する興味の盛衰と興味の累積を確認できます．
    ![DTMによるはてブのトピック解析結果](http://f.st-hatena.com/images/fotolife/n/ni66ling/20150125/20150125160625.png)
+ トピック内における語彙割合の時系列推移．対象トピックに対する興味の変化を確認できます．
    ![DTMによるはてブのトピック解析結果](http://f.st-hatena.com/images/fotolife/n/ni66ling/20150125/20150125160624.png)  

## 事前準備
MacOSX環境を前提に説明します．

1. 解析対象のはてブ記事群のデータ準備
[データの準備](https://github.com/KenshoFujisaki/CreateHatenaBookmarkLogDB "データ準備")に従って，はてブ記事群をMySQLに登録します．

2. DTMのインストール
[David M. Blei](http://www.cs.princeton.edu/~blei/topicmodeling.html "David M. Blei")の"Topic modeling software"から"dtm"をダウンロードし，バイナリを「./DTM/main」となるように配置します．具体的には次のような手順を行います．
    ```sh
    $ wget https://princeton-statistical-learning.googlecode.com/files/dtm_release-0.8.tgz
    $ tar xvf dtm_release-0.8.tgz
    $ cd dtm_release/dtm
    $ brew install gsl
    $ make
    $ cp main ../../
    $ cd ../../
    $ rm -Rf dtm_release*
    ```

3. R, Rパッケージ("ggplot2", "bursts")のインストール
    ```sh
    $ brew install R
    $ R
    > install.packages("ggplot2")
    > install.packages("bursts")
    > quit()
    ```

## 使い方
1. DTMの入力ファイルの作成
    ```sh
    $ cd ./DTM
    $ ./mkdtminput.sh [from_date] [to_date] [interval_month] [dtm_input_name]
    ```
    + [from_date]と[to_date]には，それぞれ解析対象の開始日と終了日を指定します．例えば，[from_date]に「2008-04-01」を，[to_date]に「2015-01-01」を指定すると，2008-04-01から2015-01-01までのはてブを対象に解析します．  
    + [interval_month]には，時間窓の幅を月で指定します．例えば，「3」を指定すると，3ヶ月区切り(2008-04-01~2008-06-30, 2008-07-01~2008-09-30, 2008-10-01~2008-12-31,...)で解析します．  
    + [dtm_input_name]には，DTM入力名（=mkdtminput.shにおける出力名）を指定します．例えば，「./dtm_input/sample」など．  
    + 例えば，`$ ./mkdtminput.sh 2010-04-01 2015-01-01 3 ./dtm_input/sample3`のように実行します．

2. DTMの実行
    ```sh
    $ cd ./DTM
    $ ./dtm.sh [dtm_input_name] [dtm_output_name] [number_of_topics]
    ```
    + [dtm_input_name]には，1.で作成したDTM入力名を指定します．例えば「./dtm_input/sample」など．  
    + [dtm_output_name]には，DTM出力名を指定します．例えば「./dtm_output/sample」など．  
    + [number_of_topics]には，トピック数を指定します．例えば，「50」など．  
    + 例えば，`$ ./dtm.sh ./dtm_input/sample ./dtm_output/sample 50`のように実行します．

3. DTMの実行結果の可視化
   ```sh
   $ cd ./DTM
   $ ./parseresult.sh [dtm_output_name] [number_of_topics] [number_of_top_terms] [number_of_top_topics]
   ```
   + [dtm_output_name]には，2.のDTM出力名を指定します．例えば「./dtm_output/sample」など．  
   + [number_of_top_topics]には，2.のトピック数を指定します．例えば，「50」など．  
   + [number_of_top_terms]には，出力する上位の語彙数を指定します．例えば，「30」など．  
   + [number_of_top_topics]には，出力する上位のトピック数を指定します．これは[number_of_topics]以下の値にする必要があります．例えば，「40」など．  
   + 例えば，`$ ./parseresult.sh ./dtm_output/sample 50 30 40`のように実行します．  
   + 結果は「./DTM/[dtm_output_name]/visualize/」に出力されます．出力ファイルは以下の2種類があります．本READMEのはじめの画像がこれに当たります．  
       + topic_propotion.pdf : トピック割合の時系列推移(積み上げグラフ)．対象トピックに対する興味の盛衰と興味の累積を確認できます．
       + topic[トピック番号]_topTerm.pdf : トピック内における語彙割合の時系列推移．対象トピックに対する興味の変化を確認できます．
