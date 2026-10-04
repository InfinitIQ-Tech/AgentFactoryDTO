# Structured output DTO contract

AF-83 adds an optional published manifest section to carry the public
`agent-config-spec` v2 structured output contract to external runtimes.

## Wire contract

- `AgentConfig.output` defaults to `nil` in the public initializer, decodes as
  `nil` when omitted, and is omitted on encoding when `nil`. Existing manifests
  and initializer call sites keep their prior behavior.
- When present, `output` contains a required `format` object with required
  `type: String` and `schema: [String: JSONValue]` fields. A missing format,
  discriminator, or schema, or a non-object schema, fails DTO decoding.
- The public v2 format discriminator is `json_schema`. The DTO transports a
  string discriminator without provider execution or validation; runtime
  adapters decide which formats and JSON Schema keywords they can execute.
- Schema payloads preserve arbitrary object keys (including snake_case property
  names, camelCase JSON Schema keywords, and extension names) and recursive
  JSON values through the package's snake_case encoder and decoder strategies.
  This includes unknown schema extensions, arrays, objects, booleans, numbers,
  strings, and null. Existing integer-to-Double normalization still applies.
- The same envelope survives `PublishAgentVersionRequest` serialization.
- This is an additive optional v2 field. No schema-version or platform-floor
  change is needed, and provider SDKs remain outside this contract library.

## Verification

`swift test` runs structured-output wire coverage in
`Tests/AgentFactoryDTOTests/StructuredOutputDTOTests.swift` and the existing
`AgentConfig` round-trip test. The existing DTO suite guards compatibility.

JSON Schema semantic validation, generation, decoded result validation,
prewarming, and provider/device integration tests belong to the runtime.
