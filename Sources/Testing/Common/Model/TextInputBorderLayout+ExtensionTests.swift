//
//  TextFieldBorderLayout+ExtensionTests.swift
//  SparkTextFieldUnitTests
//
//  Created by louis.borlee on 01/02/2024.
//  Copyright © 2024 Adevinta. All rights reserved.
//

import Foundation
@testable import SparkTextInput

extension TextFieldBorderLayout {
    static func mocked(radius: CGFloat, width: CGFloat) -> TextFieldBorderLayout {
        return .init(radius: radius, width: width)
    }
}
