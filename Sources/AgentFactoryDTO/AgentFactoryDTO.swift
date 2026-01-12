// The Swift Programming Language
// https://docs.swift.org/swift-book
import Vapor

public enum JSONValue: Codable, Equatable, Sendable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
            return
        }

        if let b = try? container.decode(Bool.self) {
            self = .bool(b)
            return
        }

        if let i = try? container.decode(Int.self) {
            self = .number(Double(i))
            return
        }

        if let d = try? container.decode(Double.self) {
            self = .number(d)
            return
        }

        if let s = try? container.decode(String.self) {
            self = .string(s)
            return
        }

        if let o = try? container.decode([String: JSONValue].self) {
            self = .object(o)
            return
        }

        if let a = try? container.decode([JSONValue].self) {
            self = .array(a)
            return
        }

        throw DecodingError.typeMismatch(
            JSONValue.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Unsupported JSON value"
            )
        )
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let s):
            try container.encode(s)
        case .number(let n):
            try container.encode(n)
        case .bool(let b):
            try container.encode(b)
        case .object(let o):
            try container.encode(o)
        case .array(let a):
            try container.encode(a)
        case .null:
            try container.encodeNil()
        }
    }
}

public enum EnvironmentName: String, Content, Sendable {
    case dev
    case staging
    case prod
}

public enum AgentVersionStatus: String, Content, Sendable {
    case draft
    case published
    case deprecated
}

public enum ChatRole: String, Content, Sendable {
    case system
    case user
    case assistant
    case tool
}

public enum ClientChatRole: String, Content, Sendable {
    case user
    case assistant
}

public enum FeedbackRating: String, Content, Sendable {
    case thumbsUp = "thumbs_up"
    case thumbsDown = "thumbs_down"
}

// MARK: Agents
public struct AgentRuntimeConfig: Content, Sendable {
    public let streaming: Bool
    public let maxTurns: Int?
    public let maxConcurrentTools: Int?
}

public struct AgentModelCandidate: Content, Sendable {
    public let name: String
    public let model: String
}

public struct AgentModelConfig: Content, Sendable {
    public let strategy: String
    public let candidates: [AgentModelCandidate]
    public let routingPolicy: [String: JSONValue]?
}

public struct AgentMemoryConfig: Content, Sendable {
    public let type: String?
    public let windowTurns: Int?
}

public struct AgentRetrievalConfig: Content, Sendable {
    public let enabled: Bool
    public let corpusIds: [String]?
    public let topK: Int?
    public let rerank: Bool?
    public let filters: [String: JSONValue]?
}

public struct AgentToolPolicy: Content, Sendable {
    public let requireUserConfirmation: [String]?
    public let maxTotalRuntimeMs: Int?
    public let maxToolsPerTurn: Int?
}

public struct AgentToolsConfig: Content, Sendable {
    public let allowed: [String]?
    public let toolPolicy: AgentToolPolicy?
}

public struct AgentGuardrailsConfig: Content, Sendable {
    public let piiRedaction: Bool?
    public let jailbreakDetection: Bool?
    public let blockedTopics: [String]?
}

public struct AgentConfig: Content, Sendable {
    public let id: String
    public let name: String
    public let version: String
    public let schemaVersion: String
    public let description: String?
    public let tags: [String]?

    public let runtime: AgentRuntimeConfig
    public let model: AgentModelConfig
    public let memory: AgentMemoryConfig?
    public let retrieval: AgentRetrievalConfig?
    public let tools: AgentToolsConfig?
    public let guardrails: AgentGuardrailsConfig?
}

// MARK: - Control plane: Requests

public struct CreateAgentRequest: Content, Sendable {
    public let slug: String
    public let name: String
    public let systemPrompt: String
    public let description: String?
    public let templateId: String?
    public let tags: [String]?
}

public struct UpdateAgentRequest: Content, Sendable {
    public let name: String?
    public let systemPrompt: String?
    public let description: String?
    public let tags: [String]?
}

public struct PublishAgentVersionRequest: Content, Sendable {
    public let config: AgentConfig
    public let tags: [String]?
}

