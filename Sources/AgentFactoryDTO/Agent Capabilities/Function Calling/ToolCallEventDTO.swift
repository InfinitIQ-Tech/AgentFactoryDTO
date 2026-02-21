//
//  ToolCallEventDTO.swift
//  AgentFactoryDTO
//

import Vapor

/// SSE event payload for a `tool_call` event emitted by the streaming sidecar.
///
/// Wire format: `{"tool_id":"func_name","call_id":"call_123","args":{...}}`
public struct ToolCallEventDTO: Content, Sendable {
    public let toolId: String
    public let callId: String?
    public let args: [String: JSONValue]

    public init(toolId: String, callId: String?, args: [String: JSONValue]) {
        self.toolId = toolId
        self.callId = callId
        self.args = args
    }
}
