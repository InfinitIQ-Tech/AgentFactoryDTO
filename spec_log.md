# spec_log.md

## 2026-10-04

- Files changed: `SPEC.md`, `spec_guidance.md`, `spec_log.md`, `features/structured-output/SPEC.md`, `features/structured-output/spec_log.md`, and `Tests/AgentFactoryDTOTests/StructuredOutputDTOTests.swift`.
- Summary: Completed AF-83 contract documentation and direct tests for omitted output, the required format/schema shape, recursive schema values and exact keys under snake_case strategies, and publishing the same envelope.
- Trigger: AF-83 acceptance-criteria verification against the public spec and runtime contracts.
- Operational impact: The feature spec is the source of truth for schema transport. Provider validation and execution remain in external runtimes; no package or platform dependency changes are introduced.

## 2026-04-01

- Files changed: [`AGENTS.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/AGENTS.md), [`SPEC.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/SPEC.md), [`spec_guidance.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_guidance.md), [`spec_log.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_log.md)
- Summary: Added a repo-wide requirement for agents to retrieve the company philosophy Confluence page before work and to treat that philosophy as the rationale for repository changes.
- Trigger: User request to make the company philosophy page mandatory agent context in `AGENTS.md`.
- Operational impact: Future agent work in this repository should start by retrieving the Confluence philosophy page and should frame implementation tradeoffs around InfinitIQ Tech's ethical, long-term, infinite-mindset goals.

## 2026-03-18

- Files changed: [`SPEC.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/SPEC.md), [`spec_guidance.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_guidance.md), [`spec_log.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_log.md), [`features/runtime-chat-input-history/SPEC.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/features/runtime-chat-input-history/SPEC.md), [`features/runtime-chat-input-history/spec_log.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/features/runtime-chat-input-history/spec_log.md)
- Summary: Added a feature-level source of truth for stateless runtime chat-history replay and updated the root DTO spec to document assistant tool-call replay, tool-result continuation, and the wider inbound client role set.
- Trigger: Runtime tool continuation work in the consuming AgentFactory backend exposed that the public chat request contract could not represent replayed assistant `tool_calls` or trailing `tool` messages.
- Operational impact: Future DTO work must preserve the fields and enum cases needed to resend assistant tool-call turns and tool-result continuation history across stateless `/v1/chat` requests.

## 2026-03-16

- Files changed: [`Sources/AgentFactoryDTO/Agent Capabilities/Function Calling/FunctionDefinition.swift`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/Sources/AgentFactoryDTO/Agent%20Capabilities/Function%20Calling/FunctionDefinition.swift), [`Tests/AgentFactoryDTOTests/AgentFactoryDTOTests.swift`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/Tests/AgentFactoryDTOTests/AgentFactoryDTOTests.swift), [`SPEC.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/SPEC.md), [`spec_guidance.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_guidance.md), [`spec_log.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_log.md)
- Summary: Codified `AgentToolsConfig` allow-list semantics in source comments and root specs, and added regression tests for definitions-only payloads plus explicit empty allow-lists.
- Trigger: `AF-38` contract work to make tool-allow semantics explicit and remove any implication of always-on built-in tools.
- Operational impact: Future agent work must preserve the distinction between omitted and empty `allowed` values, keep definitions-only payloads stable on the wire, and avoid documenting implicit built-in tool enablement.

## 2026-03-14

- Files changed: [`SPEC.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/SPEC.md), [`spec_guidance.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_guidance.md), [`spec_log.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_log.md)
- Summary: Created the initial repo-level spec set for the `AgentFactoryDTO` Swift package.
- Trigger: User request to write a project-level spec.
- Operational impact: Future agent work should use [`SPEC.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/SPEC.md) as the source of truth for package structure, wire-compatibility rules, verified commands, testing expectations, and DTO placement boundaries.

## 2026-03-14

