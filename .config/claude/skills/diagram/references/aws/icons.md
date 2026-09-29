# Iconify のアイコン一覧

AWS と他社のアイコンの URL。Mermaid の image-node 拡張の `img` にそのまま入れる。

## URL の形

- AWS: `https://api.iconify.design/logos/aws-<service>.svg`
- 他社のベンダー: `https://api.iconify.design/logos/<vendor>.svg` (例: `logos/auth0-icon`)
- 抽象的な記号: `https://api.iconify.design/material-symbols/<name>.svg`

迷ったら [Icônes](https://icones.js.org/) の `SVG Logos` コレクションを検索する。

## AWS サービス (確認済み)

| サービス      | URL                                            |
| ------------- | ---------------------------------------------- |
| ELB / ALB     | `https://api.iconify.design/logos/aws-elb.svg` |
| EC2           | `https://api.iconify.design/logos/aws-ec2.svg` |
| ECS / Fargate | `https://api.iconify.design/logos/aws-ecs.svg` |
| RDS / Aurora  | `https://api.iconify.design/logos/aws-rds.svg` |
| S3            | `https://api.iconify.design/logos/aws-s3.svg`  |

## AWS サービス (未確認)

Iconify の `logos` コレクションの命名に沿った名前。
使う前に `https://icones.js.org/collection/logos?s=aws` を検索して確かめる。

| サービス              | 候補の URL                                                     |
| --------------------- | -------------------------------------------------------------- |
| CloudFront            | `https://api.iconify.design/logos/aws-cloudfront.svg`          |
| API Gateway           | `https://api.iconify.design/logos/aws-api-gateway.svg`         |
| Lambda                | `https://api.iconify.design/logos/aws-lambda.svg`              |
| DynamoDB              | `https://api.iconify.design/logos/aws-dynamodb.svg`            |
| KMS                   | `https://api.iconify.design/logos/aws-kms.svg`                 |
| Aurora (専用)         | `https://api.iconify.design/logos/aws-aurora.svg`              |
| Route53               | `https://api.iconify.design/logos/aws-route-53.svg`            |
| ACM                   | `https://api.iconify.design/logos/aws-certificate-manager.svg` |
| WAF                   | `https://api.iconify.design/logos/aws-waf.svg`                 |
| VPC                   | `https://api.iconify.design/logos/aws-vpc.svg`                 |
| SQS                   | `https://api.iconify.design/logos/aws-sqs.svg`                 |
| SNS                   | `https://api.iconify.design/logos/aws-sns.svg`                 |
| Secrets Manager       | `https://api.iconify.design/logos/aws-secrets-manager.svg`     |
| Systems Manager (SSM) | `https://api.iconify.design/logos/aws-systems-manager.svg`     |
| CloudWatch            | `https://api.iconify.design/logos/aws-cloudwatch.svg`          |
| Step Functions        | `https://api.iconify.design/logos/aws-step-functions.svg`      |
| IAM                   | `https://api.iconify.design/logos/aws-iam.svg`                 |

アイコンが描画されないときは、別の Iconify のパック (`material-symbols`、`simple-icons` など) を試す。

## AWS 以外、外部のサービス

| 用途                     | URL                                                          |
| ------------------------ | ------------------------------------------------------------ |
| インターネット、ブラウザ | `https://api.iconify.design/material-symbols/globe-asia.svg` |
| 抽象的なクラウド         | `https://api.iconify.design/material-symbols/cloud.svg`      |
| リンク、RPC              | `https://api.iconify.design/material-symbols/link.svg`       |
| 鍵、認証                 | `https://api.iconify.design/material-symbols/key.svg`        |
| 汎用のデータベース       | `https://api.iconify.design/material-symbols/database.svg`   |
| Auth0                    | `https://api.iconify.design/logos/auth0-icon.svg`            |
| GitHub                   | `https://api.iconify.design/logos/github-icon.svg`           |
| Slack                    | `https://api.iconify.design/logos/slack-icon.svg`            |
| Stripe                   | `https://api.iconify.design/logos/stripe.svg`                |

## ノード ID の付け方

実際のリソース ID を使うと、あとでマネジメントコンソールの URL を組み立てやすい。

| サービス  | ノード ID の形                    |
| --------- | --------------------------------- |
| ELB / ALB | `<DNSName>`                       |
| EC2       | `ec2-<InstanceId>`                |
| ECS       | `ecs-<ClusterName>/<ServiceName>` |
| RDS       | `rds-<DBClusterIdentifier>`       |
| S3        | `s3-<BucketName>`                 |

ID には `-`、`_`、`/`、英数字だけを使う。空白や記号は Mermaid のパーサーを混乱させる。
