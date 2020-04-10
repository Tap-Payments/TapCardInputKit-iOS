//
//  ThemeCgColorSelector.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 08/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//

import class UIKit.UIColor
import class UIKit.CGColor
/// This class is responsible for fetching a CGColor from a theme file or theme array
@objc public final class ThemeCgColorSelector: ThemeSelector {
    
    /// Init with the CGColor value from a theme file
    public convenience init(keyPath: String) {
        self.init(value: { TapThemeManager.colorValue(for: keyPath)?.cgColor })
    }
    
    /// Init with the CGColor value from a theme file using a certain key mapping from the theme dictrionary
    public convenience init(keyPath: String, map: @escaping (Any?) -> CGColor?) {
        self.init(value: { map(TapThemeManager.value(for: keyPath)) })
    }
    
    /// Init with the CGColor value from an array of string colours
    public convenience init(colors: String...) {
        self.init(value: { TapThemeManager.colorElement(for: colors)?.cgColor })
    }
    
    /// Init with the CGColor value from an array of UIColors
    public convenience init(colors: UIColor...) {
        self.init(value: { TapThemeManager.element(for: colors)?.cgColor })
    }
    
    /// Init with the CGColor value from an array of CGColors
    public convenience init(colors: CGColor...) {
        self.init(value: { TapThemeManager.element(for: colors) })
    }
    
    public required convenience init(arrayLiteral elements: String...) {
        self.init(value: { TapThemeManager.colorElement(for: elements)?.cgColor })
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
    
}
    // MARK:- Objective C interface
@objc public extension ThemeCgColorSelector {
    
    class func selectorWithKeyPath(_ keyPath: String) -> ThemeCgColorSelector {
        return ThemeCgColorSelector(keyPath: keyPath)
    }
    
    class func selectorWithKeyPath(_ keyPath: String, map: @escaping (Any?) -> CGColor?) -> ThemeCgColorSelector {
        return ThemeCgColorSelector(keyPath: keyPath, map: map)
    }
    
    class func selectorWithColors(_ colors: [String]) -> ThemeCgColorSelector {
        return ThemeCgColorSelector(value: { TapThemeManager.colorElement(for: colors)?.cgColor })
    }
    
    class func selectorWithUIColors(_ colors: [UIColor]) -> ThemeCgColorSelector {
        return ThemeCgColorSelector(value: { TapThemeManager.element(for: colors)?.cgColor })
    }
    
}

extension ThemeCgColorSelector: ExpressibleByArrayLiteral {}
extension ThemeCgColorSelector: ExpressibleByStringLiteral {}

