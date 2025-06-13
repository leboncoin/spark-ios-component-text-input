//
//  TextInputBorderStyle.swift
//  Spark
//
//  Created by Jacklyn Situmorang on 18.10.23.
//  Copyright © 2023 Leboncoin. All rights reserved.
//

import UIKit

enum TextInputBorderStyle: CaseIterable {
    case roundedRect
    case none

    // MARK: - Properties

    static var `default` = Self.roundedRect // TODO: test

    // MARK: - Initialization

    init(_ borderStyle: UITextField.BorderStyle) {
        switch borderStyle {
        case .roundedRect:
            self = .roundedRect
        default:
            self = .none
        }
    }
}

extension UITextField.BorderStyle {

    // MARK: - Initialization

    init(_ borderStyle: TextInputBorderStyle) {
        switch borderStyle {
        case .roundedRect:
            self = .roundedRect
        case .none:
            self = .none
        }

    }
}
