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

    public init(streaming: Bool, maxTurns: Int?, maxConcurrentTools: Int?) {
        self.streaming = streaming
        self.maxTurns = maxTurns
        self.maxConcurrentTools = maxConcurrentTools
    }
}

public struct AgentModelCandidate: Content, Sendable {
    public let name: String
    public let model: String

    public init(name: String, model: String) {
        self.name = name
        self.model = model
    }
}

public struct AgentModelConfig: Content, Sendable {
    public let strategy: String
    public let candidates: [AgentModelCandidate]
    public let routingPolicy: [String: JSONValue]?

    public init(strategy: String, candidates: [AgentModelCandidate], routingPolicy: [String : JSONValue]?) {
        self.strategy = strategy
        self.candidates = candidates
        self.routingPolicy = routingPolicy
    }
}

public struct AgentMemoryConfig: Content, Sendable {
    public let type: String?
    public let windowTurns: Int?

    public init(type: String?, windowTurns: Int?) {
        self.type = type
        self.windowTurns = windowTurns
    }
}

public struct AgentRetrievalConfig: Content, Sendable {
    public let enabled: Bool
    public let corpusIds: [String]?
    public let topK: Int?
    public let rerank: Bool?
    public let filters: [String: JSONValue]?

    public init(enabled: Bool, corpusIds: [String]?, topK: Int?, rerank: Bool?, filters: [String : JSONValue]?) {
        self.enabled = enabled
        self.corpusIds = corpusIds
        self.topK = topK
        self.rerank = rerank
        self.filters = filters
    }
}

public struct AgentGuardrailsConfig: Content, Sendable {
    public let piiRedaction: Bool?
    public let jailbreakDetection: Bool?
    public let blockedTopics: [String]?

    public init(piiRedaction: Bool?, jailbreakDetection: Bool?, blockedTopics: [String]?) {
        self.piiRedaction = piiRedaction
        self.jailbreakDetection = jailbreakDetection
        self.blockedTopics = blockedTopics
    }
}

public struct AgentConfig: Content, Sendable {
    public let id: String
    public let name: String
    public let version: String
    public let schemaVersion: String
    public let systemPrompt: String
    public let description: String?
    public let tags: [String]?

    public let runtime: AgentRuntimeConfig
    public let model: AgentModelConfig
    public let memory: AgentMemoryConfig?
    public let retrieval: AgentRetrievalConfig?
    public let tools: AgentToolsConfig?
    public let guardrails: AgentGuardrailsConfig?

    public init(id: String, name: String, version: String, schemaVersion: String, systemPrompt: String, description: String?, tags: [String]?, runtime: AgentRuntimeConfig, model: AgentModelConfig, memory: AgentMemoryConfig?, retrieval: AgentRetrievalConfig?, tools: AgentToolsConfig?, guardrails: AgentGuardrailsConfig?) {
        self.id = id
        self.name = name
        self.version = version
        self.schemaVersion = schemaVersion
        self.systemPrompt = systemPrompt
        self.description = description
        self.tags = tags
        self.runtime = runtime
        self.model = model
        self.memory = memory
        self.retrieval = retrieval
        self.tools = tools
        self.guardrails = guardrails
    }
}

// MARK: - Control plane: Requests

public struct CreateAgentRequest: Content, Sendable {
    public let slug: String
    public let name: String
    public let systemPrompt: String
    public let description: String?
    public let templateId: String?
    public let tags: [String]?

    public init(slug: String, name: String, systemPrompt: String, description: String?, templateId: String?, tags: [String]?) {
        self.slug = slug
        self.name = name
        self.systemPrompt = systemPrompt
        self.description = description
        self.templateId = templateId
        self.tags = tags
    }
}

public struct UpdateAgentRequest: Content, Sendable {
    public let name: String?
    public let systemPrompt: String?
    public let description: String?
    public let tags: [String]?

    public init(name: String?, systemPrompt: String?, description: String?, tags: [String]?) {
        self.name = name
        self.systemPrompt = systemPrompt
        self.description = description
        self.tags = tags
    }
}

public struct PublishAgentVersionRequest: Content, Sendable {
    public let config: AgentConfig
    public let tags: [String]?

    public init(config: AgentConfig, tags: [String]?) {
        self.config = config
        self.tags = tags
    }
}

