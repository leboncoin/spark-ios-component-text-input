//
//  TextInputColors.swift
//  SparkTextField
//
//  Created by Quentin.richard on 22/09/2023.
//  Copyright © 2023 Leboncoin. All rights reserved.
//

import Foundation
import SparkTheming

struct TextInputColors: Equatable {

    // MARK: - Properties

    let text: any ColorToken
    let placeholder: any ColorToken
    let border: any ColorToken
    let background: any ColorToken

    // MARK: - Map

    func convert() -> TextInputColorsTemp {
        return .init(
            text: self.text.color,
            placeholder: self.placeholder.color,
            border: self.border.color,
            background: self.background.color
        )
    }

    // MARK: - Equatable

    static func == (lhs: TextInputColors, rhs: TextInputColors) -> Bool {
        return lhs.text.equals(rhs.text) &&
        lhs.placeholder.equals(rhs.placeholder) &&
        lhs.border.equals(rhs.border) &&
        lhs.background.equals(rhs.background)
    }
}


// TODO: Move ?

import SwiftUI

struct TextInputColorsTemp: Equatable {

    // MARK: - Properties

    var text: Color = .clear // TODO: constants
    var placeholder: Color = .clear // TODO: constants
    var border: Color = .clear // TODO: constants
    var background: Color = .clear// TODO: constants
}
