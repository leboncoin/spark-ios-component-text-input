//
//  TextInputGetBorderLayoutUseCasableGeneratedMock+ExtensionTests.swift
//  SparkTextFieldUnitTests
//
//  Created by louis.borlee on 01/02/2024.
//  Copyright © 2024 Adevinta. All rights reserved.
//

import Foundation
@testable import SparkTextInput

extension TextInputGetBorderLayoutUseCasableGeneratedMock {

    static func mocked(returnedBorderLayout: TextFieldBorderLayout) -> TextInputGetBorderLayoutUseCasableGeneratedMock {
        let mock = TextInputGetBorderLayoutUseCasableGeneratedMock()
        mock.executeWithThemeAndIsFocusedReturnValue = returnedBorderLayout
        return mock
    }
}