public struct DeploymentVersionWeight: Content, Sendable {
    public let agentVersionId: UUID
    public let rolloutWeight: Int

    public init(agentVersionId: UUID, rolloutWeight: Int) {
        self.agentVersionId = agentVersionId
        self.rolloutWeight = rolloutWeight
    }
}

public struct UpsertDeploymentRequest: Content, Sendable {
    public let agentRef: String
    public let environment: EnvironmentName
    public let versions: [DeploymentVersionWeight]

    public init(agentRef: String, environment: EnvironmentName, versions: [DeploymentVersionWeight]) {
        self.agentRef = agentRef
        self.environment = environment
        self.versions = versions
    }
}

// MARK: - Runtime: Requests

public struct ToolCall: Content, Sendable {
    public let callId: String?
    public let toolId: String
    public let args: [String: JSONValue]

    public init(callId: String? = nil, toolId: String, args: [String : JSONValue]) {
        self.callId = callId
        self.toolId = toolId
        self.args = args
    }
}

public struct ChatMessageIn: Content, Sendable {
    public let role: ClientChatRole
    public let content: String

    public init(role: ClientChatRole, content: String) {
        self.role = role
        self.content = content
    }
}

/// Request payload for the chat endpoint.
public struct ChatRequest: Content, Sendable {
    /// Agent identifier - can be either a slug (string) or UUID
    public let agentRef: String
    /// Target environment for deployment routing (dev, staging, prod)
    public let environment: EnvironmentName
    /// Optional conversation ID for maintaining chat history
    public let conversationId: UUID?
    /// Optional user identifier for consistent weighted routing
    public let userId: String?
    /// Chat messages to send (last message must be from user)
    public let messages: [ChatMessageIn]
    /// Optional metadata to pass through to the runtime
    public let metadata: [String: JSONValue]?
    /// Optional provider API keys (e.g., OpenAI). Not persisted.
    public let providerKeys: [String: String]?
    /// Optional version ID to bypass deployment routing and target a specific version directly.
    /// When nil, normal deployment routing is used (environment + rollout weights).
    /// When set, the specified version is used regardless of deployment configuration.
    public let agentVersionId: UUID?

    /// Creates a new chat request.
    /// - Parameters:
    ///   - agentRef: Agent slug or UUID
    ///   - environment: Target environment (used for deployment routing when agentVersionId is nil)
    ///   - conversationId: Optional conversation ID for chat continuity
    ///   - userId: Optional user ID for consistent weighted version selection
    ///   - messages: Array of chat messages (last must be user role)
    ///   - metadata: Optional metadata dictionary
    ///   - providerKeys: Optional provider API keys (not persisted)
    ///   - agentVersionId: Optional version ID to bypass deployment routing. Defaults to nil.
    public init(
        agentRef: String,
        environment: EnvironmentName,
        conversationId: UUID?,
        userId: String?,
        messages: [ChatMessageIn],
        metadata: [String: JSONValue]?,
        providerKeys: [String: String]?,
        agentVersionId: UUID? = nil
    ) {
        self.agentRef = agentRef
        self.environment = environment
        self.conversationId = conversationId
        self.userId = userId
        self.messages = messages
        self.metadata = metadata
        self.providerKeys = providerKeys
        self.agentVersionId = agentVersionId
    }
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

    public init(agentRef: String, agentVersionId: UUID, environment: EnvironmentName, conversationId: UUID?, messageId: UUID?, userId: String?, rating: FeedbackRating, reason: String?, metadata: [String : JSONValue]?) {
        self.agentRef = agentRef
        self.agentVersionId = agentVersionId
        self.environment = environment
        self.conversationId = conversationId
        self.messageId = messageId
        self.userId = userId
        self.rating = rating
        self.reason = reason
        self.metadata = metadata
    }
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

    public init(id: UUID, orgId: String, projectId: String, slug: String, name: String, systemPrompt: String, description: String?, tags: [String]?, createdBy: String?, createdAt: Date, updatedAt: Date?, archivedAt: Date?) {
        self.id = id
        self.orgId = orgId
        self.projectId = projectId
        self.slug = slug
        self.name = name
        self.systemPrompt = systemPrompt
        self.description = description
        self.tags = tags
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.archivedAt = archivedAt
    }
}