public struct DeploymentVersionWeight: Content, Sendable {
    public let agentVersionId: UUID
    public let rolloutWeight: Int
}

public struct UpsertDeploymentRequest: Content, Sendable {
    public let agentRef: String
    public let environment: EnvironmentName
    public let versions: [DeploymentVersionWeight]
}

// MARK: - Runtime: Requests

public struct ToolCall: Content, Sendable {
    public let toolId: String
    public let args: [String: JSONValue]
}

public struct ChatMessageIn: Content, Sendable {
    public let role: ClientChatRole
    public let content: String
}

public struct ChatRequest: Content, Sendable {
    public let agentRef: String
    public let environment: EnvironmentName
    public let conversationId: UUID?
    public let userId: String?
    public let messages: [ChatMessageIn]
    public let metadata: [String: JSONValue]?
    // Optional: provider API keys to pass to runtime sidecar. Not persisted.
    public let providerKeys: [String: String]?
}

public struct FeedbackRequest: Content, Sendable {
    public let agentRef: String
    public let agentVersionId: UUID
    public let environment: EnvironmentName
    public let conversationId: UUID?
    public let messageId: UUID?
    public let userId: String?
    public let rating: FeedbackRating
    public let reason: String?
    public let metadata: [String: JSONValue]?
}

// MARK: - Responses

public struct AgentDTO: Content, Sendable {
    public let id: UUID
    public let orgId: String
    public let projectId: String
    public let slug: String
    public let name: String
    public let systemPrompt: String
    public let description: String?
    public let tags: [String]?
    public let createdBy: String?
    public let createdAt: Date
    public let updatedAt: Date?
    public let archivedAt: Date?
}

public struct AgentVersionSummaryDTO: Content, Sendable {
    public let id: UUID
    public let version: String
    public let status: AgentVersionStatus
    public let createdAt: Date
}

public struct AgentVersionDTO: Content, Sendable {
    public let id: UUID
    public let agentId: UUID
    public let version: String
    public let schemaVersion: String
    public let status: AgentVersionStatus
    public let config: AgentConfig
    public let tags: [String]?
    public let createdBy: String?
    public let createdAt: Date
}

public struct DeploymentDTO: Content, Sendable {
    public let id: UUID
    public let orgId: String
    public let projectId: String
    public let agentId: UUID
    public let environment: EnvironmentName
    public let versions: [DeploymentVersionWeight]
    public let createdBy: String?
    public let createdAt: Date
    public let updatedAt: Date?
}

public struct AgentWithDeploymentsDTO: Content, Sendable {
    public let agent: AgentDTO
    public let latestVersions: [AgentVersionSummaryDTO]?
    public let deployments: [DeploymentDTO]?
}

public struct ToolCallSummaryDTO: Content, Sendable {
    public let toolId: String
    public let success: Bool
    public let durationMs: Int?
    public let error: String?
}

public struct RetrievalSummaryDTO: Content, Sendable {
    public let corpusIds: [String]?
    public let topK: Int?
    public let hitCount: Int?
}

public struct ChatUsageDTO: Content, Sendable {
    public let tokensInput: Int?
    public let tokensOutput: Int?
    public let cost: Double?
}

public struct ChatTelemetryDTO: Content, Sendable {
    public let latencyMs: Int?
    public let toolCalls: [ToolCallSummaryDTO]?
    public let retrieval: RetrievalSummaryDTO?
}

public struct ChatMessageDTO: Content, Sendable {
    public let id: UUID
    public let role: ChatRole
    public let content: String
    public let createdAt: Date
    public let toolCalls: [ToolCall]?
}

public struct ChatResponseDTO: Content, Sendable {
    public let requestId: UUID
    public let agentId: UUID
    public let agentVersionId: UUID
    public let environment: EnvironmentName
    public let conversationId: UUID
    public let messages: [ChatMessageDTO]
    public let usage: ChatUsageDTO?
    public let telemetry: ChatTelemetryDTO?
}

public struct AcceptedResponse: Content, Sendable {
    public let status: String
}