- Files changed: [`AGENTS.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/AGENTS.md), [`SPEC.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/SPEC.md), [`spec_guidance.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_guidance.md), [`spec_log.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_log.md)
- Summary: Added a repo-level `AGENTS.md` and updated the root spec docs to require a spec-first workflow, scoped feature-spec routing, and unit-test backing for spec-described behavior.
- Trigger: User request to make `AGENTS.md` the workflow entry point and document repository constraints, verification, and delivery requirements.
- Operational impact: Future implementation tasks should start from [`AGENTS.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/AGENTS.md), create or update feature specs only when documented feature behavior changes, and avoid closing implementation work without unit tests for the affected spec-described behavior.

## 2026-03-14

- Files changed: [`Tests/AgentFactoryDTOTests/RuntimeAndResponseDTOTests.swift`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/Tests/AgentFactoryDTOTests/RuntimeAndResponseDTOTests.swift), [`SPEC.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/SPEC.md), [`spec_log.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_log.md)
- Summary: Added wire-contract tests for stream lifecycle DTOs, `ChatRequest`, and response DTOs, and updated the root spec to reflect the narrower remaining coverage gaps.
- Trigger: User request to write tests for the documented DTO coverage gaps.
- Operational impact: Future agent work can rely on direct XCTest coverage for the stream lifecycle events, `ChatRequest`, `AgentVersionDTO`, `AgentWithDeploymentsDTO`, `ChatResponseDTO`, and `AcceptedResponse` contracts, while the remaining uncovered control-plane request DTOs stay visible in [`SPEC.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/SPEC.md).

## 2026-03-15

- Files changed: [`SPEC.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/SPEC.md), [`spec_guidance.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_guidance.md), [`spec_log.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_log.md)
- Summary: Documented `AgentConfig.systemPrompt` as a required published snapshot field and tightened the repo guidance for future `AgentConfig` contract changes.
- Trigger: `AF-29` contract change for version-scoped system instructions in runtime chat.
- Operational impact: Future DTO changes must preserve or explicitly reason about `AgentConfig` snapshot ownership, required wire fields, and snake_case serialization for runtime-facing config fields.

## 2026-03-15

- Files changed: [`Sources/AgentFactoryDTO/AgentFactoryDTO.swift`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/Sources/AgentFactoryDTO/AgentFactoryDTO.swift), [`Tests/AgentFactoryDTOTests/RuntimeAndResponseDTOTests.swift`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/Tests/AgentFactoryDTOTests/RuntimeAndResponseDTOTests.swift), [`SPEC.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/SPEC.md), [`spec_log.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_log.md)
- Summary: Implemented the documented `AgentConfig.systemPrompt` contract in source and added wire-contract tests for published version snapshots and `PublishAgentVersionRequest`.
- Trigger: `AF-29` and `AF-32` rollout implementation in the consuming backend.
- Operational impact: Local and downstream builds now compile against the required version-scoped `system_prompt` field, and the DTO spec no longer lists `PublishAgentVersionRequest` as uncovered.

## 2026-07-06

- Files changed: [`Sources/AgentFactoryDTO/AgentFactoryDTO.swift`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/Sources/AgentFactoryDTO/AgentFactoryDTO.swift), [`Tests/AgentFactoryDTOTests/AgentFactoryDTOTests.swift`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/Tests/AgentFactoryDTOTests/AgentFactoryDTOTests.swift), [`SPEC.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/SPEC.md), [`spec_log.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_log.md)
- Summary: Added the optional `AgentConfig.output` section (`AgentOutputConfig` wrapping `AgentOutputFormat` with required `type` and `schema` fields) declaring structured output configuration in the package's published config shape. The initializer defaults `output` to `nil` so existing call sites are unaffected, and tests cover the snake_case wire round trip.
- Trigger: `AF-83` (per-turn structured output for the swift-agent-runtime lane; consumer-driven gap from DREAM-18 grooming).
- Operational impact: The public AgentConfig JSON Schema in `agent-config-spec` documents the section (additive optional, no `schema_version` bump); AgentFactory treats it as pass-through and external runtimes map it to provider-native structured output. Drift gates in AgentFactory and swift-agent-runtime cover the new keys.
