//
//  TextFieldFocusPreferenceKey.swift
//  SparkTextInput
//
//  Created by robin.lemaire on 06/06/2025.
//  Copyright © 2025 Leboncoin. All rights reserved.
//

import SwiftUI

struct TextFieldFocusPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {}
}
