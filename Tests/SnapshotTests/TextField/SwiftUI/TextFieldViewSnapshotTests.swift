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
                let view = SparkTextField(
                    LocalizedStringKey(configuration.placeholder.text ?? ""),
                    text: .constant(configuration.content.text),
                    theme: self.theme,
                    leftView: {
                        self.sideView(from: configuration.leftContent)
                    },
                    rightView: {
                        self.sideView(from: configuration.rightContent)
                    },
                    leftAddon: {
                        self.sideView(from: configuration.leftAddonContent)
                    },
                    rightAddon: {
                        self.sideView(from: configuration.rightAddonContent)
                    }
                )
                    .sparkTextFieldIntent(configuration.intent)
                    .sparkTextFieldReadOnly(configuration.state.isReadOnly)
                    .sparkTextFieldClearMode(configuration.isClearButton ? .always : .never)
                    .sparkTextFieldSecureEntry(configuration.isSecureEntry)
                    .sparkTextFieldLeftAddonConfiguration(.init(configuration: configuration))
                    .sparkTextFieldRightAddonConfiguration(.init(configuration: configuration))
                    .disabled(!configuration.state.isEnabled)
                    .background(.background)
                    .frame(width: Constants.width)
                    .padding(Constants.padding)
                    .background(Color(uiColor: .secondarySystemBackground))

                self.assertSnapshot(
                    matching: view,
                    modes: configuration.modes,
                    sizes: configuration.sizes,
                    testName: configuration.testName()
                )
            }
        }
    }

    // MARK: - View Builder

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

private extension TextFieldAddonConfiguration {

    init(configuration: TextFieldConfigurationSnapshotTests) {
        self.init(
            hasPadding: configuration.isAddonsPadding,
            hasSeparator: configuration.isAddons ? configuration.isAddonsSeparator : false
        )
    }
}

private extension View {

    func sparkTextFieldLeftAddonConfiguration(
        _ configuration: TextFieldAddonConfiguration
    ) -> some View {
        return self.environment(\.textFieldLeftAddonConfiguration, configuration)
    }

    func sparkTextFieldRightAddonConfiguration(
        _ configuration: TextFieldAddonConfiguration
    ) -> some View {
        return self.environment(\.textFieldRightAddonConfiguration, configuration)
    }
}
