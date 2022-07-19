//
//  FontProvider.swift
//  TapFontsKit
//
//  Copyright © 2019 Tap Payments. All rights reserved.
//

import CoreGraphics
import func     CoreText.CTFontManager.CTFontManagerRegisterGraphicsFont
import func     TapSwiftFixesV2.synchronized
import class    UIKit.UIFont.UIFont
import Foundation

/*!
 @class         FontProvider
 @abstract      Utility class to retreive localized fonts.
 */
public class FontProvider {
    
    // MARK: - Public -
    // MARK: Methods
    
    /// Returns localized variant of font with a given original name of a given size for a given locale.
    ///
    /// - Parameters:
    ///   - originalName: Original font name.
    ///   - size: Font size
    ///   - languageIdentifier: Language identifier.
    /// - Returns: UIFont
    public static func localizedFont(_ originalName: TapFont, size: CGFloat, languageIdentifier: String) -> UIFont? {
        
        var fontName: TapFont
        
        #if TARGET_INTERFACE_BUILDER
        
        fontName = originalName
        
        #else
        
        if languageIdentifier == "ar" {
            
            fontName = self.arabicFontNames[originalName] ?? .arabicTajwalRegular
        }
        else {
            
            fontName = originalName
        }
        
        #endif
        
        return self.fontWith(name: fontName, size: size)
    }
    
    // MARK: - Internal -
    // MARK: Methods
    
    internal static func fontWith(name: TapFont, size: CGFloat) -> UIFont? {
        
        switch name {
            
        case .system(let systemFontName):
            
            guard let font = UIFont(name: systemFontName, size: size) else {
                
                fatalError("Failed to instantiate font \(systemFontName)")
            }
            
            return font
            
        default:
            
            break
        }
        
        return synchronized(self.loadedFonts) {
            
            if !self.loadedFonts.contains(name), self.loadFont(name) {
                
                self.loadedFonts.insert(name)
            }
            
            guard let font = UIFont(name: name.fileName, size: size) else {
                
                //fatalError("Failed to instantiate font \(name.fileName)")
                return nil
            }
            
            return font
        }
    }
    
    // MARK: - Private -
    
    private struct Constants {
        
        fileprivate static let resourcesBundleName = "Fonts"
        
        @available(*, unavailable) private init() {}
    }
    
    // MARK: Properties
    
    private static var arabicFontNames: [TapFont: TapFont] = {
        
        return [
            .robotoThin:     .arabicTajwalRegular,
            .robotoLight:     .arabicTajwalRegular,
            .robotoMedium:     .arabicTajwalBold,
            .robotoRegular:    .arabicTajwalMedium,
            .robotoBold:     .arabicTajwalBlack
        ]
    }()
    
    private static var loadedFonts: Set<TapFont> = {
        
        let fonts: [TapFont] = [
            .robotoThin,
            .robotoLight,
            .robotoMedium,
            .robotoRegular,
            .robotoBold,
            .arabicTajwalLight,
            .arabicTajwalRegular,
            .arabicTajwalMedium,
            .arabicTajwalBold,
            .arabicTajwalBlack
        ]
        
        
        UIFont.register(fontNames: fonts.map{ "\($0.fileName).\($0.fileExtension)" })
        
        return Set<TapFont>(fonts)
    }()
    
    private static let resourcesBundle: Bundle = {
        let bundle = Bundle(for: FontProvider.self)
        return bundle
    }()
    
    // MARK: Methods
    
    @available(*, unavailable) private init() {}
    
    private static func loadFont(_ fontName: TapFont) -> Bool {
        
        guard let fontURL = self.resourcesBundle.url(forResource: fontName.fileName, withExtension: fontName.fileExtension) else {
            
            print("There is no \(fontName.fileName).\(fontName.fileExtension) in fonts bundle.")
            return false
        }
        
        guard let fontData = try? Data(contentsOf: fontURL) else {
            
            print("Failed to load \(fontName.fileName).\(fontName.fileExtension) from fonts bundle.")
            return false
        }
        
        guard let dataProvider = CGDataProvider(data: fontData as CFData) else {
            
            print("Font data for \(fontName.fileName).\(fontName.fileExtension) is incorrect.")
            return false
        }
        
        guard let font = CGFont(dataProvider) else {
            
            print("Font data for \(fontName.fileName).\(fontName.fileExtension) is incorrect.")
            return false
        }
        
        var error: Unmanaged<CFError>? = nil
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            
            if let nonnullError = error, let errorDescription = CFErrorCopyDescription(nonnullError.takeRetainedValue()) {
                
                print("Error occured while registering font: \(errorDescription)")
                return false
            }
        }
        
        return true
    }
}


fileprivate extension UIFont {
    
    // load framework font in application
    static func register(fontNames:[String]) {
        fontNames.forEach{ registerFontWith(filenameString: $0, bundleIdentifierString: "Fonts") }
    }
    
    //MARK: - Make custom font bundle register to framework
    static func registerFontWith(filenameString: String, bundleIdentifierString: String) {
        //let frameworkBundle = Bundle(for: FontProvider.self)
        //let resourceBundleURL = frameworkBundle.url(forResource: bundleIdentifierString, withExtension: "bundle")
        let bundle = Bundle(for: FontProvider.self)
        
        if let pathForResourceString = bundle.path(forResource: filenameString, ofType: nil), let fontData = NSData(contentsOfFile: pathForResourceString), let dataProvider = CGDataProvider.init(data: fontData) {
            let fontRef = CGFont.init(dataProvider)
            var errorRef: Unmanaged<CFError>? = nil
            if (CTFontManagerRegisterGraphicsFont(fontRef!, &errorRef) == false) {
                print("Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
            }
        }
    }
}
