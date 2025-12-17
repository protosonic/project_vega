# project_vega — Master Plan & Execution Guide

## Authoritative Source of Truth

This document is the binding system-level plan for project_vega (RevuVista).

All contributors (human or AI) must treat this document as canonical context.  
If an implementation, suggestion, or feature conflicts with this plan, this plan wins.

This file is designed to:

- Prevent architectural drift
- Enable safe parallel work by AI agents
- Preserve long-term strategic coherence
- Avoid rewrites caused by premature decisions

## 1. Project Overview

RevuVista (project_vega) is a multi-tenant SaaS platform that ingests customer reviews from external platforms (Google, Yelp, etc.) and helps businesses understand and respond to those reviews with clarity, consistency, and confidence.

The product is **not** an analytics-first dashboard.

It is an assistive system that:

- Reduces cognitive load
- Surfaces context where decisions are made
- Uses AI as judgment support, not authority

> “Project Vega doesn't just show reviews. It helps you understand them.”

### Target Users

- Small to mid-sized businesses
- Owners and staff responsible for reputation management
- Teams that want automation without loss of control

## 2. Core Principles (Non-Negotiable)

### 2.1 Product Principles

- Context over metrics
- Inline insights over dashboards
- Empty states are valid and intentional
- Human approval always exists for outward-facing actions
- The system must feel optional, not prescriptive

### 2.2 Architecture Principles

- Supabase is the system of record
- PostgreSQL + RLS enforce all authorization
- Next.js App Router is the primary frontend
- Edge Functions handle ingestion and background work
- No critical business logic lives only in the frontend
- All schema changes happen through migrations only

### 2.3 Execution Principles

- Build vertically, but stabilize the spine first
- No premature abstraction
- No orphaned features
- No UI without a valid backend path
- Async boundaries are explicit and respected

### 2.4 AI Agent Rules

AI agents must:

- Read this document before proposing or executing work
- Prefer incremental changes over rewrites
- Never invent schema, routes, policies, or flows not described or approved here
- Flag ambiguity instead of guessing
- Treat this file as higher authority than conversation context

## 3. The Spine (Foundational System)

Everything in RevuVista builds on this backbone.  
If a feature does not connect to this spine, it is likely out of scope.

### 3.1 Identity & Tenancy

**Canonical tables:**

- `auth.users` (Supabase managed)
- `user_profiles`
- `businesses`
- `user_business_roles`

This defines:

- Who the user is
- Which businesses they belong to
- What role they hold per business

All access control is enforced through Postgres RLS, not frontend checks.

### 3.2 Business Lifecycle (Corrected Model)

Businesses are user-created entities, not externally validated objects.

**Lifecycle:**

1. User signs up
2. Business is created (empty allowed)
3. User is assigned owner role
4. Business dashboard shows empty state
5. Review platform is connected
6. Reviews are ingested asynchronously
7. AI enrichment occurs later

**Key rule:**

- A business may exist indefinitely with zero reviews
- "No reviews yet" is a first-class UX state

### 3.3 Review Lifecycle (Canonical)

1. External review arrives (API / webhook)
2. Review is validated and normalized
3. Review is stored in `reviews`
4. Background processing tasks are queued
5. AI enrichment occurs asynchronously
6. Human reviews or approves responses
7. Responses are posted back to source

AI is never on the critical ingestion path.

## 4. Scope Boundaries

### 4.1 In Scope (Early Phases)

- Authentication
- Business onboarding
- Review platform connection
- Review ingestion
- Review storage
- Review inbox and detail views
- Role-based access control
- Async task processing
- AI-assisted understanding and drafting

### 4.2 Explicitly Out of Scope (For Now)

- Billing and subscriptions
- Public APIs
- White-labeling
- Mobile apps
- Multi-language UI
- Competitive benchmarking
- Full analytics dashboards

*These may only be revisited after core stability.*

5. Phased Build Plan (Updated & Reconciled)
### Phase 0 — Infrastructure Lock-In

**Goal:** A foundation that will not be rewritten.

**Deliverables:**

- Supabase project initialized
- Migrations for spine tables
- RLS policies defined and tested
- pgTAP tests validating schema and policy intent
- Generated TypeScript DB types
- Edge Functions scaffold
- Next.js auth wiring (SSR safe)

