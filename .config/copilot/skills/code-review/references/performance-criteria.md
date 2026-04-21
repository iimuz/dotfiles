# Performance Criteria

Focus on efficiency, resource usage, and optimization opportunities.

- Inefficient algorithms: O(n^2) when O(n log n) or O(n) is possible.
- Unnecessary re-renders: React components re-rendering without memoization.
- Missing memoization: Expensive computations without caching.
- Large bundle sizes: Unnecessary dependencies or missing code splitting.
- Unoptimized assets: Large images without compression or lazy loading.
- Missing caching: Repeated identical API calls or computations.
- N+1 queries: Database queries in loops instead of batch operations.

Severity mapping: most items default to LOW. Elevate to MEDIUM when the
performance impact is measurable and significant (e.g., N+1 queries on a hot path).
Elevate to HIGH for issues causing noticeable user-facing latency. Elevate to
CRITICAL only when the issue causes timeouts, OOM, or denial-of-service conditions.
