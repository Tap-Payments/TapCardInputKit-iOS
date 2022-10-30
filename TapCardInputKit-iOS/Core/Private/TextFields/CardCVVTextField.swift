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
/// Represnts the card cvv text field
class CardCVVTextField:TapCardTextField {
    
    /// This is the block that will fire an event when a the card cvv has changed
    var cardCVVChanged: ((String) -> ())? =  nil
    /// The timer used to mask the CVV digits after making them visible for a little bit of time
    var timer: Timer?
    /// Defines the length of the cvv length allowed based on the brand detected
    var cvvLength:Int = 3 {
        didSet{
            // If the cvv length changed, then we need to make sure, if the user did input more than that then we need to trim it to the allowed max new length
            if let text = self.text,
               text.count > cvvLength {
                self.text = text.substring(to: cvvLength)
            }
        }
    }
    
    
    /**
     Method that is used to setup the field by providing the needed info and the obersvers for the events
     - Parameter minVisibleChars: Number of mimum charachters to be visible when the field is inactive, in Inline mode. Default is 4
     - Parameter maxVisibleChars: Number of maximum charachters to be visible when the field is inactive, in Inline mode. Default is 16
     - Parameter placeholder: The placeholder to show in this field. Default is ""
     - Parameter editingStatusChanged: Observer to listen to the event when the editing status changed, whether started or ended editing
     - Parameter cardCVVChanged: Observer to listen to the event when a the card cvv is changed by user input till the moment
     */
    func setup(with minVisibleChars: Int = 3, maxVisibleChars: Int = 3, placeholder:String = "", editingStatusChanged: ((Bool) -> ())? = nil, cardCVVChanged: ((String) -> ())? =  nil) {
        // Set the place holder with the theme color
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: placeHolderTextColor])
        // Assign and save the passed attributes
        // Card number should have a numeric pad
        self.keyboardType = .phonePad
        self.minVisibleChars = minVisibleChars
        self.maxVisibleChars = maxVisibleChars
        self.cardCVVChanged = cardCVVChanged
        // Listen to the event of text change
        self.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
        // Assign the observers and the blocks
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
        
        return self.textWidth(textfield:self, text: generateFillingValueForWidth(with: self.isEditing ? maxVisibleChars : minVisibleChars))
    }
    
    func textFieldStatus(cardNumber:String? = nil) -> CrardInputTextFieldStatusEnum {
        // Chevk if we can get the texxt from the text field first
        guard let text:String = self.text else{ return .Invalid }
        // The card number field is considered valid only if it matches the length of the allowed CVV for the current card brand
        
        if text.count < 3 {
            // Minimum is 3 digits for the cvv, if not yet reached then it is still incomplete
            return .Incomplete
        }
        
        if text.count > cvvLength {
            // Defensive code, but make sure if it is more than the allowed cvv length then it is invalid
            return .Invalid
        }
        
        if text.count == cvvLength {
            // If it matches the cvv length then it is valid
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
        // If the editing changed block is assigned, we need to fire this event as the editing now started for the field
        if let nonNullEditingBlock = editingStatusChanged {
            nonNullEditingBlock(true)
        }
        print("CVV # TRUE")
        self.textColor = normalTextColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        // If the editing changed block is assigned, we need to fire this event as the editing now ended for the field
        if let nonNullEditingBlock = editingStatusChanged {
            nonNullEditingBlock(false)
        }
        print("CVV # FALSE")
        self.textColor = (self.isValid()) ? normalTextColor : errorTextColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // attempt to read the range they are trying to change, or exit if we can't
        guard let currentText = textField.text as NSString? else {
            return false
        }
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        // Apply and valiodate the new text before writing it
        let _ = changeText(with: updatedText, setTextAfterValidation: true)
        textField.isSecureTextEntry = false
        if let timer = timer {
            timer.invalidate()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
            timer.invalidate()
            textField.isSecureTextEntry = true
        })
        return false
    }
    
    /**
     This method does the logic required when a text change event is fired for the text field
     - Parameter textField: The text field that has its text changed
     */
    @objc func didChangeText(textField:UITextField) {
        if let nonNullBlock = cardCVVChanged {
            // For the card cvv we send back the cvv entered by the user
            nonNullBlock(textField.text!.onlyDigits())
        }
        if let nonNullTextChangeBlock = textChanged {
            nonNullTextChangeBlock(self.text ?? "")
        }
    }
    
    /**
     This method does the logic required to check if a given text is allowed to be written to the card cvv field or not
     - Parameter updatedText: The text we want to validate and write to the card cvv text field
     - Parameter setTextAfterValidation: States if the caller wants to write the text if is correcly validated
     - Returns: True if the text is valid and can be written to the card cvv field and false otherwise
     */
    internal func changeText(with updatedText:String, setTextAfterValidation:Bool = false) -> Bool {
        
        // First of all we need to make sure that the text is only numeric
        let filteredText = updatedText.onlyDigits()
        
        
        if updatedText.count > cvvLength ||  filteredText != updatedText {
            // If the tetx has non numeric or longer than the allowed max cvv length then it is false
            return false
        }else {
            if setTextAfterValidation {
                // If the caller wants us to write the text after validating it, then we do so here
                self.text = updatedText
            }
            // Fire the event of text changed block
            didChangeText(textField: self)
            self.textColor = (self.isValid()) ? normalTextColor : errorTextColor
        }
        if let nonNullTextChangeBlock = textChanged {
            nonNullTextChangeBlock(self.text ?? "")
        }
        return true
    }
}

internal extension String {
    
    /**
     Method to calculate  the index to start of when taking a substring
     - Parameter from: The starting position ew need to start with
     */
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    /**
     Extension to get a substring from a string starting from a given position
     - Parameter from: The index you want to start taking the substrin from
     - Returns: The substring of the given string starting from the given index
     */
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }
    
    /**
     Extension to get a substring from a string starting from 0 till a given position
     - Parameter from: The index you want to end taking the substrin to
     - Returns: The substring of the given string starting from 0 to the given index
     */
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
