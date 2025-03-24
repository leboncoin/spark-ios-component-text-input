//
//  TextFieldColors+ExtensionTests.swift
//  SparkTextFieldUnitTests
//
//  Created by louis.borlee on 01/02/2024.
//  Copyright © 2024 Leboncoin. All rights reserved.
//

import Foundation
@testable import SparkTextInput
@_spi(SI_SPI) import SparkThemingTesting

extension TextFieldColors {
    static func mocked(
        text: ColorTokenGeneratedMock,
        placeholder: ColorTokenGeneratedMock,
        border: ColorTokenGeneratedMock,
        background: ColorTokenGeneratedMock
    ) -> TextFieldColors {
        return .init(
            text: text,
            placeholder: placeholder,
            border: border,
            background: background
        )
    }
}
