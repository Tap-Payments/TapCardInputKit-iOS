//
//  ThemeNavigationBarAppearanceSelector.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 08/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//

import class UIKit.UINavigationBarAppearance

@available(iOS 13.0, tvOS 13.0, *)
/// This class is responsible for fetching a UINavigationBarAppearance from a theme file or theme array
@objc public final class ThemeNavigationBarAppearanceSelector: ThemeSelector {

    
    /// This class is responsible for fetching a UINavigationBarAppearance from a theme file
    public convenience init(keyPath: String, map: @escaping (Any?) -> UINavigationBarAppearance?) {
        self.init(value: { map(TapThemeManager.value(for: keyPath)) })
    }

    
    /// This class is responsible for fetching a UINavigationBarAppearance from a array
    public convenience init(appearances: UINavigationBarAppearance...) {
        self.init(value: { TapThemeManager.element(for: appearances) })
    }

    public required convenience init(arrayLiteral elements: UINavigationBarAppearance...) {
        self.init(value: { TapThemeManager.element(for: elements) })
    }

}

// MARK:- Objective C interface
@available(iOS 13.0, tvOS 13.0, *)
@objc public extension ThemeNavigationBarAppearanceSelector {

    class func pickerWithKeyPath(_ keyPath: String, map: @escaping (Any?) -> UINavigationBarAppearance?) -> ThemeNavigationBarAppearanceSelector {
        return ThemeNavigationBarAppearanceSelector(keyPath: keyPath, map: map)
    }

    class func pickerWithAppearances(_ appearances: [UINavigationBarAppearance]) -> ThemeNavigationBarAppearanceSelector {
        return ThemeNavigationBarAppearanceSelector(value: { TapThemeManager.element(for: appearances) })
    }

}

@available(iOS 13.0, tvOS 13.0, *)
extension ThemeNavigationBarAppearanceSelector: ExpressibleByArrayLiteral {}
