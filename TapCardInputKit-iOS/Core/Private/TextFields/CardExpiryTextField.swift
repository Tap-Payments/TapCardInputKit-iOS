//
//  CardExpiryTextField.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 08/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

class CardExpiryTextField:TapCardTextField {
    
    
    func setup(with minVisibleChars: Int = 5, maxVisibleChars: Int = 5, placeholder:String = "", editingStatusChanged: ((Bool) -> ())? = nil) {
        
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

extension CardExpiryTextField:CardInputTextFieldProtocol {
    
    func calculatedWidth() -> CGFloat {
        
        return self.textWidth(textfield:self, text: generateFillingValueForWidth(with: (self.isEditing) ? maxVisibleChars : minVisibleChars))
    }
    
    func textFieldStatus(cardNumber:String? = nil) -> CrardInputTextFieldStatusEnum {
        
        let currentYear = Calendar.current.component(.year, from: Date()) % 100   // This will give you current year (i.e. if 2019 then it will be 19)
        let currentMonth = Calendar.current.component(.month, from: Date()) // This will give you current month (i.e if June then it will be 6)
        
        guard let text:String = self.text else{ return .Invalid }
        
        let enteredYear = Int(text.suffix(2)) ?? 0 // get last two digit from entered string as year
        let enteredMonth = Int(text.prefix(2)) ?? 0 // get first two digit from entered string as month

        if enteredYear > currentYear {
            if !(1 ... 12).contains(enteredMonth) {
                return .Invalid
            }
        } else if currentYear == enteredYear {
            if enteredMonth >= currentMonth {
                if !(1 ... 12).contains(enteredMonth) {
                  return .Invalid
                }
            } else {
                return .Invalid
            }
        } else {
           return .Invalid
        }
        return .Valid
    }
    
    func isValid(cardNumber:String? = nil) -> Bool {
        
        return textFieldStatus() == .Valid
    }
}

extension CardExpiryTextField:UITextFieldDelegate {
    
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

       if string == "" {
        if currentText.length == 3 {
               textField.text = "\(updatedText.prefix(1))"
               return false
           }
           return true
       } else if updatedText.count == 5 {
           return true
       } else if updatedText.count > 5 {

           return false
       } else if updatedText.count == 1 {

           if updatedText > "1" {
            textField.text = "0\(updatedText)/"
               return false
           }
       } else if updatedText.count == 2 { //Prevent user to not enter month more than 12
           if updatedText > "12" {
               return false
           }
       }
       if updatedText.count == 2 {
           textField.text = "\(updatedText)/" //This will add "/" when user enters 2nd digit of month
       } else {
           textField.text = updatedText
       }
       return false
    }
}

