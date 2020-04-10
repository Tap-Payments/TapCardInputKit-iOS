//
//  ThemeUIColorSelector.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 08/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//

import class UIKit.UIColor
/// This class is responsible for fetching a UIColor from a theme file or theme array
@objc public final class ThemeUIColorSelector: ThemeSelector {
    
    /// Init with the color value from a theme file
    public convenience init(keyPath: String) {
        self.init(value: { TapThemeManager.colorValue(for: keyPath) })
    }
    
    /// Init with the color value from a theme file using a certain key mapping from the theme dictrionary
    public convenience init(keyPath: String, map: @escaping (Any?) -> UIColor?) {
        self.init(value: { map(TapThemeManager.value(for: keyPath)) })
    }
    
    /// Init with the color value from an array of string colours
    public convenience init(colors: String...) {
        self.init(value: { TapThemeManager.colorElement(for: colors) })
    }
    
    /// Init with the color value from an array of colours
    public convenience init(colors: UIColor...) {
        self.init(value: { TapThemeManager.element(for: colors) })
    }
    
    public required convenience init(arrayLiteral elements: String...) {
        self.init(value: { TapThemeManager.colorElement(for: elements) })
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

@objc public extension ThemeUIColorSelector {
    
    class func selectorWithKeyPath(_ keyPath: String) -> ThemeUIColorSelector {
        return ThemeUIColorSelector(keyPath: keyPath)
    }
    
    class func selectorWithKeyPath(_ keyPath: String, map: @escaping (Any?) -> UIColor?) -> ThemeUIColorSelector {
        return ThemeUIColorSelector(keyPath: keyPath, map: map)
    }
    
    class func selectorWithColors(_ colors: [String]) -> ThemeUIColorSelector {
        return ThemeUIColorSelector(value: { TapThemeManager.colorElement(for: colors) })
    }
    
    class func selectorWithUIColors(_ colors: [UIColor]) -> ThemeUIColorSelector {
        return ThemeUIColorSelector(value: { TapThemeManager.element(for: colors) })
    }
    
}

extension ThemeUIColorSelector: ExpressibleByArrayLiteral {}
extension ThemeUIColorSelector: ExpressibleByStringLiteral {}