public struct AgentVersionSummaryDTO: Content, Sendable {
    public let id: UUID
    public let version: String
    public let status: AgentVersionStatus
    public let createdAt: Date

    public init(id: UUID, version: String, status: AgentVersionStatus, createdAt: Date) {
        self.id = id
        self.version = version
        self.status = status
        self.createdAt = createdAt
    }
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

    public init(id: UUID, agentId: UUID, version: String, schemaVersion: String, status: AgentVersionStatus, config: AgentConfig, tags: [String]?, createdBy: String?, createdAt: Date) {
        self.id = id
        self.agentId = agentId
        self.version = version
        self.schemaVersion = schemaVersion
        self.status = status
        self.config = config
        self.tags = tags
        self.createdBy = createdBy
        self.createdAt = createdAt
    }
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

    public init(id: UUID, orgId: String, projectId: String, agentId: UUID, environment: EnvironmentName, versions: [DeploymentVersionWeight], createdBy: String?, createdAt: Date, updatedAt: Date?) {
        self.id = id
        self.orgId = orgId
        self.projectId = projectId
        self.agentId = agentId
        self.environment = environment
        self.versions = versions
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct AgentWithDeploymentsDTO: Content, Sendable {
    public let agent: AgentDTO
    public let latestVersions: [AgentVersionSummaryDTO]?
    public let deployments: [DeploymentDTO]?

    public init(agent: AgentDTO, latestVersions: [AgentVersionSummaryDTO]?, deployments: [DeploymentDTO]?) {
        self.agent = agent
        self.latestVersions = latestVersions
        self.deployments = deployments
    }
}

public struct ToolCallSummaryDTO: Content, Sendable {
    public let toolId: String
    public let success: Bool
    public let durationMs: Int?
    public let error: String?

    public init(toolId: String, success: Bool, durationMs: Int?, error: String?) {
        self.toolId = toolId
        self.success = success
        self.durationMs = durationMs
        self.error = error
    }
}

public struct RetrievalSummaryDTO: Content, Sendable {
    public let corpusIds: [String]?
    public let topK: Int?
    public let hitCount: Int?

    public init(corpusIds: [String]?, topK: Int?, hitCount: Int?) {
        self.corpusIds = corpusIds
        self.topK = topK
        self.hitCount = hitCount
    }
}

public struct ChatUsageDTO: Content, Sendable {
    public let tokensInput: Int?
    public let tokensOutput: Int?
    public let cost: Double?

    public init(tokensInput: Int?, tokensOutput: Int?, cost: Double?) {
        self.tokensInput = tokensInput
        self.tokensOutput = tokensOutput
        self.cost = cost
    }
}

public struct ChatTelemetryDTO: Content, Sendable {
    public let latencyMs: Int?
    public let toolCalls: [ToolCallSummaryDTO]?
    public let retrieval: RetrievalSummaryDTO?
    public let ttftMs: Int?

    public init(latencyMs: Int?, toolCalls: [ToolCallSummaryDTO]?, retrieval: RetrievalSummaryDTO?, ttftMs: Int? = nil) {
        self.latencyMs = latencyMs
        self.toolCalls = toolCalls
        self.retrieval = retrieval
        self.ttftMs = ttftMs
    }
}

public struct ChatMessageDTO: Content, Sendable {
    public let id: UUID
    public let role: ChatRole
    public let content: String
    public let createdAt: Date
    public let toolCalls: [ToolCall]?

    public init(id: UUID, role: ChatRole, content: String, createdAt: Date, toolCalls: [ToolCall]?) {
        self.id = id
        self.role = role
        self.content = content
        self.createdAt = createdAt
        self.toolCalls = toolCalls
    }
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
    public let error: [String: String]?

    public init(requestId: UUID, agentId: UUID, agentVersionId: UUID, environment: EnvironmentName, conversationId: UUID, messages: [ChatMessageDTO], usage: ChatUsageDTO?, telemetry: ChatTelemetryDTO?, error: [String: String]? = nil) {
        self.requestId = requestId
        self.agentId = agentId
        self.agentVersionId = agentVersionId
        self.environment = environment
        self.conversationId = conversationId
        self.messages = messages
        self.usage = usage
        self.telemetry = telemetry
        self.error = error
    }
}

public struct AcceptedResponse: Content, Sendable {
    public let status: String

    public init(status: String) {
        self.status = status
    }
}
