# Implementation Request

## Goal

Execute code changes precisely within the defined scope of the plan below. Do not fix pre-existing issues unrelated to the current plan goal.

## Interface

```typescript
/**
 * @input  { context: ImplementContext }
 * @output { void }
 */

type ImplementContext = {
  plan: { session_state_file: string; summary: string };
  iteration: number;
  prior_issues: Array<{
    severity: "Critical" | "High" | "Medium" | "Low";
    description: string;
  }>;
  tdd_mode: boolean;
};

type WorkScope = {
  source: "plan" | "prior_issues";
  items: string[];
};

type SupportedLanguage = "go" | "python" | "typescript" | "react" | "rust";

type LanguageContext = {
  language: SupportedLanguage | null;
  best_practices_loaded: boolean;
};
```

## Operations

```typespec
op load_scope(context: ImplementContext) -> WorkScope {
  invariant: (context.iteration == 1) => read(context.plan.session_state_file);
  invariant: (context.iteration > 1)  => scope_to(context.prior_issues.filter("Critical" | "High"));
  invariant: (pre_existing_unrelated_issue_detected) => exclude_from_scope;
}

op detect_language(scope: WorkScope) -> LanguageContext {
  // Detect from file extensions (.go, .py, .ts, .tsx, .rs) or project files (go.mod, pyproject.toml, Cargo.toml, package.json)
  invariant: (language in SupportedLanguage) => skill(name: "language-pro", language: language);
  invariant: (language_not_detected)         => set(language_ctx.language, null);
}

op execute(scope: WorkScope, language_ctx: LanguageContext, tdd_mode: boolean) -> void {
  invariant: (tdd_mode == true)              => skill(name: "test-driven-development", scope: scope);
  invariant: (tdd_mode == false)             => direct_implementation(scope);
  invariant: (language_ctx.language != null) => apply(language_ctx.best_practices);
}
```

## Execution

```
load_scope -> detect_language -> execute
```

## Input Context

```typescript
interface ImplementContext {
  plan: { session_state_file: string; summary: string };
  iteration: number;
  prior_issues: Array<{ severity: string; description: string }>;
  tdd_mode: boolean;
}
```

Plan: {{plan}}
Iteration: {{iteration}}
Prior issues: {{prior_issues}}
TDD mode: {{tdd_mode}}
