# Implementation Plan Examples

Detailed examples of generated implementation plans for various scenarios.

**Important**: All example plans shown below are saved to `~/.copilot/session-state/{session-id}/files/` during actual workflow execution.

## Example 1: Feature Addition

**Input**: "Add JWT-based user authentication"

**Generated Plan**: `feature-auth-module-1.md` in session files folder

### Plan Structure

```markdown
PHASE-1: Database Schema Updates

- TASK-001: Add users table with auth fields
  - Files: migrations/001_create_users.sql
  - Validation: SELECT \* FROM users LIMIT 1 succeeds
- TASK-002: Create sessions table for token storage
  - Files: migrations/002_create_sessions.sql
  - Validation: Table exists with correct indexes
- TASK-003: Add migration scripts
  - Files: scripts/migrate.sh
  - Validation: Script executes without errors

PHASE-2: JWT Service Implementation

- TASK-004: Implement token generation (src/auth/jwt.js)
  - Files: src/auth/jwt.js
  - Dependencies: TASK-001
  - Validation: Unit tests pass for token generation
- TASK-005: Implement token validation middleware
  - Files: src/middleware/auth.js
  - Dependencies: TASK-004
  - Validation: Middleware correctly validates/rejects tokens
- TASK-006: Add token refresh logic
  - Files: src/auth/refresh.js
  - Dependencies: TASK-004, TASK-005
  - Validation: Refresh endpoint returns new valid token

PHASE-3: Authentication Endpoints

- TASK-007: Create /login endpoint (src/routes/auth.js)
  - Files: src/routes/auth.js, src/controllers/auth.js
  - Dependencies: TASK-004, TASK-005
  - Validation: POST /login returns JWT on valid credentials
- TASK-008: Create /logout endpoint
  - Files: src/routes/auth.js, src/controllers/auth.js
  - Dependencies: TASK-002, TASK-005
  - Validation: POST /logout invalidates session
- TASK-009: Create /refresh endpoint
  - Files: src/routes/auth.js, src/controllers/auth.js
  - Dependencies: TASK-006
  - Validation: POST /refresh returns new token

PHASE-4: Integration & Testing

- TASK-010: Add unit tests for JWT service
  - Files: tests/unit/auth/jwt.test.js
  - Dependencies: TASK-004, TASK-005, TASK-006
  - Validation: 100% coverage for jwt.js
- TASK-011: Add integration tests for auth flow
  - Files: tests/integration/auth.test.js
  - Dependencies: TASK-007, TASK-008, TASK-009
  - Validation: All auth scenarios covered
- TASK-012: Update API documentation
  - Files: docs/api/authentication.md
  - Dependencies: All previous tasks
  - Validation: Documentation matches implementation
```

## Example 2: System Refactor

**Input**: "Refactor legacy command system to plugin architecture"

**Generated Plan**: `refactor-command-system-2.md` in session files folder

### Plan Structure

