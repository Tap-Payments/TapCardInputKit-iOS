//
//  CardInputTextFieldProtocol.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 08/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import UIKit

/// This protocol will define the needed logic that should be there in all the textfields implemented inside the card input view
internal protocol InternalCardInputTextFieldProtocol:UITextField {
    /// The number of chars the textfield, the field will shrink to when another field is focused
    var minVisibleChars: Int {get}
    /// This is the maximum chars of the textfield, the field will expand to it when is focused
    var maxVisibleChars: Int {get}
    /// This is the preffered min width calculated by the OS itself, to show all the fields
    var autoMinCalculatedWidth: CGFloat {get set}
    /// This is a block to tell the subscriber that the editing stats had been changed, whether editing TRUE or end editing FALSE
    var editingStatusChanged:((Bool)->())? { get set }
    /// This method will what is the status of the textfield
    func textFieldStats()->CrardInputTextFieldStatusEnum
    /// This is a valiation method that defines how to validate the input of this textfield
    func isValid()->Bool
    /// This will tell the caller what should be the current visible width of textfield based
    func calculatedWidth()->CGFloat
    /// The text color for the textfields
    var normalTextColor: UIColor {get set}
    /// The error text color for the textfields
    var errorTextColor: UIColor {get set}
}

extension InternalCardInputTextFieldProtocol {
    
    /**
     This is the method that willc ompute in pixels the width of the textfield, taking in consideration the status of the field (editing or not) and the min max chars of the textfield
     - Returns: The width of the textfield to show now in pixeld
     */
    func commonCalculateWidth()->CGFloat {
        return textWidth(textfield: self)
    }
    
    func textWidth(textfield: UITextField) -> CGFloat {
        return textWidth(textfield: textfield, text: textfield.text!)
    }
    
    func textWidth(textfield: UITextField, text: String) -> CGFloat {
        // Check if the minimimuum width auto calclated exists first
        if self.autoMinCalculatedWidth > 0 && !textfield.isEditing {
            return self.autoMinCalculatedWidth
        }
        return textWidth(font: textfield.font, text: text)
    }
    
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
