//
//  TextInputGetBorderLayoutUseCase.swift
//  SparkTextField
//
//  Created by louis.borlee on 25/09/2023.
//  Copyright © 2023 Adevinta. All rights reserved.
//

import Foundation
import SparkTheming

// sourcery: AutoMockable
protocol TextInputGetBorderLayoutUseCasable {
    func execute(theme: Theme, isFocused: Bool) -> TextFieldBorderLayout
}

final class TextInputGetBorderLayoutUseCase: TextInputGetBorderLayoutUseCasable {
    func execute(theme: Theme, isFocused: Bool) -> TextFieldBorderLayout {
        return .init(
            radius: theme.border.radius.large,
            width: isFocused ? theme.border.width.medium : theme.border.width.small
        )
    }
}
