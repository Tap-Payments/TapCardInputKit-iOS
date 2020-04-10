//
//  ThemeBlurEffectSelector.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 09/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//


import class UIKit.UIBlurEffect

@objc public final class ThemeBlurEffectSelector: ThemeSelector {

    public convenience init(keyPath: String, map: @escaping (Any?) -> UIBlurEffect?) {
        self.init(value: { map(TapThemeManager.value(for: keyPath)) })
    }

    public convenience init(appearances: UIBlurEffect...) {
        self.init(value: { TapThemeManager.element(for: appearances) })
    }

    public required convenience init(arrayLiteral elements: UIBlurEffect...) {
        self.init(value: { TapThemeManager.element(for: elements) })
    }

}

@objc public extension ThemeBlurEffectSelector {

    class func pickerWithKeyPath(_ keyPath: String, map: @escaping (Any?) -> UIBlurEffect?) -> ThemeBlurEffectSelector {
        return ThemeBlurEffectSelector(keyPath: keyPath, map: map)
    }

    class func pickerWithAppearances(_ appearances: [UIBlurEffect]) -> ThemeBlurEffectSelector {
        return ThemeBlurEffectSelector(value: { TapThemeManager.element(for: appearances) })
    }

}

extension ThemeBlurEffectSelector: ExpressibleByArrayLiteral {}
