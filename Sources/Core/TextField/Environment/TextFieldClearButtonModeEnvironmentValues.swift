//
//  TextFieldClearButtonModeEnvironmentValues.swift
//  SparkTextInput
//
//  Created by robin.lemaire on 04/06/2025.
//  Copyright © 2024 Leboncoin. All rights reserved.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var textFieldClearButtonMode: TextFieldClearMode = .default
}

public extension View {

    /// A mode that controls when the standard Clear button appears in the text field.
    ///
    /// The standard clear button displays at the right side of the text field when the text field has contents, providing a way for the user to remove text quickly.
    /// This button appears automatically based on the value of this property. The default value for this property is *TextFieldClearMode.never*.
    @ViewBuilder
    func textFieldClearButtonMode(_ mode: TextFieldClearMode) -> some View {
        self.environment(\.textFieldClearButtonMode, mode)
    }
}
