//
//  ToolResultEventDTO.swift
//  AgentFactoryDTO
//

import Vapor

/// SSE event payload for a `tool_result` event emitted by the streaming sidecar.
///
/// Wire format: `{"tool":"func_name","result":"...","success":true,"id":"call_123"}`
public struct ToolResultEventDTO: Content, Sendable {
    public let id: String
    public let tool: String
    public let result: String
    public let success: Bool

    public init(id: String, tool: String, result: String, success: Bool) {
        self.id = id
        self.tool = tool
        self.result = result
        self.success = success
    }
}
