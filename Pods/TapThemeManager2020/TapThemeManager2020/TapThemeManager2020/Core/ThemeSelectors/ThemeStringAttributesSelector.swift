//
//  ThemeStringAttributesSelector.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 08/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//
/// This class is responsible for fetching a StringAttributes from a theme file or theme array
@objc public final class ThemeStringAttributesSelector: ThemeSelector {
    
    /// This class is responsible for fetching a StringAttributes from a theme file or theme array
    public convenience init(keyPath: String, map: @escaping (Any?) -> [NSAttributedString.Key: Any]?) {
        self.init(value: { map(TapThemeManager.value(for: keyPath)) })
    }
    
    public convenience init(_ attributes: [NSAttributedString.Key: Any]...) {
        self.init(value: { TapThemeManager.element(for: attributes) })
    }
    
    public required convenience init(arrayLiteral elements: [NSAttributedString.Key: Any]...) {
        self.init(value: { TapThemeManager.element(for: elements) })
    }
    
}

// MARK:- Objective C interface

@objc public extension ThemeStringAttributesSelector {
    
    class func selectorWithKeyPath(_ keyPath: String, map: @escaping (Any?) -> [NSAttributedString.Key: Any]?) -> ThemeStringAttributesSelector {
        return ThemeStringAttributesSelector(keyPath: keyPath, map: map)
    }
    
    class func selectorWithAttributes(_ attributes: [[NSAttributedString.Key: Any]]) -> ThemeStringAttributesSelector {
        return ThemeStringAttributesSelector(value: { TapThemeManager.element(for: attributes) })
    }
    
}

extension ThemeStringAttributesSelector: ExpressibleByArrayLiteral {}

