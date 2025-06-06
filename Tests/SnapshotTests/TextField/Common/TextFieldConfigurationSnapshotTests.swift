//
//  TextFieldConfigurationSnapshotTests.swift
//  SparkTextFieldSnapshotTests
//
//  Created by robin.lemaire on 30/11/2023.
//  Copyright © 2023 Leboncoin. All rights reserved.
//

@testable import SparkTextInput
@_spi(SI_SPI) import SparkCommonSnapshotTesting
@_spi(SI_SPI) import SparkCommon
import XCTest

struct TextFieldConfigurationSnapshotTests {

    // MARK: - Type Alias

    private typealias Constants = ComponentSnapshotTestConstants

    // MARK: - Properties

    let scenario: TextFieldScenarioSnapshotTests

    let intent: TextFieldIntent
    let state: TextInputState
    let content: TextInputContentResilience
    let placeholder: TextInputPlaceholder
    let leftContent: TextFieldSideViewType
    let leftAddonContent: TextFieldSideViewType
    let rightContent: TextFieldSideViewType
    let rightAddonContent: TextFieldSideViewType
    let isAddonsPadding: Bool
    let isClearButton: Bool
    let isFocused: Bool
    let isSecureMode: Bool

    let modes: [ComponentSnapshotTestMode]
    let sizes: [UIContentSizeCategory]

    var isAddons: Bool {
        !self.leftAddonContent.isNone || !self.rightAddonContent.isNone
    }

    // MARK: - Initialization

    init(
        scenario: TextFieldScenarioSnapshotTests,
        intent: TextFieldIntent,
        state: TextInputState,
        content: TextInputContentResilience,
        placeholder: TextInputPlaceholder,
        leftContent: TextFieldSideViewType,
        leftAddonContent: TextFieldSideViewType,
        rightContent: TextFieldSideViewType,
        rightAddonContent: TextFieldSideViewType,
        isAddonsPadding: Bool,
        isClearButton: Bool,
        isFocused: Bool,
        isSecureMode: Bool,
        modes: [ComponentSnapshotTestMode] = Constants.Modes.default,
        sizes: [UIContentSizeCategory] = Constants.Sizes.default
    ) {
        self.scenario = scenario
        self.intent = intent
        self.state = state
        self.content = content
        self.placeholder = placeholder
        self.leftContent = leftContent
        self.leftAddonContent = leftAddonContent
        self.rightContent = rightContent
        self.rightAddonContent = rightAddonContent
        self.isAddonsPadding = isAddonsPadding
        self.isClearButton = isClearButton
        self.isFocused = isFocused
        self.isSecureMode = isSecureMode
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
            "\(self.leftContent)" + "LeftContent",
            "\(self.leftAddonContent)" + "LeftAddonContent",
            "\(self.rightContent)" + "RightContent",
            "\(self.rightAddonContent)" + "RightAddonContent",
            self.isAddonsPadding ? "isAddonsPadding" : nil,
            self.isClearButton ? "isClearButton" : nil,
            self.isFocused ? "isFocused" : nil,
            self.isSecureMode ? "isSecureMode" : nil,
        ]
            .compactMap { $0 }
            .joined(separator: "-")
    }
}

// MARK: - Enum

enum TextFieldSideViewType: String, CaseIterable {
    case empty
    case button
    case image

    var isNone: Bool {
        return self == .empty
    }
}

enum TextFieldSideViewState: CaseIterable {
    case left
    case right
    case both

    var isLeft: Bool {
        switch self {
        case .left, .both:
            return true
        default:
            return false
        }
    }

    var isRight: Bool {
        switch self {
        case .right, .both:
            return true
        default:
            return false
        }
    }
}
