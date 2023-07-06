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
import enum TapCardVlidatorKit_iOS.CardBrand
/// Protocol defines the common method needed to be implemented by all the card text fields, this is used to make sure all subclasses have the needed common logic
@objc internal protocol CardInputTextFieldProtocol {
    /// This method will what is the status of the textfield
    func textFieldStatus(cardNumber:String?)->CrardInputTextFieldStatusEnum
    /// This is a valiation method that defines how to validate the input of this textfield
    func isValid(cardNumber:String?)->Bool
    /// This is a valiation method that defines if we can show a warning related to this input, it will check first if the field is focused & the data is complete length
    func canShowHint()->Bool
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
            self.attributedPlaceholder = NSAttributedString(string: self.attributedPlaceholder?.string ?? "", attributes: [
                .foregroundColor: placeHolderTextColor,
                .font: fieldPlacedHolderFont])
            
        }
    }
    
    /// The font for the palcedholder of the textfield
    var fieldPlacedHolderFont:UIFont = .systemFont(ofSize: 12, weight: .regular)
    
    /// The placeholder of the text field
    var fieldPlaceHolder:String = "" {
        didSet{
            self.attributedPlaceholder = NSAttributedString(string: fieldPlaceHolder, attributes: [.foregroundColor: placeHolderTextColor,
                                                                                                   .font: fieldPlacedHolderFont])
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
    /// This is a block to tell the subscriber that any change happened to the text
    var textChanged:((String)->())?
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
        return textfield.textWidth(text: text)
    }
    
    func generateFillingValueForWidth(with count:Int, filling:String = "M") -> String {
        return String(repeating: filling, count: count)
    }
}

extension String {
    /**
     Returns all the charachters that are only digits
     - Returns: A string that has only digits from the provided string
     */
    func onlyDigits() -> String {
        return self.filter { "0123456789".contains($0) }
    }
    
    /**
     Returns all the charachters that are only digits and spaces
     - Returns: A string that has only digits and spaces from the provided string
     */
    func digitsWithSpaces() -> String {
        return self.filter { "0123456789 ".contains($0) }
    }
    
    /**
     Returns all the charachters that are only alphabet
     - Returns: A lowercase string that has only alphabet from the provided string
     */
    func alphabetOnly() -> String {
        return self.lowercased().filter { "abcdefghijklmnopqrstuvwxyz ".contains($0) }
    }
    
    /**
     Returns a formatted credit card number with the spaces in the correct palces
     - Parameter spaces: List of indices where you want to put the spaces in
     - Returns: Formatted string where a space is added at the provided indices
     */
    public func cardFormat(with spaces:[Int]) -> String {
        // Create a regexx template that will decide where to put the spaces afterwards
        let regex: NSRegularExpression
        
        do {
            var pattern = ""
            var first = true
            for group in spaces {
                // For every spacing index, we will create a regex pattern of DIGTS with the length of the index provided
                pattern += "(\\d{1,\(group)})"
                if !first {
                    pattern += "?"
                }
                first = false
            }
            regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options())
        } catch {
            fatalError("Error when creating regular expression: \(error)")
        }
        
        return NSArray(array: self.onlyDigits().split(with: regex)).componentsJoined(by: " ")
    }
    
    private func split(with regex: NSRegularExpression) -> [String] {
        let matches = regex.matches(in: self, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, self.count))
        var result = [String]()
        
        matches.forEach {
            for i in 1..<$0.numberOfRanges {
                let range = $0.range(at: i)
                
                if range.length > 0 {
                    result.append(NSString(string: self).substring(with: range))
                }
            }
        }
        
        return result
    }
    
}


extension UITextField {
    /**
     This is the method that willc ompute in pixels the width of the textfield, taking in consideration the status of the field (editing or not) and the min max chars of the textfield
     - Parameter text: The text you want to calculate the width needed to show them
     - Returns: The width of the textfield to show now in pixeld
     */
    func textWidth(text: String) -> CGFloat {
        guard let font = self.font else { return 0 }
        let myText = text as NSString
        
        let rect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(labelSize.width)
    }
}
