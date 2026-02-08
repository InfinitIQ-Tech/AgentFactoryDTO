//
//  ToolCallEventDTO.swift
//  AgentFactoryDTO
//

import Vapor

/// SSE event payload for a `tool_call` event emitted by the streaming sidecar.
///
/// Wire format: `{"tool":"func_name","arguments":{...},"status":"started","id":"call_123"}`
public struct ToolCallEventDTO: Content, Sendable {
    public let id: String
    public let tool: String
    public let arguments: [String: JSONValue]
    public let status: String

    public init(id: String, tool: String, arguments: [String: JSONValue], status: String = "started") {
        self.id = id
        self.tool = tool
        self.arguments = arguments
        self.status = status
    }
}
