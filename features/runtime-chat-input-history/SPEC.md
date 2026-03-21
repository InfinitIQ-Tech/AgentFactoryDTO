# SPEC.md - Runtime Chat Input History

> This document is the feature-level source of truth for stateless runtime chat-history replay in AgentFactoryDTO.
> Scope: `ChatMessageIn`, `ClientChatRole`, and the wire-contract fields required to replay assistant tool calls and tool results across `/v1/chat` turns.

## 1. Feature Purpose

AgentFactory runtime chat is stateless at the request layer. Clients resend the relevant conversation history on each `/v1/chat` request, including intermediate tool-call turns when continuing after client-side tool execution.

This feature defines the DTO contract that allows callers to replay:

- normal user turns
- prior assistant turns that include `tool_calls`
- tool result turns that answer a prior assistant `tool_call_id`

## 2. In-Scope Types

- `ClientChatRole`
- `ChatMessageIn`
- `ChatRequest.messages`

## 3. Runtime Replay Rules

1. `ClientChatRole` includes `user`, `assistant`, and `tool`.
2. `ChatMessageIn` always carries `role` and `content`.
3. Assistant replay messages may include `tool_calls` so the caller can resend the prior assistant tool-call turn exactly enough for downstream runtimes to continue.
4. Tool replay messages may include `tool_call_id` so the caller can attach tool output to the specific prior assistant tool call being satisfied.
5. `ChatRequest.messages` is a stateless history envelope. It may end in either:
   - a `user` message for a fresh model turn, or
   - a `tool` message for continuation after client-side tool execution.
6. The DTO package documents this runtime contract but does not enforce turn-sequencing rules locally.

## 4. Out-of-Scope Behavior

This feature does not:

- validate that a `tool` message has a matching prior assistant `tool_calls` entry
- execute tools
- persist conversation history
- enforce provider-specific sequencing rules

Those behaviors belong to consuming runtimes.

## 5. Verification Requirements

Coverage for this feature must prove:

1. `ChatMessageIn` decodes and encodes `role: "tool"` with `tool_call_id`.
2. `ChatMessageIn` decodes and encodes assistant `tool_calls`.
3. `ChatRequest` round-trips message histories that end with a `tool` message.
