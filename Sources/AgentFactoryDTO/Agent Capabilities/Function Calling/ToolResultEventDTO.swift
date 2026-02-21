//
//  ToolResultEventDTO.swift
//  AgentFactoryDTO
//

import Vapor

/// SSE event payload for a `tool_result` event emitted by the streaming sidecar.
///
/// Wire format: `{"tool_id":"func_name","call_id":"call_123","output":"...","success":true}`
public struct ToolResultEventDTO: Content, Sendable {
    public let toolId: String
    public let callId: String?
    public let output: String
    public let success: Bool

    public init(toolId: String, callId: String?, output: String, success: Bool) {
        self.toolId = toolId
        self.callId = callId
        self.output = output
        self.success = success
    }
}
