//
//  TextInputSpacings+ExtensionTests.swift
//  SparkTextFieldUnitTests
//
//  Created by louis.borlee on 01/02/2024.
//  Copyright © 2024 Adevinta. All rights reserved.
//

import Foundation
@testable import SparkTextInput

extension TextInputSpacings {
    static func mocked(left: CGFloat, content: CGFloat, right: CGFloat) -> TextInputSpacings {
        return .init(left: left, content: content, right: right)
    }
}
