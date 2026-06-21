# Iconify icon catalog

URLs of AWS and third-party icons. Drop them directly into the `img` field of the Mermaid image-node extension.

## URL patterns

- AWS: `https://api.iconify.design/logos/aws-<service>.svg`
- Third-party vendor: `https://api.iconify.design/logos/<vendor>.svg` (e.g. `logos/auth0-icon`)
- Abstract symbol: `https://api.iconify.design/material-symbols/<name>.svg`

When unsure, search the `SVG Logos` collection on [Icônes](https://icones.js.org/).

## AWS services (verified against the source article)

| Service       | URL                                            |
| ------------- | ---------------------------------------------- |
| ELB / ALB     | `https://api.iconify.design/logos/aws-elb.svg` |
| EC2           | `https://api.iconify.design/logos/aws-ec2.svg` |
| ECS / Fargate | `https://api.iconify.design/logos/aws-ecs.svg` |
| RDS / Aurora  | `https://api.iconify.design/logos/aws-rds.svg` |
| S3            | `https://api.iconify.design/logos/aws-s3.svg`  |

## AWS services (likely, confirm in the renderer)

These names follow Iconify's `logos` collection naming.
Verify by searching `https://icones.js.org/collection/logos?s=aws` before relying on them.

| Service               | Candidate URL                                                  |
| --------------------- | -------------------------------------------------------------- |
| CloudFront            | `https://api.iconify.design/logos/aws-cloudfront.svg`          |
| API Gateway           | `https://api.iconify.design/logos/aws-api-gateway.svg`         |
| Lambda                | `https://api.iconify.design/logos/aws-lambda.svg`              |
| DynamoDB              | `https://api.iconify.design/logos/aws-dynamodb.svg`            |
| KMS                   | `https://api.iconify.design/logos/aws-kms.svg`                 |
| Aurora (dedicated)    | `https://api.iconify.design/logos/aws-aurora.svg`              |
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

If the icon does not render, try a different Iconify pack (`material-symbols`, `simple-icons`, etc.).

## Non-AWS / external services

| Use                | URL                                                          |
| ------------------ | ------------------------------------------------------------ |
| Internet / Browser | `https://api.iconify.design/material-symbols/globe-asia.svg` |
| Abstract cloud     | `https://api.iconify.design/material-symbols/cloud.svg`      |
| Link / RPC         | `https://api.iconify.design/material-symbols/link.svg`       |
| Key / Auth         | `https://api.iconify.design/material-symbols/key.svg`        |
| Generic database   | `https://api.iconify.design/material-symbols/database.svg`   |
| Auth0              | `https://api.iconify.design/logos/auth0-icon.svg`            |
| GitHub             | `https://api.iconify.design/logos/github-icon.svg`           |
| Slack              | `https://api.iconify.design/logos/slack-icon.svg`            |
| Stripe             | `https://api.iconify.design/logos/stripe.svg`                |

## Node ID conventions

Match the source article's recommendation.
Using the real resource ID makes it easier to derive management-console URLs later.

| Service   | Node ID format                    |
| --------- | --------------------------------- |
| ELB / ALB | `<DNSName>`                       |
| EC2       | `ec2-<InstanceId>`                |
| ECS       | `ecs-<ClusterName>/<ServiceName>` |
| RDS       | `rds-<DBClusterIdentifier>`       |
| S3        | `s3-<BucketName>`                 |

Restrict IDs to `-`, `_`, `/`, and alphanumerics — spaces or punctuation can confuse the Mermaid parser.
