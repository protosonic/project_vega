# AGENTS.md

## Project Context
**project_vega** is a multi-tenant SaaS platform that ingests customer reviews from external platforms (Google, Yelp, etc.), analyzes them, and assists businesses in responding intelligently and consistently.

## Agent Rules
- Read PLAN.md before proposing work
- Prefer incremental changes over rewrites
- Never invent schema, routes, or policies not described or approved
- Flag ambiguity instead of guessing
- Build vertically, but stabilize the spine first
- No premature abstraction, orphaned features, or UI without backend
- Migrations are the only way schema changes happen

## Architecture Principles
- Supabase is the system of record
- PostgreSQL + RLS enforce all authorization
- Next.js App Router is the primary frontend
- Edge Functions handle ingestion and background work
- No business logic lives only in the frontend
- Schema changes via `supabase/migrations` only
- RLS must exist for every table with tenant data
- Foreign keys are mandatory unless justified
- JSON allowed only for truly unstructured data

## File Structure
- Supabase CLI files belong in `/supabase`
- Next.js imports belong in `/src`

## Commands
- **Build**: `npm run build`
- **Dev**: `npm run dev`
- **Lint**: `npm run lint`
- **Start**: `npm run start`
- **Test**: No test framework configured

## Code Style Guidelines

### Imports
- React imports first (`import * as React from "react"`)
- External libraries next (alphabetically)
- Internal imports last with `@/` alias
- Use named imports for components, default for utilities

### Types
- Strict TypeScript enabled
- Use explicit types for component props
- Error handling: `catch (error: unknown)` with type guards
- Prefer interfaces over types for component props

### Naming
- Components: PascalCase
- Functions: camelCase
- Files: kebab-case for pages, camelCase for components
- Variables: camelCase

### Formatting
- ESLint with Next.js rules
- Use `cn()` utility for conditional classes
- 2-space indentation
- Single quotes for strings

### Error Handling
- Use try/catch blocks
- Set error state for user feedback
- Type errors as `unknown` then check instanceof Error

### Components
- Use React.forwardRef for custom components
- Export both component and variants (if applicable)
- Use `displayName` for debugging
