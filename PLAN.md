
# RevuVista — Master Plan & Execution Guide

This document is the **authoritative source of truth** for the project_vega project.

All contributors (human or AI) must treat this file as **binding context**.  
If a task, feature, or design decision conflicts with this plan, the plan wins.

---

## 1. Project Overview

**RevuVista** is a multi-tenant SaaS platform that ingests customer reviews from external platforms (Google, Yelp, etc.), analyzes them, and assists businesses in responding intelligently and consistently.

The system is designed for:
- Small to mid-sized businesses
- High automation with human approval
- Strong data ownership and isolation
- Incremental feature growth without rewrites

---

## 2. Core Principles (Non-Negotiable)

### 2.1 Architecture Principles
- Supabase is the **system of record**
- PostgreSQL + RLS enforce all authorization
- Next.js App Router is the primary frontend
- Edge Functions handle ingestion and background work
- No business logic lives only in the frontend

### 2.2 Execution Principles
- Build vertically, but **stabilize the spine first**
- No premature abstraction
- No orphaned features
- No UI without a working backend path
- Migrations are the only way schema changes happen

### 2.3 AI Agent Rules
AI agents must:
- Read this file before proposing work
- Prefer incremental changes over rewrites
- Never invent schema, routes, or policies not described or approved
- Flag ambiguity instead of guessing

---

## 3. The Spine (Foundational System)

Everything in RevuVista is built on this backbone:

### 3.1 Identity & Tenancy
- `auth.users` (Supabase managed)
- `user_profiles`
- `businesses`
- `user_business_roles`

This defines:
- Who the user is
- Which businesses they belong to
- What role they have per business

### 3.2 Review Lifecycle
1. External review arrives (webhook / API)
2. Review is validated and normalized
3. Review is stored in `reviews`
4. Processing tasks are queued
5. AI suggestions are generated (later)
6. Human approves or edits
7. Response is posted back to source

If a feature does not connect to this lifecycle, it is likely out of scope.

---

## 4. Current Scope Boundaries

### 4.1 In Scope (Early Phases)
- Authentication
- Business onboarding
- Review ingestion
- Review storage
- Basic review listing
- Role-based access
- Task queue for background work

### 4.2 Explicitly Out of Scope (For Now)
- Billing and subscriptions
- Public APIs
- White-labeling
- Advanced analytics dashboards
- Mobile apps
- Multi-language UI

These may be revisited only after core stability.

---

## 5. Phased Build Plan

### Phase 0 — Infrastructure Lock-In
**Goal:** A stable foundation that will not be rewritten.

Deliverables:
- Supabase project initialized
- Migrations for core tables
- RLS policies for spine tables
- Generated TypeScript DB types
- Supabase Edge Functions scaffold
- Next.js auth wiring (SSR safe)

Exit Criteria:
- Local DB reset works cleanly
- Auth + RLS verified
- No schema drift between environments

---

### Phase 1 — Review Ingestion (Minimal Vertical Slice)
**Goal:** Reviews can enter the system reliably.

Deliverables:
- Webhook Edge Functions (Google, Yelp)
- Signature verification
- Review normalization logic
- `reviews` table populated
- Basic failure logging

Exit Criteria:
- Reviews appear in DB from external sources
- Duplicate protection works
- No UI required yet

---

### Phase 2 — Review Visibility & Control
**Goal:** Businesses can see and manage reviews.

Deliverables:
- Review list UI
- Review detail view
- Role-based access enforcement
- Manual review entry (fallback)

Exit Criteria:
- Business users can view only their data
- Staff vs admin permissions enforced

---

### Phase 3 — Assisted Responses
**Goal:** AI assists but humans stay in control.

Deliverables:
- AI draft generation
- Approval workflow
- Response storage
- Manual edit + post flow

Exit Criteria:
- No auto-posting without approval
- Full audit trail exists

---

### Phase 4 — Optimization & Insights
**Goal:** Make the system fast and useful at scale.

Deliverables:
- Caching
- Index tuning
- Basic analytics
- Monitoring and health checks

Exit Criteria:
- System handles realistic load
- No blind spots in failures

---

## 6. Data & Schema Rules

- All schema changes happen via `supabase/migrations`
- No direct edits in the Supabase UI
- RLS must exist for every table that contains tenant data
- Foreign keys are mandatory unless explicitly justified
- JSON is allowed only for truly unstructured data

---

## 7. File Structure Authority

Canonical layout:
Anything touching Supabase CLI belongs in `/supabase`.  
Anything imported by Next.js belongs in `/src`.

---

## 8. Success Criteria

### Technical
- <500ms average API latency
- Zero cross-tenant data leaks
- Deterministic migrations

### Product
- Time-to-first-review < 10 minutes
- Clear review → response workflow
- No user confusion about ownership or roles

---

## 9. Change Management

If this plan must change:
1. Update this file first
2. Justify the change explicitly
3. Re-evaluate downstream impact

Unplanned divergence is technical debt.

---

## 10. Final Directive

**Build the spine. Then add muscle. Then add intelligence.**

If unsure, default to:
- Simpler
- Safer
- More explicit

This document exists to keep the project moving forward without losing coherence.
