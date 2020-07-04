//
//  ThemeFontSelector.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 08/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//

import class UIKit.UIFont

/// This class is responsible for fetching a UIFont from a theme file or theme array
@objc public final class ThemeFontSelector: ThemeSelector {
    
    /// Init with the UIFont value from a theme file
    public convenience init(keyPath: String, map: @escaping (Any?) -> UIFont?) {
        self.init(value: { map(TapThemeManager.value(for: keyPath)) })
    }
    
    /// Init with the UIFont value from array fonts
    public convenience init(fonts: UIFont...) {
        self.init(value: { TapThemeManager.element(for: fonts) })
    }
    
    public required convenience init(stringLiteral value: String) {
        self.init(value: { TapThemeManager.fontValue(for: value) })
    }
    
    public required convenience init(stringLiteral value: String,shouldLocalise:Bool = true) {
        self.init(value: { TapThemeManager.fontValue(for: value,shouldLocalise: shouldLocalise) })
    }
    
    public required convenience init(arrayLiteral elements: UIFont...) {
        self.init(value: { TapThemeManager.element(for: elements) })
    }
    
}

// MARK:- Objective C interface

@objc public extension ThemeFontSelector {
    
    class func selectorWithKeyPath(_ keyPath: String, map: @escaping (Any?) -> UIFont?) -> ThemeFontSelector {
        return ThemeFontSelector(keyPath: keyPath, map: map)
    }
    
    class func selectorWithFonts(_ fonts: [UIFont]) -> ThemeFontSelector {
        return ThemeFontSelector(value: { TapThemeManager.element(for: fonts) })
    }
    
}

extension ThemeFontSelector: ExpressibleByArrayLiteral {}
extension ThemeFontSelector: ExpressibleByStringLiteral {}


