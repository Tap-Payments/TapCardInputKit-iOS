//
//  ThemeCGFloatSelector.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 08/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//

import struct UIKit.CGFloat


/// This class is responsible for fetching a CGFloat value from a theme file or theme array
@objc public final class ThemeCGFloatSelector: ThemeSelector{
    
    /// Init with the CGFloat value from a theme file
    public convenience init(keyPath: String) {
        self.init(value: { CGFloat(TapThemeManager.numberValue(for: keyPath)?.doubleValue ?? 0) })
    }
    
    
    /// Init with the CGFloat value from a theme file using a certain key mapping from the theme dictrionary
    public convenience init(keyPath: String, map: @escaping (Any?) -> CGFloat?) {
        self.init(value: { map(TapThemeManager.value(for: keyPath)) })
    }
    
    /// Init with the CGColor value from an array of floats
    public convenience init(floats: CGFloat...) {
        self.init(value: { TapThemeManager.element(for: floats) })
    }
    
    public required convenience init(arrayLiteral elements: CGFloat...) {
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
    
}

public extension ThemeCGFloatSelector {
    
    class func selectorWithKeyPath(_ keyPath: String, map: @escaping (Any?) -> CGFloat?) -> ThemeCGFloatSelector {
        return ThemeCGFloatSelector(keyPath: keyPath, map: map)
    }
    
}

// MARK:- Objective C interface
@objc public extension ThemeCGFloatSelector {
    
    class func selectorWithKeyPath(_ keyPath: String) -> ThemeCGFloatSelector {
        return ThemeCGFloatSelector(keyPath: keyPath)
    }
    
    class func selectorWithFloats(_ floats: [CGFloat]) -> ThemeCGFloatSelector {
        return ThemeCGFloatSelector(value: { TapThemeManager.element(for: floats) })
    }
}

extension ThemeCGFloatSelector: ExpressibleByArrayLiteral {}
extension ThemeCGFloatSelector: ExpressibleByStringLiteral {}

