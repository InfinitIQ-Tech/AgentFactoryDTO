// The Swift Programming Language
// https://docs.swift.org/swift-book
import Vapor

enum JSONValue: Codable, Equatable, Sendable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    init(from decoder: any Decoder) throws {
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

    func encode(to encoder: any Encoder) throws {
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

enum EnvironmentName: String, Content, Sendable {
    case dev
    case staging
    case prod
}

enum AgentVersionStatus: String, Content, Sendable {
    case draft
    case published
    case deprecated
}

enum ChatRole: String, Content, Sendable {
    case system
    case user
    case assistant
    case tool
}

enum ClientChatRole: String, Content, Sendable {
    case user
    case assistant
}

enum FeedbackRating: String, Content, Sendable {
    case thumbsUp = "thumbs_up"
    case thumbsDown = "thumbs_down"
}

// MARK: Agents
struct AgentRuntimeConfig: Content, Sendable {
    var streaming: Bool
    var maxTurns: Int?
    var maxConcurrentTools: Int?
}

struct AgentModelCandidate: Content, Sendable {
    var name: String
    var model: String
}

struct AgentModelConfig: Content, Sendable {
    var strategy: String
    var candidates: [AgentModelCandidate]
    var routingPolicy: [String: JSONValue]?
}

struct AgentMemoryConfig: Content, Sendable {
    var type: String?
    var windowTurns: Int?
}

struct AgentRetrievalConfig: Content, Sendable {
    var enabled: Bool
    var corpusIds: [String]?
    var topK: Int?
    var rerank: Bool?
    var filters: [String: JSONValue]?
}

struct AgentToolPolicy: Content, Sendable {
    var requireUserConfirmation: [String]?
    var maxTotalRuntimeMs: Int?
    var maxToolsPerTurn: Int?
}

struct AgentToolsConfig: Content, Sendable {
    var allowed: [String]?
    var toolPolicy: AgentToolPolicy?
}

struct AgentGuardrailsConfig: Content, Sendable {
    var piiRedaction: Bool?
    var jailbreakDetection: Bool?
    var blockedTopics: [String]?
}

struct AgentConfig: Content, Sendable {
    var id: String
    var name: String
    var version: String
    var schemaVersion: String
    var description: String?
    var tags: [String]?

    var runtime: AgentRuntimeConfig
    var model: AgentModelConfig
    var memory: AgentMemoryConfig?
    var retrieval: AgentRetrievalConfig?
    var tools: AgentToolsConfig?
    var guardrails: AgentGuardrailsConfig?
}

// MARK: - Control plane: Requests

struct CreateAgentRequest: Content, Sendable {
    var slug: String
    var name: String
    var systemPrompt: String
    var description: String?
    var templateId: String?
    var tags: [String]?
}

struct UpdateAgentRequest: Content, Sendable {
    var name: String?
    var systemPrompt: String?
    var description: String?
    var tags: [String]?
}

struct PublishAgentVersionRequest: Content, Sendable {
    var config: AgentConfig
    var tags: [String]?
}

struct DeploymentVersionWeight: Content, Sendable {
    var agentVersionId: UUID
    var rolloutWeight: Int
}

struct UpsertDeploymentRequest: Content, Sendable {
    var agentRef: String
    var environment: EnvironmentName
    var versions: [DeploymentVersionWeight]
}

// MARK: - Runtime: Requests

struct ToolCall: Content, Sendable {
    var toolId: String
    var args: [String: JSONValue]
}

struct ChatMessageIn: Content, Sendable {
    var role: ClientChatRole
    var content: String
}

struct ChatRequest: Content, Sendable {
    var agentRef: String
    var environment: EnvironmentName
    var conversationId: UUID?
    var userId: String?
    var messages: [ChatMessageIn]
    var metadata: [String: JSONValue]?
    // Optional: provider API keys to pass to runtime sidecar. Not persisted.
    var providerKeys: [String: String]?
}

struct FeedbackRequest: Content, Sendable {
    var agentRef: String
    var agentVersionId: UUID
    var environment: EnvironmentName
    var conversationId: UUID?
    var messageId: UUID?
    var userId: String?
    var rating: FeedbackRating
    var reason: String?
    var metadata: [String: JSONValue]?
}

// MARK: - Responses

struct AgentDTO: Content, Sendable {
    var id: UUID
    var orgId: String
    var projectId: String
    var slug: String
    var name: String
    var systemPrompt: String
    var description: String?
    var tags: [String]?
    var createdBy: String?
    var createdAt: Date
    var updatedAt: Date?
    var archivedAt: Date?
}

struct AgentVersionSummaryDTO: Content, Sendable {
    var id: UUID
    var version: String
    var status: AgentVersionStatus
    var createdAt: Date
}

struct AgentVersionDTO: Content, Sendable {
    var id: UUID
    var agentId: UUID
    var version: String
    var schemaVersion: String
    var status: AgentVersionStatus
    var config: AgentConfig
    var tags: [String]?
    var createdBy: String?
    var createdAt: Date
}

struct DeploymentDTO: Content, Sendable {
    var id: UUID
    var orgId: String
    var projectId: String
    var agentId: UUID
    var environment: EnvironmentName
    var versions: [DeploymentVersionWeight]
    var createdBy: String?
    var createdAt: Date
    var updatedAt: Date?
}

struct AgentWithDeploymentsDTO: Content, Sendable {
    var agent: AgentDTO
    var latestVersions: [AgentVersionSummaryDTO]?
    var deployments: [DeploymentDTO]?
}

struct ToolCallSummaryDTO: Content, Sendable {
    var toolId: String
    var success: Bool
    var durationMs: Int?
    var error: String?
}

struct RetrievalSummaryDTO: Content, Sendable {
    var corpusIds: [String]?
    var topK: Int?
    var hitCount: Int?
}

struct ChatUsageDTO: Content, Sendable {
    var tokensInput: Int?
    var tokensOutput: Int?
    var cost: Double?
}

struct ChatTelemetryDTO: Content, Sendable {
    var latencyMs: Int?
    var toolCalls: [ToolCallSummaryDTO]?
    var retrieval: RetrievalSummaryDTO?
}

struct ChatMessageDTO: Content, Sendable {
    var id: UUID
    var role: ChatRole
    var content: String
    var createdAt: Date
    var toolCalls: [ToolCall]?
}

struct ChatResponseDTO: Content, Sendable {
    var requestId: UUID
    var agentId: UUID
    var agentVersionId: UUID
    var environment: EnvironmentName
    var conversationId: UUID
    var messages: [ChatMessageDTO]
    var usage: ChatUsageDTO?
    var telemetry: ChatTelemetryDTO?
}

struct AcceptedResponse: Content, Sendable {
    var status: String
}
