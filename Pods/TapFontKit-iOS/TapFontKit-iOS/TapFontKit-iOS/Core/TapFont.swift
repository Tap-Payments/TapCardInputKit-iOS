//
//  TapFont.swift
//  TapFontsKit
//
//  Copyright © 2019 Tap Payments. All rights reserved.
//

import CoreGraphics
import class     UIKit.UIFont.UIFont

/// Font name enum
public enum TapFont {
    
    case robotoThin
    case robotoLight
    case robotoMedium
    case robotoRegular
    case robotoBold
  
    case arabicTajwalLight
    case arabicTajwalRegular
    case arabicTajwalMedium
    case arabicTajwalBold
    case arabicTajwalBlack
    
    case system(String)
    
    // MARK: - Public -
    // MARK: Methods
    
    /// Returns localized ready-to-use UIFont instance.
    ///
    /// - Parameters:
    ///   - size: Point size.
    ///   - languageIdentifier: Language identifier.
    /// - Returns: Localized ready-to-use UIFont instance.
    public func localizedWithSize(_ size: CGFloat, languageIdentifier: String) -> UIFont? {
        return FontProvider.localizedFont(self, size: size, languageIdentifier: languageIdentifier)
    }
    
    /// Returns non-localized ready-to-use UIFont instance.
    ///
    /// - Parameter size: Point size.
    /// - Returns: Non-localized ready-to-use UIFont instance.
    public func withSize(_ size: CGFloat) -> UIFont? {
        
        return FontProvider.fontWith(name: self, size: size)
    }
    
    public static func TapFont(from fontName:String) -> TapFont {
        
        switch fontName.lowercased() {
        
        case "Roboto-Thin".lowercased():
            return .robotoThin
        case "Roboto-Light".lowercased():
            return .robotoLight
        case "Roboto-Medium".lowercased():
            return .robotoMedium
        case "Roboto-Regular".lowercased():
            return .robotoRegular
        case "Roboto-Bold".lowercased():
            return .robotoBold
         
        case "Tajawal-Light".lowercased():
            return .arabicTajwalLight
        case "Tajawal-Regular".lowercased():
            return .arabicTajwalRegular
        case "Tajawal-Medium".lowercased():
            return .arabicTajwalMedium
        case "Tajawal-Bold".lowercased():
            return .arabicTajwalBold
        case "Tajawal-Black".lowercased():
            return .arabicTajwalBlack
            
        default:
            return .robotoRegular
        }
        
    }
    
    // MARK: - Internal -
    // MARK: Properties
    
    /// Font file name.
    internal var fileName: String {
        
        switch self {
        
        case .robotoThin: return "Roboto-Thin"
        case .robotoLight: return "Roboto-Light"
        case .robotoMedium: return "Roboto-Medium"
        case .robotoRegular: return "Roboto-Regular"
        case .robotoBold: return "Roboto-Bold"
        
        case .arabicTajwalLight:     return "Tajawal-Light"
        case .arabicTajwalRegular:    return "Tajawal-Regular"
        case .arabicTajwalMedium:    return "Tajawal-Medium"
        case .arabicTajwalBold:         return "Tajawal-Bold"
        case .arabicTajwalBlack:         return "Tajawal-Black"
            
        default:
            
            fatalError("System font is not accessible through its file.")
        }
    }
    
    /// Font file extension.
    internal var fileExtension: String {
        
        return "ttf"
    }
}

// MARK: - Hashable
extension TapFont: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        
        switch self {
            
        case .system(let name): hasher.combine(name)
        default:                hasher.combine(self.fileName)
            
        }
    }
}
