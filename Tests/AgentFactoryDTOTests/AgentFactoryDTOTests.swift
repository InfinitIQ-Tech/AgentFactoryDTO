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
}
