//
//  TextFieldAddonsUIView.swift
//  SparkTextField
//
//  Created by louis.borlee on 14/02/2024.
//  Copyright © 2024 Leboncoin. All rights reserved.
//

import UIKit
import Combine
@_spi(SI_SPI) import SparkCommon
import SparkTheming

/// A Spark TextField that can be surrounded by left and/or right addons
public final class TextFieldAddonsUIView: UIControl {

    // MARK: - Properties

    @ScaledUIMetric private var scaleCornerRadius: CGFloat = 0
    @ScaledUIMetric private var scaleBorderWidth: CGFloat = 0

    /// Embbeded textField
    public let textField: TextFieldUIView
    /// Current leftAddon, set using setLeftAddon(_:, _withPadding:)
    private(set) public var leftAddon: UIView?
    private var leftAddonCenterXConstraint: NSLayoutConstraint = NSLayoutConstraint()
    /// Current rightAddon, set using setRightAddon(_:, _withPadding:)
    private(set) public var rightAddon: UIView?
    private var rightAddonCenterXConstraint: NSLayoutConstraint = NSLayoutConstraint()

    private var leftAddonContainer = UIView()
    private var leftSeparatorView = UIView()
    private var leftSeparatorWidthConstraint = NSLayoutConstraint()
    private var rightAddonContainer = UIView()
    private var rightSeparatorView = UIView()
    private var rightSeparatorWidthConstraint = NSLayoutConstraint()

    private let viewModel: TextFieldAddonsViewModel
    private var cancellables = Set<AnyCancellable>()

    private var leadingConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var trailingConstraint: NSLayoutConstraint = NSLayoutConstraint()

    private lazy var stackView = UIStackView(arrangedSubviews: [
        self.leftAddonContainer,
        self.textField,
        self.rightAddonContainer
    ])

    public override var isEnabled: Bool {
        didSet {
            self.textField.isEnabled = self.isEnabled
        }
    }

    /// A boolean value indicating whether the field is in a read-only state. Default value is ``false``.
    public var isReadOnly: Bool {
        get { return self.textField.isReadOnly }
        set { self.textField.isReadOnly = newValue }
    }

    // MARK: - Initialization

