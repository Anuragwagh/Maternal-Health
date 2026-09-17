Product Requirements Document (PRD)
Maternal Health App — "Integrating Digital Care into India's Existing ASHA Workflow"
Platform: Flutter (Android/iOS) Current Phase: MVP (Functional Prototype) Positioning: A digital layer that plugs into and strengthens the existing ASHA / public maternal health system — not a parallel app competing with it.

0. Research Basis (Why the Priorities Below Are Ordered This Way)
Before phasing the roadmap, we grounded it in documented, real-world ASHA digitalization experience rather than assumptions:

Connectivity blocks OTP itself. Field studies report frontline workers frequently failing to receive OTPs needed to log into government apps, especially in low-network areas — meaning an OTP-gated login is a reliability risk for the ASHA side specifically, not just a UX inconvenience.
Duplicate data entry is a named grievance, not a minor friction. ASHAs already work across multiple mandated apps and portals (e.g., ANMOL, Ni-Kshay, state health surveys) in addition to paper registers, because poor connectivity and app glitches force them to keep paper as backup — effectively doubling their workload with no extra pay.
GPS/location-tracking features are perceived as surveillance, not support. A state-mandated app with real-time GPS tracking of ASHA movement was collectively rejected by ASHA unions and ultimately withdrawn. Any "visit verification" feature must be framed and built as ASHA-controlled proof-of-work, not passive tracking.
Digital literacy is a harder constraint than language. A 2025 government survey found 64% of rural women cannot perform basic smartphone tasks — trilingual text alone does not solve this; icon-led and voice-assisted design is necessary, not a nice-to-have.
Lack of feedback loops reduces motivation. ASHAs report entering data repeatedly without seeing how it improves their own work or their patients' outcomes — a tool that only takes input without showing value back will face the same adoption resistance as existing government apps.
Real workflow structure to build around: ASHAs already work to specific scheme mechanics — identifying and registering pregnant women, ensuring a minimum of 3 ANC checkups, flagging High-Risk Pregnancies (HRP) via a red/green sticker system on the Mother and Child Protection card, fixing an institutional delivery location by the 7th month, and aligning follow-ups to the fixed PMSMA date (9th of every month). Incentive payments under JSY/PMSMA are tied to visit counts and verified outcomes. This is the actual process the app should mirror — not a generic "reminders app."
These findings directly shaped which features are Phase 1 versus later.

1. Problem Statement
India's maternal health outcomes are delivered largely through the ASHA (Accredited Social Health Activist) network — over 1 million community health workers who track pregnancies, remind mothers about checkups, and escalate risk cases. This system works, but it runs almost entirely on paper registers, memory, and manual visits.

The result:

ASHA workers manage 20–25+ pregnant women each with no digital prioritization — every case looks equally urgent until a paper register is manually flipped through.
Missed medication (iron, calcium, folic acid) is the single biggest preventable contributor to maternal anemia and complications, but there is no real-time visibility into adherence.
Expecting mothers, especially in rural/semi-urban areas, have no digital companion for diet, vaccine, and medicine guidance between ASHA visits.
Existing government digital efforts (ABDM, Anmol, RCH portal) are data-entry systems for the state, not workflow tools for the ASHA worker or the mother.
Our thesis: We don't need to replace the ASHA system — we need to give it a digital nervous system.

2. Solution Overview
A two-sided Flutter app that mirrors the real-world relationship between an ASHA worker and her assigned patients, and digitizes the exact tasks she already does — visit tracking, risk monitoring, and follow-ups — while giving the mother a simple, trilingual self-care companion between visits.

