# Design Compliance Criteria

Focus on alignment between the code changes and the provided design information.

- Interface contract violations: Method signatures, return types, or parameters that deviate from the design.
- Missing implementations: Design-specified components or behaviors not present in the code.
- Architectural deviations: Code structure that contradicts design decisions
  (e.g., wrong module boundaries, wrong dependency directions).
- Behavioral mismatches: Logic that produces different outcomes than the design specifies.
- Constraint violations: Design-specified constraints (performance budgets, size limits, invariants) not enforced in code.
- Naming inconsistencies: Identifiers that deviate from design-specified terminology.

Severity mapping: interface contract violations and missing implementations default to
CRITICAL. Architectural deviations default to HIGH. Behavioral mismatches default to
MEDIUM. Naming inconsistencies default to LOW.
