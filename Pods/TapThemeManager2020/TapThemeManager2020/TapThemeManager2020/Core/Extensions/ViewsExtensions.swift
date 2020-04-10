//
//  ViewsExtensions.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 09/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//

import class UIKit.UITextField
import class UIKit.UILabel
import class UIKit.UIRefreshControl
/// Thess extensions will hold  the needed methods for every UIView subclass that we will need to apply the theme manager or a part of it. These extensions are not inclusive and will always be added to while needed


// MARK:- NSAttributedString
extension NSAttributedString {
    
    /**
        - This is a new constructor added to create an attribtted string from another attributed string and applying new attributes to it.
        - Parameter attributedString: This is the original attributed string we will use to create a new one
        - Parameter newAttributes: This is a set of new attributes we want to apply to the passed attributed string. The new set will be merged into the current one's attributes, in case of conflicts the new will override the old ones.
        - Returns: A new NSAttributedString has the same text of attributedString with merging old and new attributes
     */
    internal convenience init(attributedString originalString: NSAttributedString,
                     byMerging newAttributes: [NSAttributedString.Key: Any]) {
        // Create the new string first
        let newString = NSMutableAttributedString(attributedString: originalString)
        let range = NSMakeRange(0, originalString.length)
        newString.enumerateAttributes(in: range, options: []) {
            (currentAttributes, range, _) in
            // For each attribute in the original one, whether to add them directly or override them by a new value from the new passed attributes
            let mergedAttributes = currentAttributes.merge(to: newAttributes)
            newString.setAttributes(mergedAttributes, range: range)
        }
        self.init(attributedString: newString)
    }
}

// MARK:- Dictionary
internal extension Dictionary {
    /**
       - A function that merge's the current dictionary with a new one.
       - Parameter newDictionary: This is the new dictionary we want to merge into the original one
       - Returns: The original dictionary having both his old vales and the new added ones. In case of conflicts, the new one overrides the old values.
    */
    func merge(to newDictionary: Dictionary) -> Dictionary {
        return newDictionary.reduce(into: self) { (result, pair) in
            let (key, value) = pair
            result[key] = value
        }
    }
}


// MARK:- UITextField
extension UITextField {
    /**
       - A function that applies and updates an attributed placeholder of a UITxetfield. To be used when you need to ONLY update/merge new set of attributes to the current one
       - Parameter withNewAttributes: The new set of attributes we want to apply to the current textfield's placeholder
    */
    @objc func tap_setPlaceholderAttributes(_ withNewAttributes: [NSAttributedString.Key: Any]) {
        // First check if there is a placeholder to apply the attributes to
        guard let placeholder = self.attributedPlaceholder else { return }
        // Merge the passed attributtes and the original attributes
        let newString = NSAttributedString(attributedString: placeholder,
                                           byMerging: withNewAttributes)
        self.attributedPlaceholder = newString
    }
}

// MARK:- UILabel
extension UILabel {
    /**
       - A function that applies and updates an attributed text of a UILabel.
       - Parameter withNewAttributes: The new set of attributes we want to apply to the current UILabel's text
    */
    @objc func tap_setTextAttributes(_ withNewAttributes: [NSAttributedString.Key: Any]) {
        // First check if there is a text to apply the attributes to
        guard let text = self.attributedText else { return }
        // Merge the passed attributtes and the original attributes
        self.attributedText = NSAttributedString(
            attributedString: text,
            byMerging: withNewAttributes
        )
    }
}

// MARK:- UIRefreshControl
extension UIRefreshControl {
    /**
       - A function that applies and updates an attributed title of a UIRefreshControl.
       - Parameter withNewAttributes: The new set of attributes we want to apply to the current UIRefreshControl's title
    */
    @objc func tap_setTitleAttributes(_ withNewAttributes: [NSAttributedString.Key: Any]) {
        // First check if there is a text to apply the attributes to
        guard let title = self.attributedTitle else { return }
        // Merge the passed attributtes and the original attributes
        let newString = NSAttributedString(attributedString: title,
                                           byMerging: withNewAttributes)
        self.attributedTitle = newString
    }
}


