---
name: standards-react
description: >-
  Use when writing or reviewing React components in JSX or TSX files to enforce
  architecture, state, accessibility, and testing standards.
user-invocable: true
disable-model-invocation: false
---

# React

## Official Documentation

When encountering unfamiliar React APIs or patterns, use a subagent to fetch
the relevant specification details from the official documentation:

- [React Reference](https://react.dev/reference/react)

If the fetch fails, follow the guidelines described below instead.
If there are still unclear points, ask the user for clarification.

## Architecture

- Use functional components with hooks. Do not use class components.
- Mark Client Components explicitly with the `use client` directive when needed.
- Use Server Components only for data fetching and bundle reduction, not for interactive or stateful UI.
- Split large component files into smaller focused files when a single component exceeds 200 lines.
- Use strict TypeScript with proper interface design and discriminated unions for component props.

## State and Rendering

- Use the `use()` hook for promise handling and async data fetching. Do not
  manage loading/error state manually when using `use()` with Suspense and
  error boundaries.
- Use `useActionState` for managing form action state and submissions.
- Use `useFormStatus` to reflect pending state inside form components.
- Use `useOptimistic` for optimistic UI updates during async operations.
- Use `useEffectEvent()` to extract non-reactive logic from effects.
- Use the `Activity` component to manage UI visibility and preserve state across navigation.
- Pass ref directly as a prop. Do not use `forwardRef`.
- Render Context directly. Do not wrap with `Context.Provider`.
- Return cleanup functions from ref callbacks when cleanup is needed.
- Use `startTransition` for non-urgent state updates to keep the UI responsive.
- Use `useDeferredValue` to defer expensive re-renders triggered by user input.
- Wrap async data fetching with Suspense boundaries.
- Do not mutate state directly. Produce new values.
- Provide correct dependency arrays in `useEffect`, `useMemo`, and `useCallback`.
- Use code splitting with `React.lazy()` and dynamic imports for route-level components.
- Use the Actions API for form handling with progressive enhancement.
- Use `cacheSignal` in React Server Components to abort cached fetch calls when no longer needed.
- Use document metadata tags (`title`, `meta`, `link`) directly in
  components instead of separate head management libraries.

## Error Handling

- Implement error boundaries around component trees that may throw.
- Provide meaningful fallback content for all error boundary fallback UIs.
- Do not swallow errors silently in async event handlers to bypass error boundaries.
- Do not block the main thread with synchronous work inside render. Defer with transitions.

## Accessibility

- Use semantic HTML elements (`button`, `nav`, `main`, `article`) instead of generic divs.
- Ensure all interactive elements are keyboard accessible.
- Add ARIA attributes when semantic HTML alone is insufficient for accessibility.
- Meet WCAG 2.1 AA compliance for all user-facing components.

## Testing

- Test user interactions via rendered output and behavior. Do not assert on internal component state.
- Provide test coverage for all error boundary fallback conditions.
- Test accessibility roles and labels as part of component tests.
