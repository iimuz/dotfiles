---
name: sample-greeting
description: plugin の配線を確かめる sample の skill。ユーザーが sample greeting の実行か、sample plugin の確認を求めたときに使う。
---

# sample-greeting

この skill は、ローカルで開発した plugin が正しく読み込まれることを確かめるためだけにある。

呼ばれたら、`sample` plugin の skill が読み込まれたことを短く確認して返し (マーカーの文字列
`SAMPLE-PLUGIN-SKILL-OK` を含める)、そこで止まる。
