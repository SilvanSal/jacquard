# Research Loop

The iterative domain research cycle. No fixed round limit — the agent keeps digging until depth is reached.

```mermaid
flowchart TD
    start([Research agenda\nderived from intake]) --> investigate

    investigate[Investigate source\npaper / API / tool / docs] --> finding{Discovery?}

    finding -->|New insight| save[Save structured finding\nYAML frontmatter + source chain\n+ evidence quality assessment]
    finding -->|Contradicts existing| flag[Flag contradiction\nmark superseded finding]
    finding -->|Confirms existing| strengthen[Update confidence level\nadd corroborating source]

    save --> update_index[Update findings INDEX.md\nfilter tables + dependency graph]
    flag --> update_index
    strengthen --> update_index

    update_index --> surface_check{Should surface\nto user?}

    surface_check -->|"Architectural implication\nfound"| surface
    surface_check -->|"Contradicts user\nassumption"| surface
    surface_check -->|"Needs access to\ngated resource"| surface
    surface_check -->|"Research branching —\nneed prioritization"| surface
    surface_check -->|No| depth_check

    surface{{Present to user\n+ ask question}} --> user_input{{User responds}}
    user_input --> depth_check

    depth_check{Depth reached?}
    depth_check -->|"Open threads remain\nor new leads found"| investigate
    depth_check -->|"Agenda covered,\nconfidence high"| done([Research complete\nfindings index sealed])

    style start fill:#e0e0e0
    style done fill:#e0e0e0
    style surface fill:#fff3e0
    style user_input fill:#fff3e0
    style save fill:#c8e6c9
    style flag fill:#ffcdd2
    style strengthen fill:#e1f5fe
```

**When to surface to user:**
- Architectural implication discovered (constraints the design)
- Finding contradicts something the user stated
- Gated resource needs user access (subscriptions, internal tools)
- Research is branching — user picks the priority
