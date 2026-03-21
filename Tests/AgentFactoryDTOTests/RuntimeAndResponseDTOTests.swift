import XCTest
@testable import AgentFactoryDTO

final class RuntimeAndResponseDTOTests: XCTestCase {
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

    func testStreamStartEventDecodes() throws {
        let json = #"""
        {
          "request_id": "req_123",
          "agent_id": "agent_456",
          "agent_version_id": "ver_789",
          "environment": "staging",
          "conversation_id": "conv_321"
        }
        """#

        let event = try decoder.decode(StreamStartEventDTO.self, from: Data(json.utf8))

        XCTAssertEqual(event.requestId, "req_123")
        XCTAssertEqual(event.agentId, "agent_456")
        XCTAssertEqual(event.agentVersionId, "ver_789")
        XCTAssertEqual(event.environment, "staging")
        XCTAssertEqual(event.conversationId, "conv_321")
    }

    func testStreamChunkEventDecodes() throws {
        let json = #"{"delta":"partial response"}"#

        let event = try decoder.decode(StreamChunkEventDTO.self, from: Data(json.utf8))

        XCTAssertEqual(event.delta, "partial response")
    }

    func testStreamEndEventDecodesNestedChatResponse() throws {
        let json = #"""
        {
          "response": {
            "request_id": "11111111-1111-1111-1111-111111111111",
            "agent_id": "22222222-2222-2222-2222-222222222222",
            "agent_version_id": "33333333-3333-3333-3333-333333333333",
            "environment": "prod",
            "conversation_id": "44444444-4444-4444-4444-444444444444",
            "messages": [
              {
                "id": "55555555-5555-5555-5555-555555555555",
                "role": "assistant",
                "content": "Completed",
                "created_at": "2026-03-14T12:00:00Z",
                "tool_calls": [
                  {
                    "call_id": "call_123",
                    "tool_id": "search",
                    "args": {
                      "query": "status"
                    }
                  }
                ]
              }
            ],
            "usage": {
              "tokens_input": 10,
              "tokens_output": 20,
              "cost": 0.25
            },
            "telemetry": {
              "latency_ms": 350,
              "ttft_ms": 120,
              "tool_calls": [
                {
                  "tool_id": "search",
                  "success": true,
                  "duration_ms": 25,
                  "error": null
                }
              ],
              "retrieval": {
                "corpus_ids": ["docs"],
                "top_k": 4,
                "hit_count": 2
              }
            },
            "error": {
              "code": "none"
            }
          }
        }
        """#

        let event = try decoder.decode(StreamEndEventDTO.self, from: Data(json.utf8))

        XCTAssertEqual(event.response?.environment, .prod)
        XCTAssertEqual(event.response?.messages.count, 1)
        XCTAssertEqual(event.response?.messages.first?.toolCalls?.first?.callId, "call_123")
        XCTAssertEqual(event.response?.usage?.tokensInput, 10)
        XCTAssertEqual(event.response?.telemetry?.ttftMs, 120)
        XCTAssertEqual(event.response?.telemetry?.retrieval?.corpusIds ?? [], ["docs"])
        XCTAssertEqual(event.response?.error?["code"], "none")
    }

    func testChatRequestDecodesDirectVersionRoutingFields() throws {
        let json = #"""
        {
          "agent_ref": "support-agent",
          "environment": "dev",
          "conversation_id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
          "user_id": "user-123",
          "messages": [
            {
              "role": "assistant",
              "content": "How can I help?"
            },
            {
              "role": "user",
              "content": "Check order status"
            }
          ],
          "metadata": {
            "attempt": 1,
            "priority": true,
            "context": {
              "channel": "chat"
            }
          },
          "provider_keys": {
            "openai": "sk-test"
          },
          "agent_version_id": "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
        }
        """#

        let request = try decoder.decode(ChatRequest.self, from: Data(json.utf8))

        XCTAssertEqual(request.agentRef, "support-agent")
        XCTAssertEqual(request.environment, .dev)
        XCTAssertEqual(request.conversationId, UUID(uuidString: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"))
        XCTAssertEqual(request.userId, "user-123")
        XCTAssertEqual(request.messages.map(\.role), [.assistant, .user])
        XCTAssertEqual(request.messages.last?.content, "Check order status")
        XCTAssertEqual(request.metadata?["attempt"], .number(1))
        XCTAssertEqual(request.metadata?["priority"], .bool(true))
        XCTAssertEqual(request.metadata?["context"], .object(["channel": .string("chat")]))
        XCTAssertEqual(request.providerKeys?["openai"], "sk-test")
        XCTAssertEqual(request.agentVersionId, UUID(uuidString: "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"))
    }

    func testChatRequestEncodesSnakeCaseKeys() throws {
        let request = ChatRequest(
            agentRef: "cccccccc-cccc-cccc-cccc-cccccccccccc",
            environment: .staging,
            conversationId: UUID(uuidString: "dddddddd-dddd-dddd-dddd-dddddddddddd"),
            userId: "user-456",
            messages: [
                ChatMessageIn(role: .assistant, content: "Ready"),
                ChatMessageIn(role: .user, content: "Run lookup")
            ],
            metadata: [
                "count": .number(2),
                "tags": .array([.string("urgent"), .string("vip")])
            ],
            providerKeys: [
                "anthropic": "key-value"
            ],
            agentVersionId: UUID(uuidString: "eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee")
        )

        let data = try encoder.encode(request)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(json["agent_ref"] as? String, "cccccccc-cccc-cccc-cccc-cccccccccccc")
        XCTAssertEqual(json["environment"] as? String, "staging")
        XCTAssertEqual(json["user_id"] as? String, "user-456")
        XCTAssertNotNil(json["conversation_id"])
        XCTAssertNotNil(json["agent_version_id"])
        XCTAssertNotNil(json["provider_keys"])
        XCTAssertNil(json["agentRef"])
        XCTAssertNil(json["agentVersionId"])
    }

    func testChatRequestDecodesToolContinuationHistory() throws {
        let json = #"""
        {
          "agent_ref": "support-agent",
          "environment": "dev",
          "messages": [
            {
              "role": "assistant",
              "content": "",
              "tool_calls": [
                {
                  "call_id": "call-weather",
                  "tool_id": "weather",
                  "args": {
                    "zip_code": 94518
                  }
                }
              ]
            },
            {
              "role": "tool",
              "content": "{\"temp\":82}",
              "tool_call_id": "call-weather"
            }
          ]
        }
        """#

        let request = try decoder.decode(ChatRequest.self, from: Data(json.utf8))

        XCTAssertEqual(request.messages.map(\.role), [.assistant, .tool])
        XCTAssertEqual(request.messages[0].toolCalls?.first?.toolId, "weather")
        XCTAssertEqual(request.messages[0].toolCalls?.first?.callId, "call-weather")
        XCTAssertEqual(request.messages[1].toolCallId, "call-weather")
        XCTAssertEqual(request.messages[1].content, #"{"temp":82}"#)
    }

    func testChatRequestEncodesToolContinuationFields() throws {
        let request = ChatRequest(
            agentRef: "support-agent",
            environment: .dev,
            conversationId: nil,
            userId: nil,
            messages: [
                ChatMessageIn(
                    role: .assistant,
                    content: "",
                    toolCalls: [
                        ToolCall(
                            callId: "call-weather",
                            toolId: "weather",
                            args: ["zip_code": .number(94518)]
                        )
                    ]
                ),
                ChatMessageIn(
                    role: .tool,
                    content: #"{"temp":82}"#,
                    toolCallId: "call-weather"
                )
            ],
            metadata: nil,
            providerKeys: nil,
            agentVersionId: nil
        )

        let data = try encoder.encode(request)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let messages = try XCTUnwrap(json["messages"] as? [[String: Any]])

        XCTAssertEqual(messages[0]["role"] as? String, "assistant")
        let toolCalls = try XCTUnwrap(messages[0]["tool_calls"] as? [[String: Any]])
        XCTAssertEqual(toolCalls[0]["call_id"] as? String, "call-weather")
        XCTAssertEqual(toolCalls[0]["tool_id"] as? String, "weather")
        XCTAssertEqual(messages[1]["role"] as? String, "tool")
        XCTAssertEqual(messages[1]["tool_call_id"] as? String, "call-weather")
        XCTAssertEqual(messages[1]["content"] as? String, #"{"temp":82}"#)
    }

    func testResponseDTOsDecode() throws {
        let json = #"""
        {
          "agent": {
            "id": "10000000-0000-0000-0000-000000000001",
            "org_id": "org-1",
            "project_id": "proj-1",
            "slug": "support-agent",
            "name": "Support Agent",
            "system_prompt": "Help users",
            "description": "Customer support agent",
            "tags": ["support", "customer"],
            "created_by": "user-1",
            "created_at": "2026-03-14T12:00:00Z",
            "updated_at": "2026-03-14T12:30:00Z",
            "archived_at": null
          },
          "latest_versions": [
            {
              "id": "10000000-0000-0000-0000-000000000002",
              "version": "1.0.0",
              "status": "published",
              "created_at": "2026-03-14T12:15:00Z"
            }
          ],
          "deployments": [
            {
              "id": "10000000-0000-0000-0000-000000000003",
              "org_id": "org-1",
              "project_id": "proj-1",
              "agent_id": "10000000-0000-0000-0000-000000000001",
              "environment": "prod",
              "versions": [
                {
                  "agent_version_id": "10000000-0000-0000-0000-000000000002",
                  "rollout_weight": 100
                }
              ],
              "created_by": "user-2",
              "created_at": "2026-03-14T12:20:00Z",
              "updated_at": "2026-03-14T12:25:00Z"
            }
          ]
        }
        """#

        let dto = try decoder.decode(AgentWithDeploymentsDTO.self, from: Data(json.utf8))

        XCTAssertEqual(dto.agent.orgId, "org-1")
        XCTAssertEqual(dto.agent.tags ?? [], ["support", "customer"])
        XCTAssertEqual(dto.latestVersions?.first?.status, .published)
        XCTAssertEqual(dto.deployments?.first?.environment, .prod)
        XCTAssertEqual(dto.deployments?.first?.versions.first?.rolloutWeight, 100)
    }

    func testAgentVersionDTODecodesNestedConfig() throws {
        let json = #"""
        {
          "id": "20000000-0000-0000-0000-000000000001",
          "agent_id": "20000000-0000-0000-0000-000000000002",
          "version": "2.1.0",
          "schema_version": "2026-01",
          "status": "draft",
          "config": {
            "id": "cfg-1",
            "name": "Support",
            "version": "2.1.0",
            "schema_version": "2026-01",
            "system_prompt": "Use the published version instructions.",
            "description": "Draft config",
            "tags": ["alpha"],
            "runtime": {
              "streaming": true,
              "max_turns": 8,
              "max_concurrent_tools": 2
            },
            "model": {
              "strategy": "fallback",
              "candidates": [
                {
                  "name": "primary",
                  "model": "gpt-test"
                }
              ],
              "routing_policy": {
                "tier": "gold"
              }
            },
            "memory": {
              "type": "window",
              "window_turns": 6
            },
            "retrieval": {
              "enabled": true,
              "corpus_ids": ["kb"],
              "top_k": 3,
              "rerank": false,
              "filters": {
                "region": "us"
              }
            },
            "tools": {
              "allowed": ["search"],
              "definitions": [
                {
                  "name": "search",
                  "description": "Search docs",
                  "parameters": {
                    "type": "object"
                  }
                }
              ],
              "tool_policy": {
                "require_user_confirmation": ["search"],
                "max_total_runtime_ms": 2000,
                "max_tools_per_turn": 2
              }
            },
            "guardrails": {
              "pii_redaction": true,
              "jailbreak_detection": true,
              "blocked_topics": ["secrets"]
            }
          },
          "tags": ["draft"],
          "created_by": "author-1",
          "created_at": "2026-03-14T13:00:00Z"
        }
        """#

        let dto = try decoder.decode(AgentVersionDTO.self, from: Data(json.utf8))

        XCTAssertEqual(dto.status, .draft)
        XCTAssertEqual(dto.config.systemPrompt, "Use the published version instructions.")
        XCTAssertEqual(dto.config.runtime.maxTurns, 8)
        XCTAssertEqual(dto.config.model.candidates.first?.model, "gpt-test")
        XCTAssertEqual(dto.config.model.routingPolicy?["tier"], .string("gold"))
        XCTAssertEqual(dto.config.retrieval?.filters?["region"], .string("us"))
        XCTAssertEqual(dto.config.tools?.definitions?.first?.name, "search")
        XCTAssertEqual(dto.config.tools?.toolPolicy?.maxTotalRuntimeMs, 2000)
        XCTAssertEqual(dto.config.guardrails?.blockedTopics ?? [], ["secrets"])
    }

    func testPublishAgentVersionRequestEncodesVersionScopedSystemPrompt() throws {
        let request = PublishAgentVersionRequest(
            config: AgentConfig(
                id: "support-agent",
                name: "Support Agent",
                version: "v2",
                schemaVersion: "2026-03",
                systemPrompt: "Follow the rollout instructions for v2.",
                description: "Published contract",
                tags: ["ga"],
                runtime: AgentRuntimeConfig(streaming: true, maxTurns: 12, maxConcurrentTools: 2),
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
            tags: ["rollout"]
        )

        let data = try encoder.encode(request)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let config = try XCTUnwrap(json["config"] as? [String: Any])

        XCTAssertEqual(config["system_prompt"] as? String, "Follow the rollout instructions for v2.")
        XCTAssertNil(config["systemPrompt"])
    }

    func testChatResponseDTOEncodesNestedUsageTelemetryAndErrors() throws {
        let response = ChatResponseDTO(
            requestId: UUID(uuidString: "30000000-0000-0000-0000-000000000001")!,
            agentId: UUID(uuidString: "30000000-0000-0000-0000-000000000002")!,
            agentVersionId: UUID(uuidString: "30000000-0000-0000-0000-000000000003")!,
            environment: .staging,
            conversationId: UUID(uuidString: "30000000-0000-0000-0000-000000000004")!,
            messages: [
                ChatMessageDTO(
                    id: UUID(uuidString: "30000000-0000-0000-0000-000000000005")!,
                    role: .tool,
                    content: "Search complete",
                    createdAt: ISO8601DateFormatter().date(from: "2026-03-14T13:30:00Z")!,
                    toolCalls: [
                        ToolCall(
                            callId: "call_789",
                            toolId: "search",
                            args: ["query": .string("delivery ETA")]
                        )
                    ]
                )
            ],
            usage: ChatUsageDTO(tokensInput: 21, tokensOutput: 34, cost: 0.61),
            telemetry: ChatTelemetryDTO(
                latencyMs: 410,
                toolCalls: [
                    ToolCallSummaryDTO(toolId: "search", success: true, durationMs: 90, error: nil)
                ],
                retrieval: RetrievalSummaryDTO(corpusIds: ["orders"], topK: 5, hitCount: 3),
                ttftMs: 140
            ),
            error: ["code": "timeout"]
        )

        let data = try encoder.encode(response)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let messages = try XCTUnwrap(json["messages"] as? [[String: Any]])
        let message = try XCTUnwrap(messages.first)
        let toolCalls = try XCTUnwrap(message["tool_calls"] as? [[String: Any]])
        let usage = try XCTUnwrap(json["usage"] as? [String: Any])
        let telemetry = try XCTUnwrap(json["telemetry"] as? [String: Any])
        let retrieval = try XCTUnwrap(telemetry["retrieval"] as? [String: Any])
        let error = try XCTUnwrap(json["error"] as? [String: String])

        XCTAssertEqual(json["environment"] as? String, "staging")
        XCTAssertNotNil(json["request_id"])
        XCTAssertEqual(message["role"] as? String, "tool")
        XCTAssertEqual(toolCalls.first?["call_id"] as? String, "call_789")
        XCTAssertEqual(usage["tokens_input"] as? Int, 21)
        XCTAssertEqual(telemetry["ttft_ms"] as? Int, 140)
        XCTAssertEqual(retrieval["hit_count"] as? Int, 3)
        XCTAssertEqual(error["code"], "timeout")
    }

    func testAcceptedResponseDecodes() throws {
        let json = #"{"status":"accepted"}"#

        let response = try decoder.decode(AcceptedResponse.self, from: Data(json.utf8))

        XCTAssertEqual(response.status, "accepted")
    }
}
