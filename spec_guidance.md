# spec_guidance.md

## Purpose

This repository uses a root-level spec set to give coding agents one current source of truth for the `AgentFactoryDTO` Swift package. The spec system documents what the package contains now, how its wire contracts behave, and how future spec updates should be recorded.

## File Layout

| File | Responsibility |
|---|---|
| [`AGENTS.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/AGENTS.md) | Agent workflow entry point: read order, spec-first implementation process, verification, and delivery requirements |
| [`SPEC.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/SPEC.md) | Current repo-wide source of truth for package scope, structure, commands, public API rules, compatibility rules, testing expectations, and boundaries |
| [`spec_guidance.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_guidance.md) | Procedural instructions for reading, writing, and maintaining specs in this repository |
| [`spec_log.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_log.md) | Dated log of repo-level spec changes |

This repository currently has no `features/` subtree. Add feature-level specs only if the package grows into clearly bounded modules that need their own source-of-truth documents.

## How To Read Specs In This Repository

Read spec files in this order:

1. [`AGENTS.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/AGENTS.md)
2. The relevant feature spec in `features/<feature-name>/SPEC.md`, if it exists
3. [`SPEC.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/SPEC.md)
4. [`spec_guidance.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_guidance.md)
5. The relevant spec log files
6. Live code in [`Package.swift`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/Package.swift), [`Sources/AgentFactoryDTO`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/Sources/AgentFactoryDTO), and [`Tests/AgentFactoryDTOTests`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/Tests/AgentFactoryDTOTests)

If the code and spec disagree, inspect the live code first and then update the stale document.

## How To Update `SPEC.md`

- Keep `SPEC.md` repo-level. Do not turn it into a changelog.
- Document only current package structure, current contracts, repository rules, verification instructions, or known discrepancies that affect agent work.
- Use real type names, filenames, and commands from the package.
- For this library, prefer sections that map to package structure, public API surface, serialization rules, commands, testing, boundaries, and conformance criteria.
- When a rule affects a compatibility-sensitive DTO such as `JSONValue` or `AgentToolsConfig`, verify the statement against the live implementation and tests before saving the spec.
- When `AgentConfig` changes, state whether the field is required, how it serializes on the wire, and whether it represents published runtime snapshot data or separate control-plane metadata.
- When the package gains new public API subdomains, update the repository structure and placement rules so agents know where new files belong.
- Keep [`AGENTS.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/AGENTS.md) aligned with repo-wide workflow, verification, and delivery rules when those rules change.

## How To Write Feature Specs If They Become Necessary

- Create or update feature specs only when an implementation request changes documented feature behavior or a bounded package subdomain needs a new long-lived source of truth.
- Use `features/<feature-name>/SPEC.md` and `features/<feature-name>/spec_log.md`.
- Use kebab-case for `<feature-name>`.
- Keep shared package rules in the root [`SPEC.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/SPEC.md). Do not copy the root boundaries or commands into a feature spec unless the feature has a documented exception.
- Never create `spec_guidance.md` inside a feature folder.

## Logging Rules

- Every repo-level change to [`SPEC.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/SPEC.md) must be logged in [`spec_log.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/spec_log.md).
- `spec_log.md` entries must include the date, the files changed, a brief summary, the trigger, and any operational impact that future agents should know.
- If feature-level specs are added later, log feature-only changes in that feature's `spec_log.md` and keep repo-wide entries in the root log.

## Verification Rules For Spec Maintenance

Before finalizing a spec update:

1. Confirm the scope is repo-level or feature-level and write to the correct path.
2. Re-read the affected code so each factual statement is tied to the current implementation.
3. Re-run or confirm the commands documented in the spec when command behavior changes.
4. Check that compatibility-sensitive claims match the current tests or add tests if the change introduces new custom serialization behavior.
5. Confirm that any behavior described in [`SPEC.md`](/Users/kennethdubroff/Development/InfinitIQTech/core/backend/AgentFactoryDTO/SPEC.md) or a feature spec and touched by the implementation has unit-test coverage.
6. Remove subjective language, roadmap language, and unimplemented design intent.

## Naming And Path Conventions

- Root spec files stay at the repository root.
- Feature folders, if introduced, use `features/<feature-name>/`.
- Use filesystem-safe kebab-case names for new feature folders.
- Reference the existing source tree exactly as it exists, including the quoted `Agent Capabilities/Function Calling` path when using shell commands.
