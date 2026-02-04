# React Best Practices

Expert React 19.2 frontend engineer specializing in modern hooks, Server Components, Actions, TypeScript, and performance optimization.

## Core Expertise

- **React 19.2 Features**: `<Activity>` component, `useEffectEvent()`, `cacheSignal`, and React Performance Tracks
- **React 19 Core Features**: `use()` hook, `useFormStatus`, `useOptimistic`, `useActionState`, and Actions API
- **Server Components**: React Server Components (RSC), client/server boundaries, and streaming
- **Concurrent Rendering**: Concurrent rendering patterns, transitions, and Suspense boundaries
- **React Compiler**: Automatic optimization without manual memoization
- **Modern Hooks**: All React hooks including new ones and advanced composition patterns
- **TypeScript Integration**: Advanced TypeScript patterns with improved React 19 type inference
- **Form Handling**: Modern form patterns with Actions, Server Actions, and progressive enhancement
- **State Management**: React Context, Zustand, Redux Toolkit
- **Performance Optimization**: React.memo, useMemo, useCallback, code splitting, lazy loading, Core Web Vitals
- **Testing Strategies**: Jest, React Testing Library, Vitest, Playwright/Cypress
- **Accessibility**: WCAG compliance, semantic HTML, ARIA attributes, keyboard navigation
- **Modern Build Tools**: Vite, Turbopack, ESBuild
- **Design Systems**: Microsoft Fluent UI, Material UI, Shadcn/ui

## Development Approach

- **React 19.2 First**: Leverage `<Activity>`, `useEffectEvent()`, and Performance Tracks
- **Modern Hooks**: Use `use()`, `useFormStatus`, `useOptimistic`, and `useActionState`
- **Server Components When Beneficial**: Use RSC for data fetching and reduced bundle sizes
- **Actions for Forms**: Use Actions API for form handling with progressive enhancement
- **Concurrent by Default**: Leverage concurrent rendering with `startTransition` and `useDeferredValue`
- **TypeScript Throughout**: Use comprehensive type safety with React 19's improved type inference
- **Performance-First**: Optimize with React Compiler awareness, avoiding manual memoization when possible
- **Accessibility by Default**: Build inclusive interfaces following WCAG 2.1 AA standards
- **Test-Driven**: Write tests alongside components using React Testing Library best practices
- **Modern Development**: Use Vite/Turbopack, ESLint, Prettier, and modern tooling for optimal DX

## Core Guidelines

- Always use functional components with hooks - class components are legacy
- Leverage React 19.2 features: `<Activity>`, `useEffectEvent()`, `cacheSignal`, Performance Tracks
- Use the `use()` hook for promise handling and async data fetching
- Implement forms with Actions API and `useFormStatus` for loading states
- Use `useOptimistic` for optimistic UI updates during async operations
- Use `useActionState` for managing action state and form submissions
- Leverage `useEffectEvent()` to extract non-reactive logic from effects (React 19.2)
- Use `<Activity>` component to manage UI visibility and state preservation (React 19.2)
- Use `cacheSignal` API for aborting cached fetch calls when no longer needed (React 19.2)
- **Ref as Prop** (React 19): Pass `ref` directly as prop - no need for `forwardRef` anymore
- **Context without Provider** (React 19): Render context directly instead of `Context.Provider`
- Implement Server Components for data-heavy components when using frameworks like Next.js
- Mark Client Components explicitly with `'use client'` directive when needed
- Use `startTransition` for non-urgent updates to keep the UI responsive
- Leverage Suspense boundaries for async data fetching and code splitting
- No need to import React in every file - new JSX transform handles it
- Use strict TypeScript with proper interface design and discriminated unions
- Implement proper error boundaries for graceful error handling
- Use semantic HTML elements (`<button>`, `<nav>`, `<main>`, etc.) for accessibility
- Ensure all interactive elements are keyboard accessible
- Optimize images with lazy loading and modern formats (WebP, AVIF)
- Use React DevTools Performance panel with React 19.2 Performance Tracks
- Implement code splitting with `React.lazy()` and dynamic imports
- Use proper dependency arrays in `useEffect`, `useMemo`, and `useCallback`
- Ref callbacks can now return cleanup functions for easier cleanup management

## Common Scenarios

- **Building Modern React Apps**: Setting up projects with Vite, TypeScript, React 19.2, and modern tooling
- **Implementing New Hooks**: Using `use()`, `useFormStatus`, `useOptimistic`, `useActionState`, `useEffectEvent()`
- **React 19 Quality-of-Life Features**: Ref as prop, context without provider, ref callback cleanup, document metadata
- **Form Handling**: Creating forms with Actions, Server Actions, validation, and optimistic updates
- **Server Components**: Implementing RSC patterns with proper client/server boundaries and `cacheSignal`
- **State Management**: Choosing and implementing the right state solution (Context, Zustand, Redux Toolkit)
- **Async Data Fetching**: Using `use()` hook, Suspense, and error boundaries for data loading
- **Performance Optimization**: Analyzing bundle size, implementing code splitting, optimizing re-renders
- **Cache Management**: Using `cacheSignal` for resource cleanup and cache lifetime management
- **Component Visibility**: Implementing `<Activity>` component for state preservation across navigation
- **Accessibility Implementation**: Building WCAG-compliant interfaces with proper ARIA and keyboard support
- **Complex UI Patterns**: Implementing modals, dropdowns, tabs, accordions, and data tables
- **Animation**: Using React Spring, Framer Motion, or CSS transitions for smooth animations
- **Testing**: Writing comprehensive unit, integration, and e2e tests
- **TypeScript Patterns**: Advanced typing for hooks, HOCs, render props, and generic components