```markdown
PHASE-1: Define Plugin Interface

- TASK-001: Create IPlugin interface (src/plugins/IPlugin.ts)
  - Files: src/plugins/IPlugin.ts
  - Validation: Interface compiles without errors
- TASK-002: Define plugin metadata structure
  - Files: src/plugins/PluginMetadata.ts
  - Dependencies: TASK-001
  - Validation: Metadata schema validates
- TASK-003: Document plugin lifecycle hooks
  - Files: docs/architecture/plugin-lifecycle.md
  - Dependencies: TASK-001
  - Validation: All hooks documented with examples

PHASE-2: Extract Existing Commands

- TASK-004: Convert HelpCommand to plugin
  - Files: src/plugins/help/HelpPlugin.ts
  - Dependencies: TASK-001, TASK-002
  - Validation: Help command works via plugin system
- TASK-005: Convert ConfigCommand to plugin
  - Files: src/plugins/config/ConfigPlugin.ts
  - Dependencies: TASK-001, TASK-002
  - Validation: Config command works via plugin system
- TASK-006: Convert SearchCommand to plugin
  - Files: src/plugins/search/SearchPlugin.ts
  - Dependencies: TASK-001, TASK-002
  - Validation: Search command works via plugin system

PHASE-3: Implement Plugin Loader

- TASK-007: Create PluginManager (src/plugins/PluginManager.ts)
  - Files: src/plugins/PluginManager.ts
  - Dependencies: TASK-001, TASK-002
  - Validation: Manager loads and initializes plugins
- TASK-008: Add plugin discovery mechanism
  - Files: src/plugins/PluginDiscovery.ts
  - Dependencies: TASK-007
  - Validation: Auto-discovers plugins in plugins/ directory
- TASK-009: Implement plugin registration
  - Files: src/plugins/PluginRegistry.ts
  - Dependencies: TASK-007
  - Validation: Plugins register and deregister correctly

PHASE-4: Migration Validation

- TASK-010: Verify all commands functional as plugins
  - Files: tests/integration/plugin-migration.test.ts
  - Dependencies: TASK-004, TASK-005, TASK-006, TASK-009
  - Validation: All legacy commands work identically
- TASK-011: Performance benchmark comparison
  - Files: benchmarks/command-vs-plugin.ts
  - Dependencies: TASK-010
  - Validation: Plugin system ≤5% performance overhead
- TASK-012: Update architecture documentation
  - Files: docs/architecture/plugin-system.md
  - Dependencies: All previous tasks
  - Validation: Architecture diagrams and examples complete
```

## Example 3: Infrastructure Upgrade

**Input**: "Upgrade from Node 16 to Node 20"

**Generated Plan**: `upgrade-node-runtime-1.md` in session files folder

### Plan Structure

```markdown
PHASE-1: Compatibility Audit

- TASK-001: Audit dependencies for Node 20 support
  - Files: audit-results.md
  - Validation: List of incompatible packages identified
- TASK-002: Identify deprecated API usage
  - Files: deprecated-apis.md
  - Validation: All deprecated API calls documented
- TASK-003: List breaking changes affecting codebase
  - Files: breaking-changes.md
  - Validation: Impact assessment for each change

PHASE-2: Configuration Updates

- TASK-004: Update package.json engines field
  - Files: package.json
  - Dependencies: TASK-001
  - Validation: engines.node: ">=20.0.0"
- TASK-005: Update .nvmrc to 20.x
  - Files: .nvmrc
  - Validation: File contains "20"
- TASK-006: Update Dockerfile base image
  - Files: Dockerfile
  - Validation: FROM node:20-alpine

PHASE-3: Code Compatibility

- TASK-007: Replace deprecated Buffer() constructor
  - Files: src/\*_/_.js (identified in TASK-002)
  - Dependencies: TASK-002
  - Validation: No Buffer() constructor calls remain
- TASK-008: Update stream handling for new APIs
  - Files: src/streams/\*.js
  - Dependencies: TASK-002
  - Validation: Streams use Node 20 recommended patterns
- TASK-009: Fix crypto module usage
  - Files: src/crypto/\*.js
  - Dependencies: TASK-002
  - Validation: Crypto calls compatible with Node 20

PHASE-4: CI/CD Updates

- TASK-010: Update GitHub Actions workflow
  - Files: .github/workflows/\*.yml
  - Dependencies: TASK-004, TASK-005
  - Validation: node-version: '20.x' in all workflows
- TASK-011: Update Docker build pipeline
  - Files: .github/workflows/docker.yml
  - Dependencies: TASK-006
  - Validation: Docker builds use Node 20 image
- TASK-012: Verify all tests pass on Node 20
  - Files: N/A (execution task)
  - Dependencies: All previous tasks
  - Validation: npm test exits with code 0 on Node 20
```

## Plan File Locations

All plans are saved to the session files folder:

- Path: `~/.copilot/session-state/{session-id}/files/`
- Naming: `[purpose]-[component]-[version].md`
- Examples:
  - `feature-auth-module-1.md`
  - `refactor-command-system-2.md`
  - `upgrade-node-runtime-1.md`
