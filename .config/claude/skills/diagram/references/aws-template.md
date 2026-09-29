# テンプレート

Mermaid の `flowchart LR` で AWS の構成図を書くときに写すテンプレート。

## image-node 拡張の一般形

アイコンのノードはすべてこの形で定義する。`img` と `label` は必須。

```text
nodeID@{
  img: "<image URL>",
  label: "<text label, <br> for line break>",
  pos: "t" | "b",
  w: <width px>,
  h: <height px>,
  constraint: "on" | "off"
}
```

| プロパティ   | 用途                               |
| ------------ | ---------------------------------- |
| `img`        | SVG アイコンの URL (Iconify など)  |
| `label`      | ノードに出すテキスト               |
| `pos`        | ラベルの位置 (`t` は上、`b` は下)  |
| `w`, `h`     | アイコンの幅と高さ (px)            |
| `constraint` | レイアウトの制約 (`on` で制約する) |

## 最小の例

```mermaid
---
title: Sample AWS architecture
config:
  theme: neutral
  flowchart:
    nodeSpacing: 10
    rankSpacing: 30
---
flowchart LR

browser@{img: "https://api.iconify.design/material-symbols/globe-asia.svg", label: "Browser", pos: "b", w: 60, h: 60, constraint: "on"}

subgraph aws["AWS account"]
  cf@{img: "https://api.iconify.design/logos/aws-cloudfront.svg", label: "CloudFront", pos: "b", w: 60, h: 60, constraint: "on"}
  s3@{img: "https://api.iconify.design/logos/aws-s3.svg", label: "S3<br>SPA bucket", pos: "b", w: 60, h: 60, constraint: "on"}
  alb@{img: "https://api.iconify.design/logos/aws-elb.svg", label: "Internal ALB", pos: "b", w: 60, h: 60, constraint: "on"}
  ecs@{img: "https://api.iconify.design/logos/aws-ecs.svg", label: "ECS Fargate", pos: "b", w: 60, h: 60, constraint: "on"}
  rds@{img: "https://api.iconify.design/logos/aws-rds.svg", label: "Aurora PG", pos: "b", w: 60, h: 60, constraint: "on"}
end

browser ----|"HTTPS"| cf
cf --- s3
cf --- alb
alb --- ecs
ecs --- rds

classDef default fill:#fff
style aws fill:#fff,color:#345,stroke:#345
```

## subgraph の入れ子と、見えない配置の補助

アカウント、リージョン、VPC、外部の境界を入れ子の `subgraph` で表し、
ラベルが空の見えない subgraph と見えない辺 `~~~` を組み合わせて配置を整える。

```mermaid
---
title: AWS architecture (nested subgraphs + invisible layout)
config:
  theme: neutral
  flowchart:
    nodeSpacing: 10
    rankSpacing: 30
---
flowchart LR

browser@{img: "https://api.iconify.design/material-symbols/globe-asia.svg", label: "Browser", pos: "b", w: 60, h: 60, constraint: "on"}

subgraph aws["AWS account"]
  subgraph g-cdn[" "]
    cf-spa@{img: "https://api.iconify.design/logos/aws-cloudfront.svg", label: "CloudFront<br>SPA", pos: "b", w: 60, h: 60, constraint: "on"}
    cf-img@{img: "https://api.iconify.design/logos/aws-cloudfront.svg", label: "CloudFront<br>images", pos: "b", w: 60, h: 60, constraint: "on"}
  end

  subgraph vpc["VPC (ap-northeast-1)"]
    alb@{img: "https://api.iconify.design/logos/aws-elb.svg", label: "Internal ALB", pos: "b", w: 60, h: 60, constraint: "on"}
    ecs@{img: "https://api.iconify.design/logos/aws-ecs.svg", label: "ECS Fargate", pos: "b", w: 60, h: 60, constraint: "on"}
    aurora@{img: "https://api.iconify.design/logos/aws-aurora.svg", label: "Aurora PG", pos: "b", w: 60, h: 60, constraint: "on"}
  end

  subgraph g-aux[" "]
    dynamodb@{img: "https://api.iconify.design/logos/aws-dynamodb.svg", label: "DynamoDB", pos: "b", w: 60, h: 60, constraint: "on"}
    kms@{img: "https://api.iconify.design/logos/aws-kms.svg", label: "KMS", pos: "b", w: 60, h: 60, constraint: "on"}
  end
end

browser ----|"HTTPS"| cf-spa
cf-spa --- alb
alb --- ecs
ecs --- aurora
ecs --- dynamodb
ecs --- kms

g-cdn ~~~ vpc ~~~ g-aux

classDef default fill:#fff
classDef group fill:none,stroke:none
class g-cdn,g-aux group
style aws fill:#fff,color:#345,stroke:#345
style vpc fill:#fff,color:#0a0,stroke:#0a0
```

