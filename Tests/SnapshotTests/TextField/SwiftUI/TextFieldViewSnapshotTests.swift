//
//  TextFieldViewSnapshotTests.swift
//  SparkTextFieldSnapshotTests
//
//  Created by robin.lemaire on 05/06/2025.
//  Copyright © 2025 Leboncoin. All rights reserved.
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

final class TextFieldViewSnapshotTests: SwiftUIComponentSnapshotTestCase {

    // MARK: - Type Alias

    private typealias Constants = TextFieldSnapshotConstants

    // MARK: - Properties

    private let theme: Theme = SparkTheme.shared

    // MARK: - Tests

    func test() throws {
        let scenarios = TextFieldScenarioSnapshotTests.allCases

        for scenario in scenarios {
            let configurations: [TextFieldConfigurationSnapshotTests] = try scenario.configuration(
                isSwiftUIComponent: true
            )

            for configuration in configurations {
                let view = self.textField(from: configuration)
                    .disabled(!configuration.state.isEnabled)
                    .textFieldClearButtonMode(configuration.isClearButton ? .always : .never)
                    .background(.background)
                    .frame(width: Constants.width)
                    .padding(Constants.padding)
                    .background(Color(uiColor: .secondarySystemBackground))

                // TODO: add secure

                self.assertSnapshot(
                    matching: view,
                    modes: configuration.modes,
                    sizes: configuration.sizes,
                    testName: configuration.testName()
                )
            }
        }
    }

    // MARK: - Builder

    @ViewBuilder
    private func textField(from configuration: TextFieldConfigurationSnapshotTests) -> some View {
        if configuration.isAddons {
            TextFieldAddons(
                LocalizedStringKey(configuration.placeholder.text ?? ""),
                text: .constant(configuration.content.text),
                theme: self.theme,
                intent: configuration.intent,
                type: .value(for: configuration),
                isReadOnly: configuration.state.isReadOnly,
                leftView: { self.sideView(from: configuration.leftContent) },
                rightView: { self.sideView(from: configuration.rightContent) },
                leftAddon: { TextFieldAddon(
                    withPadding: configuration.isAddonsPadding,
                    layoutPriority: 1) {
                        self.sideView(from: configuration.leftAddonContent)
                    }
                },
                rightAddon: { TextFieldAddon(
                    withPadding: configuration.isAddonsPadding,
                    layoutPriority: 1) {
                        self.sideView(from: configuration.rightAddonContent)
                    }
                }
            )
        } else {
            TextFieldView(
                LocalizedStringKey(configuration.placeholder.text ?? ""),
                text: .constant(configuration.content.text),
                theme: self.theme,
                intent: configuration.intent,
                type: .value(for: configuration),
                isReadOnly: configuration.state.isReadOnly,
                leftView: { self.sideView(from: configuration.leftContent) },
                rightView: { self.sideView(from: configuration.rightContent) }
            )
        }
    }

    @ViewBuilder
    private func sideView(from sideType: TextFieldSideViewType) -> some View {
        switch sideType {
        case .empty: EmptyView()
        case .button:
            Button("Btn", action: { })
                .padding(.all, 4)
                .background(Color(.secondaryLabel))
        case .image: Image(systemName: "eject.circle.fill")
        }
    }
}

// MARK: - Extension

private extension TextFieldViewType {

    static func value(for configuration: TextFieldConfigurationSnapshotTests) -> Self {
        if configuration.isSecureMode {
            return .secure()
        } else {
            return .standard()
        }
    }
}
