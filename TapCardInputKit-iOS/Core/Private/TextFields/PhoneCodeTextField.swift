//
//  PhoneCodeTextField.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 7/8/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import struct UIKit.CGFloat
import struct UIKit.CGRect
import class UIKit.UITextField
import protocol UIKit.UITextFieldDelegate
/// Represnts the card cvv text field
class PhoneCodeTextField:TapCardTextField {
    
    /// This is the block that will fire an event when a the country phone code has changed
    var phoneCodeChanged: ((String) -> ())? =  nil
    
    
    /**
     Method that is used to setup the field by providing the needed info and the obersvers for the events
     - Parameter placeholder: The placeholder to show in this field. Default is ""
     - Parameter phoneCodeChanged: Observer to listen to the event when a the phoneCode changed by user input till the moment
     */
    func setup(placeholder:String = "", phoneCodeChanged: ((String) -> ())? =  nil) {
        // Set the place holder with the theme color
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: placeHolderTextColor])
        // Assign and save the passed attributes
        // Card number should have a numeric pad
        self.keyboardType = .phonePad
        self.minVisibleChars = 3
        self.maxVisibleChars = 3
        self.phoneCodeChanged = phoneCodeChanged
        // Assign the observers and the blocks
        self.editingStatusChanged = nil
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
}

extension PhoneCodeTextField:CardInputTextFieldProtocol {
    
    func calculatedWidth() -> CGFloat {
        
        return self.textWidth(textfield:self, text: generateFillingValueForWidth(with: self.isEditing ? maxVisibleChars : minVisibleChars))
    }
    
    func textFieldStatus(cardNumber:String? = nil) -> CrardInputTextFieldStatusEnum {
        return .Valid
    }
    
    func isValid(cardNumber:String? = nil) -> Bool {
        
        return textFieldStatus() == .Valid
    }
}