## 辺の書き方

| 書き方                | 意味            | 使う場面                                                   |
| --------------------- | --------------- | ---------------------------------------------------------- |
| `A --- B`             | 同期の呼び出し  | 既定                                                       |
| `A ----\|"label"\| B` | ラベル付きの辺  | ホスト名、パス、プロトコルを辺に書きたいとき               |
| `A -.-> B`            | 点線 (向きあり) | 非同期、設定の参照、OIDC、帯域外の流れ                     |
| `A ~~~ B`             | 見えない辺      | 配置のためだけに使う (subgraph 同士の縦の並びを決めるなど) |

辺の長さはダッシュの数で決まる。

- `-` 短い
- `---` 中くらい
- `-----` 長い (subgraph の間の辺にラベルを付けるときは、ラベルが収まるよう長い辺にする)

## コンソールへの click

```text
click nodeID href "<URL>" _blank
```

## スタイル

```text
classDef default fill:#fff
classDef group fill:none,stroke:none
style <subgraphID> fill:#fff,color:#345,stroke:#345
style <subgraphID> fill:#fff,color:#0a0,stroke:#0a0       %% green-ish for VPC
style <subgraphID> fill:#fff,color:#888,stroke:#888       %% grey for external services
style <subgraphID> fill:#fff8c4,color:#a80,stroke:#a80,stroke-width:2px  %% diff highlight
class <id1>,<id2> group                                    %% remove frame on empty-label subgraphs
```

## 比較図 (before/after、案 A と案 B)

比較を読みやすくするために、次のようにする。

1. 両方の図で同じノード ID と配置を使い回し、読み手の視線が同じ場所に落ちるようにする
2. 差分のノードだけを `classDef diff` (淡い黄色の塗りとオレンジの枠) で目立たせる
3. 図のすぐ後に比較表を置く

```mermaid
---
title: Option B (diff-highlighted)
config:
  theme: neutral
  flowchart:
    nodeSpacing: 10
    rankSpacing: 30
---
flowchart LR

browser@{img: "https://api.iconify.design/material-symbols/globe-asia.svg", label: "Browser", pos: "b", w: 60, h: 60, constraint: "on"}

subgraph aws["AWS account"]
  alb@{img: "https://api.iconify.design/logos/aws-elb.svg", label: "ALB", pos: "b", w: 60, h: 60, constraint: "on"}
  ecs@{img: "https://api.iconify.design/logos/aws-ecs.svg", label: "ECS Fargate", pos: "b", w: 60, h: 60, constraint: "on"}
  subgraph batch["Batch"]
    ec2@{img: "https://api.iconify.design/logos/aws-ec2.svg", label: "EC2 worker", pos: "b", w: 60, h: 60, constraint: "on"}
  end
end

browser ----|"HTTPS"| alb
alb --- ecs
ecs --- ec2

classDef default fill:#fff
style aws fill:#fff,color:#345,stroke:#345

%% A changed node: classDef diff + class
classDef diff fill:#fff8c4,stroke:#a80,stroke-width:2px
class ecs diff
%% A whole added subgraph: style
style batch fill:#fff8c4,color:#a80,stroke:#a80,stroke-width:2px
```
