//
//  SparkTextField.swift
//  SparkTextInput
//
//  Created by robin.lemaire on 10/06/2025.
//  Copyright © 2025 Leboncoin. All rights reserved.
//

import SwiftUI
@_spi(SI_SPI) import SparkCommon
import SparkTheming

/// A **Spark** control that displays an editable text interface.
///
/// It is possible to display some side views :
/// - leftView (at the left of the textField).
/// - rightView (at the right of the textField)
///
/// And some addons :
/// - leftAddon (at the left of the leftView or textField if there is no leftView)
/// - rightAddon (at the right of the rightView or textField if there is no rightView)
///
/// All theses views are optional. By default all side views are **nil** (corresponding to EmptyView).
///
/// **Default values** :
/// - **intent**: .neutral
/// - **readOnly**: false
/// - **clearMode**: never
/// - **secureEntry**: false
/// - **leftAddonConfiguration**: ``TextFieldAddonConfiguration``default init
/// - **rightAddonConfiguration**: ``TextFieldAddonConfiguration``default init
///
/// Implementation example :
/// - With all side views :
/// ```swift
/// struct MyView: View {
///     let theme: SparkTheming.Theme = MyTheme()
///     @State var text = ""
///
///     var body: some View {
///         SparkTextField(
///             "My placeholder",
///             text: self.$text,
///             theme: self.theme,
///             leftView: {
///                 Text("Hello")
///             },
///             rightView: {
///                 Image(systemName: "circle")
///             },
///             leftAddon: {
///                 Button("In", action: {})
///             },
///             rightAddon: {
///                 Button("Out", action: {})
///             }
///         )
///         .sparkTextFieldIntent(.success)
///         .sparkTextFieldReadOnly(false)
///         .sparkTextFieldClearMode(.always)
///         .sparkTextFieldSecureEntry(false)
///         .sparkTextFieldLeftAddonConfiguration(hasPadding: false, hasSeparator: true)
///         .sparkTextFieldLeftAddonConfiguration(hasPadding: true, hasSeparator: false)
///     }
/// }
/// ```
/// - Without side views
/// ```swift
/// struct MyView: View {
///     let theme: SparkTheming.Theme = MyTheme()
///     @State var text = ""
///
///     var body: some View {
///         SparkTextField(
///             "My placeholder",
///             text: self.$text,
///             theme: self.theme
///         )
///     }
/// }
/// ```
///
/// Some environment values are used by the ``SparkTextField``:
/// - Intent (change the intent) :
/// ```swift
/// SparkTextField(
///     "My placeholder",
///     text: self.$text,
///     theme: self.theme
/// )
/// .sparkTextFieldIntent(.success)
/// ```
/// - Read Only (activate or not the read only):
/// ```swift
/// SparkTextField(
///     "My placeholder",
///     text: self.$text,
///     theme: self.theme
/// )
/// .sparkTextFieldReadOnly(false)
/// ```
/// - Clear Mode (show a clear button from enum ``TextFieldClearMode``):
/// ```swift
/// SparkTextField(
///     "My placeholder",
///     text: self.$text,
///     theme: self.theme
/// )
/// .sparkTextFieldClearMode(.always)
/// ```
/// - Secure Entry  (activate or not the secure entry):
/// ```swift
/// SparkTextField(
///     "My placeholder",
///     text: self.$text,
///     theme: self.theme
/// )
/// .sparkTextFieldSecureEntry(false)
/// ```
/// - Left Addon Configuration (some style of the addon):
/// ```swift
/// SparkTextField(
///     "My placeholder",
///     text: self.$text,
///     theme: self.theme
/// )
/// .sparkTextFieldLeftAddonConfiguration(hasPadding: false, hasSeparator: true)
/// ```
/// - Right Addon Configuration (some style of the addon):
/// ```swift
/// SparkTextField(
///     "My placeholder",
///     text: self.$text,
///     theme: self.theme
/// )
/// .sparkTextFieldLeftAddonConfiguration(hasPadding: true, hasSeparator: false)
/// ```
// TODO: add screenshot
public struct SparkTextField<Value, Format, LeftView: View, RightView: View, LeftAddon: View, RightAddon: View, Content: View>: View {

    // MARK: - Properties

    private let theme: Theme
    private let titleKey: LocalizedStringKey

