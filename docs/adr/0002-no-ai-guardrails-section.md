---
id: "0002"
status: Accepted
date: 2026-03-15
supersedes: []
---

# ADR-0002: ADR に AI Guardrails セクションを持たない

## Context

AI エージェント駆動開発において、ADR に AI Guardrails セクション
(AI への禁止事項や優先順位を明示する専用セクション) を設ける
ベストプラクティスが提案されている。

検討の結果、以下の理由から AI Guardrails は不要と判断した。
ADR の Context と Decision セクションが十分な制約として機能する。
AI エージェントは Decision を読めば「何を守るべきか」を理解できる。
Guardrails セクションは Context/Decision と内容が重複しやすく、
同期の保守コストが発生する。
さらに、このリポジトリでは instructions ファイルが行動制約として
既に機能しており、ADR 固有の禁止事項を別途記載する必要がない。

## Decision

ADR テンプレートおよび instructions に AI Guardrails セクションを
設けない。ADR の Decision セクション自体が AI エージェントに対する
制約として機能する。

## Consequences

ADR テンプレートが簡素に保たれ、記載の保守コストが低くなる。
Context/Decision との重複が発生せず、情報の一貫性が維持される。
一方、AI エージェントが Decision を無視して「改善」を試みるリスクは
残るが、これは instructions のライフサイクルルール (不変性) で
カバーされる。将来、Decision だけでは制約が伝わらないケースが
頻発した場合は、この ADR を Supersede して Guardrails を導入する。
