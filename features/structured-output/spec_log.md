# Structured output spec log

## 2026-10-04

- Files changed: `SPEC.md`, `spec_log.md` in this feature directory.
- Trigger: AF-83 structured output contract synchronization.
- Summary: Documented the optional output envelope, required fields,
  compatibility defaults, recursive schema preservation, and the boundary
  between DTO transport and runtime validation.
- Operational impact: Future DTO work must preserve schema keys and values
  under the package's snake_case wire strategies.
