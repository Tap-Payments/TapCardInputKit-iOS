//
//  ThemeDictionarySelector.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 08/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//


/// This class is responsible for fetching a Dictionary from a theme file or theme array
@objc public final class ThemeDictionarySelector: ThemeSelector {
    
    /// Init with the Dictionary value from a theme file
    public convenience init<T>(keyPath: String, map: @escaping (Any?) -> [T: AnyObject]?) {
        self.init(value: { map(TapThemeManager.value(for: keyPath)) })
    }
    
    public convenience init<T>(dicts: [T: AnyObject]...) {
        self.init(value: { TapThemeManager.element(for: dicts) })
    }
    
    public required convenience init(arrayLiteral elements: [String: AnyObject]...) {
        self.init(value: { TapThemeManager.element(for: elements) })
    }
    
}

// MARK:- Objective C interface
@objc public extension ThemeDictionarySelector  {
    
    class func selectorWithKeyPath(_ keyPath: String, map: @escaping (Any?) -> [String: AnyObject]?) -> ThemeDictionarySelector  {
        return ThemeDictionarySelector (keyPath: keyPath, map: map)
    }
    
    class func selectorWithDicts(_ dicts: [[String: AnyObject]]) -> ThemeDictionarySelector  {
        return ThemeDictionarySelector (value: { TapThemeManager.element(for: dicts) })
    }
    
}

extension ThemeDictionarySelector : ExpressibleByArrayLiteral {}
