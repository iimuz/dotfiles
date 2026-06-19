# Template

Copy-paste templates for AWS architecture diagrams in Mermaid `flowchart LR`.

## 0. General form of the image-node extension

Available in Mermaid v11.3.0+. Define every icon node with this form.

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

| Property     | Purpose                                  | Default  |
| ------------ | ---------------------------------------- | -------- |
| `img`        | URL of the SVG icon (Iconify, etc.)      | required |
| `label`      | Text displayed on the node               | required |
| `pos`        | Label position (`t` = top / `b` = below) | `b`      |
| `w`, `h`     | Icon width / height in px                | 60 / 60  |
| `constraint` | Layout constraint (`on` = constrained)   | `on`     |

## 1. Minimum sample

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

## 2. Subgraph nesting + invisible layout helpers

Nest `subgraph` to express account / region / VPC / external boundaries.
For layout polishing, combine **empty-label invisible subgraphs** with **invisible edges** `~~~`.

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

## 3. Edge syntax

| Syntax                | Meaning           | When to use                                                 |
| --------------------- | ----------------- | ----------------------------------------------------------- |
| `A --- B`             | synchronous call  | default                                                     |
| `A ----\|"label"\| B` | labelled edge     | when you want hostnames / paths / protocols on the edge     |
| `A -.-> B`            | dotted (directed) | async / config reference / OIDC / out-of-band flow          |
| `A ~~~ B`             | invisible edge    | layout only (e.g. force a vertical order between subgraphs) |

Edge length is controlled by the number of dashes:

- `-` short
- `---` medium
- `-----` long (use a longer edge when adding a label between subgraphs so the label has room)

## 4. Click navigation (only when the user explicitly asks)

Add `click` lines **only when the user explicitly requests** management-console navigation. Never embed by default.

```text
click nodeID href "<URL>" _blank
```

URL patterns per service live in [`console-urls.md`](console-urls.md).

## 5. Styling

```text
classDef default fill:#fff
classDef group fill:none,stroke:none
style <subgraphID> fill:#fff,color:#345,stroke:#345
style <subgraphID> fill:#fff,color:#0a0,stroke:#0a0       %% green-ish for VPC
style <subgraphID> fill:#fff,color:#888,stroke:#888       %% grey for external services
style <subgraphID> fill:#fff8c4,color:#a80,stroke:#a80,stroke-width:2px  %% diff highlight
class <id1>,<id2> group                                    %% remove frame on empty-label subgraphs
```

## 6. Comparison diagrams (before/after, Option A vs Option B)

To make comparisons readable:

1. **Reuse the same node IDs and layout positions** across both diagrams so the reader's eye lands in the same spot.
2. Highlight only the diff nodes with `classDef diff` (pale yellow fill + orange border).
3. Place a comparison table directly after the diagrams.

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

%% Reuse the same node IDs as the Option A diagram; only add or change diff parts.
authorizer@{img: "https://api.iconify.design/logos/aws-lambda.svg", label: "Lambda Authorizer", pos: "b", w: 60, h: 60, constraint: "on"}
%% ... rest of the node definitions match Option A ...

%% Diff highlight
classDef diff fill:#fff8c4,stroke:#a80,stroke-width:2px
class authorizer diff
%% To highlight a whole subgraph, use `style`:
style tenant-dev fill:#fff8c4,color:#a80,stroke:#a80,stroke-width:2px
```

See `docs/reports/2026-06-17-mspf-dev-plan.md` ("全体アーキテクチャ案" section) for a worked
three-stage comparison (before / Option A / Option B) that uses identical node IDs across the
diagrams with diff classes on the changed nodes.
