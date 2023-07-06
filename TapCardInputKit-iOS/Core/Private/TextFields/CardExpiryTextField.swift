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

/// Represnts the card expiry text field
class CardExpiryTextField:TapCardTextField {
    
    /// This is the block that will fire an event when a the card exxpiry has changed by passing back the month and the year
    var cardExpiryChanged: ((String,String) -> ())? =  nil
    
    /**
     Method that is used to setup the field by providing the needed info and the obersvers for the events
     - Parameter minVisibleChars: Number of mimum charachters to be visible when the field is inactive, in Inline mode. Default is 5
     - Parameter maxVisibleChars: Number of maximum charachters to be visible when the field is inactive, in Inline mode. Default is 5
     - Parameter placeholder: The placeholder to show in this field. Default is ""
     - Parameter editingStatusChanged: Observer to listen to the event when the editing status changed, whether started or ended editing
     - Parameter cardExpiryChanged: Observer to listen to the event when a the card exxpiry is changed by user input till the moment
     */
    func setup(with minVisibleChars: Int = 5, maxVisibleChars: Int = 5, placeholder:String = "", editingStatusChanged: ((Bool) -> ())? = nil, cardExpiryChanged: ((String,String) -> ())? =  nil) {
        
        // Set the place holder with the theme color
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: placeHolderTextColor])
        
        // Card expiry should have a numeric pad
        self.keyboardType = .phonePad
        
        // Assign and save the passed attributes
        self.minVisibleChars = max(placeholder.count, minVisibleChars, maxVisibleChars)
        self.maxVisibleChars = max(placeholder.count, minVisibleChars, maxVisibleChars)
        self.cardExpiryChanged = cardExpiryChanged
        
        // Listen to the event of text change
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

extension CardExpiryTextField:CardInputTextFieldProtocol {
    
    func canShowHint()->Bool {
        return isEditing && text?.count == 5
    }
    
    func calculatedWidth() -> CGFloat {
        // Calculate the width of the field based on it is active status, if it is activbe we calculaye the width needed to show the max visible charachters and if it is inactive we calculate width based on minimum visible characters
        return self.textWidth(textfield:self, text: generateFillingValueForWidth(with: self.isEditing ? maxVisibleChars : minVisibleChars))
    }
    
    func textFieldStatus(cardNumber:String? = nil) -> CrardInputTextFieldStatusEnum {
        // The expiry field is considered valid only if it provides a valid month and year that are AFTER the current date
        
        let currentYear = Calendar.current.component(.year, from: Date()) % 100   // This will give you current year (i.e. if 2019 then it will be 19)
        let currentMonth = Calendar.current.component(.month, from: Date()) // This will give you current month (i.e if June then it will be 6)
        
        // Check if we can get the field text and return invlalid otherwise
        guard let text:String = self.text else{ return .Invalid }
        
        let enteredYear = Int(text.suffix(2)) ?? 0 // get last two digit from entered string as year
        let enteredMonth = Int(text.prefix(2)) ?? 0 // get first two digit from entered string as month
        
        if enteredYear > currentYear {
            if !(1 ... 12).contains(enteredMonth) {
                // This means the user entered number bigger than 12 or lower than 1 for the month number, hence it is invalid
                return .Invalid
            }
        } else if currentYear == enteredYear {
            if enteredMonth >= currentMonth {
                if !(1 ... 12).contains(enteredMonth) {
                    // This means the user entered number bigger than 12 or lower than 1 for the month number, hence it is invalid
                    return .Invalid
                }
            } else {
                // This means the user entered same year as the current one, but entered a month that is earlier the current one, hence it is invalid
                return .Invalid
            }
        } else {
            // This means the user entered a year before the current year, hence it is invalid
            return .Invalid
        }
        // All good!
        return .Valid
    }
    
    func isValid(cardNumber:String? = nil) -> Bool {
        
        return textFieldStatus() == .Valid
    }
    
    
    /**
     This method does the logic required when a text change event is fired for the text field
     - Parameter textField: The text field that has its text changed
     */
    @objc func didChangeText(textField:UITextField) {
        textField.text = String((self.text ?? "").prefix(5))
        if self.isValid(), let nonNullBlock = cardExpiryChanged {
            // If the text input by the user is valid and exxpiry changed block is assigned, we need to fire this event by passing back the entered month and year
            nonNullBlock(textField.text!.substring(to: 2),textField.text!.substring(from: 3).substring(to: 2))
        }
        if let nonNullTextChangeBlock = textChanged {
            nonNullTextChangeBlock(String((self.text ?? "").prefix(5)))
        }
    }
}

