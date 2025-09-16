//
//  SparkTextEditor.swift
//  SparkComponentTextInput
//
//  Created by robin.lemaire on 20/06/2025.
//  Copyright © 2025 Leboncoin. All rights reserved.
//

import SwiftUI
@_spi(SI_SPI) import SparkCommon
import SparkTheming

/// A **Spark** view that can display and edit long-form text.
///
/// A text editor view allows you to display and edit multiline, scrollable
/// text in your app's user interface.
///
/// If you want to have a *clear button*, you must use the **Spark** **FormField**
///
/// **Default values** :
/// - **intent**: .neutral
/// - **readOnly**: false
///
/// Implementation example :
/// ```swift
/// struct MyView: View {
///     let theme: SparkTheming.Theme = MyTheme()
///     @State var text = ""
///
///     var body: some View {
///         SparkTextEditor(
///             "My placeholder",
///             text: self.$text,
///             theme: self.theme
///         )
///         .sparkTextEditorIntent(.success)
///         .sparkTextEditorReadOnly(false)
///     }
/// }
/// ```
/// ![TextEditor rendering with a multiline text.](texteditor.png)
///
/// Some environment values are used by the ``SparkTextEditor``:
/// - Intent:
/// ```swift
/// SparkTextEditor(
///     "My placeholder",
///     text: self.$text,
///     theme: self.theme
/// )
/// .sparkTextEditorIntent(.success)
/// ```
/// - Read Only:
/// ```swift
/// SparkTextEditor(
///     "My placeholder",
///     text: self.$text,
///     theme: self.theme
/// )
/// .sparkTextEditorReadOnly(false)
/// ```
public struct SparkTextEditor: View {

    // MARK: - Properties

    private let theme: any Theme
    private let title: String

    @Binding private var text: String

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.textEditorIntent) private var intent
    @Environment(\.textEditorReadOnly) private var isReadOnly
    @Environment(\.textEditorAccessibilityLabel) private var accessibilityLabel
    @Environment(\.textEditorAccessibilityValue) private var accessibilityValue
    @Environment(\.textEditorAccessibilityHint) private var accessibilityHint

    @FocusState private var isFocused: Bool

    private var minHeight: CGFloat = 38

    @StateObject private var viewModel = TextEditorViewModel()

    // MARK: - Initialization

    /// SparkTextEditor initializer.
    /// - Parameters:
    ///   - title: The texteditor's current placeholder.
    ///   - text: The texteditor's text binding.
    ///   - theme: The texteditor's current theme.
    ///
    /// Implementation example :
    /// ```swift
    /// struct MyView: View {
    ///     let theme: SparkTheming.Theme = MyTheme()
    ///     @State var text = ""
    ///
    ///     var body: some View {
    ///         SparkTextEditor(
    ///             "My placeholder",
    ///             text: self.$text,
    ///             theme: self.theme
    ///         )
    ///     }
    /// }
    /// ```
    /// ![TextEditor rendering with a multiline text.](texteditor.png)
    public init(
        _ title: String,
        text: Binding<String>,
        theme: any Theme
    ) {
        self.title = title
        self._text = text
        self.theme = theme
    }

    // MARK: - View

    public var body: some View {
        ZStack {
            TextEditor(text: .constant(self.title))
                .foregroundStyle(self.viewModel.colors.placeholder)
                .opacity(self.text.isEmpty ? 1.0 : 0.0)
                .disabled(true)
                .accessibilityHidden(true)

            TextEditor(text: self.$text)
                .foregroundStyle(self.viewModel.colors.text)
                .tint(self.viewModel.colors.text)
                .scrollIndicators(.visible)
                .focused(self.$isFocused)
                .accessibilityLabel(self.accessibilityLabel ?? self.title)
                .accessibilityOptionalValue(self.accessibilityValue)
                .accessibilityOptionalHint(self.accessibilityHint)
        }
        .font(self.viewModel.font)
        .scaledFrame(minHeight: self.minHeight)
        .scrollContentBackground(.hidden)
        .scaledPadding(.horizontal, self.viewModel.horizontalPadding)
        .background(self.viewModel.colors.background)
        .scaledBorder(
            width: self.viewModel.borderLayout.width,
            radius: self.viewModel.borderLayout.radius,
            colorToken: self.viewModel.colors.border
        )
        .opacity(self.viewModel.dim)
        .allowsHitTesting(!self.isReadOnly)
        .dynamicTypeSize(...DynamicTypeSize.accessibility3)
        .accessibilityIdentifier(TextEditorAccessibilityIdentifier.view)
        .onAppear() {
            self.viewModel.updateAll(
                theme: self.theme,
                intent: self.intent,
                isReadOnly: self.isReadOnly,
                isFocused: self.isFocused,
                isEnabled: self.isEnabled
            )
        }
        .onChange(of: self.intent) { intent in
            self.viewModel.intent = intent
        }
        .onChange(of: self.isReadOnly) { isReadOnly in
            self.viewModel.isReadOnly = isReadOnly
        }
        .onChange(of: self.isFocused) { isFocused in
            self.viewModel.isFocused = isFocused
        }
        .onChange(of: self.isEnabled) { isEnabled in
            self.viewModel.isEnabled = isEnabled
        }
    }
}
