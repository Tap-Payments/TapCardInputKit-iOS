//
//  TapCardTextFiekld.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 09/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import struct UIKit.CGFloat
import struct UIKit.CGRect
import struct UIKit.CGSize
import class UIKit.UITextField
import class UIKit.UIColor
import class UIKit.UIFont
import enum UIKit.NSTextAlignment
import protocol UIKit.UITextFieldDelegate
import enum TapCardValidator.CardBrand
/// Protocol defines the common method needed to be implemented by all the card text fields, this is used to make sure all subclasses have the needed common logic
@objc internal protocol CardInputTextFieldProtocol {
    /// This method will what is the status of the textfield
    func textFieldStatus(cardNumber:String?)->CrardInputTextFieldStatusEnum
    /// This is a valiation method that defines how to validate the input of this textfield
    func isValid(cardNumber:String?)->Bool
    /// Compute the field width
    func calculatedWidth() -> CGFloat
}

/// This is the super class for all the tap card fields. This will help in providing a single interface for any caller to deal with this class only to access all common attributes and methods rather than talking to each card field type alone
internal class TapCardTextField: UITextField {

    /// The number of chars the textfield, the field will shrink to when another field is focused
    var minVisibleChars: Int = 0
    /// This is the maximum chars of the textfield, the field will expand to it when is focused
    var maxVisibleChars: Int = 0
    /// This is the preffered min width calculated by the OS itself, to show all the fields
    var autoMinCalculatedWidth: CGFloat = 0
    /// The text color for the textfields
    var normalTextColor: UIColor = .black {
        didSet{
            self.textColor = normalTextColor
        }
    }
    /// The text color for the textfields
    var placeHolderTextColor: UIColor = .black {
        didSet{
            self.attributedPlaceholder = NSAttributedString(string: self.attributedPlaceholder?.string ?? "", attributes: [NSAttributedString.Key.foregroundColor: placeHolderTextColor])

        }
    }
    /// The background color of the text fields
    var bgColor:UIColor = .clear {
        didSet{
            self.backgroundColor = bgColor
        }
    }
    /// The alignments of the tetx fields
    var alignment:NSTextAlignment = .left {
        didSet{
            self.textAlignment = alignment
        }
    }
    
    /// The error text color for the textfields
    var errorTextColor: UIColor = .red
    /// This is a block to tell the subscriber that the editing stats had been changed, whether editing TRUE or end editing FALSE
    var editingStatusChanged:((Bool)->())?
    
    /// This defines if the field should fill in the remaining space width wise in the inline mode
    var fillBiggestAvailableSpace:Bool = false

}




extension TapCardTextField {
    
    /**
     This is the method that willc ompute in pixels the width of the textfield, taking in consideration the status of the field (editing or not) and the min max chars of the textfield
     - Parameter textField: The textfield you need to check its width
     - Returns: The width of the textfield to show now in pixeld
     */
    func textWidth(textfield: UITextField) -> CGFloat {
        return textWidth(textfield: textfield, text: textfield.text!)
    }
    
    /**
    This is the method that willc ompute in pixels the width of the textfield, taking in consideration the status of the field (editing or not) and the min max chars of the textfield
     - Parameter textField: The textfield you need to check its width
     - Parameter text: The text you want to calculate the width needed to show them
    - Returns: The width of the textfield to show now in pixeld
    */
    func textWidth(textfield: UITextField, text: String) -> CGFloat {
        // Check if the minimimuum width auto calclated exists first
        if self.autoMinCalculatedWidth > 0 && !textfield.isEditing {
            return self.autoMinCalculatedWidth
        }
        return textWidth(font: textfield.font, text: text)
    }
    
    /**
    This is the method that willc ompute in pixels the width of the textfield, taking in consideration the status of the field (editing or not) and the min max chars of the textfield
     - Parameter font: The font you will use to show the given text
     - Parameter text: The text you want to calculate the width needed to show them
    - Returns: The width of the textfield to show now in pixeld
    */
    func textWidth(font: UIFont?, text: String) -> CGFloat {
        guard let font = font else { return 0 }
        let myText = text as NSString
        
        let rect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(labelSize.width)
    }
    
    func generateFillingValueForWidth(with count:Int, filling:String = "M") -> String {
        return String(repeating: filling, count: count)
    }
}

extension String {
    
    func onlyDigits() -> String {
        return self.filter { "0123456789".contains($0) }
    }
    
    func digitsWithSpaces() -> String {
        return self.filter { "0123456789 ".contains($0) }
    }
    
    func alphabetOnly() -> String {
        return self.lowercased().filter { "abcdefghijklmnopqrstuvwxyz ".contains($0) }
    }
    
    
    func modifyCreditCardString() -> String {
        let trimmedString = self.components(separatedBy: .whitespaces).joined()

        let arrOfCharacters = Array(trimmedString)
        var modifiedCreditCardString = ""

        if(arrOfCharacters.count > 0) {
            for i in 0...arrOfCharacters.count-1 {
                modifiedCreditCardString.append(arrOfCharacters[i])
                if((i+1) % 4 == 0 && i+1 != arrOfCharacters.count){
                    modifiedCreditCardString.append(" ")
                }
            }
        }
        return modifiedCreditCardString
    }
    
}
