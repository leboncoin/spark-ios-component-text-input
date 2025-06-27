//
//  TextInputGetBorderLayoutUseCase.swift
//  SparkTextInput
//
//  Created by louis.borlee on 25/09/2023.
//  Copyright © 2023 Leboncoin. All rights reserved.
//

import Foundation
import SparkTheming

// sourcery: AutoMockable, AutoMockTest
protocol TextInputGetBorderLayoutUseCaseable {
    // sourcery: theme = "Identical"
    func execute(
        theme: Theme,
        borderStyle: TextInputBorderStyle,
        isFocused: Bool
    ) -> TextInputBorderLayout

    // sourcery: theme = "Identical"
    func execute(
        theme: Theme,
        isFocused: Bool
    ) -> TextInputBorderLayout
}

final class TextInputGetBorderLayoutUseCase: TextInputGetBorderLayoutUseCaseable {

    func execute(
        theme: Theme,
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
            self.execute(theme: theme, isFocused: isFocused)
        }
    }

    func execute(
        theme: Theme,
        isFocused: Bool
    ) -> TextInputBorderLayout {
        return .init(
            radius: theme.border.radius.large,
            width: isFocused ? theme.border.width.medium : theme.border.width.small
        )
    }
}
