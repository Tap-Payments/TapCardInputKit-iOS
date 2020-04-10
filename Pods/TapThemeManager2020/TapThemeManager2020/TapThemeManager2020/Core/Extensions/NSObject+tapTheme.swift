//
//  NSObject+tapTheme.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 09/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//

import class UIKit.UIView
import class UIKit.UINavigationBar
import class UIKit.UIColor
import class UIKit.CGColor
import class UIKit.UIControl
import enum UIKit.UIKeyboardAppearance
import class UIKit.UIScrollView
import class UIKit.UIActivityIndicatorView
import enum UIKit.UIStatusBarStyle
import enum UIKit.UIBarStyle
import struct UIKit.CGFloat
/// This class will define two set of extensions for the NSObject. One will provide set of methods to actually apply the theming values to the subview (like alpha, color, etc). The other extension will be set of methods to listen for theme changing and re draw itself when a theme changed


// Define set of typealiases to apply the selector for a theme selector in a nice and shorthanded way
fileprivate typealias applyCGColorValueWithSelector        = @convention(c) (NSObject, Selector, CGColor) -> Void
fileprivate typealias applyCGFloatValueWithSelector        = @convention(c) (NSObject, Selector, CGFloat) -> Void
fileprivate typealias applyValueForStateWithSelector       = @convention(c) (NSObject, Selector, AnyObject, UIControl.State) -> Void
fileprivate typealias applyKeyboardValueWithSelector       = @convention(c) (NSObject, Selector, UIKeyboardAppearance) -> Void
fileprivate typealias applyActivityStyleValueWithSelector  = @convention(c) (NSObject, Selector, UIActivityIndicatorView.Style) -> Void
fileprivate typealias applyScrollStyleValueWithSelector    = @convention(c) (NSObject, Selector, UIScrollView.IndicatorStyle) -> Void
fileprivate typealias applyBarStyleValueWithSelector       = @convention(c) (NSObject, Selector, UIBarStyle) -> Void
fileprivate typealias applyStatusBarStyleValueWithSelector = @convention(c) (NSObject, Selector, UIStatusBarStyle, Bool) -> Void

// Set of methods to actually apply a value from the theme file. Taking the value and the selector it needs to execute. The selector will be defined from the caller to tell the Object please attach this value using this selector
extension NSObject {
    
    /// Typealias to define an array of all implementted theme selectors each defined with a string key
     typealias ThemeSelectors = [String: ThemeSelector]
    
