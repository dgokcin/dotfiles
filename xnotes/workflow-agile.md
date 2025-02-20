AI Agent Agile Workflow

<on-init>
1. Verify .ai directory exists
2. Locate approved .ai/prd.md and .ai/arch.md
3. If neither do not exist or are not approved, work with user to get them approved.
4. If both are approved, Identify current story status if one exists
5. Report current workflow state
</on-init>

<workflow-rules>
- All documentation created must follow these templates:
  - @prd-template.md
  - @arch-template.md
  - @story-template.md
- PRD must define at least one Epic
- Stories must be organized under Epics in .ai/epic-{n}/ directories
- Only 1 Epic can be in_progress at any time
- <critical>Do not create the first story unless the user has approved the prd and arch.</critical>
- Only 1 story can be in_progress at any time
- New story files will only be created after the previous is completed (or is the first story)
- Stories created as .ai/story-{number}.story.md
- Update arch.md change log for major changes
- Maintain test coverage and documentation
- Record all implementation notes and commands in the current story
- Stories must be implemented in PRD-specified order within their Epic
- Story status progression: draft -> in_progress -> complete
- Never implement without story approval
</workflow-rules>

<critical>
Until PRD and ARCH are approved, only modify:
- .ai/ directory files and structure
- documentation files
- readme files
- workflow rules
</critical>

## Workflow Sequence

```mermaid
sequenceDiagram
    participant U as USER
    participant A as AGENT

    Note over U,A: PLAN PHASE (Only modify .ai/, docs, readme, rules)

    alt No PRD Exists
        A->>U: Request project requirements
        U->>A: Provide initial requirements
        A->>U: Ask clarifying questions
        U->>A: Provide clarifications
        A->>U: Create and Present draft .ai/prd.md with Epics
    end

    alt No ARCH Exists
        A->>U: Suggest architecture as inferred from PRD
        A->>U: Request architecture preferences that are still needed
        U->>A: Provide architecture context
        A->>U: Present draft .ai/arch.md
    end

    loop Until Both Approved
        A->>U: Present PRD for review
        U->>A: Request PRD changes
        A->>U: Update PRD
        A->>U: Present ARCH for review
        U->>A: Request ARCH changes
        A->>U: Update ARCH
        U->>A: Confirm PRD/ARCH approval
    end

    Note over U,A: ACT PHASE (Implement approved story tasks)

    loop For Each Epic in PRD
        Note over U,A: Only one Epic active at a time

        loop For Each Story in Current Epic
            A->>U: Create and Present draft story
            U->>A: Review and provide feedback
            A->>U: Update story based on feedback
            U->>A: Approve story for implementation

            loop For Each Task in Story
                A->>U: Implement and test task
                alt Tests or Implementation Issues
                    A->>U: Report issues and request guidance
                    U->>A: Provide direction
                else Success
                    A->>U: Present completed task
                end
            end

            A->>U: Present completed story
            U->>A: Verify and approve completion
        end

        A->>U: Present completed Epic
        U->>A: Verify and approve Epic completion
    end
```
