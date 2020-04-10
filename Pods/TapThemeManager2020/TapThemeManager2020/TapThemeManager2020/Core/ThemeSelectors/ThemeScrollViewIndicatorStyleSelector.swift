//
//  ThemeScrollViewIndicatorStyleSelector.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 08/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//

import class UIKit.UIScrollView

/// This class is responsible for fetching a UIScrollView.IndicatorStyle from a theme file or theme array
@objc public final class ThemeScrollViewIndicatorStyleSelector: ThemeSelector {

    /// This class is responsible for fetching a UIScrollView.IndicatorStyle from a theme file
    public convenience init(keyPath: String) {
        self.init(value: { ThemeScrollViewIndicatorStyleSelector.indicatorStyle(from: TapThemeManager.stringValue(for: keyPath) ?? "") })
    }
    
    public convenience init(keyPath: String, map: @escaping (Any?) -> UIScrollView.IndicatorStyle?) {
        self.init(value: { map(TapThemeManager.value(for: keyPath)) })
    }
    
    /// This class is responsible for fetching a UIScrollView.IndicatorStyle from a given array
    public convenience init(styles: UIScrollView.IndicatorStyle...) {
        self.init(value: { TapThemeManager.element(for: styles) })
    }
    
    public required convenience init(arrayLiteral elements: UIScrollView.IndicatorStyle...) {
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
    - Converts a given string value to an actual UIScrollView.IndicatorStyle
    - Parameter stringStyle: A string vale ro reprenset the needed UIScrollView.IndicatorStyle
    - Returns: UIScrollView.IndicatorStyle .default, .white, .black
    */
    class func indicatorStyle(from stringStyle: String) -> UIScrollView.IndicatorStyle {
        switch stringStyle.lowercased() {
        case "default"  : return .default
        case "black"    : return .black
        case "white"    : return .white
        default: return .default
        }
    }
    
}

public extension ThemeScrollViewIndicatorStyleSelector {
    
    class func selectorWithKeyPath(_ keyPath: String, map: @escaping (Any?) -> UIScrollView.IndicatorStyle?) -> ThemeScrollViewIndicatorStyleSelector {
        return ThemeScrollViewIndicatorStyleSelector(keyPath: keyPath, map: map)
    }
    
    class func pickerWithStyles(_ styles: [UIScrollView.IndicatorStyle]) -> ThemeScrollViewIndicatorStyleSelector {
        return ThemeScrollViewIndicatorStyleSelector(value: { TapThemeManager.element(for: styles) })
    }
    
}

// MARK:- Objective C interface
@objc public extension ThemeScrollViewIndicatorStyleSelector {
    
    class func selectorWithKeyPath(_ keyPath: String) -> ThemeScrollViewIndicatorStyleSelector {
        return ThemeScrollViewIndicatorStyleSelector(keyPath: keyPath)
    }
    
    class func pickerWithStringStyles(_ styles: [String]) -> ThemeScrollViewIndicatorStyleSelector {
        return ThemeScrollViewIndicatorStyleSelector(value: { TapThemeManager.element(for: styles.map(indicatorStyle(from:))) })
    }
    
}

extension ThemeScrollViewIndicatorStyleSelector: ExpressibleByArrayLiteral {}
extension ThemeScrollViewIndicatorStyleSelector: ExpressibleByStringLiteral {}


