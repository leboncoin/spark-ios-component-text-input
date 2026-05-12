//
//  TextInputGetBorderLayoutUseCase.swift
//  SparkComponentTextInput
//
//  Created by louis.borlee on 25/09/2023.
//  Copyright © 2023 Leboncoin. All rights reserved.
//

import Foundation
@_spi(SI_SPI) import SparkCommon
import SparkTheming

// sourcery: AutoMockable, AutoMockTest
protocol TextInputGetBorderLayoutUseCaseable {
    // sourcery: theme = "Identical"
    func execute(
        theme: any Theme,
        borderStyle: TextInputBorderStyle,
        isFocused: Bool
    ) -> TextInputBorderLayout

    // sourcery: theme = "Identical"
    func execute(
        theme: any Theme,
        isFocused: Bool
    ) -> TextInputBorderLayout
}

final class TextInputGetBorderLayoutUseCase: TextInputGetBorderLayoutUseCaseable {

    // MARK: - Properties

    private let featureTogglesService: any SparkFeatureToggleServicing

    // MARK: - Initialization

    init(featureTogglesService: any SparkFeatureToggleServicing = SparkFeatureToggleService.shared) {
        self.featureTogglesService = featureTogglesService
    }

    // MARK: - Methods

    func execute(
        theme: any Theme,
        borderStyle: TextInputBorderStyle,
        isFocused: Bool
    ) -> TextInputBorderLayout {
        return switch borderStyle {
        case .none:
            .init(
                radius: theme.border.radius.none,
                width: theme.border.width.none
            )
        case .roundedRect:
            self.execute(
                theme: theme,
                isFocused: isFocused
            )
        }
    }

    func execute(
        theme: any Theme,
        isFocused: Bool
    ) -> TextInputBorderLayout {
        let radius = self.featureTogglesService.rebranding ? theme.border.radius.full : theme.border.radius.large
        return .init(
            radius: radius,
            width: isFocused ? theme.border.width.medium : theme.border.width.small
        )
    }
}
