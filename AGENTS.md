# AGENTS.md

## Purpose

Use specs as the implementation contract for this repository. Do not go straight from prompt to code.

## Read Order

1. `AGENTS.md`
2. The relevant feature spec in `features/<feature-name>/SPEC.md`, if it exists
3. `SPEC.md`
4. `spec_guidance.md`
5. The relevant spec log files
6. The live code in `Package.swift`, `Sources/AgentFactoryDTO/AgentFactoryDTO.swift`, `Sources/AgentFactoryDTO/Agent Capabilities/Function Calling/`, and `Tests/AgentFactoryDTOTests/`

Live code wins when documentation is stale, but any discovered mismatch must be corrected in the appropriate spec files before closing the task.

## Required Workflow

For every implementation request, use this sequence:

1. Read the user prompt and identify the smallest stable feature boundary affected by the request.
2. Decide whether the request changes documented feature behavior or needs a new feature-level source of truth. If yes, write a new feature spec or update the existing one before changing code. If no, use the root specs as the active implementation contract.
3. Implement the change against the relevant spec files.
4. Update the feature spec after implementation so it matches shipped behavior when feature-scoped behavior changed.
5. Update `SPEC.md`, `spec_guidance.md`, and `spec_log.md` when the change affects any existing repo-wide rule, workflow, command, boundary, architecture detail, shared behavior, or spec-maintenance process.
6. Correct any code-versus-spec mismatch discovered during the work in the appropriate spec files before closing the task.

Do not skip spec updates when behavior in a current spec changes. Do not create a feature spec for every small implementation-only change that does not change documented behavior.

## Feature Spec Routing

- Store feature specs in `features/<feature-name>/SPEC.md`.
- Store feature spec history in `features/<feature-name>/spec_log.md`.
- Use kebab-case for feature folder names.
- Reuse an existing feature folder when the request clearly belongs to it.
- If a feature-scoped behavior change needs a new long-lived spec and no feature spec exists, create it before implementation.
- Keep shared rules in the root `SPEC.md`; keep local behavior in the feature spec.

## Repository Overview

- This repository is a Swift Package Manager library named `AgentFactoryDTO`.
- The package exports DTOs and contract types for an agent platform backend. It does not contain route handlers, persistence models, provider integrations, or executable entrypoints.
- The package currently has one library target, `AgentFactoryDTO`, and one XCTest target, `AgentFactoryDTOTests`.
- The manifest is `Package.swift`. The current platform floor is macOS 13 and the primary dependency is Vapor 4.
- The main DTO inventory lives in `Sources/AgentFactoryDTO/AgentFactoryDTO.swift`.
- Tool-calling and streaming DTOs live under `Sources/AgentFactoryDTO/Agent Capabilities/Function Calling/`.
- The test suite currently lives in `Tests/AgentFactoryDTOTests/AgentFactoryDTOTests.swift`.
- `.build/` and `.swiftpm/` are generated directories and are not hand-edited.

## Repository Constraints

- Preserve the package as a contract library. Do not add server-only logic, database code, route registration, or provider SDK workflows here.
- Preserve public DTO names, property names, optionality, enum raw values, and compatibility behavior unless the user explicitly asks for a contract change.
- Keep the main DTO definitions in `Sources/AgentFactoryDTO/AgentFactoryDTO.swift` unless the change belongs to an existing focused subdomain.
- Keep tool-calling and SSE-specific DTOs in `Sources/AgentFactoryDTO/Agent Capabilities/Function Calling/` unless the repository introduces a new documented subdomain.
- Quote shell paths that include `Agent Capabilities/Function Calling` because the directory names contain spaces.
- `AgentToolsConfig` must continue to decode both `definitions` and legacy `functions`, and it must encode only `definitions`.
- `JSONValue` must continue to support string, bool, number, object, array, and null payloads, and integer inputs continue to normalize to `Double`.
- Never hand-edit `.build/` or `.swiftpm/`.

## Testing Requirements

- Any new or changed implementation must add or update unit tests.
- Any behavior mentioned in `SPEC.md` or a feature spec must be backed by an XCTest unit test.
- Put tests in `Tests/AgentFactoryDTOTests/`. Add new test files when that improves clarity instead of forcing unrelated cases into one file.
- For wire-format behavior, use `JSONDecoder.keyDecodingStrategy = .convertFromSnakeCase`, `JSONEncoder.keyEncodingStrategy = .convertToSnakeCase`, and `.iso8601` date strategies unless the spec for that behavior says otherwise.
- When compatibility behavior changes, add tests for both the new path and any legacy path the repository still supports.

## How To Verify Changes

- Re-read the relevant spec files and live code to confirm they match.
- Run `swift test` from the repository root for any implementation change.
- Run `swift build` when package structure, manifest settings, or source placement changes make an explicit build check useful.
- Verify that every spec-described behavior touched by the change has direct unit-test coverage.
- If the task changes repo-wide workflow or feature-spec routing, confirm `AGENTS.md`, `SPEC.md`, `spec_guidance.md`, and the correct spec log files were updated together.

## Delivery Requirements

Every delivery for an implementation task must include:

- A summary of the changes.
- The tests run and their results.
- The tests created or updated.
- Any obvious remaining gaps in test coverage.
- Remaining risks.
- Follow-ups, if any.

If a verification step was not run, say so explicitly and give the reason.