    /// TextFieldAddonsUIView  initializer
    /// - Parameters:
    ///   - theme: The textfield's current theme
    ///   - intent: The textfield's current intent
    public init(
        theme: Theme,
        intent: TextInputIntent
    ) {
        let viewModel = TextFieldAddonsViewModel(
            theme: theme,
            intent: intent
        )
        self.viewModel = viewModel
        self.textField = TextFieldUIView(viewModel: viewModel.textFieldViewModel)
        self.leftAddon = nil
        self.rightAddon = nil
        super.init(frame: .init(origin: .zero, size: .init(width: 0, height: TextInputConstants.height)))
        self.textField.backgroundColor = ColorTokenDefault.clear.uiColor
        self.setupViews()
        self.subscribeToViewModel()
        self.textField.backgroundColor = .clear

        self.accessibilityContainerType = .semanticGroup
        self.accessibilityIdentifier = TextFieldAddonsAccessibilityIdentifier.view
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        self.clipsToBounds = true
        self.addSubview(self.stackView)

        self.textField.setContentHuggingPriority(.defaultLow, for: .horizontal)

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        // Adding constant padding to set borders outline instead of inline
        self.leadingConstraint = self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.scaleBorderWidth)
        self.trailingConstraint = self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.scaleBorderWidth)
        NSLayoutConstraint.activate([
            self.leadingConstraint,
            self.trailingConstraint,
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        self.setupSeparators()
        self.setLeftAddon(nil)
        self.setRightAddon(nil)
    }

    private func setupSeparators() {
        self.leftAddonContainer.addSubview(self.leftSeparatorView)
        self.leftSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        self.leftSeparatorWidthConstraint = self.leftSeparatorView.widthAnchor.constraint(equalToConstant: self.scaleBorderWidth)

        self.rightAddonContainer.addSubview(self.rightSeparatorView)
        self.rightSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        self.rightSeparatorWidthConstraint = self.rightSeparatorView.widthAnchor.constraint(equalToConstant: self.scaleBorderWidth)

        NSLayoutConstraint.activate([
            self.leftSeparatorWidthConstraint,
            self.leftSeparatorView.topAnchor.constraint(equalTo: self.leftAddonContainer.topAnchor),
            self.leftSeparatorView.bottomAnchor.constraint(equalTo: self.leftAddonContainer.bottomAnchor),
            self.leftSeparatorView.trailingAnchor.constraint(equalTo: self.leftAddonContainer.trailingAnchor),

            self.rightSeparatorWidthConstraint,
            self.rightSeparatorView.topAnchor.constraint(equalTo: self.rightAddonContainer.topAnchor),
            self.rightSeparatorView.bottomAnchor.constraint(equalTo: self.rightAddonContainer.bottomAnchor),
            self.rightSeparatorView.leadingAnchor.constraint(equalTo: self.rightAddonContainer.leadingAnchor)
        ])
    }

    private func subscribeToViewModel() {
        self.viewModel.$backgroundColor.removeDuplicates(by: { lhs, rhs in
            lhs.equals(rhs)
        })
        .subscribe(in: &self.cancellables) { [weak self] backgroundColor in
            guard let self else { return }
            self.backgroundColor = backgroundColor.uiColor
        }

        self.viewModel.textFieldViewModel.$borderColor.removeDuplicates(by: { lhs, rhs in
            lhs.equals(rhs)
        })
        .subscribe(in: &self.cancellables) { [weak self] borderColor in
            guard let self else { return }
            self.setBorderColor(from: borderColor)
            self.leftSeparatorView.backgroundColor = borderColor.uiColor
            self.rightSeparatorView.backgroundColor = borderColor.uiColor
        }

        self.viewModel.$borderWidth.removeDuplicates().subscribe(in: &self.cancellables) { [weak self] borderWidth in
            guard let self else { return }

            self.scaleBorderWidth = borderWidth
            self._scaleBorderWidth.update(traitCollection: self.traitCollection)

            self.setBorderWidthAndRefreshAddonsXCenter(self.scaleBorderWidth)
            self.setLeftSpacing(self.viewModel.leftSpacing, borderWidth: self.scaleBorderWidth)
            self.setRightSpacing(self.viewModel.rightSpacing, borderWidth: self.scaleBorderWidth)
            self.leftSeparatorWidthConstraint.constant = self.scaleBorderWidth
            self.rightSeparatorWidthConstraint.constant = self.scaleBorderWidth
        }

        self.viewModel.$borderRadius.removeDuplicates().subscribe(in: &self.cancellables) { [weak self] borderRadius in
            guard let self else { return }

            self.scaleCornerRadius = borderRadius
            self._scaleCornerRadius.update(traitCollection: self.traitCollection)

            self.setCornerRadius(self.scaleCornerRadius)
        }

        self.viewModel.$leftSpacing.removeDuplicates().subscribe(in: &self.cancellables) { [weak self] leftSpacing in
            guard let self else { return }
            self.setLeftSpacing(leftSpacing, borderWidth: self.scaleBorderWidth)
            self.setNeedsLayout()
        }

        self.viewModel.$rightSpacing.removeDuplicates().subscribe(in: &self.cancellables) { [weak self] rightSpacing in
            guard let self else { return }
            self.setRightSpacing(rightSpacing, borderWidth: self.scaleBorderWidth)
            self.setNeedsLayout()
        }

        self.viewModel.$contentSpacing.removeDuplicates().subscribe(in: &self.cancellables) { [weak self] contentSpacing in
            guard let self else { return }
            self.stackView.spacing = contentSpacing
            self.setNeedsLayout()
        }

        self.viewModel.$dim.removeDuplicates().subscribe(in: &self.cancellables) { [weak self] dim in
            guard let self else { return }
            self.alpha = dim
            self.setNeedsLayout()
        }
    }

    // MARK: - Setter

    private func setLeftSpacing(_ leftSpacing: CGFloat, borderWidth: CGFloat) {
        self.leadingConstraint.constant = (self.leftAddonContainer.isHidden ? leftSpacing : .zero) + borderWidth
    }

    private func setRightSpacing(_ rightSpacing: CGFloat, borderWidth: CGFloat) {
        self.trailingConstraint.constant = (self.rightAddonContainer.isHidden ? -rightSpacing : .zero) - borderWidth
    }

    private func setBorderWidthAndRefreshAddonsXCenter(_ borderWidth: CGFloat) {
        self.setBorderWidth(borderWidth)
        self.setLeftAddonCenterXConstant(borderWidth: borderWidth)
        self.setRightAddonCenterXConstant(borderWidth: borderWidth)
    }

    private func setLeftAddonCenterXConstant(borderWidth: CGFloat) {
        self.leftAddonCenterXConstraint.constant = -borderWidth / 2.0
    }

    private func setRightAddonCenterXConstant(borderWidth: CGFloat) {
        self.rightAddonCenterXConstraint.constant = borderWidth / 2.0
    }

    /// Set the textfield's left addon
    /// - Parameters:
    ///   - leftAddon: the view to be set as leftAddon
    ///   - withPadding: adds a padding on the addon if `true`, default is `false`
    public func setLeftAddon(_ leftAddon: UIView?, withPadding: Bool = false) {
        if let oldValue = self.leftAddon, oldValue.isDescendant(of: self.leftAddonContainer) {
            oldValue.removeConstraint(self.leftSeparatorWidthConstraint)
            oldValue.removeFromSuperview()
        }
        if let leftAddon {
            self.leftAddonContainer.addSubview(leftAddon)
            leftAddon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            leftAddon.translatesAutoresizingMaskIntoConstraints = false
            self.leftAddonCenterXConstraint = leftAddon.centerXAnchor.constraint(equalTo: self.leftAddonContainer.centerXAnchor)
            NSLayoutConstraint.activate([
                leftAddon.trailingAnchor.constraint(equalTo: self.leftSeparatorView.leadingAnchor, constant: withPadding ? -self.viewModel.leftSpacing : 0),
                self.leftAddonCenterXConstraint,
                leftAddon.centerYAnchor.constraint(equalTo: self.leftAddonContainer.centerYAnchor)
            ])
        }
        self.leftAddon = leftAddon
        self.leftAddonContainer.isHidden = self.leftAddon == nil
        self.setLeftAddonCenterXConstant(borderWidth: self.scaleBorderWidth)
        self.setLeftSpacing(self.viewModel.leftSpacing, borderWidth: self.scaleBorderWidth)
    }

    /// Set the textfield's right addon
    /// - Parameters:
    ///   - rightAddon: the view to be set as rightAddon
    ///   - withPadding: adds a padding on the addon if `true`, default is `false`
    public func setRightAddon(_ rightAddon: UIView? = nil, withPadding: Bool = false) {
        if let oldValue = self.rightAddon, oldValue.isDescendant(of: self.rightAddonContainer) {
            oldValue.removeConstraint(self.rightAddonCenterXConstraint)
            oldValue.removeFromSuperview()
        }
        if let rightAddon {
            self.rightAddonContainer.addSubview(rightAddon)
            rightAddon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            rightAddon.translatesAutoresizingMaskIntoConstraints = false
            self.rightAddonCenterXConstraint = rightAddon.centerXAnchor.constraint(equalTo: self.rightAddonContainer.centerXAnchor)
            NSLayoutConstraint.activate([
                rightAddon.leadingAnchor.constraint(equalTo: self.rightSeparatorView.trailingAnchor, constant: withPadding ? self.viewModel.rightSpacing : 0),
                self.rightAddonCenterXConstraint,
                rightAddon.centerYAnchor.constraint(equalTo: self.rightAddonContainer.centerYAnchor)
            ])
        }
        self.rightAddon = rightAddon
        self.rightAddonContainer.isHidden = self.rightAddon == nil
        self.setRightAddonCenterXConstant(borderWidth: self.scaleBorderWidth)
        self.setRightSpacing(self.viewModel.rightSpacing, borderWidth: self.scaleBorderWidth)
    }

    // MARK: - Trait Collection

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.setBorderColor(from: self.viewModel.textFieldViewModel.borderColor)
        }

        guard previousTraitCollection?.preferredContentSizeCategory != self.traitCollection.preferredContentSizeCategory else { return }

        self._scaleCornerRadius.update(traitCollection: self.traitCollection)
        self._scaleBorderWidth.update(traitCollection: self.traitCollection)

        self.setCornerRadius(self.scaleCornerRadius)
        self.setBorderWidthAndRefreshAddonsXCenter(self.scaleBorderWidth)
        self.setLeftSpacing(self.viewModel.leftSpacing, borderWidth: self.scaleBorderWidth)
        self.setRightSpacing(self.viewModel.rightSpacing, borderWidth: self.scaleBorderWidth)
        self.leftSeparatorWidthConstraint.constant = self.scaleBorderWidth
        self.rightSeparatorWidthConstraint.constant = self.scaleBorderWidth
        self.invalidateIntrinsicContentSize()
    }
}