Patient App	ASHA Worker App
Core job	Daily self-tracking + guidance	Multi-patient monitoring + prioritization
Replaces	Nothing (new habit)	Paper register
Key value	"I know what to do today"	"I know who needs me today"
3. Target Users
Expecting Mothers — rural/semi-urban, variable literacy and connectivity, need simple daily guidance and reassurance.
ASHA Workers — manage 20–25+ patients simultaneously, are paid partly via incentive schemes tied to visit completion, and need to triage who's at risk today, not scroll through everyone.
(Roadmap) PHC Supervisors / District Health Officers — need rollup visibility across ASHA workers for program monitoring.
4. Core Features — Currently Implemented (MVP)
4.1 Foundation
Trilingual support (English, Hindi, Marathi) — language selection is the first screen.
Role-based access — Patient vs. ASHA Worker, each with a distinct auth flow and dashboard.
Material 3 UI with maternal-specific, high-accessibility color system.
4.2 Patient Module
Phone number + OTP login flow
Home dashboard: next checkup countdown, diet plans by pregnancy stage, vaccine due dates, daily medicine tracker (Calcium, Iron, Folic Acid)
AI chatbot widget for immediate maternal health queries
Patient history/profile view
4.3 ASHA Worker Module
ASHA-specific login
Dashboard summary: total patients, active alerts, visits scheduled today
Emergency Alert System: auto-triggers when a patient misses medication 3+ consecutive days, prompting a call or in-person visit
Patient roster: name, pregnancy month, live status (Stable / High BP Alert / Due for Vaccine)
5. What Makes This "Workflow-Integrated" (Judge-Facing Differentiator)
This is the section that separates this from a generic health-tracking app. Every feature below is designed to slot into a task the ASHA worker or government scheme already requires, rather than inventing new behavior.

Existing Workflow / Scheme	How the App Plugs In
ASHA home visit register (paper-based)	Digital visit logging with timestamp — replaces the register, doesn't duplicate it
JSY (Janani Suraksha Yojana) incentive payouts, tied to visit + institutional delivery completion	App tracks visit completion status per patient, giving ASHA a ready proof-of-work log for incentive claims
PMSMA (Pradhan Mantri Surakshit Matritva Abhiyan) — fixed-day antenatal checkups	Checkup tracker aligns reminder dates to PMSMA's fixed-day schedule instead of generic reminders
ABDM (Ayushman Bharat Digital Mission) health ID	Roadmap: patient records structured to be ABDM-ID compatible for future interoperability with government health records
ASHA's existing risk-escalation habit (call → visit → refer to PHC)	Emergency Alert System mirrors this exact 3-step decision, digitized, instead of introducing a new process
The pitch line for judges: "We didn't design a new maternal health process. We digitized the one ASHA workers already run, so adoption doesn't require retraining — it requires a phone."

6. Roadmap in Phases — Current State → Next Priority
Phasing is ordered by what unblocks real rural/ASHA adoption first, not by build difficulty. A feature that looks technically impressive but ignores connectivity or literacy constraints will fail in the field the way earlier government apps did.

Phase 0 — Current State (Built)
What exists today, as validated in Section 4:

Language selection (English/Hindi/Marathi) + role-based routing
Patient: OTP login, dashboard (checkup tracker, diet, vaccines, medicines), chatbot widget, profile
ASHA: login, summary dashboard, missed-medication alert (3+ days), flat patient roster
Material 3 UI, mocked/local data only
Gap this phase leaves open: everything currently assumes an always-online, always-legible-to-everyone user. That assumption breaks first for the ASHA worker, not the patient.

Phase 1 — Rural & ASHA-Critical Foundations (Next Priority)
These are prioritized first because the research above shows they are where existing government apps actually fail in the field — fixing them is higher-leverage than adding new features.

