//
//  ThemeActivityIndicatorViewStyleSelector.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 08/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//

import class UIKit.UIActivityIndicatorView

/// This class is responsible for fetching a UIActivityIndicatorView.Style from a theme file or theme array

@objc public final class ThemeActivityIndicatorViewStyleSelector: ThemeSelector {
    
    /// Init with the UIActivityIndicatorView.Style value from a theme file
    public convenience init(keyPath: String) {
        self.init(value: { ThemeActivityIndicatorViewStyleSelector.activityStyle(from: TapThemeManager.stringValue(for: keyPath) ?? "") })
    }
    
    /// Init with the UIActivityIndicatorView.Style value from a theme file
    public convenience init(keyPath: String, map: @escaping (Any?) -> UIActivityIndicatorView.Style?) {
        self.init(value: { map(TapThemeManager.value(for: keyPath))
        })
    }
    
    /// Init with the UIActivityIndicatorView.Style value from a array of  styles
    public convenience init(styles: UIActivityIndicatorView.Style...) {
        self.init(value: { TapThemeManager.element(for: styles) })
    }
    
    public required convenience init(arrayLiteral elements: UIActivityIndicatorView.Style...) {
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
       - Converts a given string value to an actual UIActivityIndicatorView.Style
    - Parameter stringStyle: A string vale ro reprenset the needed UIActivityIndicatorView.Style
    - Returns: UIActivityIndicatorView.Style .gray, .white, .whiteLarge
    */
    class func activityStyle(from stringStyle: String) -> UIActivityIndicatorView.Style {
        switch stringStyle.lowercased() {
        case "gray"         : return .gray
        case "white"        : return .white
        case "whitelarge"   : return .whiteLarge
        default: return .gray
        }
    }
    
}

public extension ThemeActivityIndicatorViewStyleSelector {
    
    class func selectorWithKeyPath(_ keyPath: String, map: @escaping (Any?) -> UIActivityIndicatorView.Style?) -> ThemeActivityIndicatorViewStyleSelector {
        return ThemeActivityIndicatorViewStyleSelector(keyPath: keyPath, map: map)
    }
    
    class func selectorWithStyles(_ styles: [UIActivityIndicatorView.Style]) -> ThemeActivityIndicatorViewStyleSelector {
        return ThemeActivityIndicatorViewStyleSelector(value: { TapThemeManager.element(for: styles) })
    }
    
}


// MARK:- Objective C interface

@objc public extension ThemeActivityIndicatorViewStyleSelector {
    
    class func selectorWithKeyPath(_ keyPath: String) -> ThemeActivityIndicatorViewStyleSelector {
        return ThemeActivityIndicatorViewStyleSelector(keyPath: keyPath)
    }
    
    class func selectorWithStringStyles(_ styles: [String]) -> ThemeActivityIndicatorViewStyleSelector {
        return ThemeActivityIndicatorViewStyleSelector(value: { TapThemeManager.element(for: styles.map(activityStyle(from:))) })
    }
    
}

extension ThemeActivityIndicatorViewStyleSelector: ExpressibleByArrayLiteral {}
extension ThemeActivityIndicatorViewStyleSelector: ExpressibleByStringLiteral {}

