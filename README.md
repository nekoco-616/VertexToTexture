# VertexToTexture

## 概要

頂点情報をテクスチャに格納するBlenderスクリプト

テクスチャから頂点情報を読み出し、変形するジオメトリシェーダー

## VertexToTexture.py

![image](https://github.com/nekoco-616/VertexToTexture/assets/72448021/ccdd5d05-8406-404b-9d74-1ece341ed87f)
*UV修正*


![image](https://github.com/nekoco-616/VertexToTexture/assets/72448021/01813d83-020e-438f-b9af-a2cec2fa7467)
*テクスチャ出力*


頂点情報をテクスチャに格納するBlenderスクリプトです。

情報を格納するにあたりUVも修正されます。　(テクスチャ作成とUV修正は別スクリプトでも良かったかもしれません)

### 使用方法

Blenderにてスクリプトを作成します。

オブジェクトモードで対象オブジェクトを選択したままスクリプトを実行してください。


TextureResolutionを変えることで、保存できるポリゴン数を変えることができます。

TextureModeを切り替えることでテクスチャの作成、修正か選択できます。

| TextureMode | 内容 |
|:-----------:|:------------:|
| Create | テクスチャを新規作成 |
| それ以外 | 指定テクスチャを上書き |

### 注意点

対象オブジェクトのポリゴンはすべて三角形に変換してください。

## TextureToVertex.shader

![image](https://github.com/nekoco-616/VertexToTexture/assets/72448021/85638f8b-20e6-43d8-92f9-3b741c340d2c)

テクスチャから頂点情報を読み出し、変形するジオメトリシェーダーです。

上記のスクリプトでUVが修正された、十分にポリゴン数の多いモデルを用いることで、テクスチャ情報の通りに変形されます。

### 使用方法

Unityにてシェーダーを追加します。

マテリアルに適応し、テクスチャと解像度を指定してください。

### 注意点

テクスチャ設定を下記の通りにしないと正常に読み込めません。
- sRGB(Color Texture)のチェックを外す
- FormatをRGBA 32bitに変更


## 連絡先

[twitter](https://twitter.com/nekoco_vrc)

## ライセンス

These codes are licensed under CC0.

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png "CC0")](http://creativecommons.org/publicdomain/zero/1.0/deed.ja)
