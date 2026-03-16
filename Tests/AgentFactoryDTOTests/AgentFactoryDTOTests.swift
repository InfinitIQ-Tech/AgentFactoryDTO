import XCTest
@testable import AgentFactoryDTO

final class AgentFactoryDTOTests: XCTestCase {
    private var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        return d
    }

    private var encoder: JSONEncoder {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        e.dateEncodingStrategy = .iso8601
        return e
    }

    func testAgentToolsConfigDecodesDefinitions() throws {
        let json = #"""
        {
          "allowed": ["search"],
          "definitions": [
            {
              "name": "search",
              "description": "Search the web",
              "parameters": { "type": "object" }
            }
          ],
          "tool_policy": { "max_tools_per_turn": 2 }
        }
        """#
        let cfg = try decoder.decode(AgentToolsConfig.self, from: Data(json.utf8))
        XCTAssertEqual(cfg.allowed ?? [], ["search"])
        XCTAssertEqual(cfg.definitions?.count, 1)
        XCTAssertEqual(cfg.definitions?.first?.name, "search")
        XCTAssertEqual(cfg.toolPolicy?.maxToolsPerTurn, 2)
    }

    func testAgentToolsConfigDecodesLegacyFunctions() throws {
        let json = #"""
        {
          "allowed": ["search"],
          "functions": [
            {
              "name": "search",
              "description": "Search the web",
              "parameters": { "type": "object" }
            }
          ]
        }
        """#
        let cfg = try decoder.decode(AgentToolsConfig.self, from: Data(json.utf8))
        XCTAssertEqual(cfg.allowed ?? [], ["search"])
        XCTAssertEqual(cfg.definitions?.count, 1)
        XCTAssertEqual(cfg.definitions?.first?.name, "search")
    }

    func testAgentToolsConfigEncodesDefinitions() throws {
        let cfg = AgentToolsConfig(
            allowed: ["search"],
            definitions: [
                ToolDefinition(
                    name: "search",
                    description: "Search the web",
                    parameters: ["type": .string("object")]
                )
            ],
            toolPolicy: nil
        )
        let data = try encoder.encode(cfg)
        let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertNotNil(obj?["definitions"])
        XCTAssertNil(obj?["functions"])
    }

    func testToolCallDecodesCallId() throws {
        let json = #"""
        { "tool_id": "search", "call_id": "call_123", "args": { "query": "hi" } }
        """#
        let tc = try decoder.decode(ToolCall.self, from: Data(json.utf8))
        XCTAssertEqual(tc.toolId, "search")
        XCTAssertEqual(tc.callId, "call_123")
        XCTAssertEqual(tc.args["query"], .string("hi"))
    }

    func testSseToolCallEventDecodes() throws {
        let json = #"""
        { "tool_id": "search", "call_id": "call_123", "args": { "query": "hi" } }
        """#
        let evt = try decoder.decode(ToolCallEventDTO.self, from: Data(json.utf8))
        XCTAssertEqual(evt.toolId, "search")
        XCTAssertEqual(evt.callId, "call_123")
        XCTAssertEqual(evt.args["query"], .string("hi"))
    }

    func testSseToolResultEventDecodes() throws {
        let json = #"""
        { "tool_id": "search", "call_id": "call_123", "output": "ok", "success": true }
        """#
        let evt = try decoder.decode(ToolResultEventDTO.self, from: Data(json.utf8))
        XCTAssertEqual(evt.toolId, "search")
        XCTAssertEqual(evt.callId, "call_123")
        XCTAssertEqual(evt.output, "ok")
        XCTAssertEqual(evt.success, true)
    }

    func testAgentConfigEncodesVersionScopedSystemPrompt() throws {
        let config = AgentConfig(
            id: "support-agent",
            name: "Support Agent",
            version: "v1",
            schemaVersion: "2026-03",
            systemPrompt: "Use the published support instructions.",
            description: "Published config",
            tags: ["ga"],
            runtime: AgentRuntimeConfig(streaming: true, maxTurns: 8, maxConcurrentTools: 1),
            model: AgentModelConfig(
                strategy: "single",
                candidates: [AgentModelCandidate(name: "primary", model: "openai:gpt-4o")],
                routingPolicy: nil
            ),
            memory: nil,
            retrieval: nil,
            tools: nil,
            guardrails: nil
        )

        let data = try encoder.encode(config)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(json["system_prompt"] as? String, "Use the published support instructions.")
        XCTAssertNil(json["systemPrompt"])
    }

    func testPublishAgentVersionRequestEncodesNestedSystemPrompt() throws {
        let request = PublishAgentVersionRequest(
            config: AgentConfig(
                id: "support-agent",
                name: "Support Agent",
                version: "v2",
                schemaVersion: "2026-03",
                systemPrompt: "Use the published v2 instructions.",
                description: nil,
                tags: nil,
                runtime: AgentRuntimeConfig(streaming: true, maxTurns: nil, maxConcurrentTools: nil),
                model: AgentModelConfig(
                    strategy: "single",
                    candidates: [AgentModelCandidate(name: "primary", model: "openai:gpt-4o")],
                    routingPolicy: nil
                ),
                memory: nil,
                retrieval: nil,
                tools: nil,
                guardrails: nil
            ),
            tags: ["ga"]
        )

        let data = try encoder.encode(request)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let config = try XCTUnwrap(json["config"] as? [String: Any])

        XCTAssertEqual(config["system_prompt"] as? String, "Use the published v2 instructions.")
    }

    func testAgentConfigDecodeFailsWhenSystemPromptIsMissing() throws {
        let json = #"""
        {
          "id": "support-agent",
          "name": "Support Agent",
          "version": "v1",
          "schema_version": "2026-03",
          "runtime": {
            "streaming": true
          },
          "model": {
            "strategy": "single",
            "candidates": [
              {
                "name": "primary",
                "model": "openai:gpt-4o"
              }
            ]
          }
        }
        """#

        XCTAssertThrowsError(try decoder.decode(AgentConfig.self, from: Data(json.utf8)))
    }
}
