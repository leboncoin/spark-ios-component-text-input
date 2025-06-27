//
//  TextFieldPlaceholderColorEnvironmentValues.swift
//  SparkTextInput
//
//  Created by robin.lemaire on 04/06/2025.
//  Copyright © 2025 Leboncoin. All rights reserved.
//

import SwiftUI
import SparkTheming

extension EnvironmentValues {
    @Entry var textFieldPlaceholderColor: Color? = .clear
}

extension View {

    func sparkTextFieldPlaceholderColor(_ token: (any ColorToken)?) -> some View {
        self.environment(\.textFieldPlaceholderColor, token?.color)
    }
}
