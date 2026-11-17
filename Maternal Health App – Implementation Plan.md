# Maternal Health App – Implementation Plan

From prototype to a fully working, connected app for the Avishkar zonal round

This plan turns the improvements we identified (smarter risk engine, closed-loop alerts, ANM step, real backend, validation) into concrete work. It assumes about four weeks and a team of three to four. If the deadline is closer, use the cut list in section 12.

## 1. What "fully functional" means

In four weeks, "fully functional" should mean the following, and nothing more:

- Real login for five roles: patient, ASHA, ANM, supervisor, caregiver.
- One shared database, so an action on one phone appears on another phone within seconds.
- The closed loop works end to end: missed medicines lead to an alert for the ASHA, then escalation to the ANM, then the supervisor's HRP count.
- A server-side risk engine with a weighted, explainable score and trend detection.
- Offline use: the app works without internet and syncs when it returns.
- Seeded realistic data and a rehearsed demo.

**Explicitly out of scope (present as phase 2):** RCH/ABHA integration, SMS/IVR alerts, real OTP login at scale, production-grade security audit, app store release.

## 2. Target architecture

Flutter app (all roles) talks to a managed backend through a repository layer. Hive stays on the device as a cache and an outbox of pending changes.

- **Client:** Flutter, Provider, Hive (cache and outbox), repositories that hide whether data comes from the network or the cache.
- **Backend:** Supabase (Postgres database, authentication, row-level security, realtime, scheduled jobs, edge functions).
- **Risk and alert engine:** runs on the server as the single source of truth. The same rules are mirrored in Dart so the app can show a preview offline.
- **Notifications:** Firebase Cloud Messaging for push, plus Supabase Realtime inside the app, so the demo never depends on push delivery alone.

### Why Supabase

- Pregnancy data is relational (patients, visits, assignments, alerts), which suits Postgres well.
- Row-level security lets us express "an ASHA sees only her own patients" in the database itself, which also helps the privacy answer for judges.
- Realtime, scheduled jobs and functions are included, so we avoid running our own server.
- **Alternative:** Firebase (Firestore plus Cloud Functions) is fine if the team already knows it. The plan below still applies, but the data model would be denormalised and security rules replace RLS. Pick one now and don't switch midway.

**Check before committing:** current free-tier limits and pricing for the chosen service, since these change. Record the numbers for the cost slide.

## 3. Roles and hierarchy

The real chain is mother, ASHA, ANM, PHC supervisor, with the caregiver linked to the mother.

| Role | Can read | Can write |
| --- | --- | --- |
| Patient | Own record, own alerts | Own medicine logs, symptoms, SOS, vaccination entries |
| ASHA | Patients assigned to her | Visit logs, reported symptoms, escalation to ANM |
| ANM | Patients of ASHAs assigned to her | Clinical vitals, confirm or clear HRP, refer to PHC |
| Supervisor | Aggregates and confirmed HRPs in their PHC | Assignments, review of alerts |
| Caregiver | Limited view of linked patient, only with the patient's consent | Nothing clinical (read-only) |

## 4. Data model

Keep it small. Every table has an id, created\_at and updated\_at, and a sync\_status on the client side.

| Table | Key columns |
| --- | --- |
| profiles | user id, role, name, phone, language, phc\_id |
| phcs | id, name, district |
| patients | id, profile id, date of birth, LMP, EDD, height, blood group and Rh, history flags (previous C-section, stillbirth, pregnancy loss, bleeding in past pregnancy), twin flag |
| assignments | patient id, asha id, anm id (who looks after whom) |
| caregiver\_links | patient id, caregiver profile id, consent given (yes/no), consent time |
| medicine\_plans | patient id, medicine (iron, calcium, folic acid), schedule |
| medicine\_logs | patient id, medicine, date, taken (yes/no), logged\_at |
| visits | patient id, recorded\_by, role, date, systolic, diastolic, hemoglobin, weight, danger-sign flags, notes |
| risk\_assessments | patient id, computed\_at, score, level, reasons (list), trigger (visit, missed dose, manual) |
| alerts | patient id, type, level, status (open, acknowledged, escalated, closed), created\_at, assigned\_to |
| escalations | alert id, from, to, decision (confirm HRP, clear, refer), decided\_by, time |
| vaccinations | patient id, vaccine, due date, given date |
| sos\_events | patient id, time, location if available, status |
| consents | profile id, type, text version, time |
| audit\_log | who, what, when (for sensitive reads and writes) |

