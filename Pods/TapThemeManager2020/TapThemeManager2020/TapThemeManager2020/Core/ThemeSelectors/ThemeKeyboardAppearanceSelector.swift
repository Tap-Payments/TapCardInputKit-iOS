//
//  ThemeKeyboardAppearanceSelector.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 08/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//

import enum UIKit.UIKeyboardAppearance

/// This class is responsible for fetching a UIKeyboardAppearance from a theme file or theme array
@objc public final class ThemeKeyboardAppearanceSelector: ThemeSelector {
    
    /// Init with the UIKeyboardAppearance value from a theme file
    public convenience init(keyPath: String) {
        self.init(value: { ThemeKeyboardAppearanceSelector.UIKeyboardAppearanceStyle(from: TapThemeManager.stringValue(for: keyPath) ?? "") })
    }
    
    public convenience init(keyPath: String, map: @escaping (Any?) -> UIKeyboardAppearance?) {
        self.init(value: { map(TapThemeManager.value(for: keyPath)) })
    }
    
    /// Init with the UIKeyboardAppearance value from array of UIKeyboardAppearances
    public convenience init(styles: UIKeyboardAppearance...) {
        self.init(value: { TapThemeManager.element(for: styles) })
    }
    
    public required convenience init(arrayLiteral elements: UIKeyboardAppearance...) {
        self.init(value: { TapThemeManager.element(for: elements) })
    }
    
    public required convenience init(stringLiteral value: String) {
        self.init(keyPath: value)
    }
    
    public required convenience init(unicodeScalarLiteral value: String) {
        self.init(keyPath: value)
    }
    
    public required convenience init(extendedGraphemeClusterLiteral value: String) {
        self.init(keyPath: value)
    }
    
    /**
    - Converts a given string value to an actual UIKeyboardAppearanceStyle
    - Parameter stringStyle: A string value to reprenset the needed UIKeyboardAppearanceStyle
    - Returns: UIKeyboardAppearanceStyle.default .dark, .light, .alert
    */
    class func UIKeyboardAppearanceStyle(from stringStyle: String) -> UIKeyboardAppearance {
        switch stringStyle.lowercased() {
        case "default"  : return .default
        case "dark"     : return .dark
        case "light"    : return .light
        case "alert"    : return .alert
        default: return .default
        }
    }
    
}

public extension ThemeKeyboardAppearanceSelector {
    
    class func pickerWithKeyPath(_ keyPath: String, map: @escaping (Any?) -> UIKeyboardAppearance?) -> ThemeKeyboardAppearanceSelector {
        return ThemeKeyboardAppearanceSelector(keyPath: keyPath, map: map)
    }
    
    class func pickerWithStyles(_ styles: [UIKeyboardAppearance]) -> ThemeKeyboardAppearanceSelector {
        return ThemeKeyboardAppearanceSelector(value: { TapThemeManager.element(for: styles) })
    }
    
}

// MARK:- Objective C interface

@objc public extension ThemeKeyboardAppearanceSelector {
    
    class func pickerWithKeyPath(_ keyPath: String) -> ThemeKeyboardAppearanceSelector {
        return ThemeKeyboardAppearanceSelector(keyPath: keyPath)
    }
    
    class func pickerWithStringStyles(_ styles: [String]) -> ThemeKeyboardAppearanceSelector {
        return ThemeKeyboardAppearanceSelector(value: { TapThemeManager.element(for: styles.map(UIKeyboardAppearanceStyle(from:))) })
    }
    
}

extension ThemeKeyboardAppearanceSelector: ExpressibleByArrayLiteral {}
extension ThemeKeyboardAppearanceSelector: ExpressibleByStringLiteral {}

