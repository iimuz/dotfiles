# AWS management console URL patterns

URL templates for `click nodeID href "URL" _blank` annotations.
Only attach these when the user has explicitly asked for clickable navigation.

Placeholders:

- `[ACCOUNT]` — 12-digit AWS account ID
- `[REGION]` — region (e.g. `ap-northeast-1`)
- `[ARN]` / `[ID]` / `[CLUSTER]` / `[SERVICE]` / `[BUCKET]` — per-service identifiers

## ELB / ALB

```text
https://[ACCOUNT].[REGION].console.aws.amazon.com/ec2/home?region=[REGION]#LoadBalancer:loadBalancerArn=[ARN]
```

Using the `<DNSName>` as the node ID lets the presenter build URLs directly.

## EC2

```text
https://[ACCOUNT].[REGION].console.aws.amazon.com/ec2/home?region=[REGION]#InstanceDetails:instanceId=[ID]
```

## ECS

```text
https://[ACCOUNT].[REGION].console.aws.amazon.com/ecs/v2/clusters/[CLUSTER]/services/[SERVICE]/health?region=[REGION]
```

Node ID format `<ClusterName>/<ServiceName>` lines up with the AWS CLI output.

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

CloudFront is global, but the console URL is fixed to `region=us-east-1`.

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

## Harvesting identifiers via the AWS CLI

When building clickable diagrams at scale, bulk-extract identifiers with the CLI first.

```bash
AWS_REGION="ap-northeast-1"

# All resources (ARN + Name tag)
aws resourcegroupstaggingapi get-resources \
  --query "ResourceTagMappingList[].[ResourceARN,Tags[?Key=='Name']|[0].Value]" \
  --output text --region $AWS_REGION

# ELB
aws elbv2 describe-load-balancers \
  --query "LoadBalancers[].[VpcId,DNSName,LoadBalancerName,LoadBalancerArn]" \
  --output text --region $AWS_REGION

# EC2
aws ec2 describe-instances \
  --query "Reservations[].Instances[].[VpcId,InstanceId,Tags[?Key=='Name']|[0].Value]" \
  --output text --region $AWS_REGION

# S3 buckets
aws s3 ls | awk '{print $3}'
```

## Caveats

- The `[ACCOUNT].[REGION].console.aws.amazon.com` host prefix is the IAM Identity Center / SSO
  style. The bare `<region>.console.aws.amazon.com` form also works but switches account context
  implicitly, so prefer the explicit form.
- Clicks assume the user is already signed in to AWS; if not, the SSO login screen will intercept.
- ARNs embedded in URLs may need URL encoding (`:` and `/`) depending on the renderer / browser.
- GitHub README cannot follow `click` links — see the note in SKILL.md.
