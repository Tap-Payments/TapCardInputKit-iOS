//
//  ThemeImageSelector.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 08/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//

import class UIKit.UIImage

/// This class is responsible for fetching a UIImage from a theme file or theme array
@objc public final class ThemeImageSelector: ThemeSelector {
    
    /// Init with the UIImage value from a theme file
    public convenience init(keyPath: String,from bundle:Bundle? = nil) {
        self.init(value: { TapThemeManager.imageValue(for: keyPath,from: bundle) })
    }
    
    public convenience init(keyPath: String, map: @escaping (Any?) -> UIImage?) {
        self.init(value: { map(TapThemeManager.value(for: keyPath)) })
    }
    
    /// Init with the UIImage value from a array of image names
    public convenience init(names: String...) {
        self.init(value: { TapThemeManager.imageElement(for: names) })
    }
    
    /// Init with the UIImage value from a array of images
    public convenience init(images: UIImage...) {
        self.init(value: { TapThemeManager.element(for: images) })
    }
    
    public required convenience init(arrayLiteral elements: String...) {
        self.init(value: { TapThemeManager.imageElement(for: elements) })
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

@objc public extension ThemeImageSelector {
    
    class func selectorWithKeyPath(_ keyPath: String) -> ThemeImageSelector {
        return ThemeImageSelector(keyPath: keyPath)
    }
    
    class func selectorWithKeyPath(_ keyPath: String, map: @escaping (Any?) -> UIImage?) -> ThemeImageSelector {
        return ThemeImageSelector(keyPath: keyPath, map: map)
    }
    
    class func selectorWithNames(_ names: [String]) -> ThemeImageSelector {
        return ThemeImageSelector(value: { TapThemeManager.imageElement(for: names) })
    }
    
    class func selectorWithImages(_ images: [UIImage]) -> ThemeImageSelector {
        return ThemeImageSelector(value: { TapThemeManager.element(for: images) })
    }
    
}

extension ThemeImageSelector: ExpressibleByArrayLiteral {}
extension ThemeImageSelector: ExpressibleByStringLiteral {}
