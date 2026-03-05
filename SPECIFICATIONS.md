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

> **Status: AWAITING NORTH MEMORIAL IDENTITY STANDARDS DOCUMENT**
>
> The UI design will align with North Memorial Health brand standards. The identity standards document is needed to define:
> - Primary and secondary color palette
> - Typography (font families, sizes, weights)
> - Logo usage rules and safe zones
> - Iconography style
> - Photography and imagery guidelines
> - Tone of voice for UI copy
>
> **Action Required:** Upload or provide the North Memorial Identity Standards document.

### General UI Principles (Pre-Brand)

- **High contrast** for readability in variable lighting (bright sunlight, dark ambulance)
- **Large touch targets** for gloved hands or moving vehicles
- **Dark mode** support (essential for night operations)
- **Minimal chrome** — maximize content area, minimize navigation overhead
- **Consistent navigation** — primary functions accessible within 2 taps from any screen
- **Accessible** — WCAG 2.1 AA compliance minimum; consider colorblind-safe palette
- **State-aware theming** — subtle visual cue indicating which jurisdiction's protocols are active (MN vs. WI vs. Air Medical)

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

## 16. Open Questions & Decisions

These items require discussion and decisions before implementation can proceed on the affected features.

### DECISION-001: Content Architecture Model

**Affects:** Specs 4.1, 4.4, 4.5, 7.1
**Status:** Needs Discussion
**Options:** Structured Data / PDF+Metadata Hybrid / PDF-First
**Recommendation:** Structured Data with phased migration (see Section 5)
**Discussion Points:**
- What is the acceptable timeline for migrating existing Lucid Chart PDFs to structured format?
- Can Lucid Chart export data in a structured format (JSON, XML) that could accelerate migration?
- Is there appetite for running both systems in parallel during transition?
- Who will be responsible for migrating existing content?

### DECISION-002: Authentication Approach

**Affects:** Specs 6.1, 6.2, 6.3
**Status:** Needs Decision
**Options:** SSO / Custom Auth / Hybrid
**Discussion Points:**
- Does NMHAS currently use Azure AD, Okta, or another identity provider?
- What identity systems do partner agencies (police, fire) use?
- Is IT available to support SSO integration, or is a self-contained system preferred?
- What are the password/security policies that must be enforced?

### DECISION-003: Pediatric Dosing Data Source

**Affects:** Spec 4.3
**Status:** Needs Decision
**Options:** License Handtevy / Build from own protocols / Other
**Discussion Points:**
- Is Handtevy-equivalent accuracy required, or is this a simplified dosing reference?
- Who validates dosing data for clinical accuracy?
- How frequently do pediatric dosing guidelines change?
- Are there regulatory requirements for dosing calculator certification?

### DECISION-004: Cross-Platform Framework

**Affects:** All platform targets
**Status:** Needs Decision
**Options:** Flutter / React Native / .NET MAUI / Kotlin Multiplatform / Other
**Discussion Points:**
- Does the team have existing expertise in any of these frameworks?
- Are there organizational technology standards that constrain this choice?
- Performance requirements for offline-first architecture may favor certain frameworks

### DECISION-005: AI Provider for Quiz Generation

**Affects:** Spec 7.1
**Status:** Needs Decision
**Options:** Claude API / OpenAI / On-device model / Custom ML
**Discussion Points:**
- Can clinical content be sent to a third-party AI API, or must generation happen on-premise?
- What review process is required before AI-generated questions are served to users?
- Should AI-generated questions be pre-generated and cached, or generated on-demand?
- Budget considerations for API usage at scale

### DECISION-006: Hosting & Infrastructure

**Affects:** Spec 12
**Status:** Needs Decision
**Options:** Cloud (AWS/Azure/GCP) / On-premise / Hybrid
**Discussion Points:**
- Existing infrastructure and cloud provider relationships
- HIPAA compliance requirements
- IT team capacity for infrastructure management
- Budget for cloud services vs. capital expenditure for on-premise

### DECISION-007: Web Application

**Affects:** Platform targets
**Status:** Needs Decision
**Discussion Points:**
- Is a web version needed, or are native apps sufficient?
- Web version could serve as the admin portal platform
- Progressive Web App (PWA) could provide a lightweight option for partner agencies

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