**Exit Criteria:**

- Local DB reset works cleanly
- Auth and RLS are verified
- No schema drift between environments

**Status:** Largely complete

### Phase 1 — Business Creation (Spine Entry Point)

**Goal:** Users can create and own businesses.

**Deliverables:**

- `create_business` backend logic
- Automatic owner role assignment
- Create business UI
- Empty-state business dashboard

**Rules:**

- No real-world validation
- No review requirement
- No platform connection required

**Exit Criteria:**

- User can create multiple businesses
- Empty dashboard clearly communicates next steps

### Phase 2 — Review Platform Connection & Ingestion (Vertical Slice)

**Goal:** Reviews enter the system reliably.

**Deliverables:**

- Review source connection flow
- Credential storage
- Edge Functions for ingestion
- Normalization logic
- Duplicate protection
- Failure logging
- Async backfill on connection

**Exit Criteria:**

- Reviews appear incrementally after connection
- No ingestion blocks UI
- System tolerates partial or delayed data

### Phase 3 — Review Visibility & Control

**Goal:** Businesses can see and manage reviews.

**Deliverables:**

- Review inbox
- Review detail view
- Filtering and sorting
- Role-based access enforcement
- Manual review entry (fallback)

**Exit Criteria:**

- Users only see their own tenant data
- Permissions are respected across all views

### Phase 4 — Assisted Responses

**Goal:** AI assists without removing human judgment.

**Deliverables:**

- AI draft generation
- Approval workflow
- Editable drafts
- Response storage
- Posting back to platforms
- Audit trail

**Rules:**

- No auto-posting
- AI suggestions are optional

**Exit Criteria:**

- Clear review → response loop
- Full human control preserved

### Phase 5 — Root-Cause Review Clustering (Early Differentiator)

**Goal:** Help users understand patterns, not just individual reviews.

*This is not analytics. It is contextual assistance.*

#### Scope (v1)

- Semantic similarity within a single business
- Small local clusters (2–5 reviews)
- Recent reviews only
- Conservative similarity thresholds
- Neutral, factual labels

#### Technical Components

- Review embeddings (pgvector)
- Similarity search per review
- LLM-assisted cluster label generation
- Cached labels and relationships

#### UI

- Inline on review detail view
- Subtle indicators only
- Expand to show related reviews
- No charts, no metrics

**Exit Criteria:**

- Feature feels assistive, not noisy
- Most reviews may show nothing, and that is acceptable

### Phase 6 — Operational Maturity

**Goal:** Reliability and confidence at scale.

**Deliverables:**

- Monitoring and health checks
- Retry and backoff logic
- Integration status visibility
- Performance tuning
- Cleanup and maintenance tasks

## 6. Data & Schema Rules

- All schema changes go through `supabase/migrations`
- No direct Supabase UI edits
- RLS required on all tenant data tables
- Foreign keys are mandatory unless explicitly justified
- JSON only for truly unstructured data
- Tests validate intent, not runtime enforcement, due to superuser context.

## 7. File Structure Authority

**Canonical layout:**

- `/supabase` → CLI, migrations, functions, tests
- `/src` → Next.js app, components, server actions

No cross-contamination.

## 8. AI Usage Philosophy

- AI assists, never decides
- AI output is optional and contextual
- Neutral, factual language only
- Cached aggressively
- Safe failure modes by default

AI should evoke:

> "Oh, that's interesting."

Not:

> "The system says you must..."

## 9. Success Criteria

### Technical

- <500ms average API latency
- Zero cross-tenant data leaks
- Deterministic, repeatable migrations

### Product

- Time-to-first-review < 10 minutes after platform connection
- Clear ownership and role boundaries
- Reduced time spent reading repetitive reviews

## 10. Change Management

If this plan must change:

- Update this document first
- Explicitly justify the change
- Re-evaluate downstream impact

Unplanned divergence is technical debt.

## 11. Final Directive

Build the spine.  
Then add muscle.  
Then add intelligence.

When unsure, default to:

- Simpler
- Safer
- More explicit

This document exists to keep project_vega moving forward without losing coherence.