**Rules for the schema:**

- Medicine logs and visits are append-only, which makes offline sync safe and avoids conflicts.
- Store the *reasons* for each risk result, not just the number. That is what makes the score explainable.
- Record who took each vital reading and in which role. This answers the "who measures Hb?" question and fits the ANM step.

## 5. Security, consent and privacy

- Enable row-level security on every table. Write one policy per role from the table in section 3 and test each one with a second account that should be blocked.
- Store the consent text version and timestamp when a user accepts the consent screen. Caregiver access is enabled only if the patient gave consent.
- Don't put API secrets in the app. Only the public client key goes in the app; anything privileged lives in edge functions.
- Encrypt the local Hive boxes holding health data, with the key kept in secure storage.
- Log access to sensitive records in audit\_log.
- Say in the pitch: decision support, not diagnosis; designed with the DPDP Act principles of consent and purpose limitation in mind. Don't claim formal compliance.

## 6. Risk engine v2

This is the most important scientific upgrade. Build it as a pure function (patient data in, score, level and reasons out) so it is easy to test.

### Step 1: danger signs and critical values (immediate High)

Any one of these makes the level High regardless of score: hemoglobin below 7.0, blood pressure at or above 160 systolic or 110 diastolic, vaginal bleeding, severe headache with blurred vision, convulsions, absent fetal movement reported.

### Step 2: weighted score (draft weights)

| Factor | Points |
| --- | --- |
| Age under 18 or over 35 | 2 |
| BP 140-159 / 90-109 | 3 |
| Hemoglobin 7.0-9.9 (moderate anemia) | 2 |
| Hemoglobin 10.0-10.9 (mild anemia) | 1 |
| Previous C-section, stillbirth, pregnancy loss or postpartum hemorrhage | 2 each, capped at 4 |
| Twin pregnancy | 3 |
| Diabetes or gestational diabetes | 2 |
| Rh-negative blood group | 1 |
| Missed medicines 3-6 days | 2 |
| Missed medicines 7 or more days | 3 |
| Overdue ANC visit | 1 |
| Systolic BP rising 20 mmHg or more across last two visits | 2 |
| Hemoglobin falling 1.0 g/dL or more between visits | 1 |

**Levels:** 0-2 Low, 3-4 Moderate, 5 or more High.

**Important:** these weights are a starting design, not clinical truth. Before presenting, have them reviewed against MoHFW high-risk pregnancy guidelines and, if possible, by a doctor, ANM or PHC medical officer. Put the source of every rule on a slide. Where we can't source a rule, remove it.

### Step 3: explainability

Every result returns reasons in plain language, for example "Moderate anemia (Hb 8.4) + BP rising across 2 visits + 4 days of missed medicines". Show this on the ASHA's patient card in all three languages.

### Step 4: one rule set, two implementations

The server version is authoritative. The Dart version gives an offline preview. Keep one shared file of test cases (inputs and expected outputs) and run it against both, so they can't drift apart.

## 7. The closed loop

This is the demo. Build it first and keep it simple.

1. **Detection.** A scheduled job runs every few hours, counts consecutive missed days from medicine\_logs against medicine\_plans, and recomputes risk for affected patients.
2. **Alert.** If missed days reach 3, an alert is created for the patient's ASHA and a push plus in-app notification is sent. The ASHA sees a critical banner with call and visit actions.
3. **ASHA action.** She calls or visits, logs the outcome, and either closes the alert or escalates to the ANM with her observations.
4. **ANM decision.** The ANM records clinical vitals if available, then taps Confirm HRP, Clear or Refer to PHC.
5. **Supervisor visibility.** Only confirmed HRPs count in the supervisor dashboard and appear in the PHC list.
6. **Caregiver.** The linked family member sees the next checkup and a gentle reminder to help with medicines, without clinical detail beyond what the patient consented to.

Every step writes to escalations so the full chain can be shown on a timeline in the demo.

## 8. Frontend changes (Flutter)

**Structure**

