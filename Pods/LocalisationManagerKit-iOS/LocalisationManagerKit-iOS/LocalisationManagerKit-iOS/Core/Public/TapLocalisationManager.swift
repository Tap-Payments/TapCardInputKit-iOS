//
//  TapLocalisationManager.swift
//  LocalisationManagerKit-iOS
//
//  Created by Osama Rabie on 19/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
/// Represents  the tap localisation singleton class
@objc public class TapLocalisationManager: NSObject {
    
    /// This is the shared instance of the tap localiser, this is what you  have to use to access the available methods
    @objc public static let shared = TapLocalisationManager()
    /// Please set the localisation json file path you want the localiser to fetch values from
    @objc public var localisationFilePath:URL?
    /// Please set the locale you want the localiser to use
    @objc public var localisationLocale:String?
    
    /**
     This method returns the localised value for a given key
     - Parameter keyPath: The keypath of the value you want inside the json localisation object. Exampe "tapCardInput.cardNumberPlaceholder"
     - Parameter fallBackLocalisationFilePath: The keypath of a fallBack localisation file to use if the user didn't provide a localisation file or a malformed one. This will be used inside TAP kit's to provide its own defaut localistion as a fallBack. Default is nil
     - Returns: The localised value from the provided localisationFilePath if localisationFilePath and locale were provided and the key existed. The localised value from the fallBack if provided or the key given otherwise
     */
    @objc public func localisedValue(for keyPath:String,with fallBackLocalisationFilePath:URL? = nil) -> String {
        
        
        // by Default take the device locale
        var selectedLocale = localisationLocale ?? (Locale.current.languageCode ?? "en")
        // Check if the user configured the localisation file path and a locale
        if validConfiguration() {
            // This means, the user provided a correct localisation file path and it has the provided locale
            selectedLocale = localisationLocale ?? "en"
            // Now it is time to localise the value from the providede localisation file
            if let localisedValueFromProvidedFile:String = localise(for: keyPath, with: selectedLocale, from: localisationFilePath!) {
                return localisedValueFromProvidedFile
            }
        }
        
        // If we reached here, this means whether the used provided wrong data or the localistion file provided by the user misses the locale or the keypath provided, now it is time to check if the caller provided a fallBackFile to fetch from
        if let nonNullFullBack = fallBackLocalisationFilePath {
            // If we will use the fallBack provided file, we will try to fetch the localisation with the provided locale, if not found we will try with device's local otherwise try with en
            if let localisedValueFromProvidedFile:String = localise(for: keyPath, with: selectedLocale, from: nonNullFullBack) {
                // This means the fall back provided file has the value for the provided locale identefier
                return localisedValueFromProvidedFile
            }else if let localisedValueFromProvidedFile:String = localise(for: keyPath, with: (Locale.current.languageCode ?? "en"), from: nonNullFullBack) {
                // This means the fall back provided file didn't have the value for the provided locale identefier, but has the locale of the device
                return localisedValueFromProvidedFile
            }else if let localisedValueFromProvidedFile:String = localise(for: keyPath, with: "en", from: nonNullFullBack) {
                // This means we are trying to fall back to en if any
                return localisedValueFromProvidedFile
            }
        }
        
        return keyPath
    }
    
    
    
    
    
    /**
     Fetches the localised value from a given localisation file
     - Parameter keyPath:  The keypath of the value you want inside the json localisation object. Exampe "tapCardInput.cardNumberPlaceholder"
     - Parameter locale:   The locale you want the localiser to use
     - Parameter filePath: The localisation json file path you want the localiser to fetch values from
     */
    internal func localise(for keyPath:String, with locale:String, from filePath:URL) -> String? {
        // Try to fetch the localised value from the givn file
        do {
            // Check if the localisation file provided exists and readable
            let data = try Data(contentsOf: filePath)
            if let json:[String:Any] = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String : Any] {
                // Check if the JSON file has the stated keypath
                if let localisedValue:String = json[keyPath:KeyPath("\(locale).\(keyPath)")] as? String {
                    return localisedValue
                }
            }
        } catch  {}
        // Default is nil, this means the value didn't exist
        return nil
    }
    
    internal func validConfiguration() -> Bool {
        // Check if the user filled the needed values first
        if let nonNullLocalisationPath = localisationFilePath,
            let nonNullLocale = localisationLocale {
            
            do {
                // Check if the localisation file provided exists and readable
                let data = try Data(contentsOf: nonNullLocalisationPath)
                if let json:[String:Any] = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String : Any] {
                    // Check if the JSON file has the stated locale
                    if let _ = json[keyPath:KeyPath(nonNullLocale)] as? [String:Any] {
                        return true
                    }
                }
            } catch  {}
        }
        return false
    }
}


