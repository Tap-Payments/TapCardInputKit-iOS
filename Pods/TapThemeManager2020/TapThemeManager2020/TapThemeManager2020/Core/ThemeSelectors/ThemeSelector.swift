//
//  ThemeSelector.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 08/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//


import Foundation

/// This a theme selector (GENERIC) type. Which is mainly defines that the input for a theme selector will be a value from the theme dict and an output which is the selector to be done to apply the attribute to a the UIView

@objc public class ThemeSelector: NSObject, NSCopying {
    
    /// The ThemeValueType is a typealias defines a generic value for all theming vales inclyding UIColors,  Strings, Fonts, etc.
    public typealias ThemeValueType = () -> Any?
    
    public var value: ThemeValueType
    
    required public init(value: @escaping ThemeValueType) {
        self.value = value
    }
    
    public func copy(with zone: NSZone?) -> Any {
        return type(of: self).init(value: value)
    }
    
}