- Add a data layer: repositories for patients, visits, medicine logs, alerts and escalations, each reading from the backend and caching in Hive.
- Add a sync service: every write goes to a local outbox first, then is uploaded when online. Show a small sync-status indicator.
- Add AuthState to Provider for session and role. Route users to the right module after login.
- Remove all hard-coded or mock data from screens. Everything displayed should come from a repository.

**New and changed screens**

- Login and role routing (replaces the local role selection screen).
- New ANM module: escalation inbox, patient detail, Confirm HRP, Clear, Refer.
- ASHA: alert banner connected to real alerts, visit log with a "vitals recorded by" field, risk reasons on each patient card.
- Patient: medicine logging that really syncs, caregiver consent toggle.
- Supervisor: live counts, confirmed HRP list, ASHA leaderboard from real visit data.
- Caregiver: consent-based read-only view.
- Complete Hindi and Marathi strings for every screen in the demo path.

**Offline rules**

- Logs and visits are append-only, so they can be uploaded in any order.
- Alerts and risk results are always computed on the server and pulled down; offline, show the last known value with a "last updated" label and the Dart preview.
- Test airplane mode on a real phone, not only an emulator.

## 9. Backend work (Supabase)

- Create the project, tables and relationships from section 4.
- Write and test row-level security policies for all five roles.
- Authentication: use email and password with pre-created demo accounts for the competition. Phone OTP can be shown as phase 2 because it needs an SMS provider.
- Database function or edge function for the risk engine.
- Scheduled job for missed-dose detection.
- Edge function to send push notifications through FCM.
- A seed script that creates one PHC, 2 ANMs, 4 ASHAs, 30 patients across risk levels and 30 days of medicine logs, so dashboards are never empty. The script must be re-runnable to reset the demo.

## 10. Validation (the "scientific" marks)

- **Test table for the risk engine.** Write 30 to 40 synthetic patient cases with expected levels, ideally checked by a clinician. Report how many the engine classified as expected, and fix and explain the misses. Show a summarized table on a slide.
- **Unit tests** for the risk engine on both server and Dart.
- **Security test:** log in as each role and confirm blocked access, for example an ASHA trying to read another ASHA's patient.
- **Offline test:** log medicines offline, reconnect, confirm the ASHA's alert appears.
- **Usability check:** have one real ASHA, ANM or health worker try the app for 15 minutes and note what confused them. Even one session lets you say you validated the workflow.
- **Pilot protocol (document only):** one PHC in Nashik district, 30 to 50 women, 3 months, measuring medicine adherence, ANC visit completion and time to HRP detection.

## 11. Cost-effectiveness numbers

Fill this in with real figures and put one slide in the deck.

- Monthly backend cost for the pilot size (from current pricing of the chosen service).
- Optional cost of SMS or voice alerts per patient (phase 2).
- Cost per patient per month = total monthly cost divided by number of patients.
- Hardware: runs on smartphones people already own, with no dedicated devices needed.
- Savings to name (without invented numbers): less ASHA time on paper registers, earlier detection of high-risk cases, fewer emergency referrals.

## 12. Timeline and priorities

This assumes about four weeks. Freeze code at least three days before the competition.

| Week | Goal | Done when |
| --- | --- | --- |
| 1 | Foundations | Backend live, schema and RLS done, login and role routing work, repository layer in place for patients and medicine logs, seed script runs |
| 2 | Core flows | Patient medicine logging syncs, ASHA list is live, visit logging works, risk engine v2 passes its test cases |
| 3 | Closed loop and roles | Missed-dose job and alerts work, ANM module done, supervisor and caregiver views live, offline sync and notifications tested on real devices |
| 4 | Validation and polish | Test table and security tests complete, translations finished, demo data tuned, slides done, demo rehearsed, backup recording made |

### Suggested split for three or four people

- **Backend:** schema, RLS, scheduled job, functions, seed script.
- **Flutter integration:** auth, repositories, sync, screens.
- **Risk engine and research:** rules, sources, test cases, clinician review, cost numbers.
- **Pitch and demo:** slides, story, Q&A, rehearsal, backup recording (also tests the app daily).

### If you have only two weeks, cut in this order

1. Keep: login, shared database, medicine logging, missed-dose alert, ASHA view, supervisor count, risk engine v2 with test table.
2. Show as designed but not built: caregiver consent flow, push notifications beyond in-app, ANM screens (use the escalation chain on the architecture slide).
3. Drop entirely for now: new features, extra languages beyond the three, incentive tracker polish, the clinic locator improvements.

