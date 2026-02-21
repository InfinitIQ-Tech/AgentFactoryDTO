//
//  FunctionDefinition.swift
//  AgentFactoryDTO
//
//  Created by Kenneth Dubroff on 2/1/26.
//

import Vapor

public struct ToolDefinition: Content, Sendable, Equatable {
    public let name: String
    public let description: String
    public let parameters: [String: JSONValue]

    public init(name: String, description: String, parameters: [String: JSONValue]) {
        self.name = name
        self.description = description
        self.parameters = parameters
    }
}

@available(*, deprecated, renamed: "ToolDefinition")
public typealias FunctionDefinition = ToolDefinition

public struct AgentToolsConfig: Content, Sendable, Equatable {
    /// Tool IDs for text-pattern matching / allow-listing.
    public let allowed: [String]?
    /// LLM-native tool schemas (JSON Schema).
    public let definitions: [ToolDefinition]?
    public let toolPolicy: AgentToolPolicy?

    public init(
        allowed: [String]? = nil,
        definitions: [ToolDefinition]? = nil,
        toolPolicy: AgentToolPolicy? = nil
    ) {
        self.allowed = allowed
        self.definitions = definitions
        self.toolPolicy = toolPolicy
    }

    // Custom Codable to accept legacy "functions" key.
    private enum CodingKeys: String, CodingKey {
        case allowed
        case definitions
        case functions
        case toolPolicy
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.allowed = try container.decodeIfPresent([String].self, forKey: .allowed)

        if let defs = try container.decodeIfPresent([ToolDefinition].self, forKey: .definitions) {
            self.definitions = defs
        } else {
            self.definitions = try container.decodeIfPresent([ToolDefinition].self, forKey: .functions)
        }

        self.toolPolicy = try container.decodeIfPresent(AgentToolPolicy.self, forKey: .toolPolicy)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(allowed, forKey: .allowed)
        try container.encodeIfPresent(definitions, forKey: .definitions)
        try container.encodeIfPresent(toolPolicy, forKey: .toolPolicy)
    }
}

public struct AgentToolPolicy: Content, Sendable, Equatable {
    public let requireUserConfirmation: [String]?
    public let maxTotalRuntimeMs: Int?
    public let maxToolsPerTurn: Int?

    public init(requireUserConfirmation: [String]?, maxTotalRuntimeMs: Int?, maxToolsPerTurn: Int?) {
        self.requireUserConfirmation = requireUserConfirmation
        self.maxTotalRuntimeMs = maxTotalRuntimeMs
        self.maxToolsPerTurn = maxToolsPerTurn
    }
}
