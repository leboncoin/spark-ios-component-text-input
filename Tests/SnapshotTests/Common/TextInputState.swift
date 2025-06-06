//
//  TextInputState.swift
//  SparkTextEditorSnapshotTests
//
//  Created by robin.lemaire on 30/11/2023.
//  Copyright © 2023 Leboncoin. All rights reserved.
//

enum TextInputState: String, CaseIterable {
    case enabled
    case disabled
    case readOnly

    static func allCases(isSwiftUIComponent: Bool) -> [Self] {
        var cases = Self.allCases
        if isSwiftUIComponent {
            cases.removeAll(where: { $0 == .readOnly })
        }
        return cases
    }

    var isEnabled: Bool {
        switch self {
        case .enabled, .readOnly: true
        case .disabled: false
        }
    }

    var isEditable: Bool {
        switch self {
        case .enabled, .disabled: true
        case .readOnly: false
        }
    }

    var isReadOnly: Bool {
        switch self {
        case .readOnly: true
        default: false
        }
    }
}
