//
//  SSEEventDTOs.swift
//  AgentFactoryDTO
//

import Vapor

/// SSE event payload for a `start` event emitted at the beginning of a streaming response.
///
/// Wire format: `{"request_id":"...","agent_id":"...","agent_version_id":"...","environment":"...","conversation_id":"..."}`
public struct StreamStartEventDTO: Content, Sendable {
    public let requestId: String
    public let agentId: String
    public let agentVersionId: String
    public let environment: String
    public let conversationId: String

    public init(requestId: String, agentId: String, agentVersionId: String, environment: String, conversationId: String) {
        self.requestId = requestId
        self.agentId = agentId
        self.agentVersionId = agentVersionId
        self.environment = environment
        self.conversationId = conversationId
    }
}

/// SSE event payload for a `chunk` event containing a text delta.
///
/// Wire format: `{"delta":"..."}`
public struct StreamChunkEventDTO: Content, Sendable {
    public let delta: String

    public init(delta: String) {
        self.delta = delta
    }
}

/// SSE event payload for an `end` event containing the final response.
///
/// Wire format: `{"response":{...ChatResponseDTO...}}`
public struct StreamEndEventDTO: Content, Sendable {
    public let response: ChatResponseDTO?

    public init(response: ChatResponseDTO?) {
        self.response = response
    }
}
