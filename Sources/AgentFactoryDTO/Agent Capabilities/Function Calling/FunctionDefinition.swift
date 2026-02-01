//
//  FunctionDefinition.swift
//  AgentFactoryDTO
//
//  Created by Kenneth Dubroff on 2/1/26.
//


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
