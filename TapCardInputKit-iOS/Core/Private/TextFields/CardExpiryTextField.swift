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
        } else if updatedText.count < 3 {
            if let nonNullMonth = formatMonthPart(with: updatedText,addSlash: true) {
                textField.text = "\(nonNullMonth)"
            }
        }else if updatedText.count > 2 {
            textField.text = updatedText
        }
        return false
    }
    
    internal func changeText(with month:String?, year:String?) {
        
        if let nonNullMonth = formatMonthPart(with: month),
            let nonNullYear = formatYearPart(with: year) {
            self.text = "\(nonNullMonth)/\(nonNullYear)"
        }
        self.textColor = (self.isValid()) ? normalTextColor : errorTextColor
    }
    
    
    internal func formatMonthPart(with month:String?, addSlash:Bool = false) -> String? {
        var formattedMonth:String? = nil
        if let nonNullMonth = month{
            
            if nonNullMonth.count == 1 {
                if nonNullMonth > "1" {
                    formattedMonth = "0\(nonNullMonth)\((addSlash) ? "/" : "")"
                }else{
                    formattedMonth = "\(nonNullMonth)"
                }
            }else if nonNullMonth.count == 2 { //Prevent user to not enter month more than 12
                if nonNullMonth <= "12" {
                    formattedMonth = "\(nonNullMonth)\((addSlash) ? "/" : "")"
                }
            }
        }
        
        return formattedMonth
    }
    
    
    internal func formatYearPart(with year:String?) -> String? {
        if let nonNullYear = year {
            if nonNullYear.count == 2 {
                return nonNullYear
            }else if nonNullYear.count == 4 {
                return nonNullYear.substring(from: 3)
            }
        }
        return nil
    }
}