## 13. Demo plan

Tell one patient's story with two or three phones on the table.

1. Patient phone (Marathi): log medicines and show audio help.
2. Skip ahead using seeded data: a patient with three missed days.
3. ASHA phone: the red banner appears; show the risk reasons.
4. ANM phone: confirm HRP.
5. Supervisor screen: HRP count updates.
6. Caregiver phone: sees the next checkup.

Prepare a backup screen recording and a reset script. Keep a mobile hotspot ready in case venue Wi-Fi fails, and show the offline sync once as a highlight.

## 14. Risks and how to handle them

| Risk | Mitigation |
| --- | --- |
| Backend work takes longer than expected | Build the closed loop first; cut the cut-list items |
| Venue internet fails | Offline mode, hotspot, backup recording |
| Risk rules challenged by a clinician | Cite sources, state that it is decision support, remove any unsourced rule |
| Security flaw exposes data | RLS tests per role, no secrets in app, demo accounts only with synthetic data |
| Too many features distract | One hero story; everything else on a single slide |
| Team members unavailable late in the process | Freeze code 3 days early, document how to reset and run the demo |

## 15. First 48 hours

1. Decide Supabase or Firebase, and create the project.
2. Agree the data model in section 4 and create the tables.
3. Draft the risk rules with sources and send them to one clinical contact for review.
4. Contact one ASHA, ANM or PHC worker for a short conversation and a later usability check.
5. Add the login screen and role routing to the Flutter app.
6. Write the first ten risk test cases.

After that, follow the weekly goals in section 12 and review progress against the "done when" column at the end of each week.

## 16. Two-person work split

This section replaces the three-to-four person split in section 12 for a team of two. **Person A owns the backend and clinical logic. Person B owns the Flutter app and the demo.** They meet at one agreed contract, so neither waits for the other.

### 16.1 Ownership at a glance

|  | Person A: Backend and risk engine | Person B: Flutter app and demo |
| --- | --- | --- |
| Main goal | A secure shared database, a correct and explainable risk engine, and a working alert chain | A connected app for all five roles that works offline, plus a polished pitch |
| Owns sections | 4, 5, 6, 7 (server side), 9, 10, 11 | 7 (client side), 8, 13, 14 |
| Tools | Supabase, SQL, edge functions, FCM | Flutter, Provider, Hive |
| Deliverables | Schema, RLS, accounts, risk engine, alert jobs, seed script, test table, cost numbers | Login, repositories, sync, all role screens, translations, slides, demo and backup recording |

### 16.2 Person A: detailed tasks

**A1. Database and security**

- Create the project, tables and relationships from section 4.
- Write row-level security policies for patient, ASHA, ANM, supervisor and caregiver, and test each with a second account that should be blocked.
- Create the assignment structure: patient to ASHA to ANM to PHC.
- Account creation: ANM, ASHA and supervisor accounts are created by an admin or supervisor, never by self-signup. Pre-create demo accounts for the competition.
- Store consent records, and enable caregiver access only after patient consent.

**A2. Risk engine v2**

- Implement danger-sign overrides, the weighted score and the trend rules from section 6 as one testable function.
- Return the level, the score and plain-language reasons.
- Collect the source for every rule and send the draft to one clinical contact for review.
- Write 30 to 40 synthetic test cases in the shared JSON file.

**A3. Closed loop and alerts**

- Scheduled job for missed-dose detection and risk recomputation.
- Alert creation, status flow (open, acknowledged, escalated, closed) and the escalations table.
- Edge function for push notifications; realtime events for in-app alerts.
- Functions the app calls, for example get\_patient\_list, log\_medicine, submit\_visit, escalate\_alert and decide\_hrp.

**A4. Data, testing and numbers**

- Seed and reset script: one PHC, 2 ANMs, 4 ASHAs, 30 patients across risk levels, 30 days of medicine logs.
- Security tests for every role, and a short results table.
- Risk test table: cases run, matches, misses and how they were fixed.
- Cost figures for the cost-effectiveness slide.
- Outreach: one real ASHA, ANM or PHC conversation.

### 16.3 Person B: detailed tasks

**B1. Foundations**

