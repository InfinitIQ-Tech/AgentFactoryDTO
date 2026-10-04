# SPEC.md - AgentFactoryDTO

> This document is the single source of truth for the AgentFactoryDTO repository.
> Hierarchy: live code > this spec > other documentation.
> Scope: repo-level rules for the `AgentFactoryDTO` Swift package and its public DTO surface.

---

## 1. Project Summary and Scope

`AgentFactoryDTO` is a Swift Package library that exports request, response, configuration, and streaming DTOs for an agent platform backend. The package is consumed as a shared contract layer; it does not contain route handlers, persistence, executables, or runtime business logic.

Current scope:

- Public DTOs for agent control-plane requests and responses.
- Public DTOs for runtime chat requests and responses.
- Public DTOs for tool-calling and streaming SSE payloads.
- JSON compatibility helpers used by those DTOs.

Out of scope in this repository:

- Server implementation.
- Database models or migrations.
- HTTP route registration.
- Provider SDK integrations.

## 2. Tech Stack and Platform Requirements

| Layer | Technology | Version / Notes |
|---|---|---|
| Language | Swift | `swift-tools-version: 6.1` in [`Package.swift`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/Package.swift) |
| Package manager | Swift Package Manager | Single library product |
| Platform | macOS | Minimum target `.macOS(.v13)` |
| Primary dependency | Vapor | `4.121.0` lower bound via SPM |
| Test framework | XCTest | Single test target `AgentFactoryDTOTests` |

There are no repo-local lint, formatting, or CI workflow files in the current tree.

## 3. Repository Structure

