//
//  TextFieldIntentEnvironmentValues.swift
//  SparkTextInput
//
//  Created by robin.lemaire on 04/06/2025.
//  Copyright © 2025 Leboncoin. All rights reserved.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var textFieldIntent: TextFieldIntent = .default
}

public extension View {

    /// Set the **intent** on the``SparkTextField``.
    ///
    /// The default value for this property is *TextFieldIntent.neutral*.
    @ViewBuilder
    func textFieldIntent(_ intent: TextFieldIntent) -> some View {
        self.environment(\.textFieldIntent, intent)
    }
}
