//
//  CardExpiryTextField.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 08/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

class CardCVVTextField:TapCardTextField {
    
    var cvvLength:Int = 3
    
    func setup(with minVisibleChars: Int = 3, maxVisibleChars: Int = 3, placeholder:String = "", editingStatusChanged: ((Bool) -> ())? = nil) {

        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: placeHolderTextColor])
        
        self.keyboardType = .phonePad
        self.minVisibleChars = minVisibleChars
        self.maxVisibleChars = maxVisibleChars
        
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
    
    func textFieldStatus() -> CrardInputTextFieldStatusEnum {
        
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
    
    func isValid() -> Bool {
        
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

        if updatedText.count > cvvLength {
            return false
        }
       return true
    }
}

