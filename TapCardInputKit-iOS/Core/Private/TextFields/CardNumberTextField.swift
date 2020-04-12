//
//  CardNumberTextField.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 08/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapCardValidator

class CardNumberTextField:TapCardTextField {
   
    var cardBrandDetected: ((CardBrand?) -> ())? =  nil
    
    
    func setup(with minVisibleChars: Int = 4, maxVisibleChars: Int = 16, placeholder:String = "", editingStatusChanged: ((Bool) -> ())? = nil,cardBrandDetected: ((CardBrand?) -> ())? =  nil) {
        
        self.minVisibleChars = minVisibleChars
        self.maxVisibleChars = maxVisibleChars
        self.fillBiggestAvailableSpace = true
        
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: placeHolderTextColor])
 
        self.keyboardType = .phonePad
        
        self.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)

        self.editingStatusChanged = editingStatusChanged
        self.cardBrandDetected = cardBrandDetected
        
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
}


extension CardNumberTextField:CardInputTextFieldProtocol {
    
    func calculatedWidth() -> CGFloat {
        
        return self.textWidth(textfield:self, text: generateFillingValueForWidth(with: (self.isEditing) ? maxVisibleChars : minVisibleChars))
    }
    
    func textFieldStatus(cardNumber:String? = nil) -> CrardInputTextFieldStatusEnum {
        var nonNullCardNumber =  self.text?.onlyDigits() ?? ""
        if let _ = cardNumber {
            nonNullCardNumber = cardNumber!
        }
        let validationState = CardValidator.validate(cardNumber: nonNullCardNumber).validationState
        switch validationState {
            case .incomplete:
                return .Incomplete
            case .invalid:
                return .Invalid
            case .valid:
                return .Valid
        }
    }
    
    func isValid(cardNumber:String? = nil) -> Bool {
        
        return textFieldStatus(cardNumber:cardNumber) == .Valid
    }
}

extension CardNumberTextField:UITextFieldDelegate {
    
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
        let filteredText:String = updatedText.digitsWithSpaces()
        let validation = CardValidator.validate(cardNumber: filteredText.onlyDigits())
        self.textColor = errorTextColor
        
        if let nonNullCardBrandBlock = cardBrandDetected {
            nonNullCardBrandBlock(validation.cardBrand)
            self.textColor = (validation.validationState == .valid) ? normalTextColor : errorTextColor
        }
        
        return updatedText == filteredText && validation.validationState != .invalid
    }
    
    @objc func didChangeText(textField:UITextField) {
        textField.text = textField.text!.modifyCreditCardString()
    }
}


extension CardBrand {
    
    
    func cardImageName() -> String {
        
        switch self {
        case .visa,.visaElectron:
            return "visa"
        case .americanExpress:
            return "american-express"
        case .discover:
            return "discover"
        case .dinersClub:
            return "diners-club"
        case .jcb:
            return "jcb"
        case .masterCard,.maestro:
            return "mastercard"
        case .unionPay:
            return "unionpay"
        default:
            return "bank"
        }
    }
}
