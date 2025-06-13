//
//  TextInputGetFontUseCase.swift
//  SparkTextInput
//
//  Created by robin.lemaire on 11/06/2025.
//  Copyright © 2025 Leboncoin. All rights reserved.
//

import Foundation
import SparkTheming

// TODO: test

// sourcery: AutoMockable
protocol TextInputGetFontUseCaseable {
    func execute(theme: Theme) -> any TypographyFontToken
}

final class TextInputGetFontUseCase: TextInputGetFontUseCaseable {

    // MARK: - Methods

    func execute(theme: Theme) -> any TypographyFontToken {
        theme.typography.body1
    }
}
