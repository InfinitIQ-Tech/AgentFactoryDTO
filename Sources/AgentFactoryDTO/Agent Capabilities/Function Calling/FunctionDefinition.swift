//
//  FunctionDefinition.swift
//  AgentFactoryDTO
//
//  Created by Kenneth Dubroff on 2/1/26.
//

import Vapor

public struct ToolEndpoint: Content, Sendable, Equatable {
    public let url: String
    public let method: String?
    public let headers: [String: String]?

    public init(url: String, method: String? = nil, headers: [String: String]? = nil) {
        self.url = url
        self.method = method
        self.headers = headers
    }
}

public struct ToolDefinition: Content, Sendable, Equatable {
    public let name: String
    public let description: String
    public let parameters: [String: JSONValue]
    public let endpoint: ToolEndpoint?

    public init(
        name: String,
        description: String,
        parameters: [String: JSONValue],
        endpoint: ToolEndpoint? = nil
    ) {
        self.name = name
        self.description = description
        self.parameters = parameters
        self.endpoint = endpoint
    }
}

public struct AddToolToAgentVersionRequest: Content, Sendable, Equatable {
    public let definition: ToolDefinition

    public init(definition: ToolDefinition) {
        self.definition = definition
    }
}

@available(*, deprecated, renamed: "ToolDefinition")
public typealias FunctionDefinition = ToolDefinition

public struct AgentToolsConfig: Content, Sendable, Equatable {
    /// Optional exact allow-list of tool names.
    ///
    /// `nil` preserves the absence of an allow-list in the payload.
    /// `[]` is an explicit allow-list that enables no tool names.
    /// When `definitions` is present and `allowed` is `nil`, the payload remains
    /// "definitions-only" so downstream runtimes or publishers can apply their
    /// own normalization without this DTO implying hidden built-in tools.
    public let allowed: [String]?
    /// LLM-native tool schemas plus optional execution endpoints.
    ///
    /// A payload may provide `definitions` without `allowed`; this DTO preserves
    /// that wire shape instead of synthesizing an allow-list.
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