True offline-first architecture (not "nice to have," foundational) — local storage (Hive/SQLite) with a sync queue, so a missed connection never means lost data. This directly answers the "data disappears" failure mode reported by ASHAs and ANMs in the field.
Non-OTP-dependent ASHA login — cached/offline session login for the ASHA app specifically (e.g., PIN or biometric after first successful online auth), since OTP delivery itself is unreliable in low-network areas. Patient login can retain OTP but needs a clear offline-retry state instead of a dead end.
Risk-prioritized patient roster — sort by urgency (HRP flag, missed medication, overdue checkup) instead of a flat list, so an ASHA managing 20–25+ patients can triage in seconds, not scroll.
One-tap, low-bandwidth visit logging — timestamped visit confirmation that syncs when connectivity returns; GPS/photo attached only as an opt-in the ASHA controls, never silent background tracking — directly avoiding the surveillance backlash pattern seen with GPS-mandated apps.
Icon-led, voice-assisted UI — audio prompts and icon-first navigation layered on top of trilingual text, since text literacy cannot be assumed even with language support solved.
Single-entry data design — whatever an ASHA logs once (a visit, a symptom, a missed dose) auto-populates every downstream view (roster status, incentive log, patient timeline) rather than requiring re-entry in multiple places, directly targeting the "double workload" complaint.
Phase 2 — Adoption & Incentive Alignment
ASHA feedback loop / impact view — a simple "your impact this month" view (checkups completed, HRPs flagged, incentive-eligible visits) so data entry visibly pays back to the worker, not just the system.
Government scheme + incentive tracker — maps logged visits to JSY/PMSMA incentive eligibility (e.g., 3 ANC visit minimum, HRP follow-up count) so the ASHA can see her incentive status without separate paperwork.
PMSMA-aligned checkup scheduling — reminders anchored to the fixed 9th-of-the-month PMSMA clinic date plus the 3-ANC-minimum requirement, instead of generic reminder intervals.
SOS / emergency access — one-tap call to ASHA or 108 ambulance, nearest PHC locator.
SMS fallback for reminders — reaches feature-phone households in the same family for connectivity-poor stretches (e.g., seasonal network loss).
Expanded clinical risk logic — BP trends, anemia risk, age/prior-complication flags — mirroring the actual HRP red/green sticker system used on the MCP card today, so the app's risk flag means the same thing ASHAs already recognize.
Phase 3 — Scale & Institutional Integration
Data privacy/consent layer formalized against ABDM/DISHA compliance
Backend integration (replacing mocked/local data), live chatbot API
Push notifications (FCM) as a complement to — not replacement for — SMS fallback
Supervisor/PHC-level rollup dashboard for program monitoring
Secondary caregiver (family) view
7. User Flows
Both flows below assume Phase 1 foundations (offline-first, non-OTP-dependent ASHA login, risk-prioritized roster) are in place — this is the flow the app should support, not just the current MVP screens.

7.1 Patient (Expecting Mother) Flow
Yes

No

Call ASHA

Medical Emergency

Yes

Open App

Select Language
English / Hindi / Marathi

Select Role: Patient

First time?

Phone Number Entry

OTP Verification

Basic Profile Setup:
LMP/EDD, linked ASHA, village

Cached Login /
Offline Resume

Patient Home Dashboard

Next Checkup Countdown
aligned to PMSMA date

Daily Medicine Tracker
one-tap mark-as-taken

Diet Plan
by pregnancy stage

Vaccine Tracker

AI Chatbot Widget

SOS Button

Emergency type

Direct Call to Assigned ASHA

Call 108 / Nearest PHC Locator

Profile / History
top-right avatar

Missed 3+ days?

Flag surfaces on
ASHA's roster automatically

Offline Mode:
content cached, actions
queued for sync

Flow narrative:

Onboarding — language first, then role, then the lightest possible profile setup (LMP/EDD and linked ASHA/village only — deep history can be added later, not as a signup blocker).
Daily loop — the mother opens the app mainly to mark medicines taken and check "what's next," not to browse. This is intentionally a 10-second daily habit, not a portal.
Passive safety net — if she misses medication 3+ days, she doesn't need to do anything else — it surfaces automatically on her ASHA's prioritized roster (this is the link between the two flows).
Emergency path is always one tap away from the home screen, never buried in a menu.
Offline behavior is explicit: cached content works without a connection; any action taken offline (marking a dose, a chatbot query queued) syncs silently once reconnected.
7.2 ASHA Worker Flow
Yes

