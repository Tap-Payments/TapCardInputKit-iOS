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
    
    case helveticaNeueThin
    case helveticaNeueLight
    case helveticaNeueMedium
    case helveticaNeueRegular
    case helveticaNeueBold
    
    case robotoThin
    case robotoLight
    case robotoMedium
    case robotoRegular
    case robotoBold
    
    case circeExtraLight
    case circeLight
    case circeRegular
    case circeBold
    
    case arabicHelveticaNeueLight
    case arabicHelveticaNeueRegular
    case arabicHelveticaNeueBold
    
    
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
        case "HelveticaNeue-Thin".lowercased():
            return .helveticaNeueThin
        case "HelveticaNeue-Light".lowercased():
            return .helveticaNeueLight
        case "HelveticaNeue-Medium".lowercased():
            return .helveticaNeueMedium
        case "HelveticaNeue".lowercased():
            return .helveticaNeueRegular
        case "HelveticaNeue-Bold".lowercased():
            return .helveticaNeueBold
            
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
            
        case "Circe-ExtraLight".lowercased():
            return .circeExtraLight
        case "Circe-Light".lowercased():
            return .circeLight
        case "Circe-Regular".lowercased():
            return .circeRegular
        case "Circe-Bold".lowercased():
            return .circeBold
            
        case "HelveticaNeueLTW20-Light".lowercased():
            return .arabicHelveticaNeueLight
        case "HelveticaNeueLTW20-Roman".lowercased():
            return .arabicHelveticaNeueRegular
        case "HelveticaNeueLTW20-Bold".lowercased():
            return .arabicHelveticaNeueBold
            
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
            
        case .helveticaNeueThin:     return "HelveticaNeue-Thin"
        case .helveticaNeueLight:     return "HelveticaNeue-Light"
        case .helveticaNeueMedium:     return "HelveticaNeue-Medium"
        case .helveticaNeueRegular:    return "HelveticaNeue"
        case .helveticaNeueBold:     return "HelveticaNeue-Bold"
            
        case .robotoThin: return "Roboto-Thin"
        case .robotoLight: return "Roboto-Light"
        case .robotoMedium: return "Roboto-Medium"
        case .robotoRegular: return "Roboto-Regular"
        case .robotoBold: return "Roboto-Bold"
            
        case .circeExtraLight:    return "Circe-ExtraLight"
        case .circeLight:         return "Circe-Light"
        case .circeRegular:     return "Circe-Regular"
        case .circeBold:         return "Circe-Bold"
            
        case .arabicHelveticaNeueLight:     return "HelveticaNeueLTW20-Light"
        case .arabicHelveticaNeueRegular:    return "HelveticaNeueLTW20-Roman"
        case .arabicHelveticaNeueBold:         return "HelveticaNeueLTW20-Bold"
            
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
