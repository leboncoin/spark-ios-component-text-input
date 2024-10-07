//
//  TextEditor.swift
//  SparkEditor
//
//  Created by robin.lemaire on 05/09/2024.
//  Copyright © 2024 Adevinta. All rights reserved.
//

import SwiftUI
import SparkTheming

@available(iOS 16.0, *)
/// The SwiftUI version for the text editor.
public struct TextEditorView: View {

    // MARK: - Properties

    private let title: String

    @Binding private var text: String

    @ScaledMetric private var minHeight: CGFloat = TextInputConstants.height
    @ScaledMetric private var scaleFactor: CGFloat = 1.0

    @FocusState private var focused: FocusedType?

    @ObservedObject private var viewModel: TextEditorViewModel

    // MARK: - Initialization

    /// TextEditorView initializer
    /// - Parameters:
    ///   - title: The texteditor's current placeholder
    ///   - text: The texteditor's text binding
    ///   - theme: The texteditor's current theme
    ///   - intent: The texteditor's current intent
    public init(
        _ title: String,
        text: Binding<String>,
        theme: any Theme,
        intent: TextEditorIntent
    ) {
        self.init(
            title: title,
            text: text,
            viewModel: .init(theme: theme, intent: intent)
        )
    }

    private init(
        title: String,
        text: Binding<String>,
        viewModel: TextEditorViewModel
    ) {
        self.title = title
        self._text = text
        self.viewModel = viewModel
    }

    // MARK: - View

    public var body: some View {
        VStack(alignment: .leading) {
            SwiftUI.TextField(
                self.title,
                text: self.$text,
                axis: .vertical
            )
            .font(self.viewModel.font.font)
            .foregroundStyle(self.viewModel.textColor.color)
            .tint(self.viewModel.textColor.color)
            .scrollContentBackground(.hidden)

            Spacer(minLength: 0)
        }
        .padding(.leading, self.viewModel.leftSpacing)
        .padding(.trailing, self.viewModel.rightSpacing)
        .verticalPadding(from: self.viewModel, height: self.minHeight)
        .background(self.viewModel.backgroundColor.color)
        .border(
            width: self.viewModel.borderWidth * self.scaleFactor,
            radius: self.viewModel.borderRadius * self.scaleFactor,
            colorToken: self.viewModel.borderColor
        )
        .opacity(self.viewModel.dim)
        .disabled(!self.viewModel.isEnabled)
        .allowsHitTesting(self.viewModel.isEnabled)
        .focused(self.$focused, equals: .text)
        .accessibilityElement()
        .accessibilityIdentifier(TextEditorAccessibilityIdentifier.view)
        .accessibilityLabel(self.title)
        .accessibilityValue(self.text)
        .onChange(of: self.focused) { type in
            self.viewModel.isFocused = type == .text
        }
        .onTapGesture {
            if !self.viewModel.isReadOnly {
                self.focused = .text
            }
        }
    }

    // MARK: - Modifier

    /// Set the textEditor to disabled.
    /// - Parameters:
    ///   - text: The textEditor is disabled or not.
    /// - Returns: Current TextEditor View.
    public func disabled(_ isDisabled: Bool) -> Self {
        self.viewModel.isEnabled = !isDisabled

        return self
    }
}

// MARK: - Extension

private extension View {

    func verticalPadding(from viewModel: TextEditorViewModel, height: CGFloat) -> some View {
        self.padding(.vertical, viewModel.getVerticalSpacing(from: height))
    }
}

// MARK: - Focus

fileprivate enum FocusedType: Hashable {
    case text
}
