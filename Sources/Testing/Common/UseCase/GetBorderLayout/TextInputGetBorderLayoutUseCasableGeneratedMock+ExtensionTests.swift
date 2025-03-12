//
//  TextInputGetBorderLayoutUseCasableGeneratedMock+ExtensionTests.swift
//  SparkTextFieldUnitTests
//
//  Created by louis.borlee on 01/02/2024.
//  Copyright © 2024 Leboncoin. All rights reserved.
//

import Foundation
@testable import SparkTextInput

extension TextInputGetBorderLayoutUseCasableGeneratedMock {

    static func mocked(returnedBorderLayout: TextInputBorderLayout) -> TextInputGetBorderLayoutUseCasableGeneratedMock {
        let mock = TextInputGetBorderLayoutUseCasableGeneratedMock()
        mock.executeWithThemeAndBorderStyleAndIsFocusedReturnValue = returnedBorderLayout
        return mock
    }
}

