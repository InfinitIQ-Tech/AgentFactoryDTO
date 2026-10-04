import XCTest
@testable import AgentFactoryDTO

final class StructuredOutputDTOTests: XCTestCase {
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    func testManifestWithoutOutputRoundTripsWithoutAddingOutput() throws {
        let data = Data(#"""
        {
          "id": "story-companion",
          "name": "Story Companion",
          "version": "v1",
          "schema_version": "2",
          "system_prompt": "Continue the story.",
          "runtime": { "streaming": true },
          "model": {
            "strategy": "single",
            "candidates": [{ "name": "primary", "model": "anthropic:claude-sonnet-4-6" }]
          }
        }
        """#.utf8)

        let config = try decoder.decode(AgentConfig.self, from: data)
        XCTAssertNil(config.output)

        let encoded = try encoder.encode(config)
        let actual = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? NSDictionary)
        let expected = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? NSDictionary)
        XCTAssertEqual(actual, expected)
    }

    func testExistingInitializerDefaultsOutputToNil() throws {
        let config = AgentConfig(
            id: "story-companion", name: "Story Companion", version: "v1",
            schemaVersion: "2", systemPrompt: "Continue the story.",
            description: nil, tags: nil,
            runtime: AgentRuntimeConfig(streaming: true, maxTurns: nil, maxConcurrentTools: nil),
            model: AgentModelConfig(strategy: "single", candidates: [], routingPolicy: nil),
            memory: nil, retrieval: nil, tools: nil, guardrails: nil
        )

        XCTAssertNil(config.output)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoder.encode(config)) as? [String: Any])
        XCTAssertNil(object["output"])
    }

    func testSchemaPreservesExactKeysAndAllJSONValueShapes() throws {
        let data = Data(#"""
        {
          "format": {
            "type": "json_schema",
            "schema": {
              "$schema": "https://json-schema.org/draft/2020-12/schema",
              "type": "object",
              "properties": {
                "story_text": { "type": "string", "minLength": 1 },
                "storyText": { "type": "string" },
                "selected_choice": { "$ref": "#/$defs/choice_option" }
              },
              "required": ["story_text", "selected_choice"],
              "additionalProperties": false,
              "$defs": {
                "choice_option": { "enum": ["keep_going", "stop_here"] }
              },
              "x_future_extension": {
                "null_value": null,
                "bool_value": true,
                "integer_value": 3,
                "number_value": 2.5,
                "array_value": [null, false, 7, { "nested_key": "雪" }]
              }
            }
          }
        }
        """#.utf8)

        let output = try decoder.decode(AgentOutputConfig.self, from: data)
        XCTAssertEqual(output.format.type, "json_schema")
        XCTAssertEqual(output.format.schema["additionalProperties"], .bool(false))
        guard case .object(let properties) = output.format.schema["properties"],
              case .object(let extensions) = output.format.schema["x_future_extension"] else {
            return XCTFail("Expected schema property and extension objects")
        }
        XCTAssertNotNil(properties["story_text"])
        XCTAssertNotNil(properties["storyText"])
        XCTAssertEqual(extensions["null_value"], .null)
        XCTAssertEqual(extensions["integer_value"], .number(3))
        XCTAssertEqual(extensions["number_value"], .number(2.5))

        let encoded = try encoder.encode(output)
        let actual = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? NSDictionary)
        let expected = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? NSDictionary)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(try decoder.decode(AgentOutputConfig.self, from: encoded).format.schema, output.format.schema)
    }

    func testPublishRequestPreservesOutputEnvelope() throws {
        let schema: [String: JSONValue] = [
            "type": .string("object"),
            "properties": .object(["story_text": .object(["type": .string("string")])]),
            "required": .array([.string("story_text")]),
            "additionalProperties": .bool(false)
        ]
        let config = AgentConfig(
            id: "story-companion", name: "Story Companion", version: "v1",
            schemaVersion: "2", systemPrompt: "Return the story as JSON.",
            description: nil, tags: nil,
            runtime: AgentRuntimeConfig(streaming: true, maxTurns: nil, maxConcurrentTools: nil),
            model: AgentModelConfig(strategy: "single", candidates: [], routingPolicy: nil),
            memory: nil, retrieval: nil, tools: nil, guardrails: nil,
            output: AgentOutputConfig(format: AgentOutputFormat(type: "json_schema", schema: schema))
        )
        let request = PublishAgentVersionRequest(config: config, tags: nil)
        let data = try encoder.encode(request)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let encodedConfig = try XCTUnwrap(object["config"] as? [String: Any])
        let output = try XCTUnwrap(encodedConfig["output"] as? [String: Any])
        let format = try XCTUnwrap(output["format"] as? [String: Any])
        XCTAssertEqual(Set(output.keys), ["format"])
        XCTAssertEqual(Set(format.keys), ["type", "schema"])
        XCTAssertEqual(format["type"] as? String, "json_schema")
        XCTAssertEqual(try decoder.decode(PublishAgentVersionRequest.self, from: data).config.output?.format.schema, schema)
    }

    func testOutputRequiresFormatTypeAndObjectSchema() {
        let invalidPayloads = [
            #"{}"#,
            #"{"format":null}"#,
            #"{"format":{}}"#,
            #"{"format":{"type":"json_schema"}}"#,
            #"{"format":{"schema":{}}}"#,
            #"{"format":{"type":12,"schema":{}}}"#,
            #"{"format":{"type":"json_schema","schema":null}}"#,
            #"{"format":{"type":"json_schema","schema":[]}}"#,
            #"{"format":{"type":"json_schema","schema":true}}"#,
            #"{"format":{"type":"json_schema","schema":"object"}}"#
        ]
        for payload in invalidPayloads {
            XCTAssertThrowsError(try decoder.decode(AgentOutputConfig.self, from: Data(payload.utf8)), payload)
        }
    }

    func testDTOTransportsFormatDiscriminatorWithoutProviderValidation() throws {
        let data = Data(#"{"format":{"type":"future_format","schema":{}}}"#.utf8)
        let output = try decoder.decode(AgentOutputConfig.self, from: data)
        XCTAssertEqual(output.format.type, "future_format")
        XCTAssertEqual(output.format.schema, [:])
        let roundTrip = try decoder.decode(AgentOutputConfig.self, from: encoder.encode(output))
        XCTAssertEqual(roundTrip.format.type, "future_format")
    }
}
