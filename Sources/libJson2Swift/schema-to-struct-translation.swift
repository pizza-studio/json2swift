//
//  schema-to-struct-translation.swift
//  json2swift
//
//  Created by Joshua Smith on 10/22/16.
//  Copyright © 2016 iJoshSmith. All rights reserved.
//

// MARK: - JSONElementSchema --> SwiftStruct

extension SwiftStruct {
    internal static func create(from jsonElementSchema: JSONElementSchema) -> SwiftStruct {
        let name = jsonElementSchema.name.toSwiftStructName()
        let properties = SwiftProperty.createProperties(forStructBasedOn: jsonElementSchema)
        let parameters = SwiftParameter.createParameters(for: properties)
        let initializer = SwiftInitializer(parameters: parameters)
        let failableInitializer = SwiftFailableInitializer.create(forStructBasedOn: jsonElementSchema)
        let nestedStructs = createNestedStructs(forElementsIn: jsonElementSchema)
        return SwiftStruct(
            name: name,
            properties: properties,
            initializer: initializer,
            failableInitializer: failableInitializer,
            nestedStructs: nestedStructs
        )
    }

    private static func createNestedStructs(forElementsIn jsonElementSchema: JSONElementSchema) -> [SwiftStruct] {
        jsonElementSchema.attributes.values.compactMap(SwiftStruct.tryToCreate(fromJSONType:))
    }

    private static func tryToCreate(fromJSONType jsonType: JSONType) -> SwiftStruct? {
        if let schema = jsonType.jsonElementSchema {
            return SwiftStruct.create(from: schema)
        } else {
            return nil
        }
    }
}

// MARK: - JSONElementSchema --> SwiftProperty

extension SwiftProperty {
    fileprivate static func createProperties(forStructBasedOn jsonElementSchema: JSONElementSchema) -> [SwiftProperty] {
        jsonElementSchema.attributes.map { name, type in
            createProperty(basedOnJSONAttribute: name, and: type)
        }
    }

    private static func createProperty(
        basedOnJSONAttribute attributeName: String,
        and attributeType: JSONType
    )
        -> SwiftProperty {
        let propertyName = attributeName.toSwiftPropertyName()
        let propertyType = SwiftType.createType(from: attributeType)
        return SwiftProperty(name: propertyName, type: propertyType)
    }
}

// MARK: - SwiftProperty --> SwiftParameter

extension SwiftParameter {
    fileprivate static func createParameters(for properties: [SwiftProperty]) -> [SwiftParameter] {
        properties.map { SwiftParameter(name: $0.name, type: $0.type) }
    }
}

// MARK: - JSONType --> SwiftType

extension SwiftType {
    fileprivate static func createType(from jsonType: JSONType) -> SwiftType {
        let typeName = jsonType.swiftTypeName
        let isOptional = jsonType.isRequired == false
        return SwiftType(name: typeName, isOptional: isOptional)
    }
}

// MARK: - JSONType --> Swift type name

extension JSONType {
    fileprivate var swiftTypeName: String {
        switch self {
        case let .element(_, schema): return schema.name.toSwiftStructName()
        case let .elementArray(_, elementSchema, hasNullableElements): return JSONType
            .nameForArray(of: elementSchema, hasNullableElements)
        case let .valueArray(_, valueType): return JSONType.nameForArray(of: valueType)
        case let .number(_, isFloatingPoint): return isFloatingPoint ? "Double" : "Int"
        case .date: return "Date"
        case .url: return "URL"
        case .string: return "String"
        case .bool: return "Bool"
        case .anything, .nullable: return "Any"
        case .emptyArray: return "[Any?]"
        }
    }

    private static func nameForArray(of schema: JSONElementSchema, _ hasOptionalElements: Bool) -> String {
        nameForArray(of: schema.name.toSwiftStructName(), hasOptionalElements: hasOptionalElements)
    }

    private static func nameForArray(of valueType: JSONType) -> String {
        nameForArray(of: valueType.swiftTypeName, hasOptionalElements: valueType.isRequired == false)
    }

    private static func nameForArray(of typeName: String, hasOptionalElements: Bool) -> String {
        let fullTypeName = hasOptionalElements
            ? typeName + "?"
            : typeName
        return "[" + fullTypeName + "]"
    }
}