    var themeSelectors: ThemeSelectors {
        get {
            // If the array is filled, return it
            if let themeSelectors = objc_getAssociatedObject(self, &themeSelectorsKey) as? ThemeSelectors {
                return themeSelectors
            }
            // Otherwise, create an empty list of selectors
            let initValue = ThemeSelectors()
            objc_setAssociatedObject(self, &themeSelectorsKey, initValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return initValue
        }
        set {
            // Set it, first remove the theme update notification and set a new listener
            objc_setAssociatedObject(self, &themeSelectorsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            _removeUpdateThemeNotification()
            if newValue.isEmpty == false { _setupUpdateThemeNotification() }
        }
    }
    
    
    
    /**
     -  Method to apply a theme selector (holds a value from a theme file) to its matching attribute using the selector
     - Parameter methodSelector: The name of the selector that matches the value from the theme file (For example: setAlpha:, setBackgroundColor:)
     - Parameter themeSelector:  The theme selector which fetch and parse the value from the theme file to understanble value to be used with the methodSelector
     */
    func performThemeSelector(methodSelector: String, themeSelector: ThemeSelector?) {
        
        // Create the selector to perform from the given selector name
        let selectorToPerform = Selector(methodSelector)

        // Make sure that the current object can perform the given selector
        guard responds(to: selectorToPerform)else {
            // This case shouldn't happen, but a defenisve code added just in case to avoid crashes
            return
        }
        
        // Get the converted value from the theme file. For example, the theme file will have #000000 the themeSelector will provide it in an understandable object as UIColor
        guard let value = themeSelector?.value() else { return }
        
        // We need to define tthe type of tthe current theme value and based on it we apply the theme value
        if let statePicker = themeSelector as? ThemeStateSelector {
            // It is a theme value to applied to a certain Control state
            let setState = unsafeBitCast(method(for: selectorToPerform), to: applyValueForStateWithSelector.self)
            // Fetch the states availble for current object
            statePicker.values.forEach {
                // Make sure that currwnt object has the specified state
                guard let value = $1.value() else {
                    print("TapThemeManager WARNING: Missing value for ThemeState Selector: \(String(describing: selectorToPerform))")
                    return
                }
                // Apply the value to the matching state
                setState(self, selectorToPerform, value as AnyObject, UIControl.State(rawValue: $0))
            }
        }
       
        else if let statusBarStylePicker = themeSelector as? ThemeStatusBarStyleSelector {
            // It is a theme value to applied to the status bar
            let setStatusBarStyle = unsafeBitCast(method(for: selectorToPerform), to: applyStatusBarStyleValueWithSelector.self)
            setStatusBarStyle(self, selectorToPerform, value as! UIStatusBarStyle, statusBarStylePicker.animated)
        }
            
        else if themeSelector is ThemeBarStyleSelector {
            let setBarStyle = unsafeBitCast(method(for: selectorToPerform), to: applyBarStyleValueWithSelector.self)
            setBarStyle(self, selectorToPerform, value as! UIBarStyle)
        }
       
        else if themeSelector is ThemeKeyboardAppearanceSelector {
            let setKeyboard = unsafeBitCast(method(for: selectorToPerform), to: applyKeyboardValueWithSelector.self)
            setKeyboard(self, selectorToPerform, value as! UIKeyboardAppearance)
        }
            
        else if themeSelector is ThemeActivityIndicatorViewStyleSelector {
            let setActivityStyle = unsafeBitCast(method(for: selectorToPerform), to: applyActivityStyleValueWithSelector.self)
            setActivityStyle(self, selectorToPerform, value as! UIActivityIndicatorView.Style)
        }
            
        else if themeSelector is ThemeScrollViewIndicatorStyleSelector {
            let setIndicatorStyle = unsafeBitCast(method(for: selectorToPerform), to: applyScrollStyleValueWithSelector.self)
            setIndicatorStyle(self, selectorToPerform, value as! UIScrollView.IndicatorStyle)
        }
       
        else if themeSelector is ThemeCGFloatSelector {
            let setCGFloat = unsafeBitCast(method(for: selectorToPerform), to: applyCGFloatValueWithSelector.self)
            setCGFloat(self, selectorToPerform, value as! CGFloat)
        }
       
        else if themeSelector is ThemeCgColorSelector {
            let setCGColor = unsafeBitCast(method(for: selectorToPerform), to: applyCGColorValueWithSelector.self)
            setCGColor(self, selectorToPerform, value as! CGColor)
        }
       
        else { perform(selectorToPerform, with: value) }
    }
    
}

// Set of methods to provide an interface to add selector and fetch a certain selector for the calling object
extension NSObject
{
    /**
        - Interface to fetch a certain theme selector from the current object
        - Parameter methodSelector: The unique identifer for the theme selector. As each object should have one theme selector for each different UI attribute
        - Returns: The theme selector attatched with the passed method selector
     */
    internal func themeSelector(for methodSelector : String) -> ThemeSelector? {
        return self.themeSelectors[methodSelector]
    }

    /**
       - Interface to set a certain theme selector for a given method selector name
       - Parameter methodSelector: The unique identifer for the theme selector. As each object should have one theme selector for each different UI attribute
- Parameter themeSelector: The theme selector we want to attach to the current object
    */
    internal func setThemeSelector(with methodSelector : String,for themeSelector : ThemeSelector?) {
        self.themeSelectors[methodSelector] = themeSelector
        self.performThemeSelector(methodSelector: methodSelector, themeSelector: themeSelector)
    }

    /**
       - Interface to create a certain complex type of selectors. The one that is attached with a certain UIControl state
       - Parameter methodSelector: The unique identifer for the theme selector. As each object should have one theme selector for each different UI attribute
       - Parameter themeSelector: The theme selector we want to attach to the current object
       - Parameter controlState: The control state we want to attach the theme selector with
       - Returns: The theme selector attatched with the passed method selector
    */
    internal func stateSelector(with methodSelector : String,for themeSelector : ThemeSelector?,to controlState : UIControl.State) -> ThemeSelector? {
        
        var mutableThemeSelector = themeSelector
        if let stateSelector = self.themeSelectors[methodSelector] as? ThemeStateSelector {
            mutableThemeSelector = stateSelector.setSelector(mutableThemeSelector, forState: controlState)
        } else {
            mutableThemeSelector = ThemeStateSelector(selector: mutableThemeSelector, withState: controlState)
        }
        return mutableThemeSelector
    }
}

// Set of methods to setup the NSObject to listen for theme update and to update itself using the new current theme
extension NSObject {
    
    /// This method interface an object to listen to the notification sent form TapThemeManager when a new theme is updated
    fileprivate func _setupUpdateThemeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(_updateTapTheme), name: NSNotification.Name(rawValue: TapThemeUpdateNotification), object: nil)
    }
    
    /// This method interface an object to remove a the listener of the notification sent form TapThemeManager when a new theme is updated
    fileprivate func _removeUpdateThemeNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TapThemeUpdateNotification), object: nil)
    }
    
    /// This method interface for an object to loop through all the selectors applied to the current object to re apply it using the new theme
    @objc private func _updateTapTheme() {
        // Loop through each theme value attached to the current object and re apply it using the new vale from the new theme
        themeSelectors.forEach { methodSelector, themeSelector in
            UIView.animate(withDuration: TapThemeManager.themeUpdateAnimationDuration) {
                self.performThemeSelector(methodSelector: methodSelector, themeSelector: themeSelector)
                // For iOS 13, force an update of the nav bar when the theme changes.
                if #available(iOS 13.0, *) {
                    if let navBar = self as? UINavigationBar {
                        navBar.setNeedsLayout()
                    }
                }
            }
        }
    }
}


private var themeSelectorsKey = ""
