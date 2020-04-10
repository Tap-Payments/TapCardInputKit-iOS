//
//  ThemeBarStyleSelector.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 08/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//

import enum UIKit.UIBarStyle

/// This class is responsible for fetching a UIBarStyle from a theme file or theme array
@objc public final class ThemeBarStyleSelector: ThemeSelector {
    
    /// Init with the UIBarStyle value from a theme file
    public convenience init(keyPath: String) {
        self.init(value: { ThemeBarStyleSelector.barStyle(from: TapThemeManager.stringValue(for: keyPath) ?? "") })
    }
    
    /// Init with the UIBarStyle value from a theme file
    public convenience init(keyPath: String, map: @escaping (Any?) -> UIBarStyle?) {
        self.init(value: { map(TapThemeManager.value(for: keyPath)) })
    }
    
    /// Init with the UIBarStyle value from a array of bar styles
    public convenience init(styles: UIBarStyle...) {
        self.init(value: { TapThemeManager.element(for: styles) })
    }
    
    public required convenience init(arrayLiteral elements: UIBarStyle...) {
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
        - Converts a given string value to an actual UIBarStyle
     - Parameter stringStyle: A string vale ro reprenset the needed UIBarStyle as follows default, black or blackTranslucent
     - Returns: UIBarStyle .default, .black, .blackTranslucent
     */
    class func barStyle(from stringStyle: String) -> UIBarStyle {
        switch stringStyle.lowercased() {
        case "default"          : return .default
        case "black"            : return .black
        case "blackTranslucent" : return .blackTranslucent
        default: return .default
        }
    }
    
}

public extension ThemeBarStyleSelector {
    
    class func selectorWithKeyPath(_ keyPath: String, map: @escaping (Any?) -> UIBarStyle?) -> ThemeBarStyleSelector {
        return ThemeBarStyleSelector(keyPath: keyPath, map: map)
    }
    
    class func selectorWithStyles(_ styles: [UIBarStyle]) -> ThemeBarStyleSelector {
        return ThemeBarStyleSelector(value: { TapThemeManager.element(for: styles) })
    }
    
}


// MARK:- Objective C interface
@objc public extension ThemeBarStyleSelector {
    
    class func selectorWithKeyPath(_ keyPath: String) -> ThemeBarStyleSelector {
        return ThemeBarStyleSelector(keyPath: keyPath)
    }
    
    class func selectorWithStringStyles(_ styles: [String]) -> ThemeBarStyleSelector {
        return ThemeBarStyleSelector(value: { TapThemeManager.element(for: styles.map(barStyle(from:))) })
    }
    
}

extension ThemeBarStyleSelector: ExpressibleByArrayLiteral {}
extension ThemeBarStyleSelector: ExpressibleByStringLiteral {}
