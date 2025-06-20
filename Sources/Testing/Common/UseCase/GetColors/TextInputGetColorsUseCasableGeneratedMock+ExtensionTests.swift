//
//  TextInputGetColorsUseCaseableGeneratedMock+ExtensionTests.swift
//  SparkTextFieldUnitTests
//
//  Created by louis.borlee on 01/02/2024.
//  Copyright © 2024 Leboncoin. All rights reserved.
//

import Foundation
@testable import SparkTextInput

extension TextInputGetColorsUseCaseableGeneratedMock {
    static func mocked(returnedColors: TextInputColors) -> TextInputGetColorsUseCaseableGeneratedMock {
        let mock = TextInputGetColorsUseCaseableGeneratedMock()
        mock.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyReturnValue = returnedColors
        return mock
    }
}
