//
//  CardExpiryTextField.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 08/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import struct UIKit.CGFloat
import struct UIKit.CGRect
import class UIKit.UITextField
import protocol UIKit.UITextFieldDelegate

class CardCVVTextField:TapCardTextField {
    
    var cardCVVChanged: ((String) -> ())? =  nil
    
    var cvvLength:Int = 3 {
        didSet{
            if let text = self.text,
                text.count > cvvLength {
                self.text = text.substring(to: cvvLength)
            }
        }
    }
    
    func setup(with minVisibleChars: Int = 3, maxVisibleChars: Int = 3, placeholder:String = "", editingStatusChanged: ((Bool) -> ())? = nil, cardCVVChanged: ((String) -> ())? =  nil) {

        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: placeHolderTextColor])
        
        self.keyboardType = .phonePad
        self.minVisibleChars = minVisibleChars
        self.maxVisibleChars = maxVisibleChars
        self.cardCVVChanged = cardCVVChanged
        
        self.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
        
        self.editingStatusChanged = editingStatusChanged
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
}

extension CardCVVTextField:CardInputTextFieldProtocol {
    
    func calculatedWidth() -> CGFloat {
        
        return self.textWidth(textfield:self, text: generateFillingValueForWidth(with: (self.isEditing) ? maxVisibleChars : minVisibleChars))
    }
    
    func textFieldStatus(cardNumber:String? = nil) -> CrardInputTextFieldStatusEnum {
        
        guard let text:String = self.text else{ return .Invalid }
        
        if text.count < 3 {
            return .Incomplete
        }
        
        if text.count > cvvLength {
            return .Invalid
        }
        
        if text.count == cvvLength {
            return .Valid
        }
        
        return .Invalid
    }
    
    func isValid(cardNumber:String? = nil) -> Bool {
        
        return textFieldStatus() == .Valid
    }
}

extension CardCVVTextField:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let nonNullEditingBlock = editingStatusChanged {
            nonNullEditingBlock(true)
        }
        self.textColor = normalTextColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if let nonNullEditingBlock = editingStatusChanged {
            nonNullEditingBlock(false)
        }
        self.textColor = (self.isValid()) ? normalTextColor : errorTextColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       guard let currentText = textField.text as NSString? else {
           return false
       }
        
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        let _ = changeText(with: updatedText, setTextAfterValidation: true)
        return false
    }
    
    @objc func didChangeText(textField:UITextField) {
        if let nonNullBlock = cardCVVChanged {
            nonNullBlock(textField.text!.onlyDigits())
        }
    }
    
    
    internal func changeText(with updatedText:String, setTextAfterValidation:Bool = false) -> Bool {
        
        let filteredText = updatedText.onlyDigits()
        
        
        if updatedText.count > cvvLength ||  filteredText != updatedText {
            return false
        }else {
            if setTextAfterValidation {
                self.text = updatedText
            }
            didChangeText(textField: self)
            self.textColor = (self.isValid()) ? normalTextColor : errorTextColor
        }
        
        return true
    }
}

internal extension String {

    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}