| Path | Purpose |
|---|---|
| [`AGENTS.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/AGENTS.md) | Entry-point workflow for agents, including read order, spec-first implementation rules, verification, and delivery requirements |
| [`Package.swift`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/Package.swift) | Package manifest, product definition, platform floor, dependency list |
| [`Package.resolved`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/Package.resolved) | Pinned dependency resolution |
| [`Sources/AgentFactoryDTO/AgentFactoryDTO.swift`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/Sources/AgentFactoryDTO/AgentFactoryDTO.swift) | Core enums and the main request/response/config DTO set |
| [`Sources/AgentFactoryDTO/Agent Capabilities/Function Calling/FunctionDefinition.swift`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/Sources/AgentFactoryDTO/Agent%20Capabilities/Function%20Calling/FunctionDefinition.swift) | Tool definition and tool-policy DTOs, including legacy compatibility for `functions` |
| [`Sources/AgentFactoryDTO/Agent Capabilities/Function Calling/ToolCallEventDTO.swift`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/Sources/AgentFactoryDTO/Agent%20Capabilities/Function%20Calling/ToolCallEventDTO.swift) | Streaming `tool_call` payload |
| [`Sources/AgentFactoryDTO/Agent Capabilities/Function Calling/ToolResultEventDTO.swift`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/Sources/AgentFactoryDTO/Agent%20Capabilities/Function%20Calling/ToolResultEventDTO.swift) | Streaming `tool_result` payload |
| [`Sources/AgentFactoryDTO/Agent Capabilities/Function Calling/SSEEventDTOs.swift`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/Sources/AgentFactoryDTO/Agent%20Capabilities/Function%20Calling/SSEEventDTOs.swift) | Streaming `start`, `chunk`, and `end` payloads |
| [`Tests/AgentFactoryDTOTests/AgentFactoryDTOTests.swift`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/Tests/AgentFactoryDTOTests/AgentFactoryDTOTests.swift) | Unit tests for tool-config compatibility and SSE tool event decoding |
| `.build/`, `.swiftpm/` | Generated SwiftPM state; do not hand-edit |

The source tree contains spaces in `Agent Capabilities/Function Calling`. Quote these paths in shell commands.

## 4. Documentation and Spec Workflow

- [`AGENTS.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/AGENTS.md) is the entry point for repository workflow and spec-read order.
- Before planning or implementing repository work, agents must retrieve the Confluence page `InfinitIQ Tech - Company Philosophy & The Infinite Mindset` at [https://infinitiqtech.atlassian.net/wiki/spaces/Core/pages/4292609/InfinitIQ+Tech+-+Company+Philosophy+The+Infinite+Mindset](https://infinitiqtech.atlassian.net/wiki/spaces/Core/pages/4292609/InfinitIQ+Tech+-+Company+Philosophy+The+Infinite+Mindset) and use it as the rationale context for why changes are being made.
- For implementation tasks, agents read `AGENTS.md` first, then retrieve the company-philosophy Confluence page, then any relevant feature spec, then this root spec, then [`spec_guidance.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_guidance.md), then relevant spec logs, then live code.
- Live code is the final authority when docs are stale, but any discovered mismatch must be corrected in the appropriate spec files before the task is closed.
- Feature specs are required only when a request changes documented feature behavior or needs a new long-lived feature-level source of truth.
- Repo-wide workflow, boundary, command, architecture, and shared-behavior changes require updates to [`AGENTS.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/AGENTS.md), [`SPEC.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/SPEC.md), [`spec_guidance.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_guidance.md), and [`spec_log.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_log.md) as needed.

## 5. Public API Surface

### 5.1 Core and Config Types

| Type group | Public types | Notes |
|---|---|---|
| JSON helper | `JSONValue` | Custom recursive JSON enum; decodes `Int` as `.number(Double)` |
| Shared enums | `EnvironmentName`, `AgentVersionStatus`, `ChatRole`, `ClientChatRole`, `FeedbackRating` | `ClientChatRole` is the public inbound runtime role subset |
| Agent config | `AgentRuntimeConfig`, `AgentModelCandidate`, `AgentModelConfig`, `AgentMemoryConfig`, `AgentRetrievalConfig`, `AgentGuardrailsConfig`, `AgentOutputFormat`, `AgentOutputConfig`, `AgentConfig` | Core published agent configuration contract, including the version-scoped `systemPrompt` runtime instruction |
| Tool config | `ToolEndpoint`, `ToolDefinition`, `AddToolToAgentVersionRequest`, `AgentToolsConfig`, `AgentToolPolicy` | Defined in the function-calling folder because tool schema support is a distinct subdomain |

### 5.2 Control-Plane Request Types

| Type | Purpose |
|---|---|
| `CreateAgentRequest` | Create a new agent from slug, name, system prompt, and optional metadata |
| `UpdateAgentRequest` | Partial update of name, prompt, description, and tags |
| `PublishAgentVersionRequest` | Publish a version with an `AgentConfig` payload |
| `DeploymentVersionWeight` | One version-to-weight mapping for rollout |
| `UpsertDeploymentRequest` | Environment deployment update keyed by `agentRef` |

### 5.3 Runtime Request Types

| Type | Purpose |
|---|---|
| `ToolCall` | Tool invocation envelope with `toolId`, optional `callId`, and JSON arguments |
| `ChatMessageIn` | Stateless runtime input message, including assistant tool-call replay and tool-result continuation fields |
| `ChatRequest` | Runtime chat request, including routing by `environment` or direct `agentVersionId` |
| `FeedbackRequest` | Feedback payload tied to agent, version, environment, and optional conversation or message |

### 5.4 Response Types

| Type | Purpose |
|---|---|
| `AgentDTO` | Agent metadata returned by the control plane |
| `AgentVersionSummaryDTO`, `AgentVersionDTO` | Version metadata and full published configuration |
| `DeploymentDTO` | Environment deployment state |
| `AgentWithDeploymentsDTO` | Aggregated agent record with versions and deployments |
| `ToolCallSummaryDTO`, `RetrievalSummaryDTO`, `ChatUsageDTO`, `ChatTelemetryDTO` | Runtime telemetry summaries |
| `ChatMessageDTO`, `ChatResponseDTO` | Full chat transcript and response wrapper |
| `AcceptedResponse` | Generic accepted-status response |

### 5.5 Streaming Event Types

| Event | Type | Notes |
|---|---|---|
| `start` | `StreamStartEventDTO` | Includes request, agent, version, environment, and conversation IDs |
| `chunk` | `StreamChunkEventDTO` | Carries a text delta only |
| `end` | `StreamEndEventDTO` | Wraps an optional `ChatResponseDTO` |
| `tool_call` | `ToolCallEventDTO` | Mirrors tool-call payloads from the streaming sidecar |
| `tool_result` | `ToolResultEventDTO` | Mirrors tool-result payloads from the streaming sidecar |

## 6. Wire Format and Serialization Rules

### 6.1 General Rules

- Public DTO property names remain Swift camelCase in source.
- Current tests verify snake_case JSON decoding and encoding by configuring `JSONDecoder.keyDecodingStrategy = .convertFromSnakeCase` and `JSONEncoder.keyEncodingStrategy = .convertToSnakeCase`.
- Date-bearing DTO tests use `.iso8601`; new tests for date fields should use the same strategy unless the package adds an explicit alternative contract.
- Prefer synthesized `Codable` through Vapor's `Content` conformance. Add custom encode or decode logic only for compatibility or unsupported value shapes.

### 6.2 Compatibility-Sensitive Types

| Type | Required behavior |
|---|---|
| `JSONValue` | Must support string, bool, number, object, array, and null; unsupported shapes throw `DecodingError.typeMismatch` |
| `JSONValue` | Integer payloads normalize to `.number(Double)` |
| `AgentToolsConfig` | Must decode either `definitions` or legacy `functions` input |
| `AgentToolsConfig` | Must encode only `definitions`, never `functions` |
| `AgentToolsConfig.allowed` | `nil` and `[]` are distinct wire states and must round-trip distinctly |
| `AgentToolsConfig` | A payload with `definitions` and omitted `allowed` is a valid definitions-only shape; the DTO preserves omission instead of synthesizing tool names |
| `AgentToolsConfig` | Omitted tool config or an omitted allow-list does not, by itself, imply any enabled built-in tools |
| `FunctionDefinition` | Deprecated typealias to `ToolDefinition`; do not remove without an intentional breaking-change decision |

### 6.3 Semantic Contracts Documented in Code

- `ChatRequest.agentRef` is a string that may contain either an agent slug or a UUID string.
- `ChatRequest.agentVersionId` bypasses environment deployment routing when non-`nil`.
- `ChatRequest.providerKeys` are request-only secrets and are documented as non-persisted.
- `ChatRequest.messages` are documented to end with a user message; the package currently documents this contract but does not enforce it locally.
- `AgentConfig.systemPrompt` is a required field on the published version snapshot and encodes to `system_prompt` in JSON.
- `AgentConfig.systemPrompt` is version-scoped runtime configuration; it is distinct from the mutable `AgentDTO.systemPrompt` control-plane field.
- `AgentConfig.output` is an optional published version snapshot section for structured output configuration and is omitted when `nil`.
- `AgentOutputConfig.format` wraps the required `AgentOutputFormat` payload.
- `AgentOutputFormat.type` is a required string and `AgentOutputFormat.schema` is a required recursive JSON object stored as `[String: JSONValue]`.
- [Structured output](features/structured-output/SPEC.md) defines the AF-83 envelope: required `format`, `type`, and object-valued `schema`; arbitrary recursive schema keys and values are preserved under the snake_case wire strategies. DTOs transport this schema; external runtimes own semantic validation and provider execution.
- `AgentConfig.tools == nil` means the published version snapshot does not declare any tool configuration.
- `AgentToolsConfig.allowed == nil` preserves allow-list omission from the wire payload, while `AgentToolsConfig.allowed == []` is an explicit empty allow-list.
- A definitions-only `AgentToolsConfig` payload (`definitions` present with omitted `allowed`) is valid; downstream runtimes may infer executable tool names from the definitions and publishers may normalize that payload before persistence.
- `AgentToolsConfig` does not imply built-in tools are enabled unless the payload names them explicitly.
- `ChatMessageIn` accepts `user`, `assistant`, or `tool`.
- `ChatMessageIn.toolCalls` carries assistant replay tool-call metadata when a caller resends a prior assistant tool-call turn.
- `ChatMessageIn.toolCallId` carries the correlation id for a `tool` replay message.
- `ChatRequest.messages` may end with either a `user` message or a `tool` message when continuing after client-side tool execution.
- `ChatMessageDTO` can emit `system`, `user`, `assistant`, or `tool`.

## 7. Commands

Run all commands from the repository root: [`/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO)

```bash
# Resolve dependencies
swift package resolve

# Build the library
swift build

# Run the full test suite
swift test
```

Verified command status:

- `swift test` passes in the current repository state.
- There is no repo-local lint or formatting command configured.

## 8. Code Style and Placement Rules

### 8.1 Current DTO Pattern

```swift
public struct ToolCall: Content, Sendable {
    public let callId: String?
    public let toolId: String
    public let args: [String: JSONValue]
}
```

### 8.2 Rules

- Exported wire-contract types are `public`.
- DTOs conform to `Content` and `Sendable` unless there is a concrete reason not to.
- Add `Equatable` only when tests or value semantics need direct comparison.
- Keep stored properties immutable with `let`.
- Provide explicit public initializers for exported types.
- Keep the main contract types in [`Sources/AgentFactoryDTO/AgentFactoryDTO.swift`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/Sources/AgentFactoryDTO/AgentFactoryDTO.swift) unless the new API belongs to an existing focused subdomain such as function-calling or streaming.
- Keep tool-calling and SSE-specific DTOs in the existing `Agent Capabilities/Function Calling` folder unless a new package-level subdomain is introduced.
- When adding shell commands or scripts that reference files in the function-calling folder, quote the path because the directory names contain spaces.

## 9. Testing

| Area | Current state |
|---|---|
| Framework | XCTest |
| Test target | `AgentFactoryDTOTests` |
| Current file layout | `Tests/AgentFactoryDTOTests/AgentFactoryDTOTests.swift`, `Tests/AgentFactoryDTOTests/RuntimeAndResponseDTOTests.swift`, and `Tests/AgentFactoryDTOTests/StructuredOutputDTOTests.swift` |
| Current coverage focus | `AgentConfig`, `AgentOutputConfig`, `PublishAgentVersionRequest`, `AgentToolsConfig` compatibility, `ToolCall`, SSE tool events, stream lifecycle events, `ChatRequest`, `AgentVersionDTO`, `AgentWithDeploymentsDTO`, `ChatResponseDTO`, and `AcceptedResponse` wire contracts |

Expectations for new or changed code:

- Add or update unit tests for every new or changed implementation.
- Any behavior documented in this spec or a feature spec must have direct XCTest coverage.
- Add unit tests for every custom `Codable` path.
- Add compatibility tests when changing legacy key support, deprecated aliases, or documented wire contracts.
- Add encode and decode tests for new streaming DTOs and request/response wrappers when those payloads gain custom behavior or compatibility-sensitive fields.
- Use `.convertFromSnakeCase`, `.convertToSnakeCase`, and `.iso8601` in tests when validating HTTP or SSE wire payloads that follow the current contract.

## 10. Boundaries

### Always Do

- Preserve backward-compatible decoding when the package already supports a legacy wire format.
- Keep public DTO field names, optionality, and enum raw values aligned with the live contract.
- Add or update tests when changing custom serialization logic or compatibility behavior.
- Update the appropriate spec files before closing a task when implementation changes documented behavior or reveals stale docs.
- Treat `Package.swift` and `Package.resolved` as the source of truth for dependency and platform changes.

### Ask First

- Removing a public type, public property, enum case, or deprecated typealias.
- Renaming files or splitting the monolithic DTO file into multiple files.
- Changing the macOS deployment target or the Vapor dependency floor.
- Changing documented wire behavior for `ChatRequest`, `AgentToolsConfig`, or streaming events.
- Shipping an implementation change without unit-test coverage for the affected spec-described behavior.

### Never Do

- Hand-edit `.build/` or `.swiftpm/`.
- Rename Swift properties to snake_case to satisfy JSON payloads.
- Encode legacy `functions` output from `AgentToolsConfig`.
- Introduce server-only logic, persistence code, or route handlers into this library target.

## 11. Known Gaps and Discrepancies

- There is no README or repo-local architecture note outside the source code.
- There is no repo-local CI, lint, or formatter configuration file.
- The current tests still do not cover every public DTO. `CreateAgentRequest`, `UpdateAgentRequest`, `DeploymentVersionWeight`, `UpsertDeploymentRequest`, and `FeedbackRequest` do not yet have dedicated wire-contract tests.
- The documented `ChatRequest.messages` rule now allows either a trailing user message or a trailing tool message, and that sequencing rule is not enforced by package code.

## 12. Conformance Criteria

1. `swift test` passes from the repository root after a change.
2. New public DTOs compile as part of the `AgentFactoryDTO` library target and are placed in the existing source layout or a clearly justified new subdomain.
3. Compatibility-sensitive types preserve their current behavior: `JSONValue` supports the current JSON shape set, `AgentToolsConfig` decodes `definitions` and `functions`, and `AgentToolsConfig` encodes only `definitions`.
4. New or changed implementation behavior is accompanied by unit tests, and any behavior documented in this spec or a feature spec has direct XCTest coverage.
5. Public wire-contract changes are accompanied by tests that cover the affected encode or decode path.
6. Changes do not add generated or tool-state files from `.build/` or `.swiftpm/` to the source-controlled contract surface.
7. `AgentConfig` continues to encode and decode `systemPrompt` as the required snake_case field `system_prompt`.

## 13. Glossary

| Term | Meaning in this repository |
|---|---|
| `agentRef` | A string identifier accepted by runtime and deployment requests; may be a slug or UUID string |
| `environment` | Deployment selection enum with `dev`, `staging`, and `prod` cases |
| `toolId` | Stable string identifier for a tool or tool schema |
| `callId` | Optional correlation ID that pairs a tool call with its eventual result |
| `systemPrompt` | Version-scoped instruction string carried inside `AgentConfig` and serialized as `system_prompt` |
| `allowed` | Optional exact tool-name allow-list in `AgentToolsConfig`; `nil` preserves omission and `[]` is an explicit empty whitelist |
| `definitions` | Preferred key for LLM-native tool schemas in `AgentToolsConfig` |
| `functions` | Legacy decode-only key accepted for backward compatibility in `AgentToolsConfig` |
| SSE | Server-sent events payloads represented by the `Stream*EventDTO`, `ToolCallEventDTO`, and `ToolResultEventDTO` types |
