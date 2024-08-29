//
//  TextFieldColors.swift
//  SparkTextField
//
//  Created by Quentin.richard on 22/09/2023.
//  Copyright © 2023 Adevinta. All rights reserved.
//

import Foundation
import SparkTheming

struct TextFieldColors: Equatable {

    // MARK: - Properties

    let text: any ColorToken
    let placeholder: any ColorToken
    let border: any ColorToken
    let background: any ColorToken

    // MARK: - Equatable

    static func == (lhs: TextFieldColors, rhs: TextFieldColors) -> Bool {
        return lhs.text.equals(rhs.text) &&
        lhs.placeholder.equals(rhs.placeholder) &&
        lhs.border.equals(rhs.border) &&
        lhs.background.equals(rhs.background)
    }
}
