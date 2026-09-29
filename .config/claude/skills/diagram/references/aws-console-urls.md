# AWS マネジメントコンソールの URL の形

`click nodeID href "URL" _blank` に入れる URL のテンプレート。

プレースホルダー:

- `[ACCOUNT]`: 12 桁の AWS アカウント ID
- `[REGION]`: リージョン (例: `ap-northeast-1`)
- `[ARN]`、`[ID]`、`[CLUSTER]`、`[SERVICE]`、`[BUCKET]`: サービスごとの識別子

## ELB / ALB

```text
https://[ACCOUNT].[REGION].console.aws.amazon.com/ec2/home?region=[REGION]#LoadBalancer:loadBalancerArn=[ARN]
```

## EC2

```text
https://[ACCOUNT].[REGION].console.aws.amazon.com/ec2/home?region=[REGION]#InstanceDetails:instanceId=[ID]
```

## ECS

```text
https://[ACCOUNT].[REGION].console.aws.amazon.com/ecs/v2/clusters/[CLUSTER]/services/[SERVICE]/health?region=[REGION]
```

## RDS / Aurora

```text
https://[ACCOUNT].[REGION].console.aws.amazon.com/rds/home/?region=[REGION]#database:id=[CLUSTER];is-cluster=true
```

## S3

```text
https://[ACCOUNT].[REGION].console.aws.amazon.com/s3/buckets/[BUCKET]?region=[REGION]&bucketType=general&tab=objects
```

## CloudFront

```text
https://[ACCOUNT].[REGION].console.aws.amazon.com/cloudfront/v4/home?region=us-east-1#/distributions/[DISTRIBUTION_ID]
```

CloudFront はグローバルだが、コンソールの URL は `region=us-east-1` に固定される。

## API Gateway

```text
https://[ACCOUNT].[REGION].console.aws.amazon.com/apigateway/main/apis/[API_ID]/resources?api=[API_ID]&region=[REGION]
```

## Lambda

```text
https://[ACCOUNT].[REGION].console.aws.amazon.com/lambda/home?region=[REGION]#/functions/[FUNCTION_NAME]
```

## DynamoDB

```text
https://[ACCOUNT].[REGION].console.aws.amazon.com/dynamodbv2/home?region=[REGION]#table?name=[TABLE_NAME]
```

## KMS

```text
https://[ACCOUNT].[REGION].console.aws.amazon.com/kms/home?region=[REGION]#/kms/keys/[KEY_ID]
```

## AWS CLI で識別子を集める

click 付きの図をまとめて作るときは、先に CLI で識別子を一括で取り出す。

```bash
# All resources (ARN + Name tag)
aws resourcegroupstaggingapi get-resources \
  --query "ResourceTagMappingList[].[ResourceARN,Tags[?Key=='Name']|[0].Value]" \
  --output text --region [REGION]

# ELB
aws elbv2 describe-load-balancers \
  --query "LoadBalancers[].[VpcId,DNSName,LoadBalancerName,LoadBalancerArn]" \
  --output text --region [REGION]

# EC2
aws ec2 describe-instances \
  --query "Reservations[].Instances[].[VpcId,InstanceId,Tags[?Key=='Name']|[0].Value]" \
  --output text --region [REGION]

# S3 buckets
aws s3 ls | awk '{print $3}'
```

## 注意

- `[ACCOUNT].[REGION].console.aws.amazon.com` というホストの前置きは IAM Identity Center (SSO) の形。
  素の `<region>.console.aws.amazon.com` でも動くが、アカウントが暗黙に切り替わるので、明示する形を使う
- click は AWS にサインイン済みであることを前提にする。サインインしていなければ SSO のログイン画面が挟まる
- URL に埋め込む ARN は、描画側やブラウザによっては `:` と `/` の URL エンコードが要る
- GitHub の README では click のリンクをたどれない
