//
//  FunctionDefinition.swift
//  AgentFactoryDTO
//
//  Created by Kenneth Dubroff on 2/1/26.
//

import Vapor

public struct AgentToolsConfig: Content, Sendable, Equatable {
    /// tool IDs for text-pattern matching
    public let allowed: [String]?
    /// LLM-native function schemas
    public let functions: [FunctionDefinition]?
    public let toolPolicy: AgentToolPolicy?

    public init(
        allowed: [String]? = nil,
        functions: [FunctionDefinition]? = nil,
        toolPolicy: AgentToolPolicy? = nil
    ) {
        self.allowed = allowed
        self.functions = functions
        self.toolPolicy = toolPolicy
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

 public struct FunctionDefinition: Content, Sendable, Equatable {
     public let name: String
     public let description: String?
     public let parameters: [String: JSONValue]
     public let strict: Bool?
     public init(
         name: String,
         description: String? = nil,
         parameters: [String: JSONValue],
         strict: Bool? = nil
     ) {
         self.name = name
         self.description = description
         self.parameters = parameters
         self.strict = strict
     }
 }