extension CardExpiryTextField:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // If the editing changed block is assigned, we need to fire this event as the editing now started for the field
        if let nonNullEditingBlock = editingStatusChanged {
            nonNullEditingBlock(true)
        }
        print("Expiry # TRUE")
        self.textColor = normalTextColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if let nonNullEditingBlock = editingStatusChanged {
            // If the editing changed block is assigned, we need to fire this event as the editing now ended for the field
            nonNullEditingBlock(false)
        }
        print("Expiry # FALSE")
        // When editing the field is done, we need to decide which tetx color shall we show based on the validity of the user's input
        self.textColor = (self.isValid()) ? normalTextColor : errorTextColor
        
        if self.isValid(), let nonNullBlock = cardExpiryChanged {
            // If the text input by the user is valid and exxpiry changed block is assigned, we need to fire this event by passing back the entered month and year
            nonNullBlock(textField.text!.substring(to: 2),textField.text!.substring(from: 3).substring(to: 2))
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // attempt to read the range they are trying to change, or exit if we can't
        // Also check it is only digits
        guard let currentText = textField.text as NSString?,
              string.onlyDigits() == string else {
            return false
        }
        // add the new text to the existing text
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        
        if string == "" {
            // This means we are not adding or changing any text
            if currentText.length == 3 {
                textField.text = "\(updatedText.prefix(1))"
                return false
            }
            return true
        } else if updatedText.count == 5 {
            // If the text is already has length of 5 MM/YY then e will not do anything, as it should be validated through the process until it reaches here
            textField.text = updatedText
            //resignFirstResponder()
            return true
        } else if updatedText.count > 5 {
            // we will not allow entering more than 5 charachters MM/YY
            return false
        } else if updatedText.count < 3 {
            // If the text is still less than 3 then the user is still in the month part, hence, we need to format it so if he entered 5 it converts to 05 then we assign it to the field
            if let nonNullMonth = formatMonthPart(with: updatedText,addSlash: true) {
                textField.text = "\(nonNullMonth)"
            }
        }else if updatedText.count > 2 {
            // If length is greater than 2, then user is entering the year now
            textField.text = updatedText
        }
        return false
    }
    
    /**
     This method does the logic required to check if a given text is allowed to be written to the card expiry field or not
     - Parameter month: The month part of the date
     - Parameter year: The year part of the date
     */
    internal func changeText(with month:String?, year:String?) -> Bool {
        
        if let nonNullMonth = formatMonthPart(with: month),
           let nonNullYear = formatYearPart(with: year) {
            // If the formatter accepted the given month and year, then e can assign those values to the field
            self.text = "\(nonNullMonth)/\(nonNullYear)"
        }
        // Afterall, we need to color the text based on the validty of the field
        self.textColor = (self.isValid()) ? normalTextColor : errorTextColor
        if let nonNullTextChangeBlock = textChanged {
            nonNullTextChangeBlock(String((self.text ?? "").prefix(5)))
        }
        return self.isValid()
    }
    
    /**
     This method does the logic of formatting a given month number into MM/.
     - Parameter month: The month part of the date that needs to be formatted
     - Parameter addSlash: States if the caller wants the formatter to add a slash at the end of the formatted month. Default is false
     - Returns: A formatted string as follows: If greater than 1, it returns 0M. If it is bigger than 1 less than 12 it returns the value itself and nil otherwise. If addSlash is set, it just append /
     */
    internal func formatMonthPart(with month:String?, addSlash:Bool = false) -> String? {
        var formattedMonth:String? = nil
        
        if let nonNullMonth = month{
            // Defensive code to make sure the month is passed
            if nonNullMonth.count == 1 {
                // The user entered one digit, hence we need to check if it is greater than 1 or equal to 1
                if nonNullMonth > "1" {
                    // If it is greater than one like 5, we need to make it to 05 automatically, rather than forcing the user to enter 0 then 5
                    formattedMonth = "0\(nonNullMonth)\((addSlash) ? "/" : "")"
                }else{
                    // If it is 1 we will have to keep it as is, as the user will have to put another number to create a valid month
                    formattedMonth = "\(nonNullMonth)"
                }
            }else if nonNullMonth.count == 2 {
                // If the count is 2, then he should have entered a month numbrt
                if nonNullMonth <= "12" {
                    //Prevent user to not enter month more than 12
                    formattedMonth = "\(nonNullMonth)\((addSlash) ? "/" : "")"
                }
            }
        }
        
        return formattedMonth
    }
    
    /**
     This method does the logic of formatting a given year number into YY.
     - Parameter year: The year part of the date that needs to be formatted
     - Returns: A formatted string as follows: If it is YY we return it as is, if it is YYYY we return last YY of it
     */
    internal func formatYearPart(with year:String?) -> String? {
        // Check if the caller passed a valid year string first
        if let nonNullYear = year {
            if nonNullYear.count == 2 {
                // If he passed already YY then we return it as is
                return nonNullYear
            }else if nonNullYear.count == 4 {
                // If he passed YYYY we return the last two YY
                return nonNullYear.substring(from: 3).substring(to: 2)
            }
        }
        return nil
    }
}

