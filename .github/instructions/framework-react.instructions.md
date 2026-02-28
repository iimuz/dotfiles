---
applyTo: "**/*.jsx,**/*.tsx"
---

# React

## Architecture

- ALWAYS use functional components with hooks. NEVER use class components.
- ALWAYS mark Client Components explicitly with the 'use client' directive when needed.
- NEVER use Server Components for interactive or stateful UI; use them only for data fetching and bundle reduction.
- ALWAYS split large component files into smaller focused files when a single component exceeds 200 lines.
- ALWAYS use strict TypeScript with proper interface design and discriminated unions for component props.

## State And Rendering

- ALWAYS use the use() hook for promise handling and async data fetching.
- ALWAYS use useActionState for managing form action state and submissions.
- ALWAYS use useFormStatus to reflect pending state inside form components.
- ALWAYS use useOptimistic for optimistic UI updates during async operations.
- ALWAYS use useEffectEvent() to extract non-reactive logic from effects.
- ALWAYS use the Activity component to manage UI visibility and preserve state across navigation.
- ALWAYS pass ref directly as a prop. NEVER use forwardRef in React 19.
- ALWAYS render Context directly. NEVER wrap with Context.Provider in React 19.
- ALWAYS return cleanup functions from ref callbacks when cleanup is needed.
- ALWAYS use startTransition for non-urgent state updates to keep the UI responsive.
- ALWAYS use useDeferredValue to defer expensive re-renders triggered by user input.
- ALWAYS wrap async data fetching with Suspense boundaries.
- NEVER mutate state directly; ALWAYS produce new values.
- ALWAYS provide correct dependency arrays in useEffect, useMemo, and useCallback.
- ALWAYS implement code splitting with React.lazy() and dynamic imports for route-level components.
- ALWAYS use the Actions API for form handling with progressive enhancement.
- ALWAYS use cacheSignal in React Server Components to abort cached fetch calls when no longer needed.
- ALWAYS use document metadata tags (title, meta, link) directly in components in React 19 instead
  of separate head management libraries.
- DO NOT manage loading/error state manually when using use() with Suspense and error boundaries.

## Error Handling

- ALWAYS implement error boundaries around component trees that may throw.
- DO NOT skip error boundary fallback UIs; ALWAYS provide meaningful fallback content.
- NEVER bypass error boundaries by swallowing errors silently in async event handlers.
- DO NOT block the main thread with synchronous work inside render; defer with transitions.

## Accessibility

- ALWAYS use semantic HTML elements (button, nav, main, article) instead of generic divs.
- ALWAYS ensure all interactive elements are keyboard accessible.
- ALWAYS add ARIA attributes when semantic HTML alone is insufficient for accessibility.
- MUST meet WCAG 2.1 AA compliance for all user-facing components.

## Testing

- ALWAYS test user interactions via rendered output and behavior; NEVER assert on internal component state.
- ALWAYS provide test coverage for all error boundary fallback conditions.
- ALWAYS test accessibility roles and labels as part of component tests.
