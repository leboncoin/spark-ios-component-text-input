# Introduction

This repository contains two close components: TextField & TextEditor.

# TextField & TextFieldAddons

The TextField component allows users to write in the space provided for the content.  
It has optional embedded left and right views.

The TextFieldAddons adds a left and right addons management on top of the TextField.

At most you could have
`[Left Addon, [Left View, TextField, Right View], Right Addon]`

## Specifications

The TextField specifications on Zeroheight are [here](https://zeroheight.com/1186e1705/v/latest/p/773c60-input--text-field).

![Figma anatomy](https://github.com/adevinta/spark-ios-component-text-input/blob/main/.github/assets/anatomy-textfield.png)

## UIKit

### `TextFieldUIView`

`TextFieldUIView` is a subclass of the native `UITextField` so you can use it as usual.

To access left and right views, use

```swift
    var leftView: UIView? { get set }
    var rightView: UIView? { get set }
```

Do note that when setting left and/or right views, the TextField needs to be refreshed (as it is for UITextField)

### `TextFieldAddonsUIView`

`TextFieldAddonsUIView` is a `UIControl` that embbeds a `TextFieldUIView` inbetween a `leftAddon: UIView?` and a `rightAddon: UIView?`.

To access left and right addons, use

```swift
    var leftAddon: UIView? { get }
    var rightAddon: UIView? { get }

    func setLeftAddon(_ leftAddon: UIView?, withPadding: Bool) {}
    func setRightAddon(_ leftAddon: UIView?, withPadding: Bool) {}
```

## SwiftUI

### `TextFieldView`

`TextFieldView` emulates the equivalent of `TextFieldUIView` in SwiftUI with a leftView and a rightView.

To set these views, `TextFieldView` has two parameters with generic types `LeftView` and `RightView`. Default values are `EmptyView()`.

```swift
public struct TextFieldView<LeftView: View, RightView: View>: View

/// TextFieldView initializer
/// - Parameters:
///   - titleKey: The textfield's current placeholder
///   - text: The textfield's text binding
///   - theme: The textfield's current theme
///   - intent: The textfield's current intent
///   - type: The type of field with its associated callback(s), default is `.standard()`
///   - isReadOnly: Set this to true if you want the textfield to be readOnly, default is `false`
///   - leftView: The TextField's left view, default is `EmptyView`
///   - rightView: The TextField's right view, default is `EmptyView`
public init(_ titleKey: LocalizedStringKey,
            text: Binding<String>,
            theme: Theme,
            intent: TextInputIntent,
            type: TextFieldViewType,
            isReadOnly: Bool = false,
            leftView: @escaping () -> LeftView,
            rightView: @escaping () -> RightView
)
```

To handle the fallbacks, there is a `type: TextFieldViewType` variable in the initializer.

```swift
/// A TextField type with its associated callback(s)
public enum TextFieldViewType {
    case secure(onCommit: () -> Void = {})
    case standard(onEditingChanged: (Bool) -> Void = { _ in }, onCommit: () -> Void = {})
}
```

### `TextFieldAddon`

`TextFieldAddon` is a view containing a user-defined content. It allows padding and layout priority management.

```swift
public struct TextFieldAddon<Content: View>: View

/// TextFieldAddon initializer
/// - Parameters:
///   - withPadding: Add addon padding if `true`, default is `false`
///   - layoutPriority: Set addon .layoutPriority(), default is `1.0`
///   - content: Addon's content View
public init(
        withPadding: Bool,
        layoutPriority: Double,
        content: @escaping () -> Content
)
```

### `TextFieldAddons`

`TextFieldAddons` is a view containing a TextField and optionals left and right addons.

To set these addons, use the `leftAddon` and `rightAddon` parameters in the initializer.

```swift
public struct TextFieldAddons<LeftView: View, RightView: View, LeftAddon: View, RightAddon: View>: View

/// TextFieldAddons initializer
/// - Parameters:
///   - titleKey: The textfield's current placeholder
///   - text: The textfield's text binding
///   - theme: The textfield's current theme
///   - intent: The textfield's current intent
///   - type: The type of field with its associated callback(s), default is `.standard()`
///   - isReadOnly: Set this to true if you want the textfield to be readOnly, default is `false`
///   - leftView: The TextField's left view, default is `EmptyView`
///   - rightView: The TextField's right view, default is `EmptyView`
///   - leftAddon: The TextField's left addon, default is `EmptyView`
///   - rightAddon: The TextField's right addon, default is `EmptyView`
public init(
    _ titleKey: LocalizedStringKey,
    text: Binding<String>,
    theme: Theme,
    intent: TextInputIntent,
    type: TextFieldViewType,
    isReadOnly: Bool,
    leftView: @escaping (() -> LeftView),
    rightView: @escaping (() -> RightView),
    leftAddon: @escaping (() -> TextFieldAddon<LeftAddon>),
    rightAddon: @escaping (() -> TextFieldAddon<RightAddon>)
)
```

## Properties

- `theme`: The textfield's current theme
- `intent`: The textfield's current intent

# TextEditor

A text area lets users enter long form text which spans over multiple lines.

## Specifications

The TextEditor specifications on Zeroheight is [here](https://spark.adevinta.com/1186e1705/p/365c2e-text-area--text-view).

![Figma anatomy](https://github.com/adevinta/spark-ios-component-text-input/blob/main/.github/assets/anatomy-textview.png)

## Usage

TextEditor is available in UIKit.

### TextEditorUIView

### Usage

The TextEditorUIView inherits from **UITextView**.

So all **public variables, functions and delegate** in the UITextView are also available in the TextEditorUIView.
Read the Apple documentation [here](https://developer.apple.com/documentation/uikit/uitextview) to see more information.

**Note**: You can use TextEditor with Formfield to support title, helper message and the text counter.

#### Properties

- `theme`: The current Spark-Theme. [You can always define your own theme.](https://github.com/adevinta/spark-ios/wiki/Theming#your-own-theming)
- `intent`: The intent of the TextEditor, e.g. neutral, success
- `placeholder`: The placeholder of the TextEditor.
- `isEnabled`: The status of the TextEditor. Default value is 'true'. If the value is `false`, no interaction is available.

#### Init

```swift
let textEditor = TextEditorUIView(
    theme: MyTheme(),
    intent: .neutral
)
view.addSubview(textEditor)
```

## License

```
MIT License

Copyright (c) 2024 Adevinta

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
