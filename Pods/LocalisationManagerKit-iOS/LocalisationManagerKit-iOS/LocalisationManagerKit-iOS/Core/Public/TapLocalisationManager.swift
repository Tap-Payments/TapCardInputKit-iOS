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
    /// An enum to define the source of the provided custom localisation file whether local or remote based
    @objc public var localisationType:TapLocalisationType = .LocalJsonFile
    /// Represents a direct provided JSON localisation data
    @objc public var providedLocalisationData:[String:Any]?
    /// The localisation data whether fetched from a given local or remote localisation cusom json file
    internal var localisationData:[String:Any]? = nil
    
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
            // This means, the user provided a correct localisation file path/Data and it has the provided locale
            selectedLocale = localisationLocale ?? "en"
            // Now it is time to localise the value from the providede localisation file or the provided data
            if localisationType == .DirectData {
                if let localisedValueFromProvidedData:String = localise(for: keyPath, with: selectedLocale) {
                    return localisedValueFromProvidedData
                }
            }else if let localisedValueFromProvidedFile:String = localise(for: keyPath, with: selectedLocale, from: localisationFilePath!) {
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
     Configures the localisation manager with custom localisation data loading from file or from a provided localisation data
     - Parameter filePath: The url to the file that contains the custom localisation data whether remote or a local path
     - Parameter localistionData: Represents a direct provided JSON localisation data
     - Parameter localisationType: Defines whether the passed file is a local or remote based one
     - Returns: True if the file was located and has valid json format, false otherwise.
     PS : If you path a file url then the type should be .LocalJsonFile OR .RemoteJsonFile.
     */
    @objc public func configureLocalisation(with filePath:URL?, or localistionData:[String:Any]?, from localisationType:TapLocalisationType) -> Bool {
        // Let us make sure the user provided the correct combinations
        if let filePath = filePath,
           (localisationType == .RemoteJsonFile || localisationType == .LocalJsonFile){
            // Provided a localisation file url
            return configureLocalisationFromFile(with: filePath, from: localisationType)
        }else if let localistionData = localistionData,
                 localisationType == .DirectData {
            // provided a direct localistion data
            return configureLocalisationFromDirectData(with: localistionData)
        }
        return false
    }
    
    /**
     Configures the localisation manager with custom localisation data loading from file
     - Parameter filePath: The url to the file that contains the custom localisation data whether remote or a local path
     - Parameter localisationType: Defines whether the passed file is a local or remote based one
     - Returns: True if the file was located and has valid json format, false otherwise
     */
    internal func configureLocalisationFromFile(with filePath:URL, from localisationType:TapLocalisationType) -> Bool {
        switch localisationType {
        case .LocalJsonFile:
            return fetchLocalLocalisationData(with: filePath)
        case .RemoteJsonFile:
            return fetchRemoteLocalisationData(filePath: filePath)
        default: return false
        }
    }
    
    
    /**
     Configures the localisation manager with provided localistion data
     - Parameter localistionData: Represents a direct provided JSON localisation data
     - Returns: True if the file was located and has valid json format, false otherwise
     */
    internal func configureLocalisationFromDirectData(with localistionData:[String:Any]) -> Bool {
        self.localisationData = localistionData
        self.localisationType = .DirectData
        return true
    }
    
    /**
     Fetches the localisation data from a local json custom file
     - Parameter filePath:The localisation json file path you want the localiser to fetch values from
     - Returns: True if successfuly the file was located and converted into a JSON format, false otherwise
     */
    internal func fetchLocalLocalisationData(with filePath:URL) -> Bool {
        // Try to fetch the localised value from the givn file
        do {
            // Check if the localisation file provided exists and readable
            let data = try Data(contentsOf: filePath)
            if let json:[String:Any] = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String : Any] {
                localisationData = json
                localisationFilePath = filePath
                localisationType = .LocalJsonFile
                return true
            }
        } catch  {}
        return false
    }
    
    
    /**
     Fetches the localisation data from a remote json custom file
     - Parameter filePath:The localisation json file path you want the localiser to fetch values from
     - Returns: True if successfuly the file was located and converted into a JSON format, false otherwise
     */
    internal func fetchRemoteLocalisationData(filePath:URL) -> Bool {
        var result:Bool = false
        // Validate the url
        guard validateJsonRemoteURL(remoteURL: filePath) else {
            return result
        }
        
        // Then let us load the data
        // Make it a sync call
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: filePath) {[weak self] (data, response, error) in
            // Check the data is loaded properly, no errors, and the data is a parsable json format
            if let nonNullData = data,
               let nonNullJsonDictionary = try? JSONSerialization.jsonObject(with: nonNullData, options: .allowFragments) as? [String:Any] {
                // All good
                result = true
                // Store the data for further access
                self?.localisationData = nonNullJsonDictionary
                self?.localisationFilePath = filePath
                self?.localisationType = .RemoteJsonFile
                semaphore.signal()
            }else{
                // Something happened
                semaphore.signal()
            }
        }
        
        task.resume()
        semaphore.wait()
        
        return result
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
    
    
    /**
     Fetches the localised value from the parsed and saved data
     - Parameter keyPath:  The keypath of the value you want inside the json localisation object. Exampe "tapCardInput.cardNumberPlaceholder"
     - Parameter locale:   The locale you want the localiser to use
     */
    internal func localise(for keyPath:String, with locale:String) -> String? {
        guard let localisationData = localisationData,
              let localisedValue:String = localisationData[keyPath:KeyPath("\(locale).\(keyPath)")] as? String else {
            return nil
        }
        return localisedValue
    }
    
    
    /**
     Decides if the given URL is a valid url and is pointing to a json file
     - Parameter remoteURL : The url to be checked
     - Returns: True if the remoteURL is a valid URL and points to a Json file, false otherwise
     */
    internal func validateJsonRemoteURL(remoteURL: URL) -> Bool {
        // Validate the given string to be a valid URL and of a json file
        guard remoteURL.absoluteString.isValidURL,
              remoteURL.absoluteString.hasSuffix("json") else {
            return false
        }
        return true
    }
    
    
    internal func validConfiguration() -> Bool {
        // Check if the user filled the needed values first
        
        // User provided a valid source to fetch json data from
        if let nonNullLocalisationData = localisationData,
           // The user provided a locale
           let nonNullLocale = localisationLocale,
           // The parsed localisation data has an entry for the selected locale
           let _ = nonNullLocalisationData[keyPath:KeyPath(nonNullLocale)] as? [String:Any] {
            return true
        }
        return false
    }
}


/// An enum to define the source of the provided custom localisation file whether local or remote based
@objc public enum TapLocalisationType : Int {
    /// The custom localisation file is an embedded json file
    case LocalJsonFile
    /// The custom localisation file is a remote  json file
    case RemoteJsonFile
    /// The custom localisation data is provided directly to the localisation manager
    case DirectData
}





fileprivate extension String {
    /// Decides if the given string is a valid URL format
    var isValidURL: Bool {
        // Define a charachter set that defines all availble charachters in a link
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count && !self.isEmpty
        } else {
            return false
        }
    }
}
