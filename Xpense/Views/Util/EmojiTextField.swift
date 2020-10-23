//
//  EmojiTextField.swift
//  Xpense
//
//  Created by Teddy Santya on 22/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

enum EmojiKeyboardNotification: String {
    case show = "SHOW_EMOJI_KEYBOARD"
    case hide = "HIDE_EMOJI_KEYBOARD"
    case didFocus = "FOCUS_EMOJI_KEYBOARD"
}
struct EmojiTextField: View {
    @Binding var text: String
    var body: some View {
        TextFieldWrapperView(text: $text)
    }
}


struct TextFieldWrapperView: UIViewRepresentable {
    
    @Binding var text: String
    
    func makeCoordinator() -> TFCoordinator {
        TFCoordinator(self)
    }
}

extension TextFieldWrapperView {
    
    
    func makeUIView(context: UIViewRepresentableContext<TextFieldWrapperView>) -> UITextField {
        let textField = EmojiTextFieldUIKit()
        textField.delegate = context.coordinator
        textField.textAlignment = .center
        textField.autocorrectionType = .no
        var font: UIFont
        let systemFont:UIFont = .systemFont(ofSize: 100.0, weight: .bold)
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: 100)
        } else {
            font = systemFont
        }
        textField.font = font
        return textField
    }
    
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        
    }
}

class TFCoordinator: NSObject, UITextFieldDelegate {
    var parent: TextFieldWrapperView
    
    init(_ textField: TextFieldWrapperView) {
        self.parent = textField
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 2
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if (newString.length <= maxLength) {
            parent.text = (newString) as String
        }
        return newString.length <= maxLength
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        NotificationCenter.default.post(Notification(name: Notification.Name(EmojiKeyboardNotification.didFocus.rawValue)))
    }
    
    
}


class EmojiTextFieldUIKit: UITextField {
    
    // required for iOS 13
    override var textInputContextIdentifier: String? { "" } // return non-nil to show the Emoji keyboard ¯\_(ツ)_/¯
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                return mode
            }
        }
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func commonInit() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(inputModeDidChange),
                                               name: UITextInputMode.currentInputModeDidChangeNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showEmojiKeyboard),
                                               name: NSNotification.Name(EmojiKeyboardNotification.show.rawValue),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideEmojiKeyboard),
                                               name: NSNotification.Name(EmojiKeyboardNotification.hide.rawValue),
                                               object: nil)
    }
    
    @objc func inputModeDidChange(_ notification: Notification) {
        guard isFirstResponder else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.reloadInputViews()
        }
    }
    
    @objc func showEmojiKeyboard() {
        DispatchQueue.main.async { [weak self] in
            self?.reloadInputViews()
        }
        self.becomeFirstResponder()
    }
    
    @objc func hideEmojiKeyboard() {
        DispatchQueue.main.async { [weak self] in
            self?.reloadInputViews()
        }
        self.resignFirstResponder()
    }
}


struct EmojiTextField_Previews: PreviewProvider {
    @State var text: String = ""
    static var previews: some View {
        EmojiTextField(text: .init(get: { () -> String in
            return ""
        }, set: { (string) in
            
        }))
    }
}
