//
//  UIHexColor.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 08/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//

import class UIKit.UIColor
import class UIKit.CGColor
import struct UIKit.CGFloat

/// Defines set of init methods to provide a UIColor from different values of provided #RGBA hex values. #RGB, #RGBA, #RRGGBB, #RRGGBBAA
@objc extension UIColor {
    
    /**
     #RGB input --> #RRGGBBAA output.
     
     - parameter hex3: #RGB hexadecimal value.
     - parameter alpha: 0.0 - 1.0. The default is 1.0.
     */
    internal convenience init(hex3: UInt16, alpha: CGFloat = 1) {
        let divisor = CGFloat(15)
        let red     = CGFloat((hex3 & 0xF00) >> 8) / divisor
        let green   = CGFloat((hex3 & 0x0F0) >> 4) / divisor
        let blue    = CGFloat( hex3 & 0x00F      ) / divisor

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     #RGBA input --> #RRGGBBAA output.
     
     - parameter hex4: #RGBA hexadecimal value.
     */
    internal convenience init(hex4: UInt16) {
        let divisor = CGFloat(15)
        let red     = CGFloat((hex4 & 0xF000) >> 12) / divisor
        let green   = CGFloat((hex4 & 0x0F00) >>  8) / divisor
        let blue    = CGFloat((hex4 & 0x00F0) >>  4) / divisor
        let alpha   = CGFloat( hex4 & 0x000F       ) / divisor

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     #RRGGBB input --> #RRGGBBAA output.
     - parameter hex6: Six-digit hexadecimal value.
     - parameter alpha: 0.0 - 1.0. The default is 1.0.
     */
    internal convenience init(hex6: UInt32, alpha: CGFloat = 1) {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
        let green   = CGFloat((hex6 & 0x00FF00) >>  8) / divisor
        let blue    = CGFloat( hex6 & 0x0000FF       ) / divisor

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     #RRGGBBAA input --> UIColor output.
     
     - parameter hex8: #RRGGBBAA
     */
    internal convenience init(hex8: UInt32) {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex8 & 0xFF000000) >> 24) / divisor
        let green   = CGFloat((hex8 & 0x00FF0000) >> 16) / divisor
        let blue    = CGFloat((hex8 & 0x0000FF00) >>  8) / divisor
        let alpha   = CGFloat( hex8 & 0x000000FF       ) / divisor

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    
    /**
     The global added Init method that takes in any of the allowed HEX strings and returns a valid UIColor
     
     - parameter rgba: #RGB, #RGBA, #RRGGBB, #RRGGBBAA
     */
    public convenience init(tap_hex rgba: String) throws {
        guard rgba.hasPrefix("#") else {
            throw UIColorHexInputError.noHashMark
        }
        
        let hexString: String = String(rgba[rgba.index(rgba.startIndex, offsetBy: 1)...])
        var hexValue:  UInt32 = 0
        
        guard Scanner(string: hexString).scanHexInt32(&hexValue) else {
            throw UIColorHexInputError.notValidHexValue
        }
        
        switch (hexString.count) {
        case 3:
            self.init(hex3: UInt16(hexValue))
        case 4:
            self.init(hex4: UInt16(hexValue))
        case 6:
            self.init(hex6: hexValue)
        case 8:
            self.init(hex8: hexValue)
        default:
            throw UIColorHexInputError.notSupportedHexLength
        }
    }
}

/**
 noHashMark:   "no '#' as prefix"
 notValidHexValue:      "Scan hex error"
 notSupportedHexLength: "length'#' should be either 3, 4, 6 or 8"
 */
public enum UIColorHexInputError : Error {
    case noHashMark,
    notValidHexValue,
    notSupportedHexLength
}
