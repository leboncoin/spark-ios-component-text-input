//
//  TextInputBorderLayout+ExtensionTests.swift
//  SparkTextFieldUnitTests
//
//  Created by louis.borlee on 01/02/2024.
//  Copyright © 2024 Adevinta. All rights reserved.
//

import Foundation
@testable import SparkTextInput

extension TextInputBorderLayout {
    static func mocked(radius: CGFloat, width: CGFloat) -> TextInputBorderLayout {
        return .init(radius: radius, width: width)
    }
}
