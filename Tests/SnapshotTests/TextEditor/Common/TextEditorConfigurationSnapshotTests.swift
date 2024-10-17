//
//  TextEditorConfigurationSnapshotTests.swift
//  SparkTextEditorSnapshotTests
//
//  Created by robin.lemaire on 30/11/2023.
//  Copyright © 2023 Adevinta. All rights reserved.
//

@testable import SparkTextInput
@_spi(SI_SPI) import SparkCommonSnapshotTesting
@_spi(SI_SPI) import SparkCommon
import XCTest

struct TextEditorConfigurationSnapshotTests {

    // MARK: - Type Alias

    private typealias Constants = ComponentSnapshotTestConstants

    // MARK: - Properties

    let scenario: TextEditorScenarioSnapshotTests

    let intent: TextEditorIntent = .neutral

    let state: TextEditorState
    let content: TextEditorContentResilience
    let placeholder: TextEditorPlaceholder
    let height: TextEditorHeight

    let modes: [ComponentSnapshotTestMode]
    let sizes: [UIContentSizeCategory]

    // MARK: - Initialization

    init(
        scenario: TextEditorScenarioSnapshotTests,
        state: TextEditorState,
        content: TextEditorContentResilience,
        placeholder: TextEditorPlaceholder,
        height: TextEditorHeight,
        modes: [ComponentSnapshotTestMode] = Constants.Modes.default,
        sizes: [UIContentSizeCategory] = Constants.Sizes.default
    ) {
        self.scenario = scenario
        self.state = state
        self.content = content
        self.placeholder = placeholder
        self.height = height
        self.modes = modes
        self.sizes = sizes
    }

    // MARK: - Getter

    func testName() -> String {
        return [
            "\(self.scenario.rawValue)",
            "\(self.intent)",
            "\(self.state)" + "State",
            "\(self.content)" + "Content",
            "\(self.placeholder)" + "Placeholder",
            "\(self.height)" + "Height",
        ].joined(separator: "-")
    }
}

// MARK: - Enum

enum TextEditorState: String, CaseIterable {
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
        case .enabled, .readOnly:
            true
        case .disabled:
            false
        }
    }

    var isEditable: Bool {
        switch self {
        case .enabled, .disabled:
            true
        case .readOnly:
            false
        }
    }
}

enum TextEditorContentResilience: String, CaseIterable {
    case empty
    case smallText
    case multilineText

    var text: String {
        switch self {
        case .empty: ""
        case .smallText: "My text"
        case .multilineText: "My text. Lorem ipsum dolor sit amet, consectetur adipiscing elit."
        }
    }
}

enum TextEditorHeight: String, CaseIterable {
    case flexible
    case fixed

    var value: CGFloat? {
        switch self {
        case .flexible: nil
        case .fixed: TextEditorSnapshotConstants.fixedHeight
        }
    }

    var isFixed: Bool {
        switch self {
        case .flexible: false
        case .fixed: true
        }
    }

    var isScrollEnabled: Bool {
        switch self {
        case .flexible: true
        case .fixed: false
        }
    }
}

enum TextEditorPlaceholder: String, CaseIterable {
    case empty
    case small
    case multiline

    var text: String? {
        switch self {
        case .empty: nil
        case .small: "My placeholder"
        case .multiline: "My placeholder. Duis aute irure dolor in reprehenderit in voluptate velit."
        }
    }
}
