# Context Routing

Every subagent gets a fresh context window with only the files it needs. No agent sees the full picture — each reads a narrow, enforced slice of the artifact tree.

```mermaid
flowchart LR
    orchestrator((Orchestrator))

    subgraph artifacts [Artifact Pool]
        direction TB
        constitution[constitution.md]
        intake[intake-brief.md\nintake-qa.md]
        domain[domain research\n+ findings index]
        tech[tech-stack.md]
        code_style[code-style.md]
        best[best-practices.md]
        step_spec[step-spec.md]
        knowledge[knowledge.md]
        prev_handoff[prev handoff.md]
        diff[git diff]
        eval[eval-spec.md]
        error_reg[error-registry.md]
        halluc[hallucination-traps.md]
    end

    orchestrator --> researcher
    orchestrator --> architect
    orchestrator --> coder
    orchestrator --> reviewer

    subgraph researcher [Domain Researcher]
        r_reads[Reads: constitution\nWrites: findings + index]
    end
    constitution -.-> researcher
    researcher -.-> domain

    subgraph architect [Architect]
        a_reads[Reads: constitution,\ndomain research, tech-stack,\nfindings index]
    end
    constitution -.-> architect
    domain -.-> architect
    tech -.-> architect

    subgraph coder [Coder]
        c_reads[Reads: constitution, tech-stack,\ncode-style, best-practices,\nstep-spec, knowledge,\nprev handoff, error-registry,\nhallucination-traps]
    end
    constitution -.-> coder
    tech -.-> coder
    code_style -.-> coder
    best -.-> coder
    step_spec -.-> coder
    knowledge -.-> coder
    prev_handoff -.-> coder
    error_reg -.-> coder
    halluc -.-> coder

    subgraph reviewer [Code Reviewer]
        rev_reads[Reads: code-style,\nbest-practices, step-spec,\ndiff, eval-spec]
    end
    code_style -.-> reviewer
    best -.-> reviewer
    step_spec -.-> reviewer
    diff -.-> reviewer
    eval -.-> reviewer

    style orchestrator fill:#1565c0,color:#fff
    style researcher fill:#e8f5e9
    style architect fill:#e8f5e9
    style coder fill:#e8f5e9
    style reviewer fill:#e8f5e9
```

**Key insight:** The Coder never sees raw domain research. The Researcher never sees code-style rules. The Reviewer never sees prior handoffs. This isolation prevents context pollution and keeps each agent focused on its job.