    private let format: Format?
    private let formatter: Formatter?

//    @Binding private var text: String
    @Binding private var value: Value

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.textFieldIntent) private var intent
    @Environment(\.textFieldReadOnly) private var isReadOnly
    @Environment(\.textFieldClearMode) private var clearMode
    @Environment(\.textFieldLeftAddonConfiguration) private var leftAddonConfiguration
    @Environment(\.textFieldRightAddonConfiguration) private var rightAddonConfiguration

    @FocusState private var isFocused: Bool

    private let leftView: () -> LeftView
    private let rightView: () -> RightView
    private let leftAddon: () -> LeftAddon
    private let rightAddon: () -> RightAddon

    private var height: CGFloat = TextInputConstants.height

    @StateObject private var viewModel = TextFieldViewModel()

    private let content: () -> Content

    // MARK: - Initialization

    /// SparkTextField initializer with **text**.
    /// - Parameters:
    ///   - titleKey: The textfield's current placeholder.
    ///   - text: The textfield's text binding.
    ///   - theme: The textfield's current theme.
    ///   - leftView: The textField's left view, default is `EmptyView`.
    ///   - rightView: The textField's right view, default is `EmptyView`.
    ///   - leftAddon: The textField's left addon, default is `EmptyView`.
    ///   - rightAddon: The textField's right addon, default is `EmptyView`.
    ///
    /// Implementation example :
    /// - With all side views :
    /// ```swift
    /// struct MyView: View {
    ///     let theme: SparkTheming.Theme = MyTheme()
    ///     @State var text = ""
    ///
    ///     var body: some View {
    ///         SparkTextField(
    ///             "My placeholder",
    ///             text: self.$text,
    ///             theme: self.theme,
    ///             leftView: {
    ///                 Text("Hello")
    ///             },
    ///             rightView: {
    ///                 Image(systemName: "circle")
    ///             },
    ///             leftAddon: {
    ///                 Button("In", action: {})
    ///             },
    ///             rightAddon: {
    ///                 Button("Out", action: {})
    ///             }
    ///         )
    ///     }
    /// }
    /// ```
    /// - Without side views
    /// ```swift
    /// struct MyView: View {
    ///     let theme: SparkTheming.Theme = MyTheme()
    ///     @State var text = ""
    ///
    ///     var body: some View {
    ///         SparkTextField(
    ///             "My placeholder",
    ///             text: self.$text,
    ///             theme: self.theme
    ///         )
    ///     }
    /// }
    public init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        theme: Theme,
        leftView: @escaping () -> LeftView = { EmptyView() },
        rightView: @escaping () -> RightView = { EmptyView() },
        leftAddon: @escaping () -> LeftAddon = { EmptyView() },
        rightAddon: @escaping () -> RightAddon = { EmptyView() }
    ) where Value == String, Format == Void, Content == _DefaultTextField {
        self.titleKey = titleKey
//        self._text = text
        self._value = text
        self.theme = theme
        self.formatter = nil
        self.format = nil

        self.leftAddon = leftAddon
        self.leftView = leftView
        self.rightView = rightView
        self.rightAddon = rightAddon

        self.content = {
            _DefaultTextField(
                titleKey: titleKey,
                text: text
            )
        }
    }

    /// SparkTextField initializer with **dynamic type** and *formatter*.
    /// - Parameters:
    ///   - titleKey: The textfield's current placeholder.
    ///   - text: The textfield's text binding.
    ///   - theme: The textfield's current theme.
    ///   - leftView: The textField's left view, default is `EmptyView`.
    ///   - rightView: The textField's right view, default is `EmptyView`.
    ///   - leftAddon: The textField's left addon, default is `EmptyView`.
    ///   - rightAddon: The textField's right addon, default is `EmptyView`.
    ///
    /// Implementation example :
    /// - With all side views :
    /// ```swift
    /// struct MyView: View {
    ///     let theme: SparkTheming.Theme = MyTheme()
    ///     @State var text = ""
    ///
    ///     var body: some View {
    ///         SparkTextField(
    ///             "My placeholder",
    ///             text: self.$text,
    ///             theme: self.theme,
    ///             leftView: {
    ///                 Text("Hello")
    ///             },
    ///             rightView: {
    ///                 Image(systemName: "circle")
    ///             },
    ///             leftAddon: {
    ///                 Button("In", action: {})
    ///             },
    ///             rightAddon: {
    ///                 Button("Out", action: {})
    ///             }
    ///         )
    ///     }
    /// }
    /// ```
    /// - Without side views
    /// ```swift
    /// struct MyView: View {
    ///     let theme: SparkTheming.Theme = MyTheme()
    ///     @State var text = ""
    ///
    ///     var body: some View {
    ///         SparkTextField(
    ///             "My placeholder",
    ///             text: self.$text,
    ///             theme: self.theme
    ///         )
    ///     }
    /// }
    public init(
        _ titleKey: LocalizedStringKey,
        value: Binding<Value>,
        formatter: Formatter, // TODO: change doc
        theme: Theme,
        leftView: @escaping () -> LeftView = { EmptyView() },
        rightView: @escaping () -> RightView = { EmptyView() },
        leftAddon: @escaping () -> LeftAddon = { EmptyView() },
        rightAddon: @escaping () -> RightAddon = { EmptyView() }
    ) where Content == _FormattedTextField<Value> {
        self.titleKey = titleKey
        self._value = value
        self.theme = theme
        self.formatter = formatter
        self.format = nil

        self.leftAddon = leftAddon
        self.leftView = leftView
        self.rightView = rightView
        self.rightAddon = rightAddon

        self.content = {
            _FormattedTextField(
                titleKey: titleKey,
                value: value,
                formatter: formatter
            )
        }
    }

    // TODO: comment
    public init(
        _ titleKey: LocalizedStringKey,
        value: Binding<Format.FormatInput>,
        format: Format,
        theme: Theme,
        leftView: @escaping () -> LeftView = { EmptyView() },
        rightView: @escaping () -> RightView = { EmptyView() },
        leftAddon: @escaping () -> LeftAddon = { EmptyView() },
        rightAddon: @escaping () -> RightAddon = { EmptyView() }
    ) where Format : ParseableFormatStyle, Format.FormatOutput == String, Format.FormatInput == Value, Content == _FormatTextField<Value, Format> {
        self.titleKey = titleKey
        self._value = value
        self.theme = theme
        self.formatter = nil
        self.format = format

        self.leftAddon = leftAddon
        self.leftView = leftView
        self.rightView = rightView
        self.rightAddon = rightAddon

        self.content = {
            _FormatTextField(
                titleKey: titleKey,
                value: value,
                format: format
            )
        }
    }

    // MARK: - View

    public var body: some View {
        ZStack {
            self.viewModel.colors.background.color
                .accessibilityElement()
                .accessibilityLabel(self.titleKey)
//                .accessibilityValue(self.text)
                .accessibilityValue(String(describing: self.value)) // TODO: tester
                .accessibilityIdentifier(TextFieldAccessibilityIdentifier.container)
                .accessibilitySort(.textField)

            self.contentView()
                .sparkTextFieldPlaceholderColor(self.viewModel.colors.placeholder)
        }
        .scaledFrame(height: self.height)
        .allowsHitTesting(!self.isReadOnly)
        .scaledBorder(
            width: self.viewModel.borderLayout.width,
            radius: self.viewModel.borderLayout.radius,
            colorToken: self.viewModel.colors.border
        )
        .opacity(self.viewModel.dim)
        .dynamicTypeSize(...DynamicTypeSize.accessibility3)
        .accessibilityElement(children: .contain)
        .onAppear() {
            self.viewModel.updateAll(
                theme: self.theme,
                intent: self.intent,
                isReadOnly: self.isReadOnly,
                clearMode: self.clearMode,
                leftAddonConfiguration: self.leftAddonConfiguration,
                rightAddonConfiguration: self.rightAddonConfiguration,
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
        .onChange(of: self.clearMode) { clearMode in
            self.viewModel.clearMode = clearMode
        }
        .onChange(of: self.leftAddonConfiguration) { leftAddonConfiguration in
            self.viewModel.leftAddonConfiguration = leftAddonConfiguration
        }
        .onChange(of: self.rightAddonConfiguration) { rightAddonConfiguration in
            self.viewModel.rightAddonConfiguration = rightAddonConfiguration
        }
        .onChange(of: self.isFocused) { isFocused in
            self.viewModel.isFocused = isFocused
        }
        .onChange(of: self.isEnabled) { isEnabled in
            self.viewModel.isEnabled = isEnabled
        }
    }

    // MARK: - Subviews

    private func contentView() -> some View {
        HStack(spacing: .zero) {
            // Left Addon
            self.leftAddon()
                .scaledPadding(self.viewModel.leftAddonPadding)
                .layoutPriority(self.leftAddonConfiguration.layoutPriority)
                .accessibilitySort(.leftAddon)

            // Separator
            if self.leftAddonConfiguration.hasSeparator {
                self.separator()
            }

            ScaledHStack(spacing: self.viewModel.spacings.content) {
                // Left View
                self.leftView()
                    .accessibilitySort(.leftView)

                HStack(spacing: 0) {

                    HStack(spacing: 0) {
                        // TextField
                        self.content()
                            .font(self.viewModel.font)
                            .textFieldStyle(.plain)
                            .foregroundStyle(self.viewModel.colors.text)
                            .tint(self.viewModel.colors.text)
                            .focused(self.$isFocused)
                            .accessibilityHidden(true)
                            .accessibilityIdentifier(TextFieldAccessibilityIdentifier.view)

                        if self.viewModel.isClearButton {
                            TextFieldClearButton {
                                // TODO: Try
                                if var text = self.value as? String {
                                    text = ""
                                }
//                                if var text = self._value as? Binding<String> {
//                                    text = ""
//                                }
                            }
                            .accessibilitySort(.clearButton)
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .scaledPadding(.trailing, self.viewModel.contentPadding.inputTrailing)

                    // Right View
                    self.rightView()
                        .scaledPadding(.trailing, self.viewModel.contentPadding.trailing)
                        .accessibilitySort(.rightView)
                }
            }
            .scaledPadding(.top, self.viewModel.contentPadding.top)
            .scaledPadding(.bottom, self.viewModel.contentPadding.bottom)
            .scaledPadding(.leading, self.viewModel.contentPadding.leading)

            // Separator
            if self.rightAddonConfiguration.hasSeparator {
                self.separator()
            }

            // Right Addon
            self.rightAddon()
                .scaledPadding(self.viewModel.rightAddonPadding)
                .layoutPriority(self.rightAddonConfiguration.layoutPriority)
                .accessibilitySort(.rightAddon)
        }
    }

    private func prompt() -> Text {
        Text(self.titleKey).foregroundColor(self.viewModel.colors.placeholder)
    }

    private func separator() -> some View {
        Divider()
            .scaledFrame(width: self.viewModel.borderLayout.width)
            .overlay(self.viewModel.colors.border)
    }
}



// TODO: move to another class

public struct _DefaultTextField: View {

    // MARK: - Properties

    let titleKey: LocalizedStringKey
    @Binding var text: String

    @Environment(\.textFieldSecureEntry) private var isSecureEntry
    @Environment(\.textFieldPlaceholderColor) private var placeholderColor

    // MARK: - View

    public var body: some View {
        if self.isSecureEntry {
            SecureField(
                self.titleKey,
                text: self.$text,
                prompt: self.prompt()
            )
        } else {
            TextField(
                self.titleKey,
                text: self.$text,
                prompt: self.prompt()
            )
        }
    }

    // MARK: - View Builder

    private func prompt() -> Text {
        Text(self.titleKey).foregroundColor(self.placeholderColor)
    }
}

public struct _FormattedTextField<Value>: View {

    // MARK: - Properties

    let titleKey: LocalizedStringKey
    @Binding var value: Value
    let formatter: Formatter

    @Environment(\.textFieldPlaceholderColor) private var placeholderColor

    // MARK: - View

    public var body: some View {
        TextField(
            self.titleKey,
            value: self.$value,
            formatter: self.formatter,
            prompt: Text(self.titleKey)
                .foregroundColor(self.placeholderColor)
        )
    }
}

public struct _FormatTextField<Value, Format>: View where Format : ParseableFormatStyle, Format.FormatOutput == String, Format.FormatInput == Value {

    // MARK: - Properties

    let titleKey: LocalizedStringKey
    @Binding var value: Value
    let format: Format

    @Environment(\.textFieldPlaceholderColor) private var placeholderColor

    // MARK: - Initialization

    init(titleKey: LocalizedStringKey, value: Binding<Value>, format: Format) {
        self.titleKey = titleKey
        self._value = value
        self.format = format
    }

    // MARK: - View

    public var body: some View {
        TextField(
            self.titleKey,
            value: self.$value,
            format: self.format,
            prompt: Text(self.titleKey)
                .foregroundColor(self.placeholderColor)
        )
    }
}
