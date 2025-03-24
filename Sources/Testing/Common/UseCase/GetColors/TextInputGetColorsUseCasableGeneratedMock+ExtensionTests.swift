//
//  TextInputGetColorsUseCasableGeneratedMock+ExtensionTests.swift
//  SparkTextFieldUnitTests
//
//  Created by louis.borlee on 01/02/2024.
//  Copyright © 2024 Leboncoin. All rights reserved.
//

import Foundation
@testable import SparkTextInput

extension TextInputGetColorsUseCasableGeneratedMock {
    static func mocked(returnedColors: TextFieldColors) -> TextInputGetColorsUseCasableGeneratedMock {
        let mock = TextInputGetColorsUseCasableGeneratedMock()
        mock.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyReturnValue = returnedColors
        return mock
    }
}
