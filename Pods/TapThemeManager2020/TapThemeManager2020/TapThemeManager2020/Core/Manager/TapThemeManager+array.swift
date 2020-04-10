//
//  TapThemeManager+array.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 08/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//


import class UIKit.UIColor
import class UIKit.UIImage
/// Set of methods that allows the Tap Theme Manager to get values if the theme was provided as a set of array like labelColors[Color1,Color2, etc]
extension TapThemeManager {
    
    public class func colorElement(for array: [String]) -> UIColor? {
        guard let matchingRGBString = element(for: array) else { return nil }
        guard let parsedColor = try? UIColor(tap_hex: matchingRGBString as String) else {
            print("TapThemeManager WARNING: Not convert rgba \(matchingRGBString) in array: \(array)[\(currentThemeIndex)]")
            return nil
        }
        return parsedColor
    }
    
    public class func imageElement(for array: [String]) -> UIImage? {
        guard let matchingImageName = element(for: array) else { return nil }
        guard let parsedImage = UIImage(named: matchingImageName as String) else {
            print("TapThemeManager WARNING: Not found image name '\(matchingImageName)' in array: \(array)[\(currentThemeIndex)]")
            return nil
        }
        return parsedImage
    }
    
    public class func element<T>(for array: [T]) -> T? {
        let index = TapThemeManager.currentThemeIndex
        guard  array.indices ~= index else {
            print("TapThemeManager WARNING: Not found element in array: \(array)[\(currentThemeIndex)]")
            return nil
        }
        return array[index]
    }
}

