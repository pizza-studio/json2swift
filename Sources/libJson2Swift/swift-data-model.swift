//
//  swift-data-model.swift
//  json2swift
//
//  Created by Joshua Smith on 10/14/16.
//  Copyright © 2016 iJoshSmith. All rights reserved.
//

import Foundation

// MARK: - SwiftStruct

struct SwiftStruct {
    let name: String
    let properties: [SwiftProperty]
    let initializer: SwiftInitializer
    let failableInitializer: SwiftFailableInitializer
    let nestedStructs: [SwiftStruct]
}

// MARK: - SwiftProperty

struct SwiftProperty {
    let name: String
    let type: SwiftType
}

// MARK: - SwiftType

struct SwiftType {
    let name: String
    let isOptional: Bool
}

// MARK: - SwiftInitializer

struct SwiftInitializer {
    let parameters: [SwiftParameter]
}

// MARK: - SwiftParameter

struct SwiftParameter {
    let name: String
    let type: SwiftType
}

// MARK: - SwiftFailableInitializer

struct SwiftFailableInitializer {
    let requiredTransformations: [TransformationFromJSON]
    let optionalTransformations: [TransformationFromJSON]
}

// MARK: - TransformationFromJSON

enum TransformationFromJSON {
    case toCustomStruct(attributeName: String, propertyName: String, type: SwiftStruct)
    case toPrimitiveValue(attributeName: String, propertyName: String, type: SwiftPrimitiveValueType)
    case toCustomStructArray(
        attributeName: String,
        propertyName: String,
        elementType: SwiftStruct,
        hasOptionalElements: Bool
    )
    case toPrimitiveValueArray(
        attributeName: String,
        propertyName: String,
        elementType: SwiftPrimitiveValueType,
        hasOptionalElements: Bool
    )
}

// MARK: - SwiftPrimitiveValueType

enum SwiftPrimitiveValueType {
    case int
    case double
    case date(format: String)
    case url
    case string
    case bool
    case any
    case emptyArray
}
