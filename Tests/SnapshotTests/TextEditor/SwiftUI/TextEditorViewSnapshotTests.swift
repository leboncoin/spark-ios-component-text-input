//
//  TextEditorViewSnapshotTests.swift
//  SparkTextEditorSnapshotTests
//
//  Created by robin.lemaire on 30/11/2023.
//  Copyright © 2023 Leboncoin. All rights reserved.
//

import XCTest
import SnapshotTesting
@testable import SparkTextInput
@_spi(SI_SPI) import SparkCommon
@_spi(SI_SPI) import SparkCommonSnapshotTesting
@_spi(SI_SPI) import SparkThemingTesting
import SparkTheming
import SparkTheme
import SwiftUI

@available(iOS 16.0, *)
final class TextEditorViewSnapshotTests: SwiftUIComponentSnapshotTestCase {

    // MARK: - Type Alias

    private typealias Constants = TextEditorSnapshotConstants

    // MARK: - Properties

    private let theme: Theme = SparkTheme.shared

    // MARK: - Tests

    func test() throws {
        let scenarios = TextEditorScenarioSnapshotTests.allCases

        for scenario in scenarios {
            let configurations: [TextEditorConfigurationSnapshotTests] = try scenario.configuration(
                isSwiftUIComponent: true
            )

            for configuration in configurations {
                let view = TextEditorView(
                    configuration.placeholder.text ?? configuration.content.text,
                    text: .constant(configuration.content.text),
                    theme: self.theme,
                    intent: configuration.intent
                )
                    .disabled(!configuration.state.isEnabled)
                    .frame(width: Constants.width)
                    .background(.background)

                self.assertSnapshot(
                    matching: view,
                    modes: configuration.modes,
                    sizes: configuration.sizes,
                    testName: configuration.testName()
                )
            }
        }
    }
}
