//
//  TextInputGetBorderLayoutUseCase.swift
//  SparkTextInput
//
//  Created by louis.borlee on 25/09/2023.
//  Copyright © 2023 Leboncoin. All rights reserved.
//

import Foundation
import SparkTheming

// sourcery: AutoMockable
protocol TextInputGetBorderLayoutUseCasable {
    func execute(
        theme: Theme,
        borderStyle: TextInputBorderStyle,
        isFocused: Bool
    ) -> TextInputBorderLayout
}

final class TextInputGetBorderLayoutUseCase: TextInputGetBorderLayoutUseCasable {
    func execute(
        theme: Theme,
        borderStyle: TextInputBorderStyle,
        isFocused: Bool
    ) -> TextInputBorderLayout {
        switch borderStyle {
        case .none:
            return .init(
                radius: theme.border.radius.none,
                width: theme.border.width.none
            )
        case .roundedRect:
            return .init(
                radius: theme.border.radius.large,
                width: isFocused ? theme.border.width.medium : theme.border.width.small
            )
        }
    }
}
