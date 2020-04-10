//
//  ThemeVibranceBlurEffectSelector.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 08/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//

import class UIKit.UIVisualEffect
import class UIKit.UIBlurEffect

// Defines parsing blur effect level from theme file
@objc public final class ThemeVibranceBlurEffectSelector: ThemeSelector {
    
    // Defines parsing blur effect level from theme file
    public convenience init(keyPath: String) {
        self.init(value: { ThemeVibranceBlurEffectSelector.blurEffectStyle(for: TapThemeManager.stringValue(for: keyPath) ?? "") })
    }
    
    public convenience init(keyPath: String, map: @escaping (Any?) -> UIVisualEffect?) {
        self.init(value: { map(TapThemeManager.value(for: keyPath)) })
    }
    
    // Defines parsing blur effect level from array of effects
    public convenience init(effects: UIVisualEffect...) {
        self.init(value: { TapThemeManager.element(for: effects) })
    }
    
    public required convenience init(arrayLiteral elements: UIVisualEffect...) {
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
    - Converts a given string value to an actual UIVisualEffect
    - Parameter stringStyle: A string value to reprenset the needed UIVisualEffect
    - Returns: UIBlurEffect.default .dark, .light, .extraLight,.prominent,.regular
    */
    class func blurEffectStyle(for stringEffect: String) -> UIVisualEffect {
        switch stringEffect.lowercased() {
        case "dark":
            return UIBlurEffect(style: .dark)
        case "light":
            return UIBlurEffect(style: .light)
        case "extralight":
            return UIBlurEffect(style: .extraLight)
        case "prominent":
            if #available(iOS 10.0, *) {
                return UIBlurEffect(style: .prominent)
            } else {
                return UIBlurEffect(style: .light)
            }
        case "regular":
            if #available(iOS 10.0, *) {
                return UIBlurEffect(style: .regular)
            } else {
                return UIBlurEffect(style: .light)
            }
        default:
            return UIBlurEffect(style: .light)
        }
    }
    
}

public extension ThemeVibranceBlurEffectSelector {
    
    class func selectorWithKeyPath(_ keyPath: String, map: @escaping (Any?) -> UIVisualEffect?) -> ThemeVibranceBlurEffectSelector {
        return ThemeVibranceBlurEffectSelector(keyPath: keyPath, map: map)
    }
    
    class func selectorWithEffects(_ styles: [UIVisualEffect]) -> ThemeVibranceBlurEffectSelector {
        return ThemeVibranceBlurEffectSelector(value: { TapThemeManager.element(for: styles) })
    }
    
}

// MARK:- Objective C interface

@objc public extension ThemeVibranceBlurEffectSelector {
    
    class func selectorWithKeyPath(_ keyPath: String) -> ThemeVibranceBlurEffectSelector {
        return ThemeVibranceBlurEffectSelector(keyPath: keyPath)
    }
    
    class func selectorWithStringEffects(_ effects: [String]) -> ThemeVibranceBlurEffectSelector {
        return ThemeVibranceBlurEffectSelector(value: { TapThemeManager.element(for: effects.map(blurEffectStyle(for:))) })
    }
    
}

extension ThemeVibranceBlurEffectSelector: ExpressibleByArrayLiteral {}
extension ThemeVibranceBlurEffectSelector: ExpressibleByStringLiteral {}