- Login screen, AuthState and role routing to the right module.
- Repository layer for patients, visits, medicine logs, alerts and escalations.
- Hive cache and outbox, sync service and a visible sync-status indicator.
- Mock repositories that return fake data in the agreed shape, so work can start before the backend is ready.

**B2. Role screens**

- Patient: real medicine logging, symptoms, SOS, consent toggle for the caregiver.
- ASHA: live patient list sorted by risk, alert banner, visit log with "vitals recorded by", risk reasons on each card.
- ANM (new module): escalation inbox, patient detail, Confirm HRP, Clear, Refer to PHC.
- Supervisor: live counts, confirmed HRP list, ASHA leaderboard from real visit data.
- Caregiver: consent-based, read-only view.

**B3. Offline and quality**

- Dart mirror of the risk engine for the offline preview, tested against the same JSON test cases as the server.
- Offline test on a real phone: log medicines in airplane mode, reconnect, confirm the ASHA sees the alert.
- Hindi and Marathi strings for every screen in the demo path.
- Remove all hard-coded and mock data from the final build.

**B4. Pitch and demo**

- Slides: problem, gap, closed loop, comparison with RCH and ANMOL, validation, cost, pilot plan.
- Demo script, a reset routine, a backup screen recording and a hotspot plan.
- Q&A sheet for the seven judge objections.

### 16.4 The shared contract (agree in the first two days)

This is what keeps the two tracks from blocking each other. Write it down together and treat changes as a conversation, not a surprise.

1. The table and column list from section 4.
2. The names, inputs and outputs of the server functions listed in A3.
3. The shared JSON file of risk test cases, used by A's server tests and B's Dart tests.
4. The alert status flow and the escalation decisions (confirm HRP, clear, refer).
5. The role names and the language codes used in the app.

Until the backend is ready, B builds against the mock repositories. A tests with SQL and a simple API client, without waiting for the screens.

### 16.5 Week-by-week plan

| Week | Person A | Person B | Joint checkpoint |
| --- | --- | --- | --- |
| 1 | Schema, RLS, accounts, assignments, seed script | Login and routing, repository layer with mocks, outbox design | Login works against the real backend |
| 2 | Risk engine v2, test cases, visit and medicine functions, rule sources | Real medicine and visit logging, live ASHA list, Dart risk mirror | A medicine log on one phone appears for the ASHA |
| 3 | Missed-dose job, alerts, escalations, push function, security tests | ANM module, supervisor and caregiver views, realtime alerts, offline testing | The full closed loop runs end to end |
| 4 | Test tables, sources, cost numbers, clinician and ASHA feedback | Translations, slides, rehearsal, backup recording | Full dress rehearsal two days before the freeze |

Sit together for each checkpoint. Do not leave integration problems for the last week.

### 16.6 Definition of done per person

**Person A is done when:**

- Every role is blocked from data it should not see, proven by tests.
- The risk engine passes its test cases and every rule has a source.
- A missed-dose scenario creates an alert, and an ANM decision updates the supervisor count, with no manual steps.
- The seed script resets the demo in one command.

**Person B is done when:**

- All five roles can log in and see only their own data.
- The offline test passes on a real phone.
- The demo path works end to end in all three languages.
- The slides, script and backup recording are complete.

### 16.7 Balancing the load

- B has more screens and more volume. If B falls behind, A takes over the ANM-related server logic, the risk, validation and cost slides, and part of the Q&A sheet.
- A's work is lumpy, with heavy weeks 1 and 3. In quiet stretches, A should pick up outreach to an ASHA or clinician and help test on devices.
- Review each other's work weekly, with A checking B's use of the risk engine and B checking that A's functions are easy to call.

### 16.8 Risks specific to a two-person team

| Risk | Mitigation |
| --- | --- |
| Integration problems appear late | Joint checkpoints at the end of weeks 1, 2 and 3 |
| One person is blocked by the other | Contract plus mock repositories and API testing tools |
| One person falls ill or becomes unavailable | Keep the schema, functions and setup steps documented, and share all credentials safely |
| Scope grows | Use the cut list in section 12: drop the caregiver consent flow and extra push notifications first, and show the ANM screens as designed if needed |
| Demo breaks on the day | Backup recording, hotspot, reset script and a rehearsal two days before the freeze |
