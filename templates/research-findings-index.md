# Research Findings Index

_Auto-maintained by the Domain-Researcher. Updated after every new finding is written._
_Last updated: [YYYY-MM-DD] · Total findings: [N] · Critical: [N] · With architectural impact: [N]_

## Quick-filter tables

### By relevance (highest first)

| ID | Title | Category | Confidence | Arch. impact | Status |
|---|---|---|---|---|---|
| [RF-ID] | [title] | [category] | [confidence] | [yes/no] | [active] |

### By category

| Category | Count | Critical | IDs |
|---|---|---|---|
| algorithmic-constraint | [N] | [N] | [RF-ID, RF-ID, ...] |
| data-model | [N] | [N] | [RF-ID, ...] |
| performance-cliff | [N] | [N] | [RF-ID, ...] |
| processing-pipeline | [N] | [N] | [RF-ID, ...] |
| interop-standard | [N] | [N] | [RF-ID, ...] |
| failure-mode | [N] | [N] | [RF-ID, ...] |
| regulatory | [N] | [N] | [RF-ID, ...] |
| ux-pattern | [N] | [N] | [RF-ID, ...] |
| security | [N] | [N] | [RF-ID, ...] |
| competitive-intel | [N] | [N] | [RF-ID, ...] |
| domain-concept | [N] | [N] | [RF-ID, ...] |

### Architectural constraints (Architect's fast-path)

Subset of findings where `architectural-impact: true`. The Architect (Stage 04) reads this section first.

| ID | Constraint introduced | Affects stages | Confidence |
|---|---|---|---|
| [RF-ID] | [1-line constraint from the finding's "Constraints introduced" table] | [04, 07] | [established] |

### Open threads (unresolved questions)

Pulled from each finding's "Open threads" section. Grouped by priority.

**High priority:**
- [ ] [Question] — from [RF-ID] — _action: [research next / ask user]_

**Medium priority:**
- [ ] [Question] — from [RF-ID] — _action: [research next / ask user / defer]_

**Low priority:**
- [ ] [Question] — from [RF-ID] — _action: [defer to Stage 06]_

### Dependency graph (which findings build on others)

```
RF-001 (foundational concept)
├── RF-003 (algorithmic constraint derived from RF-001)
│   └── RF-007 (performance cliff in RF-003's algorithm)
└── RF-004 (data model implied by RF-001)

RF-002 (regulatory requirement)
└── RF-005 (interop standard mandated by RF-002)
```

### Superseded / retracted

| ID | Title | Status | Reason | Replaced by |
|---|---|---|---|---|
| [RF-ID] | [title] | superseded | [1 sentence] | [RF-ID] |

## How downstream stages use this index

| Stage | What they read | Why |
|---|---|---|
| 01 Domain-Researcher | Full index + all findings | Iterative loop — adds findings, updates index |
| 04 Architect | "Architectural constraints" table → then full findings for those IDs | Must incorporate or explicitly reject each constraint |
| 05 Slice-Planner | "By category" table (filters: critical + significant) | Ensures slices don't cross constraint boundaries |
| 06 Step-Researcher | grep by tags matching the slice's libraries/APIs | Surfaces relevant gotchas into knowledge.md |
| 08 Code-Reviewer | grep by tags matching the diff's touched files | Verifies code respects known constraints |