No

Call

Log Visit

ASHA opts in

Skip

Schedule Follow-up

Open App

Select Language

Select Role: ASHA Worker

First time?

ASHA ID / Phone + OTP
one-time online setup

Set PIN/Biometric
for offline login

PIN/Biometric Login
works fully offline

ASHA Dashboard

Summary: Total Patients /
Active Alerts / Visits Today

Risk-Prioritized Roster
HRP + Alerts surfaced first

Monthly Impact View
checkups done, incentive-eligible visits

Select Patient

Patient Detail:
history, adherence, HRP flag,
checkup schedule

Action

Direct Call to Patient

One-tap Visit Log:
type, notes, timestamp

Attach location proof?

GPS/photo attached

Timestamp-only log

Queued for sync +
incentive/JSY-PMSMA tracking

Add to Visits-Today queue

Emergency Alert Banner
missed meds 3+ days

Offline Mode:
full roster + logging works,
syncs on reconnect

Flow narrative:

Login is designed around the connectivity reality — full OTP verification happens once, during first-time setup when she's likely near a facility with signal; day-to-day login uses a local PIN/biometric so a bad-network morning never locks her out.
The roster answers "who needs me today," not "who is on my list." Risk and alerts sort to the top automatically — this is the single biggest time-saving change from the flat list in the current MVP.
Visit logging is one tap, not a form. Location/photo proof is opt-in and ASHA-controlled per visit — never silent or mandatory — directly avoiding the surveillance perception that got a GPS-tracking ASHA app formally withdrawn.
Every logged visit does double duty: it updates the patient's status and feeds the incentive/JSY-PMSMA tracker automatically, so she isn't re-entering the same visit for a separate incentive claim later.
The monthly impact view is the feedback loop — closing the "I enter data but never see what it does" gap that existing government apps leave open.
Emergency alerts route directly into the same patient-detail-and-action flow, not a separate screen, so there's only one way to take action, not two to remember.
8. Technical Architecture
Current State

Framework: Flutter (Dart)
State management: ListenableBuilder + singletons (AppState.instance, MedicineStore.instance)
Routing: Named routes via MaterialApp
Theme: Material 3, custom ColorScheme (seed 0xFFFF8B94)
Near-Term Technical Roadmap

Local-first data layer (Hive/SQLite) with sync queue for offline support
Migrate state management to Provider/Riverpod as the app scales beyond singletons
Backend: Firebase (Auth, Firestore, FCM) for fastest path to real OTP + push notifications; longer-term, a dedicated backend if ABDM compliance requires more control over data residency
API contract defined for patient↔ASHA data sync ahead of backend build
Server-side enforcement of role-based access (currently UI-level only)
9. Known Limitations (Say This Proactively)
Presenting this slide before a judge asks about it is a credibility move, not a weakness.

Backend is currently mocked/local — no live data persistence yet
OTP is UI-only — no live SMS gateway integrated
Chatbot is a static widget — no live API behind it
No offline sync yet — flagged as Tier 1 priority
No formal compliance certification yet — architecture is being designed with ABDM/DISHA in mind
10. Success Metrics (Post-Pilot)
% reduction in missed antenatal checkups among enrolled patients
ASHA time saved per patient (visit logging vs. paper register)
Medication adherence rate (tracked vs. self-reported baseline)
% of visits with digital proof-of-work usable for incentive claims
ASHA-reported usefulness of the monthly impact view (adoption/retention proxy)
% of app actions completed successfully offline (reliability under real rural connectivity)
11. One-Line Summary for the Pitch
"A trilingual, offline-first companion for expecting mothers and the ASHA workers who care for them — built to slot into India's existing maternal health workflow and government schemes, and designed from real field research on why past digital-health tools failed ASHA workers, not just from assumptions about what they need."