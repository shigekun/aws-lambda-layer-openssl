# aws-lambda-layer-openssl

## 経緯

AWS Lambdaの`nodejs 8.10`で`openssl`コマンドを使っていたの。

そしたら、2019年末で終了するというので`10.x`か`12.x`に変更。

が、しかし、opensslコマンドが使えなくって、、、

Layerとやらを追加して使う事が分かり、

このへん <https://dev.classmethod.jp/cloud/aws/lambda-runtime-update-ami-201803/>

を見ると

```note
arn:aws:lambda:::awslayer:AmazonLinux1803
```

が使えるらしいんだけどエラーが出て使えなかったので、自作するのがこれ

## 参考

<https://stackoverflow.com/a/58589105/5324137>

## nodejs 10.x

```sh
docker run -it -v `pwd`:/opt/layer lambci/lambda:build-nodejs10.x /opt/layer/create-openssl-zip.sh \
 && mv lambda-openssl-layer.zip lambda-openssl-layer-nodejs10.zip
```

## nodejs 12.x

```sh
docker run -it -v `pwd`:/opt/layer lambci/lambda:build-nodejs12.x /opt/layer/create-openssl-zip.sh \
 && mv lambda-openssl-layer.zip lambda-openssl-layer-nodejs12.zip
```

## environment

使用する関数の環境変数にこれを追加

```note
LD_LIBRARY_PATH=/opt/nodejs/openssl/lib
```

## Usage

パスが通っていないので `/opt/nodejs/openssl/bin/openssl` で。

## example

```sh
'use strict';

var request = require('request');
var _ = require('underscore');

exports.handler = (event, context, callback) => {
    const execSync = require('child_process').execSync;
    const res = execSync('/opt/nodejs/openssl/bin/openssl version');
    console.log(res.toString());
}
```

SSL証明書の有効期限をチェックするやつ

```nodejs
            var exec = require('child_process').exec;
            // execするコマンド
            var cmd = "/opt/nodejs/openssl/bin/openssl s_client -connect " + domain + ":443 -servername " + domain + " < /dev/null 2> /dev/null | /opt/nodejs/openssl/bin/openssl x509 -text | grep Not | sed -e 's/^  *//g' | sed -e 's/Not.*:\ //g'";
            // 日付の差分を取得するために実行するときの日付が必要
            var today = new Date();
            var dayName = 'SunMonTueWedThuFriSat'.substr(today.getDay() * 3, 3);

            exec(cmd, function(error, stdout, stderr) {
                if (!error) {
                    var results = stdout.split("\n");
                    // 期限期限のデータを取得
                    var date = new Date(results[1]);
                    // 日付の差分がミリ秒で取得できるので差分にする
                    var diffDays = Math.floor((date - today) / 1000 / 3600 / 24);
                    console.log(domain+' : '+'残り' + diffDays + '日！'+date.toString());
                    var message = '';
                    if (diffDays < 3) {
                        message = domain + 'の証明書期限が残り' + diffDays + '日しかないよ！';
                    } else if (diffDays < 7) {
                        message = domain + 'の証明書期限が残り' + diffDays + '日しかないよ！あと一週間！';
                    } else if (diffDays < 15) {
                        message = domain + 'の証明書期限が残り' + diffDays + '日しかないよ！そろそろ更新準備！';
                    } else {
                        if ( dayName == "Mon" ) {
                            message = domain + 'の証明書期限が'+diffDays+'日あります。';
                            console.log(message);
                        }
                    }
                    console.log(message);
                    return resolve(message);
                } else {
                    console.log(error);
                    console.log(stdout.split("\n"));
                    console.log(stderr);
                    return reject('reject');
                }
            });
```
