# NMHAS Guideline Platform - Product Specifications

> **Document Status:** DRAFT - In Progress
> **Last Updated:** 2026-03-05
> **Owner:** Quality & Clinical Development
> **Target Users:** ~500-2,000 (EMS field personnel, first responders, partner agencies, admin/leadership)

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Platform Targets](#2-platform-targets)
3. [Current Capabilities to Retain](#3-current-capabilities-to-retain)
4. [Core Feature Specifications](#4-core-feature-specifications)
5. [Content Architecture](#5-content-architecture)
6. [Authentication & Permissions](#6-authentication--permissions)
7. [Learning & Retention System](#7-learning--retention-system)
8. [Gamification & Engagement](#8-gamification--engagement)
9. [Communication & Notifications](#9-communication--notifications)
10. [Usage Tracking & Analytics](#10-usage-tracking--analytics)
11. [Admin Portal](#11-admin-portal)
12. [Reliability & Infrastructure](#12-reliability--infrastructure)
13. [Branding & UI Design](#13-branding--ui-design)
14. [Nudge Theory Application](#14-nudge-theory-application)
15. [Design Principles](#15-design-principles)
16. [Open Questions & Decisions](#16-open-questions--decisions)

---

## 1. Project Overview

### Purpose

Build a proprietary guideline platform to replace the current third-party solution, giving NMHAS full control over features, roadmap, and user experience. The platform serves as a critical reference tool for EMS personnel in life-threatening situations and a continuous learning environment for protocol mastery.

### Jurisdictions

- **Minnesota** - State-specific protocols and regulatory standards
- **Wisconsin** - State-specific protocols and regulatory standards
- **Air Medical Service** - Specialized flight protocols

### Design Philosophy

- **Reduce friction.** Every tap, every second of load time, every moment of confusion is a barrier in a high-stakes environment.
- **Optimize for engagement.** The app should feel rewarding to use. Users should *want* to open it, not just *need* to.
- **Supportive but accountable.** The narrative tone encourages growth while reinforcing that protocol adherence is a professional responsibility.
- **Fun with purpose.** Gamification serves learning, not distraction.

---

## 2. Platform Targets

| Platform | Priority | Timeline |
|----------|----------|----------|
| Android (mobile) | **P0** - Launch | Phase 1 |
| iOS (mobile) | **P0** - Launch | Phase 1 |
| Windows (desktop) | P1 - Fast follow | Phase 2 |
| macOS (desktop) | P1 - Fast follow | Phase 2 |
| Web (browser) | **TBD** | TBD |

> **Note:** A cross-platform framework (e.g., Flutter, React Native, .NET MAUI) is recommended to serve all targets from a shared codebase. Framework selection is an [open decision](#16-open-questions--decisions).

---

## 3. Current Capabilities to Retain

These features exist today and must carry forward:

| Feature | Description |
|---------|-------------|
| **State-scoped protocols** | Separate guideline sets for MN, WI, and Air Medical |
| **Contact directory** | Contacts for interpreters, poison control, dispatch, and other resources |
| **Admin portal** | Upload and manage guidelines |
| **QA deployment** | Select users preview a deployment and provide feedback before full release |
| **PDF guideline upload** | Upload guidelines created in Lucid Chart (PDF format) |

### Enhancement: QA Deployment Feedback

The current QA deployment requires feedback *outside* the app. The new platform must support **in-app feedback during QA review**, including:

- Inline annotation/commenting on specific guideline content
- Approval/rejection workflow per reviewer
- Feedback summary dashboard for admins
- Version comparison (diff view) between current and proposed deployments

---

## 4. Core Feature Specifications

### 4.1 Protocol Cross-Linking (Priority: HIGH)

**Problem:** Difficult to link one protocol to another or to multiple protocols.

**Requirements:**

- Any guideline node, step, or page can link to one or more other guidelines
- Links are bidirectional (if Protocol A links to Protocol B, Protocol B shows a "Referenced by Protocol A" indicator)
- Links can be contextual (e.g., "If pediatric patient, see Pediatric Airway Protocol")
- Quick-navigate: tapping a link opens the target protocol, with a back-stack to return
- Admin portal: visual link management showing a relationship map between protocols
- Bulk link management when protocols are reorganized

### 4.2 In-App Feedback System (Priority: HIGH)

**Problem:** No way for users to provide feedback within the app.

**Requirements:**

- Users can submit feedback on any guideline (content questions, error reports, suggestions)
- Feedback tagged to specific guideline, section, and version
- Feedback categories: Error Report, Clarification Request, Suggestion, Other
- Optional screenshot/annotation attachment
- Admin dashboard for feedback triage, assignment, and resolution tracking
- Feedback status visible to submitter (Submitted, Under Review, Resolved, Declined)
- QA reviewers can provide deployment-specific feedback (see Section 3)

### 4.3 Pediatric Dosing Calculator (Priority: HIGH)

**Problem:** No pediatric dosing feature comparable to Handtevy.

**Requirements:**

- Weight-based and age-based dosing calculations
- Color-coded Broselow-style weight categories
- Medication doses pulled from the structured guideline data (single source of truth)
- Equipment sizing recommendations by weight/age
- Quick-access from any relevant protocol
- Offline-capable (all calculations must work without connectivity)
- Clear display of dose ranges, max doses, and concentration information
- Admin-configurable medication formulary and dosing rules

> **Decision Needed:** Should we license Handtevy data/methodology, or build our own dosing engine from our protocols? See [Open Questions](#16-open-questions--decisions).

### 4.4 Native Guideline Development Tool (Priority: HIGH)

**Problem:** Guidelines are developed externally in Lucid Chart, then uploaded as PDFs. No ability to make structured edits, bulk changes, or generate content from guideline data.

**Requirements:**

- Admin-facing guideline editor within the platform
- Follows NMHAS naming, shape, and content conventions (constrained editor, not freeform)
- Produces flowchart/decision-tree style guidelines matching current visual format
- Standard node types: Decision (diamond), Action (rectangle), Assessment (rounded), Alert/Warning (octagon/banner), Endpoint (oval), Reference/Link (arrow)
- Drag-and-drop layout with snap-to-grid
- Reusable content blocks (e.g., standard medication administration steps)
- Template library for common protocol structures
- Version history with diff comparison
- Collaborative editing with conflict resolution
- Export to PDF for external use or printing
- Content stored as structured data enabling cross-linking, search, bulk edits, and quiz generation

> **This is a major architectural decision.** See [Section 5: Content Architecture](#5-content-architecture) for a detailed discussion of the trade-offs.

### 4.5 Bulk Protocol Editing (Priority: HIGH)

**Problem:** When a dosage or medication changes, many documents must be individually changed and re-uploaded.

**Requirements:**

- Medications and dosages stored as shared data entities, referenced by protocols
- Changing a medication dose in one place propagates to all protocols that reference it
- "Impact analysis" view: before committing a change, see all protocols affected
- Batch update workflow with review and approval
- Change audit trail (who changed what, when, and why)
- Rollback capability for bulk changes

---

## 5. Content Architecture

> **Status: REQUIRES DISCUSSION**

This is the most consequential architectural decision for the platform. The content model determines what is possible across linking, editing, quiz generation, bulk updates, and search.

### Option A: Structured Data (Recommended)

Guidelines stored as structured decision trees — nodes, edges, conditions, actions, medications, dosages — in a database.

**Pros:**
- Enables deep cross-linking between protocols (Spec 4.1)
- Enables bulk medication/dosage updates across all protocols (Spec 4.5)
- Enables AI quiz generation from actual protocol content (Spec 7.1)
- Enables intelligent search across protocol content
- Enables the native guideline editor (Spec 4.4)
- Single source of truth for dosing calculator (Spec 4.3)
- Future-proof for AI-powered features

**Cons:**
- Largest upfront development effort
- Requires migrating existing PDF content into structured format
- Guideline editor must be well-designed or it becomes a bottleneck
- Risk: if the editor UX is poor, it could be harder to use than Lucid Chart

**Migration path:** Import existing PDFs alongside structured content during transition. Phase out PDFs as structured content matures.

### Option B: PDF + Metadata Hybrid

Keep PDFs as the visual format. Add a structured metadata layer alongside each PDF (tagged medications, dosages, links, keywords).

**Pros:**
- Lower initial effort
- Preserves current Lucid Chart workflow
- Metadata enables some automation (linking, search, bulk dose lookups)

**Cons:**
- Metadata can drift out of sync with PDF content
- Bulk edits still require re-uploading PDFs
- Quiz generation limited to metadata, not full protocol logic
- Two sources of truth creates maintenance burden

### Option C: PDF-First with Enhancements

Continue with PDF uploads. Add tagging, linking, and annotation on top.

**Pros:**
- Minimal disruption to current workflow
- Fastest to launch

**Cons:**
- Does not solve bulk editing (Spec 4.5)
- Severely limits quiz generation (Spec 7.1)
- Does not enable native editor (Spec 4.4)
- Cross-linking is manual and fragile
- Technical debt grows as feature demands increase

### Recommendation

**Option A (Structured Data)** is recommended because it is the foundation that makes most other high-value features possible. However, it requires the most upfront investment and a well-executed migration plan. A phased approach — launching with PDF support and building the structured editor in parallel — could balance risk and value.

---

## 6. Authentication & Permissions

> **Status: REQUIRES DECISION** on identity provider approach (SSO vs. custom vs. hybrid)

### 6.1 User Authentication (Priority: HIGH)

**Requirements:**

- Secure login required for all users
- Biometric authentication option (fingerprint, Face ID) for quick re-access after initial login
- Session persistence — users should not need to re-authenticate frequently during shifts
- "Quick access" mode: biometric or PIN unlock without full re-authentication
- Offline access with cached credentials (critical for areas with poor connectivity)
- Password reset / account recovery flow

### 6.2 Role-Based Access Control (Priority: HIGH)

**Requirements:**

Minimum role structure:

| Role | Access |
|------|--------|
| **Field User** | View assigned protocols, contacts, dosing tools, learning features, feedback submission |
| **QA Reviewer** | Field User + preview deployments, submit QA feedback |
| **Team Lead / Supervisor** | Field User + view team analytics, send messages to team |
| **Medical Director** | All clinical content + approval authority for protocol changes and deployments |
| **Admin** | Full platform management, user management, analytics, guideline editing |
| **Partner Agency User** | View only their agency's branded protocols and contacts |
| **Super Admin** | All Admin + system configuration, identity management, audit logs |

### 6.3 Multi-Tenancy / Agency Branding (Priority: MEDIUM)

**Problem:** Partner agencies (police, fire) need their own branded view with access limited to their protocols.

**Requirements:**

- Each partner agency is a "tenant" with its own:
  - Protocol set
  - Branding (logo, colors, agency name)
  - Contact directory
  - User roster
- NMHAS admins can manage all tenants
- Agency admins can manage only their own tenant's content and users
- Clean visual separation — users should immediately know which agency's protocols they're viewing

### Authentication Approach Options

> **Decision Needed**

| Approach | Pros | Cons |
|----------|------|------|
| **SSO (Azure AD, Okta, etc.)** | Leverages existing org identity; IT-managed; secure | Requires IT coordination; partner agencies may use different providers |
| **Custom auth** | Full control; works for all agencies regardless of IT infra | More to build and maintain; password management burden |
| **Hybrid** | SSO for internal staff, custom for partner agencies | Most flexible but most complex; two auth paths to maintain |

---

## 7. Learning & Retention System

### 7.1 AI-Powered Quiz Generation (Priority: HIGH)

**Problem:** No native learning system exists.

**Requirements:**

- Generate quizzes from selected guideline content using AI
- Two quiz types:
  - **Scenario-based:** Clinical scenario with decision points, testing protocol application
  - **Recall:** Direct knowledge questions about medications, dosages, procedures, indications
- User-configurable quiz scope:
  - All protocols
  - Selected protocols (focused study)
  - Protocols from a specific scope (MN, WI, Air Medical)
  - Randomly selected across all assigned protocols
- User-selectable quiz frequency/interval
- Immediate feedback with correct answers and protocol references
- Performance tracking per user, per protocol, per question type
- Adaptive difficulty based on user performance
- Link back to source protocol from quiz results for review

### 7.2 Spaced Repetition System (Priority: HIGH)

**Problem:** No spaced repetition feature for long-term retention.

**Requirements:**

- Implement evidence-based spaced repetition algorithm (e.g., SM-2 or similar)
- Protocols and knowledge items scheduled for review at increasing intervals based on recall success
- Integration with quiz system — quiz performance feeds the repetition scheduler
- Dashboard showing:
  - Items due for review
  - Mastery level per protocol
  - Predicted retention curves
- Push notifications when reviews are due (see Section 9)
- Prioritization logic:
  - High-acuity / low-frequency protocols get more repetition
  - Recently updated protocols get immediate review cycles
  - User's weak areas get targeted reinforcement

### 7.3 Usage-Driven Learning (Priority: MEDIUM)

**Problem:** No way for users to track their real-world protocol usage to inform learning.

**Requirements:**

- Users can log protocol usage after a call (quick-log: protocol used, patient type, outcome category)
- System identifies:
  - **Frequently used protocols** — follow up to ensure correct application and current knowledge
  - **Infrequently used protocols** — proactively push review and quizzes to prevent knowledge decay
  - **Rare presentations** — flag and celebrate when encountered; push refresher content
- AI-driven recommendations: "You haven't reviewed Tension Pneumothorax in 45 days. Take a quick quiz?"
- Aggregate (anonymized) usage data available to admins for system-wide training gap analysis

---

## 8. Gamification & Engagement

### 8.1 Badge & Achievement System (Priority: MEDIUM)

**Requirements:**

- Badges awarded for milestones across multiple categories:

| Category | Example Badges |
|----------|---------------|
| **Protocol Mastery** | "Cardiac Ace" — mastered all cardiac protocols; "Full Spectrum" — reviewed every protocol |
| **Quiz Performance** | "Perfect Score" — 100% on a quiz; "Streak Master" — 7-day quiz streak |
| **Rare Encounters** | "Needle Decompression" — logged a rare procedure usage |
| **Consistency** | "Daily Reviewer" — opened the app 30 days in a row; "Night Owl" — studied during night shift |
| **Community** | "Helpful Voice" — submitted 10 feedback items; "Mentor" — (future: helped a colleague) |
| **Milestones** | "First Quiz", "100 Quizzes", "1 Year on Platform" |

- Badge display on user profile
- Progress indicators for in-progress badges
- Optional badge visibility to team (opt-in leaderboard)
- New badge notifications with celebratory animation
- Admin-configurable: add/modify badges and their criteria

### 8.2 Engagement Loops

**Requirements:**

- Daily check-in streak tracking
- Progress bars for protocol mastery (per protocol and overall)
- "Completionist" tracking — percentage of protocols reviewed, quizzes taken, etc.
- Micro-celebrations for small wins (subtle animations, encouraging messages)
- Weekly/monthly summary: "This week you reviewed 12 protocols and scored 94% on quizzes"
- Avoid punitive mechanics — no penalties for missing a day, only positive reinforcement
- Tone: supportive, encouraging, professionally motivating

> **Engagement vs. Distraction:** Gamification elements must never interfere with the primary use case — fast protocol access in emergencies. All engagement features should be in dedicated sections of the app, not overlaid on clinical content.

---

## 9. Communication & Notifications

### 9.1 Push Notifications (Priority: HIGH)

**Requirements:**

- Notification types:
  - Guideline update alerts ("Cardiac Arrest protocol updated — review changes")
  - Quiz reminders (spaced repetition schedule)
  - Deployment previews (QA review requests)
  - Messages from admins/leadership
  - Badge/achievement earned
  - Feedback status updates
- User-configurable notification preferences (which types, quiet hours, frequency)
- Critical notifications (guideline updates, safety alerts) can be marked non-dismissable by admin
- Notification history viewable in-app

### 9.2 In-App Messaging (Priority: MEDIUM)

**Problem:** No way for admins, medical directors, or leaders to send messages to groups or individuals.

**Requirements:**

- Send messages to:
  - Individual users
  - User groups (by role, agency, state, custom group)
  - All users
- Message types:
  - Announcements (one-way, broadcast)
  - Direct messages (two-way between admin/leadership and users)
- Read receipts for critical messages
- Message archive and search
- Rich content support (formatted text, links to protocols, images)
- Admin dashboard for message analytics (sent, delivered, read rates)

---

## 10. Usage Tracking & Analytics

### 10.1 User Analytics (Priority: HIGH)

**Requirements:**

- Track per user:
  - Login frequency and session duration
  - Protocols viewed (which, how often, how long)
  - Quiz performance (scores, trends, weak areas)
  - Spaced repetition adherence
  - Feedback submissions
  - Badge/achievement progress
  - Protocol usage logs (self-reported field usage)
- Privacy considerations:
  - Users can see their own data
  - Supervisors see aggregate team data, not individual granular data (configurable by admin)
  - Medical directors and admins see system-wide analytics
  - Clear data retention policies

### 10.2 System Analytics (Priority: MEDIUM)

**Requirements:**

- Platform-wide dashboards:
  - Most/least viewed protocols
  - Quiz performance trends across the organization
  - Knowledge gap identification (protocols with consistently low quiz scores)
  - User engagement trends
  - Notification effectiveness
  - Feedback volume and resolution times
- Exportable reports for leadership review
- Configurable date ranges and filters

---

## 11. Admin Portal

### 11.1 Core Admin Functions

- User management (create, deactivate, assign roles, assign agency)
- Guideline management (create, edit, version, deploy)
- Deployment management (QA preview, staged rollout, full deployment, rollback)
- Contact directory management
- Feedback triage and resolution
- Message composition and sending
- Badge/achievement configuration
- Quiz review and override (review AI-generated questions for accuracy)
- Analytics dashboards
- System configuration and settings
- Audit logs (who did what, when)

### 11.2 Deployment Workflow

1. Admin creates or modifies guidelines
2. Admin creates a deployment (set of guideline changes)
3. Deployment sent to QA reviewers
4. QA reviewers provide in-app feedback
5. Admin reviews feedback, makes adjustments
6. Medical Director approval (if required)
7. Admin triggers full deployment
8. Push notification sent to affected users
9. Spaced repetition system flags updated protocols for review

---

## 12. Reliability & Infrastructure

### 12.1 Uptime & Performance (Priority: CRITICAL)

**This app is used during life-threatening emergencies. Downtime or slow load times are unacceptable.**

**Requirements:**

- **Target uptime:** 99.9% (less than 8.8 hours downtime per year)
- **Offline mode:** Full guideline access, dosing calculator, and contacts must work without internet
- **Sync strategy:** Background sync when connectivity is available; conflict resolution for offline changes
- **Load time:** Guideline content must render in under 2 seconds on a modern device
- **Data caching:** Aggressive local caching of all clinical content
- **Failover:** Redundant backend infrastructure with automatic failover
- **Monitoring:** Real-time uptime monitoring with alerting to IT/admin
- **Disaster recovery:** Documented backup and recovery procedures; RPO < 1 hour, RTO < 4 hours

### 12.2 Security (Priority: CRITICAL)

**Requirements:**

- Data encrypted at rest and in transit (TLS 1.2+)
- HIPAA compliance considerations (if any patient-adjacent data is stored)
- Biometric data handled per platform standards (never stored server-side)
- Regular security audits and penetration testing
- Role-based access enforced server-side (not just client-side)
- Session management with configurable timeouts
- API security (rate limiting, input validation, authentication on all endpoints)
- Secure credential storage (platform keychain)
- Audit logging for all admin and data-modification actions

### 12.3 Offline-First Architecture

Given the operational environment (ambulances, remote areas, in-flight), the app must be **offline-first**:

- All clinical content (protocols, dosing data, contacts) cached locally after initial sync
- Quizzes can be generated and taken offline (pre-cached question banks)
- Usage logs, feedback, and quiz results queued locally and synced when online
- Clear UI indicator of online/offline status and last sync time
- No feature should fail silently due to lack of connectivity — graceful degradation with user-visible status

---

## 13. Branding & UI Design

> **Status: DEFINED** — Based on North Memorial Health Identity Standards v9.7 (October 2025)

### 13.1 Color System

#### Primary Palette

| Name | PMS | Hex | RGB | Usage |
|------|-----|-----|-----|-------|
| Teal | 3262 | `#00b0ad` | 0/176/173 | Primary brand, interactive elements, links, large text headings |
| Orange/Red | 1665 | `#e04726` | 224/71/38 | Alerts, critical actions, emphasis, urgent indicators |
| Gray | 7540 | `#4b4f54` | 75/79/84 | Body text, secondary UI elements |
| Gold | 1235 | `#fcb526` | 255/184/38 | Highlights, badges, achievements, warnings |

Each primary color has approved tints at 75%, 50%, and 25%/35% opacity for use in backgrounds, dividers, and subtle accents.

#### Secondary Palette

Secondary colors must always be paired with their corresponding primary — never used alone.

| Name | PMS | Hex | Pairs With | Usage |
|------|-----|-----|-----------|-------|
| Dark Teal | 548C | `#00383d` | Teal | Dark mode backgrounds, headers, depth |
| Dark Red | 490C | `#60151E` | Orange/Red | Critical alerts in dark mode, error states |
| Dark Brown | 1535C | `#762d10` | Orange/Red | Accent in dark/warm contexts |
| Light Gray | Cool Gray 3C | `#D6D6D6` | Gray | Backgrounds, dividers, disabled states |

Secondary colors must not overpower primary colors — limited to less than 50% of any screen or component.

#### Functional Color Mapping

| Function | Light Mode | Dark Mode | Notes |
|----------|-----------|-----------|-------|
| Background | `#FFFFFF` | `#00383d` (Dark Teal) | Brand-aligned dark mode background |
| Surface | `#F5F5F5` | `#0A4A4D` | Slightly lighter than dark background |
| Text Primary | `#4b4f54` (Gray) | `#FFFFFF` | Gray passes AA on white at 5.9:1 |
| Text Secondary | `#6B7280` | `#D6D6D6` (Light Gray) | |
| Success | `#00b0ad` (Teal) | `#00b0ad` | Consistent across modes |
| Warning | `#fcb526` (Gold) | `#fcb526` | Consistent across modes |
| Error/Critical | `#e04726` (Orange/Red) | `#e04726` | Consistent across modes |

### 13.2 Typography

| Role | Font | Fallback | Weight | Usage |
|------|------|----------|--------|-------|
| Display / H1 | Gotham Bold | Arial Bold | 700 | Screen titles, hero elements |
| Heading / H2-H3 | Gotham Medium | Arial Bold | 500 | Section headers, card titles |
| Body | Gotham Book | Arial | 400 | Protocol text, descriptions |
| Caption / Meta | Gotham Light | Arial | 300 | Timestamps, secondary labels |

> **Font licensing note:** Gotham is a commercial typeface (Hoefler & Co.). Licensing for mobile app embedding must be confirmed before development begins. If licensing is not feasible, Arial is the approved digital fallback per brand standards. See [DECISION-008](#decision-008-gotham-font-licensing).

### 13.3 Logo Usage

- **Mark:** Capital "N" masterbrand with "North Memorial Health" wordmark
- **Variants available:** Full color, reversed/white (with colored N or solid white), grayscale, black
- **Clear space:** 2x the width of the rectangles in the "N" mark on all sides
- **Minimum sizes (digital):** Full logo: 168px wide; N mark alone: 24px wide
- **Placement:** Top-left of app header or centered on splash/login screens
- **Restrictions:** Do not alter colors, stretch, rotate, add effects, or place on busy backgrounds without sufficient contrast
- **N mark alone:** May only be used when the full logo appears elsewhere on the same screen (e.g., splash screen → header)
- **Sub-brand logos** (Ambulance, Air Care, etc.) follow locked placement rules — contact Marketing for files

### 13.4 Brand Voice in UI

- **Personality:** Thoughtful, Passionate, Friendly
- **Tone:** Fresh, modern, clean
- **Informal reference:** "You can call us North" — use "North" in conversational UI (nudge messages, encouragement); use "North Memorial Health" in legal, login, and official contexts
- **Application:** Active, direct language; warmth and empathy in all user-facing copy; aligns with nudge messaging guidelines in Section 14.5

### 13.5 Accessibility & Contrast

**Standard:** WCAG 2.1 AA minimum (per brand identity standards and app requirements)

| Combination | Contrast Ratio | AA Status | Usable For |
|-------------|---------------|-----------|------------|
| Gray `#4b4f54` on White | 5.9:1 | **PASS** | Body text, all text sizes |
| Orange/Red `#e04726` on White | 3.9:1 | Large text only | Headings 18px+, icons, UI elements |
| Teal `#00b0ad` on White | 3.0:1 | **FAIL** for body text | Large text 18px+, icons, interactive elements only |
| Gold `#fcb526` on White | 1.8:1 | **FAIL** | Backgrounds/fills only — never as text on white |
| White on Dark Teal `#00383d` | High | **PASS** | Dark mode text |
| Gold `#fcb526` on Dark Teal | High | **PASS** | Dark mode badges, highlights |

> **Key constraint:** Body text must use Gray (`#4b4f54`), not Teal or Gold. Teal may be used for headings 18px+ and interactive elements (buttons, links) where the touch target provides sufficient visual weight.

### 13.6 Dark Mode Strategy

Dark mode is essential for night operations (ambulance, in-flight). The brand's secondary palette provides dark mode foundations:

- **Background:** Dark Teal `#00383d` — brand-aligned, avoids generic pure black
- **Surface:** `#0A4A4D` — lighter variant for cards, modals
- **Text:** White primary, Light Gray `#D6D6D6` secondary
- **Accent:** Teal `#00b0ad` remains usable on dark backgrounds with good contrast
- **Alerts:** Orange/Red `#e04726` and Gold `#fcb526` maintain visibility on dark backgrounds
- **Critical states:** Dark Red `#60151E` for severe error backgrounds in dark mode

### 13.7 State-Aware Theming

Each jurisdiction gets a subtle accent color to differentiate active protocol scope:

| Jurisdiction | Accent Color | Rationale |
|-------------|-------------|-----------|
| Minnesota | Teal `#00b0ad` | Primary brand color as default scope |
| Wisconsin | Gold `#fcb526` | Visually distinct, warm |
| Air Medical | Orange/Red `#e04726` | High energy, urgency-appropriate |

Theming applies to: header accent bar, scope indicator badge, navigation highlight. Core UI (text, backgrounds, buttons) remains consistent across scopes to maintain usability and reduce cognitive load.

### 13.8 General UI Principles

- **High contrast** for readability in variable lighting (bright sunlight, dark ambulance)
- **Large touch targets** for gloved hands or moving vehicles
- **Dark mode** support (essential for night operations — see Section 13.6)
- **Minimal chrome** — maximize content area, minimize navigation overhead
- **Consistent navigation** — primary functions accessible within 2 taps from any screen
- **Accessible** — WCAG 2.1 AA compliance minimum; colorblind-safe palette (see Section 13.5)
- **State-aware theming** — subtle visual cue indicating which jurisdiction's protocols are active (see Section 13.7)

---

## 14. Nudge Theory Application

Nudge theory guides users toward desired behaviors through subtle design choices rather than mandates. Here is how it will be applied throughout the platform:

### 14.1 Default Nudges

| Nudge | Mechanism | Target Behavior |
|-------|-----------|-----------------|
| **Smart home screen** | Show "due for review" protocols prominently on launch | Regular protocol review |
| **Pre-selected quiz scope** | Default quiz scope to protocols due for spaced repetition | Adherence to learning schedule |
| **Streak visibility** | Display current streak prominently (but no punishment for breaking it) | Daily engagement |
| **Progress anchoring** | Show "You're 78% through Cardiac protocols" rather than "22% remaining" | Completion motivation |
| **Social proof** | "87% of your peers have reviewed the updated protocol" | Timely review of updates |

### 14.2 Choice Architecture

| Nudge | Mechanism | Target Behavior |
|-------|-----------|-----------------|
| **Friction reduction for good behavior** | One-tap quiz start, auto-populated feedback forms | More quizzes, more feedback |
| **Friction addition for risky behavior** | Confirmation step when dismissing a guideline update notification | Protocol currency |
| **Opt-out defaults** | Quiz reminders ON by default (user can adjust) | Learning engagement |
| **Chunking** | Break large protocol sets into small daily review doses | Avoid overwhelm; build habits |

### 14.3 Timely Interventions

| Nudge | Mechanism | Target Behavior |
|-------|-----------|-----------------|
| **Post-call nudge** | After logging a protocol usage, prompt a quick refresher quiz on that protocol | Reinforce just-used knowledge |
| **Shift-start prompt** | At the beginning of a shift (time-of-day based), surface a quick protocol review | Start-of-shift engagement |
| **Update salience** | When a protocol the user frequently accesses has been updated, make the "updated" badge persistent until reviewed | Awareness of changes |
| **Celebration timing** | Award badges immediately, not in batch — maximize the dopamine hit | Positive reinforcement |

### 14.4 Feedback Loops

| Nudge | Mechanism | Target Behavior |
|-------|-----------|-----------------|
| **Visible progress** | Mastery bars, completion percentages, learning velocity graphs | Self-motivated improvement |
| **Personalized insights** | "Your cardiac protocol mastery improved 15% this month" | Ownership of growth |
| **Gentle accountability** | "It's been 30 days since your last quiz — your retention may have dropped. Quick refresh?" (never punitive) | Sustained engagement |
| **Comparative framing** | Optional: "You're in the top 20% of protocol reviewers this month" (opt-in only) | Healthy aspiration |

### 14.5 Narrative Tone for Nudges

All nudge messaging follows the design philosophy: **supportive but stressing responsibility and accountability.**

- **Do:** "Staying sharp saves lives. Ready for a quick review?"
- **Do:** "You've mastered 12 protocols this month. Your patients are in good hands."
- **Do:** "The Cardiac Arrest protocol was updated yesterday. Review the changes to stay current."
- **Don't:** "You haven't studied in 5 days. You're falling behind."
- **Don't:** "Your score is below average."
- **Don't:** Guilt-based or fear-based messaging

---

## 15. Design Principles

### 15.1 Emergency-First

The primary use case — accessing a protocol during an emergency — must never be compromised by secondary features. Protocol access must be:
- Fast (under 2 seconds to render)
- Uncluttered (no gamification UI overlaid on clinical content)
- Reliable (works offline, no loading spinners in critical moments)
- Navigable (search, browse, recent, favorites — multiple paths to the same content)

### 15.2 Progressive Disclosure

- First-time users see a clean, simple interface
- Advanced features (analytics, learning tools, gamification) reveal as users engage
- Settings and customization are available but not pushed
- Complexity scales with user sophistication

### 15.3 Dopamine-Optimized (With Guardrails)

- Celebrate small wins with micro-animations and encouraging copy
- Progress visualization (bars, percentages, streaks) creates momentum
- Badge unlocks provide collection satisfaction
- Weekly summaries create reflection and pride moments
- **Guardrail:** No dark patterns. No artificial urgency. No loss aversion mechanics. No pay-to-win. Engagement must serve learning, not addiction.

### 15.4 Accountability Without Anxiety

- Users know their engagement is tracked — this is transparent and expected in a clinical environment
- Framing is always growth-oriented: "Here's where you can improve" not "Here's where you failed"
- Supervisors see team trends, not individual surveillance (configurable)
- The system is a tool for self-improvement first, organizational oversight second

---

## 16. Decisions Log

All architectural and technology decisions have been resolved. Documented here for reference.

### DECISION-001: Content Architecture Model — RESOLVED

**Affects:** Specs 4.1, 4.4, 4.5, 7.1
**Decision:** **Structured Data** with phased migration
**Rationale:** Structured data is the foundation for cross-linking, bulk editing, quiz generation, and the native guideline editor. Launch with PDF upload support for backward compatibility; build the structured editor in parallel. Phase out PDFs as structured content matures.

### DECISION-002: Authentication Approach — RESOLVED

**Affects:** Specs 6.1, 6.2, 6.3
**Decision:** **Custom auth first**, SSO-ready architecture
**Rationale:** Custom authentication (email/password + biometric) for all users at launch. Architecture designed to add SSO (Azure AD, Okta) for internal NMHAS staff as a future enhancement. Custom auth ensures partner agencies (police, fire) can onboard regardless of their IT infrastructure.

### DECISION-003: Pediatric Dosing Data Source — RESOLVED

**Affects:** Spec 4.3
**Decision:** **Build from own protocols**
**Rationale:** With Structured Data architecture (DECISION-001), medications and dosages live in the structured content model. The dosing calculator pulls directly from NMHAS protocols — single source of truth, always current. Medical Director validates dosing data as part of the protocol approval workflow.

### DECISION-004: Cross-Platform Framework — RESOLVED

**Affects:** All platform targets
**Decision:** **Flutter** (Dart)
**Rationale:** Best offline-first tooling (Hive, Drift), superior PDF rendering (Syncfusion), cohesive theming system for dark mode, unified desktop support (same rendering engine on all platforms), and AOT-compiled performance with no bridge overhead. Dart is straightforward to learn for developers with Java/JS/C# experience.

### DECISION-005: AI Provider for Quiz Generation — RESOLVED

**Affects:** Spec 7.1
**Decision:** **Claude API** (Anthropic)
**Rationale:** Strong structured reasoning for clinical scenarios and protocol-based question generation. Questions pre-generated server-side and cached for offline use. All AI-generated questions go through human review (Medical Director or designee) before being served to users.

### DECISION-006: Hosting & Infrastructure — RESOLVED

**Affects:** Spec 12
**Decision:** **Firebase / Google Cloud Platform (GCP)**
**Rationale:** Firebase pairs naturally with Flutter (same Google ecosystem). Firestore for real-time data sync with offline persistence, Firebase Auth for custom authentication, Cloud Functions for server-side logic (quiz generation, notifications), and Firebase Cloud Messaging (FCM) for push notifications. Managed infrastructure with 99.95% SLA.

### DECISION-007: Web Application — RESOLVED

**Affects:** Platform targets
**Decision:** **Yes** — Admin portal (authenticated) + public protocol viewer (no login, shareable links)
**Rationale:** Admin portal as web app gives admins browser-based access for guideline management, analytics, and user management without requiring a native app install. Public protocol viewer allows shareable links to specific protocols for reference and training without requiring authentication — accessible to partner agencies and external stakeholders.

### DECISION-008: Gotham Font Licensing — RESOLVED

**Affects:** Spec 13.2 (Typography), all UI development
**Decision:** **Open-source alternative** (Montserrat)
**Rationale:** Montserrat is a geometric sans-serif that closely matches Gotham's visual character. Available via Google Fonts, free for all use including mobile app embedding. Avoids commercial licensing cost and procurement delays. Can be swapped for licensed Gotham later if desired with minimal layout impact.

---

## Appendix A: Feature Priority Summary

| Priority | Features |
|----------|----------|
| **CRITICAL** | Offline-first architecture, uptime/reliability, security |
| **P0 (Launch)** | Protocol viewing, state scoping, contacts, admin portal, authentication, PDF upload support |
| **P1 (Fast Follow)** | Cross-linking, in-app feedback, push notifications, pediatric dosing, basic analytics |
| **P2 (Phase 2)** | Native guideline editor, bulk editing, quiz generation, spaced repetition, badge system |
| **P3 (Phase 3)** | In-app messaging, usage-driven learning, advanced analytics, partner agency multi-tenancy |
| **Desktop** | Windows and macOS apps |

> **Note:** Priorities are preliminary and subject to revision based on open decisions and stakeholder input.

## Appendix B: Glossary

| Term | Definition |
|------|------------|
| **Protocol** | A clinical guideline defining assessment and treatment procedures |
| **Deployment** | A versioned release of protocol changes to users |
| **QA Deployment** | A pre-release deployment sent to select reviewers for feedback |
| **Tenant** | An organizational unit (agency) with its own branded protocol set |
| **Spaced Repetition** | An evidence-based learning technique that schedules reviews at increasing intervals |
| **Nudge** | A design choice that subtly guides users toward desired behaviors without restricting freedom |
| **Scope** | A jurisdictional or service-line grouping of protocols (MN, WI, Air Medical) |
