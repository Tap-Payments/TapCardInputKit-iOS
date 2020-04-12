//
//  CardNumberTextField.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 08/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

class CardNameTextField:TapCardTextField {
    
    func setup(with minVisibleChars: Int = 4, maxVisibleChars: Int = 16, placeholder:String = "",editingStatusChanged: ((Bool) -> ())? = nil) {
        
        self.minVisibleChars = minVisibleChars
        self.maxVisibleChars = maxVisibleChars
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: placeHolderTextColor])
        self.keyboardType = .default
        self.fillBiggestAvailableSpace = true
        
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


extension CardNameTextField: CardInputTextFieldProtocol {
    
    func textFieldStatus(cardNumber:String? = nil) -> CrardInputTextFieldStatusEnum {
         if let text = self.text {
             if text.alphabetOnly() == text.lowercased() {
                 return .Valid
             }
         }
         return .Invalid
     }
     
     func calculatedWidth() -> CGFloat {
         
         return self.textWidth(textfield:self, text: generateFillingValueForWidth(with: (self.isEditing) ? maxVisibleChars : minVisibleChars))
     }
    
    func isValid(cardNumber:String? = nil) -> Bool {
        
        return textFieldStatus() == .Valid
     }
}

extension CardNameTextField:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let nonNullEditingBlock = editingStatusChanged {
            nonNullEditingBlock(true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if let nonNullEditingBlock = editingStatusChanged {
            nonNullEditingBlock(false)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        // add their new text to the existing text
        let updatedText:String = currentText.replacingCharacters(in: stringRange, with: string)
        self.textColor = (self.isValid()) ? normalTextColor : errorTextColor
        return updatedText.alphabetOnly() == updatedText.lowercased()
    }
}
