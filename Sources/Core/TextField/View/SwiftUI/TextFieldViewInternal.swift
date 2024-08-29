//
//  TextFieldViewInternal.swift
//  SparkTextField
//
//  Created by louis.borlee on 18/04/2024.
//  Copyright © 2024 Adevinta. All rights reserved.
//

import SwiftUI
@_spi(SI_SPI) import SparkCommon
import SparkTheming

struct TextFieldViewInternal<LeftView: View, RightView: View>: View {

    // MARK: - Properties

    @ScaledMetric private var height: CGFloat = 44
    @ScaledMetric private var scaleFactor: CGFloat = 1.0

    @ObservedObject private var viewModel: TextInputViewModel
    @Binding private var text: String

    private let titleKey: LocalizedStringKey
    private var type: TextFieldViewType

    private let leftView: () -> LeftView
    private let rightView: () -> RightView

    // MARK: - Initialization

    init(titleKey: LocalizedStringKey,
         text: Binding<String>,
         viewModel: TextInputViewModel,
         type: TextFieldViewType,
         leftView: @escaping (() -> LeftView),
         rightView: @escaping (() -> RightView)) {
        self.titleKey = titleKey
        self._text = text
        self.viewModel = viewModel
        self.type = type
        self.leftView = leftView
        self.rightView = rightView
    }

    // MARK: - View

    var body: some View {
        ZStack {
            self.viewModel.backgroundColor.color
            contentView()
        }
        .tint(self.viewModel.textColor.color)
        .allowsHitTesting(self.viewModel.isUserInteractionEnabled)
        .border(
            width: self.viewModel.borderWidth * self.scaleFactor,
            radius: self.viewModel.borderRadius * self.scaleFactor,
            colorToken: self.viewModel.borderColor
        )
        .frame(height: self.height)
        .opacity(self.viewModel.dim)
    }

    // MARK: - ViewBuilder

    @ViewBuilder
    private func contentView() -> some View {
        HStack(spacing: self.viewModel.contentSpacing) {
            leftView()
            textField()
            rightView()
        }
        .padding(EdgeInsets(top: .zero, leading: self.viewModel.leftSpacing, bottom: .zero, trailing: self.viewModel.rightSpacing))
    }

    @ViewBuilder
    private func textField() -> some View {
        Group {
            switch type {
            case .secure(let onCommit):
                SecureField(titleKey, text: $text, onCommit: onCommit)
                    .font(self.viewModel.font.font)
            case .standard(let onEditingChanged, let onCommit):
                TextField(titleKey, text: $text, onEditingChanged: onEditingChanged, onCommit: onCommit)
                    .font(self.viewModel.font.font)
            }
        }
        .textFieldStyle(.plain)
        .foregroundStyle(self.viewModel.textColor.color)
        .accessibilityIdentifier(TextFieldAccessibilityIdentifier.view)
    }

    // MARK: - Update

    func update(isEnabled: Bool, isFocused: Bool) -> some View {
        DispatchQueue.main.async {
            self.viewModel.isEnabled = isEnabled
            self.viewModel.isFocused = isFocused
        }
        return self
    }
}
