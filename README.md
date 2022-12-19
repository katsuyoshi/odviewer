# ODVIEWER

ODVIEWERはオープンデータのビューアーです。

Herokuで公開しています。  
https://odviewer.herokuapp.com


現在対応しているのは以下のデータです。  
秋田県内のデータを中心に取り入れていきたいと考えています。  

- [秋田県秋田市が公開しているオープンデータ](https://www.city.akita.lg.jp/opendata/)
- [秋田県大仙市が公開しているオープンデータ](https://www.city.daisen.lg.jp/categories/zokusei/opendatedoc/)

オープンデータの収集は[dim](https://github.com/c-3lab/dim)というオープンデータパッケージマネージャを使っています。  
[dim.json](/dim.json)にデータのダウンロード先を登録しdimコマンドを実行すると[data_files](/data_files)以下にダウンロードしてくれる優れたツールです。  

ODVIEWERはこうしてダウンロードしたデータをテーブル形式やグラフ、地図として視覚化しています。

テーブル表示

![テーブル形式での表示](https://i.gyazo.com/538f6e8bfde7dad6b7b377656bd858a7.png)

グラフ表示  
※ 財源区分と歳入項目の様に2項目で分類するグラフは未対応です。

![グラフ表示](https://i.gyazo.com/8ab0e30f0816eace60217ea30214da8b.png)

地図表示

![地図表示](https://i.gyazo.com/422d864d48cfa331d881e971be526d02.jpg)

# アプリ起動手順

アプリを起動するにはRubyが実行できる環境が必要です。Rubyのインストールなどは公式サイトなどを参照してください。

https://www.ruby-lang.org/ja/

以下のコマンドで必要な gem をインストールします。

```
% bundle instal
```

rackupコマンドでアプリを起動します。  

```
% rackup                                
Puma starting in single mode...
* Puma version: 6.0.0 (ruby 2.7.6-p219) ("Sunflower")
*  Min threads: 0
*  Max threads: 5
*  Environment: development
*          PID: 88103
* Listening on http://127.0.0.1:9292
* Listening on http://[::1]:9292
Use Ctrl-C to stop
```

Listening onで表示されるアドレス(この場合 http://127.0.0.1:9292)にWeb Browserでアクセスすると動作確認できます。


# データ更新

データの更新は dim コマンドで行っています。

dim コマンドのインストールは作者の方が qiita に記事を書いていますのでそちらをご覧ください。

[そろそろオープンデータを無秩序に管理するのは卒業したいので📦データを管理するパッケージマネージャを開発した【ツール開発】](https://qiita.com/ryo-ma/items/0505f7790ad2b12bcdc2)


データ更新は```rake```コマンドで行います。  
以下で全データが最新のデータに更新されます。  

```
% rake data:reload_all
```


# あなたの市町村に対応するには

dim.jsonファイルをあなたの市町村のオープンデータに合わせて書き換えるとあなたの市町村のオープンデータビューアーになります。  

大仙市の場合は[mkdimjson.rb](/scripts/mkdimjson.rb)ファイルで[秋田県大仙市が公開しているオープンデータ](https://www.city.daisen.lg.jp/categories/zokusei/opendatedoc/)から収集してdim.jsonファイルに書き込む様にしていますので参考にしてください。

グラフ表示する項目は力技でやっていますので、適用するには変更が必要になるかもしれません。