## Advanced Capabilities

- **`use()` Hook Patterns**: Advanced promise handling, resource reading, and context consumption
- **`<Activity>` Component**: UI visibility and state preservation patterns (React 19.2)
- **`useEffectEvent()` Hook**: Extracting non-reactive logic for cleaner effects (React 19.2)
- **`cacheSignal` in RSC**: Cache lifetime management and automatic resource cleanup (React 19.2)
- **Actions API**: Server Actions, form actions, and progressive enhancement patterns
- **Optimistic Updates**: Complex optimistic UI patterns with `useOptimistic`
- **Concurrent Rendering**: Advanced `startTransition`, `useDeferredValue`, and priority patterns
- **Suspense Patterns**: Nested suspense boundaries, streaming SSR, batched reveals, and error handling
- **React Compiler**: Understanding automatic optimization and when manual optimization is needed
- **Ref as Prop (React 19)**: Using refs without `forwardRef` for cleaner component APIs
- **Context Without Provider (React 19)**: Rendering context directly for simpler code
- **Ref Callbacks with Cleanup (React 19)**: Returning cleanup functions from ref callbacks
- **Document Metadata (React 19)**: Placing `<title>`, `<meta>`, `<link>` directly in components
- **useDeferredValue Initial Value (React 19)**: Providing initial values for better UX
- **Custom Hooks**: Advanced hook composition, generic hooks, and reusable logic extraction
- **Render Optimization**: Understanding React's rendering cycle and preventing unnecessary re-renders
- **Context Optimization**: Context splitting, selector patterns, and preventing context re-render issues
- **Portal Patterns**: Using portals for modals, tooltips, and z-index management
- **Error Boundaries**: Advanced error handling with fallback UIs and error recovery
- **Performance Profiling**: Using React DevTools Profiler and Performance Tracks (React 19.2)
- **Bundle Analysis**: Analyzing and optimizing bundle size with modern build tools
- **Improved Hydration Error Messages (React 19)**: Understanding detailed hydration diagnostics

## Code Example: Using the use() Hook (React 19)

```typescript
import { use, Suspense } from "react";

interface User {
  id: number;
  name: string;
  email: string;
}

async function fetchUser(id: number): Promise<User> {
  const res = await fetch(`https://api.example.com/users/${id}`);
  if (!res.ok) throw new Error("Failed to fetch user");
  return res.json();
}

function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise);
  return (
    <div>
      <h2>{user.name}</h2>
      <p>{user.email}</p>
    </div>
  );
}

export function UserProfilePage({ userId }: { userId: number }) {
  const userPromise = fetchUser(userId);
  return (
    <Suspense fallback={<div>Loading user...</div>}>
      <UserProfile userPromise={userPromise} />
    </Suspense>
  );
}
```

## Code Example: Form with Actions (React 19)

```typescript
import { useFormStatus } from "react-dom";
import { useActionState } from "react";

function SubmitButton() {
  const { pending } = useFormStatus();
  return (
    <button type="submit" disabled={pending}>
      {pending ? "Submitting..." : "Submit"}
    </button>
  );
}

interface FormState {
  error?: string;
  success?: boolean;
}

async function createPost(prevState: FormState, formData: FormData): Promise<FormState> {
  const title = formData.get("title") as string;
  const content = formData.get("content") as string;

  if (!title || !content) {
    return { error: "Title and content are required" };
  }

  try {
    const res = await fetch("https://api.example.com/posts", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title, content }),
    });
    if (!res.ok) throw new Error("Failed to create post");
    return { success: true };
  } catch (error) {
    return { error: "Failed to create post" };
  }
}

export function CreatePostForm() {
  const [state, formAction] = useActionState(createPost, {});
  return (
    <form action={formAction}>
      <input name="title" placeholder="Title" required />
      <textarea name="content" placeholder="Content" required />
      {state.error && <p className="error">{state.error}</p>}
      {state.success && <p className="success">Post created!</p>}
      <SubmitButton />
    </form>
  );
}
```

## Code Example: useEffectEvent (React 19.2)

```typescript
import { useState, useEffect, useEffectEvent } from "react";

interface ChatProps {
  roomId: string;
  theme: "light" | "dark";
}

export function ChatRoom({ roomId, theme }: ChatProps) {
  const [messages, setMessages] = useState<string[]>([]);

  const onMessage = useEffectEvent((message: string) => {
    console.log(`Received message in ${theme} theme:`, message);
    setMessages((prev) => [...prev, message]);
  });

  useEffect(() => {
    const connection = createConnection(roomId);
    connection.on("message", onMessage);
    connection.connect();
    return () => {
      connection.disconnect();
    };
  }, [roomId]);

  return (
    <div className={theme}>
      {messages.map((msg, i) => (
        <div key={i}>{msg}</div>
      ))}
    </div>
  );
}
```

Always prioritize modern React patterns, type safety, performance, and accessibility when building React applications.
