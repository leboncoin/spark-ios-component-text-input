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
    init(_ borderStyle: TextInputBorderStyle) {
        switch borderStyle {
        case .roundedRect:
            self = .roundedRect
        case .none:
            self = .none
        }

    }
}
