# Constitution: [Project Name]

_Created: [YYYY-MM-DD] · Last updated: [YYYY-MM-DD]_

## Project identity

[One paragraph. What the app is. Who the user is. What it is NOT.]

## Pipeline invariants (carried from playbook — do not edit)

1. Research before code: no Write/Edit on application code before stages 01–05 artifacts are committed.
2. Fresh context per stage: every stage runs in a new subagent with a narrow read-list.
3. Sub-agent nesting cap: depth ≤ 1. A pipeline-stage subagent may spawn at most one level of further subagents, and only a read-only `Explore` for lookups. No `stage-agent → spawn → spawn` chains.
4. Sub-agent return = final artifact path + one-paragraph delta, not a running commentary.
5. Commit between stages, auto-advance. The orchestrator auto-chains stages — no manual `/clear` or continue needed except at human gates.

## Human profile

Who is the human in the loop for this project? This determines how stages communicate and gather input.

- **Pipeline operator:** _[developer / product-owner / domain-expert-async]_
  - `developer` — technically fluent, runs the pipeline, reviews code-level decisions. Default.
  - `product-owner` — understands the product but not the codebase. Can approve plans and make feature decisions. Cannot review code.
  - `domain-expert-async` — deep domain knowledge but not available in real-time during the pipeline. Input is gathered via structured questionnaire rounds between stages. See below.
- **Domain expert available?** _[yes-inline / yes-async / no]_
  - `yes-inline` — the pipeline operator IS the domain expert, or the expert is co-piloting. Stages 01 and 03 run interactively.
  - `yes-async` — a separate domain expert is available but not at the keyboard. The pipeline generates questionnaire rounds, the operator relays them, answers come back as a file.
  - `no` — no domain expert. The pipeline does its best with public research only.
- **Expert's domain:** _[one sentence — e.g., "20 years in pharmaceutical compliance" or "n/a"]_
- **Expert's availability pattern:** _[e.g., "available for async rounds, no hard time limit" or "single 1-hour session only" or "n/a"]_

## Non-negotiables (project-specific)

Rules that cannot be traded off during design or execution. Each must be testable or auditable. These add to the pipeline invariants above — they may not weaken them.

1. [Rule] — _auditable via: [how]_
2. [Rule] — _auditable via: [how]_
3. [Rule] — _auditable via: [how]_

## Integration context

The app rarely exists in a vacuum. What surrounds it?

- **Upstream data sources:** _[What systems, files, or APIs feed data INTO this app? e.g., "SAP exports CSV nightly", "REST API from lab instruments", "manual Excel uploads" — or "standalone, no upstream"]_
- **Downstream consumers:** _[What reads this app's output? e.g., "regulatory submission portal", "BI dashboard queries the DB directly", "downstream microservice via message queue" — or "end-user only, no downstream"]_
- **Data formats / types:** _[Key data formats the app must ingest or produce. e.g., "HL7 FHIR bundles", "IFC/BIM files", "CSV with ISO 8601 timestamps", "PDF reports for auditors" — or "standard web I/O only"]_
- **Existing systems it must coexist with:** _[e.g., "runs alongside legacy Oracle DB that cannot be modified", "must integrate with company SSO (Azure AD)", "shares infrastructure with [X]" — or "greenfield, no coexistence constraints"]_
- **Deployment environment:** _[e.g., "on-prem Windows Server behind corporate firewall", "AWS eu-west-1, Kubernetes", "user's local machine (offline-capable)" — or "TBD"]_

## Tech-stack locks

Specific tech the user has already committed to. Leave empty if the Architect is free to choose.

- Language: _TBD / [lang + version]_
- Runtime: _TBD / [runtime + version]_
- Framework: _TBD / [framework + version]_
- Database: _TBD / [db + version]_
- Deployment target: _TBD / [target]_

## Compliance / legal constraints

[GDPR, HIPAA, license compatibility, data residency — or "none identified" with reasoning.]

## Non-goals

Explicit anti-features. The app will NOT do these, and stage 04 will not design for them.

- [Anti-feature]
- [Anti-feature]

## Revision history

| Date | Change | Reason |
|---|---|---|
| [YYYY-MM-DD] | Initial | Stage 00 |
