//
//  CardNumberTextField.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 08/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import struct UIKit.CGFloat
import struct UIKit.CGRect
import class UIKit.UITextField
import protocol UIKit.UITextFieldDelegate

/// Represnts the card name text field
class CardNameTextField:TapCardTextField {
    
    /// This is the block that will fire an event when a the card name has changed
    var cardNameChanged: ((String) -> ())? =  nil
    
    /**
     Method that is used to setup the field by providing the needed info and the obersvers for the events
     - Parameter minVisibleChars: Number of mimum charachters to be visible when the field is inactive, in Inline mode. Default is 4
     - Parameter maxVisibleChars: Number of maximum charachters to be visible when the field is inactive, in Inline mode. Default is 16
     - Parameter placeholder: The placeholder to show in this field. Default is ""
     - Parameter editingStatusChanged: Observer to listen to the event when the editing status changed, whether started or ended editing
     - Parameter cardNameChanged: Observer to listen to the event when a the card name is changed by user input till the moment
     - Parameter preloadCardHolderName:  A preloading value for the card holder name if needed
     - Parameter editCardName: Indicates whether or not the user can edit the card holder name field. Default is true
     */
    func setup(with minVisibleChars: Int = 16, maxVisibleChars: Int = 16, placeholder:String = "",editingStatusChanged: ((Bool) -> ())? = nil, cardNameChanged: ((String) -> ())? =  nil, preloadCardHolderName:String = "", editCardName:Bool = true) {
        // Assign and save the passed attributes
        self.minVisibleChars = minVisibleChars
        self.maxVisibleChars = maxVisibleChars
        // Card number should have a default keyboard
        self.keyboardType = .default
        // This indicates that this field should fill in the remaining width in the case of the inline mode
        self.fillBiggestAvailableSpace = false
        // Enable/Disable the field based on the caller desire
        self.isEnabled = editCardName
        // Set the place holder with the theme color
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: placeHolderTextColor])
        // Assign the observers and the blocks
        self.editingStatusChanged = editingStatusChanged
        self.cardNameChanged = cardNameChanged
        // Listen to the event of text change
        self.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
        
        self.delegate = self
        
        // Set the initial value if a preloading value was passed and if this value is value
        self.text = validateCardName(with: preloadCardHolderName) == .Valid ? preloadCardHolderName : ""
        didChangeText(textField: self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /**
     This method does the logic required to check if a given text is allowed to be written to the card name field or not
     - Parameter updatedText: The text we want to validate and write to the card name text field
     - Parameter setTextAfterValidation: States if the caller wants to write the text if is correcly validated
     - Returns: True if the text is valid and can be written to the card name field and false otherwise
     */
    internal func changeText(with updatedText:String, setTextAfterValidation:Bool = false) -> Bool {
        
        
        if validateCardName(with: updatedText) == .Valid {
            self.text = updatedText
        }else{
            self.text = ""
        }
        
        if let nonNullTextChangeBlock = textChanged {
            nonNullTextChangeBlock(self.text ?? "")
        }
        
        return true
    }
    
}


extension CardNameTextField: CardInputTextFieldProtocol {
    func canShowHint()->Bool {
        return false
    }
    func textFieldStatus(cardNumber:String? = nil) -> CrardInputTextFieldStatusEnum {
        // Check if the caller wants to validate the given string first
        if let passedCardName = cardNumber,
           !passedCardName.isEmpty {
            return validateCardName(with: passedCardName)
        }else {
            return validateCardName(with: self.text)
        }
    }
    
    /**
     Applys the validation of a card name on the given string
     - Parameter passedCardName: The value you want to validate against being a card holder name
     */
    internal func validateCardName(with passedCardName:String?) -> CrardInputTextFieldStatusEnum {
        if let passedCardName = passedCardName,
           !passedCardName.isEmpty {
            // Make sure it is valid where there is a text and the text contains only alphabets
            if passedCardName.alphabetOnly() == passedCardName.lowercased() && (passedCardName.count > 2 && passedCardName.count <= 26) {
                return .Valid
            }
        }
        return .Invalid
    }
    
    func calculatedWidth() -> CGFloat {
        // Calculate the width of the field based on it is active status, if it is activbe we calculaye the width needed to show the max visible charachters and if it is inactive we calculate width based on minimum visible characters
        
        return self.textWidth(textfield:self, text: generateFillingValueForWidth(with: (self.isEditing) ? maxVisibleChars : minVisibleChars))
    }
    
    func isValid(cardNumber:String? = nil) -> Bool {
        
        return textFieldStatus() == .Valid
    }
}

extension CardNameTextField:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let nonNullEditingBlock = editingStatusChanged {
            // If the editing changed block is assigned, we need to fire this event as the editing now started for the field
            nonNullEditingBlock(true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if let nonNullEditingBlock = editingStatusChanged {
            // If the editing changed block is assigned, we need to fire this event as the editing now ended for the field
            nonNullEditingBlock(false)
        }
    }
    /**
     This method does the logic required when a text change event is fired for the text field
     - Parameter textField: The text field that has its text changed
     */
    @objc func didChangeText(textField:UITextField) {
        if let nonNullBlock = cardNameChanged {
            // If the card name changed block is assigned, we need to fire this event
            textField.text = textField.text?.uppercased()
            nonNullBlock(textField.text!)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        // add their new text to the existing text
        let updatedText:String = currentText.replacingCharacters(in: stringRange, with: string)
        // Check first if it is allowed to change the string
        if updatedText.alphabetOnly() == updatedText.lowercased() && updatedText.count <= 26 {
            // Then set the text
            self.text = updatedText.uppercased()
            didChangeText(textField: textField)
        }
        // Validate it
        self.textColor = (self.isValid()) ? normalTextColor : errorTextColor
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
