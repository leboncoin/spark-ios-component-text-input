//
//  TextInputGetSpacingsUseCaseGeneratedMock+ExtensionTests.swift
//  SparkTextFieldUnitTests
//
//  Created by louis.borlee on 01/02/2024.
//  Copyright © 2024 Leboncoin. All rights reserved.
//

import Foundation
@testable import SparkTextInput

extension TextInputGetSpacingsUseCasableGeneratedMock {
    static func mocked(returnedSpacings: TextInputSpacings) -> TextInputGetSpacingsUseCasableGeneratedMock {
        let mock = TextInputGetSpacingsUseCasableGeneratedMock()
        mock.executeWithThemeAndBorderStyleReturnValue = returnedSpacings
        return mock
    }
}
