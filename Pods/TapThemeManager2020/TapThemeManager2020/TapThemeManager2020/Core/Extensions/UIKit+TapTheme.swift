//
//  UIKit+TapTheme.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 09/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//

import class UIKit.UIView
import class UIKit.UIApplication
import class UIKit.UIBarItem
import class UIKit.UIControl
import class UIKit.UIBarButtonItem
import class UIKit.UILabel
import class UIKit.UINavigationBar
import class UIKit.UITabBar
import class UIKit.UITableView
import class UIKit.UITabBarItem
import class UIKit.UITextField
import class UIKit.UITextView
import class UIKit.UISearchBar
import class UIKit.UIProgressView
import class UIKit.UIPageControl
import class UIKit.UIImageView
import class UIKit.UIActivityIndicatorView
import class UIKit.UIScrollView
import class UIKit.UIBarAppearance
import class UIKit.UINavigationBarAppearance
import class UIKit.UIVisualEffectView
import class UIKit.UIRefreshControl
import class UIKit.UIPopoverPresentationController
import class UIKit.UISlider
import class UIKit.UISwitch
import class UIKit.UISegmentedControl
import class UIKit.UIToolbar
import class UIKit.CALayer
import class UIKit.UIButton
/// This class provides extensions needed to SubViews to apply different types of theming using a nice shorthanded way. For example, instead of UIView.performSelector("setAlpha:",0) UIView.tap_alpha(0)

// MARK:- UIView

@objc public extension UIView
{
    var tap_theme_alpha: ThemeCGFloatSelector? {
        get { return self.themeSelector(for: SelectorsConstants.setAlphaSelector) as? ThemeCGFloatSelector }
        set { self.setThemeSelector(with: SelectorsConstants.setAlphaSelector, for: newValue)}
    }
    var tap_theme_backgroundColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for: SelectorsConstants.setBackgroundColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with: SelectorsConstants.setBackgroundColorSelector, for: newValue) }
    }
    var tap_theme_tintColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for: SelectorsConstants.setTintColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setTintColorSelector, for: newValue) }
    }
}

// MARK:- UIApplication
@objc public extension UIApplication
{
    func tap_theme_setStatusBarStyle(themeSelector: ThemeStatusBarStyleSelector, animated: Bool) {
        themeSelector.animated = animated
        
        self.setThemeSelector(with: SelectorsConstants.setStatusBarStyleAnimatedSelector, for: themeSelector)
    }
}

// MARK:- UIBarItem
@objc public extension UIBarItem
{
    var tap_theme_image: ThemeImageSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setImageSelector) as? ThemeImageSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setImageSelector, for: newValue) }
    }
    func tap_theme_setTitleTextAttributes(picker: ThemeStringAttributesSelector?, forState state: UIControl.State) {
        let stateSelector = self.stateSelector(with:  SelectorsConstants.setTitleTextAttributesForStateSelector, for: picker, to: state)
        self.setThemeSelector(with:  SelectorsConstants.setTitleTextAttributesForStateSelector, for: stateSelector)
    }
}


// MARK:- UIBarButtonItem
@objc public extension UIBarButtonItem
{
    var tap_theme_tintColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setTintColorSelector) as? ThemeUIColorSelector }
        set {self.setThemeSelector(with:  SelectorsConstants.setTintColorSelector, for: newValue) }
    }
}

// MARK:- UILabel
@objc public extension UILabel
{
    var tap_theme_font: ThemeFontSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setFontSelector) as? ThemeFontSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setFontSelector, for: newValue) }
    }
    var tap_theme_textColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setTextColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setTextColorSelector, for: newValue) }
    }
    var tap_theme_highlightedTextColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setHighlightedTextColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setHighlightedTextColorSelector, for: newValue) }
    }
    var tap_theme_shadowColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setShadowColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setShadowColorSelector, for: newValue) }
    }
    var tap_theme_textAttributes: ThemeStringAttributesSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.tap_setTextAttributesSelector) as? ThemeStringAttributesSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.tap_setTextAttributesSelector, for: newValue) }
    }
}


// MARK:- UINavigationBar
@objc public extension UINavigationBar
{
    var tap_theme_barStyle: ThemeBarStyleSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setBarStyleSelector) as? ThemeBarStyleSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setBarStyleSelector, for: newValue) }
    }
    
    var tap_theme_barTintColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setBarTintColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setBarTintColorSelector, for: newValue) }
    }
    var tap_theme_titleTextAttributes: ThemeStringAttributesSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setTitleTextAttributesSelector) as? ThemeStringAttributesSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setTitleTextAttributesSelector, for: newValue) }
    }
    var tap_theme_largeTitleTextAttributes: ThemeStringAttributesSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setLargeTitleTextAttributesSelector) as? ThemeStringAttributesSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setLargeTitleTextAttributesSelector, for: newValue) }
    }
    @available(iOS 13.0, *)
    var tap_theme_standardAppearance: ThemeNavigationBarAppearanceSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setStandardAppearanceSelector) as? ThemeNavigationBarAppearanceSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setStandardAppearanceSelector, for: newValue) }
    }
    @available(iOS 13.0, *)
    var tap_theme_compactAppearance: ThemeNavigationBarAppearanceSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setCompactAppearanceSelector) as? ThemeNavigationBarAppearanceSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setCompactAppearanceSelector, for: newValue) }
    }
    @available(iOS 13.0, *)
    var tap_theme_scrollEdgeAppearance: ThemeNavigationBarAppearanceSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setScrollEdgeAppearanceSelector) as? ThemeNavigationBarAppearanceSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setScrollEdgeAppearanceSelector, for: newValue) }
    }
}


// MARK:- UITabBar
@objc public extension UITabBar
{
    var tap_theme_barStyle: ThemeBarStyleSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setBarStyleSelector) as? ThemeBarStyleSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setBarStyleSelector, for: newValue) }
    }
    
    var tap_theme_unselectedItemTintColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setUnselectedItemTintColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setUnselectedItemTintColorSelector, for: newValue) }
    }
    var tap_theme_barTintColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setBarTintColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setBarTintColorSelector, for: newValue) }
    }
}

// MARK:- UITabBarItem
@objc public extension UITabBarItem
{
    var tap_theme_selectedImage: ThemeImageSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setSelectedImageSelector) as? ThemeImageSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setSelectedImageSelector, for: newValue) }
    }
}


// MARK:- UITableView
@objc public extension UITableView
{
    var tap_theme_separatorColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setSeparatorColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setSeparatorColorSelector, for: newValue) }
    }
    var tap_theme_sectionIndexColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setSectionIndexColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setSectionIndexColorSelector, for: newValue) }
    }
    var tap_theme_sectionIndexBackgroundColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setSectionIndexBackgroundColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setSectionIndexBackgroundColorSelector, for: newValue) }
    }
}



// MARK:- UITextField
@objc public extension UITextField
{
    var tap_theme_font: ThemeFontSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setFontSelector) as? ThemeFontSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setFontSelector, for: newValue) }
    }
    var tap_theme_keyboardAppearance: ThemeKeyboardAppearanceSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setKeyboardAppearanceSelector) as? ThemeKeyboardAppearanceSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setKeyboardAppearanceSelector, for: newValue) }
    }
    var tap_theme_textColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for: SelectorsConstants.setTextColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setTextColorSelector, for: newValue) }
    }
    var tap_theme_placeholderAttributes: ThemeStringAttributesSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.tap_setPlaceholderAttributesSelector) as? ThemeStringAttributesSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.tap_setPlaceholderAttributesSelector, for: newValue) }
    }
}

// MARK:- UITextView
@objc public extension UITextView
{
    var tap_theme_font: ThemeFontSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setFontSelector) as? ThemeFontSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setFontSelector, for: newValue) }
    }
    var tap_theme_keyboardAppearance: ThemeKeyboardAppearanceSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setKeyboardAppearanceSelector) as? ThemeKeyboardAppearanceSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setKeyboardAppearanceSelector, for: newValue) }
    }
    var tap_theme_textColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setTextColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setTextColorSelector, for: newValue) }
    }
}

// MARK:- UISearchBar
@objc public extension UISearchBar
{
    var tap_theme_barStyle: ThemeBarStyleSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setBarStyleSelector) as? ThemeBarStyleSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setBarStyleSelector, for: newValue) }
    }
    var tap_theme_keyboardAppearance: ThemeKeyboardAppearanceSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setKeyboardAppearanceSelector) as? ThemeKeyboardAppearanceSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setKeyboardAppearanceSelector, for: newValue) }
    }
    var tap_theme_barTintColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setBarTintColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setBarTintColorSelector, for: newValue) }
    }
}

// MARK:- UIProgressView
@objc public extension UIProgressView
{
    var tap_theme_progressTintColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setProgressTintColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setProgressTintColorSelector, for: newValue) }
    }
    var tap_theme_trackTintColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setTrackTintColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setTrackTintColorSelector, for: newValue) }
    }
}

// MARK:- UIPageControl
@objc public extension UIPageControl
{
    var tap_theme_pageIndicatorTintColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setPageIndicatorTintColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setPageIndicatorTintColorSelector, for: newValue) }
    }
    var tap_theme_currentPageIndicatorTintColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setCurrentPageIndicatorTintColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setCurrentPageIndicatorTintColorSelector, for: newValue) }
    }
}

// MARK:- UIImageView
@objc public extension UIImageView
{
    var tap_theme_image: ThemeImageSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setImageSelector) as? ThemeImageSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setImageSelector, for: newValue) }
    }
}

// MARK:- UIActivityIndicatorView
@objc public extension UIActivityIndicatorView
{
    var tap_theme_color: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setColorSelector, for: newValue) }
    }
    var tap_theme_activityIndicatorViewStyle: ThemeActivityIndicatorViewStyleSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setActivityIndicatorViewStyleSelector) as? ThemeActivityIndicatorViewStyleSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setActivityIndicatorViewStyleSelector, for: newValue) }
    }
}

// MARK:- UIScrollView
@objc public extension UIScrollView
{
    var tap_theme_indicatorStyle: ThemeScrollViewIndicatorStyleSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setIndicatorStyleSelector) as? ThemeScrollViewIndicatorStyleSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setIndicatorStyleSelector, for: newValue) }
    }
}


// MARK:- UIButton
@objc public extension UIButton
{
    func tap_theme_setImage(selector: ThemeImageSelector?, forState state: UIControl.State) {
        let selector = stateSelector(with: SelectorsConstants.setImageforStateSelector, for: selector, to: state)
        self.setThemeSelector(with:  SelectorsConstants.setImageforStateSelector, for: selector)
    }
    func tap_theme_setBackgroundImage(selector: ThemeImageSelector?, forState state: UIControl.State) {
        let selector = stateSelector(with: SelectorsConstants.setBackgroundImageforStateSelector, for: selector, to: state)
        self.setThemeSelector(with:  SelectorsConstants.setBackgroundImageforStateSelector, for: selector)
    }
    func tap_theme_setTitleColor(selector: ThemeUIColorSelector?, forState state: UIControl.State) {
        let selector = stateSelector(with: SelectorsConstants.setTitleColorforStateSelector, for: selector, to: state)
        self.setThemeSelector(with: SelectorsConstants.setTitleColorforStateSelector, for: selector)
    }
}

// MARK:- CALayer
@objc public extension CALayer
{
    var tap_theme_backgroundColor: ThemeCgColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setBackgroundColorSelector) as? ThemeCgColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setBackgroundColorSelector, for: newValue) }
    }
    var tap_theme_borderWidth: ThemeCGFloatSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setBorderWidthSelector) as? ThemeCGFloatSelector }
        set { self.setThemeSelector(with: SelectorsConstants.setBorderWidthSelector, for: newValue) }
    }
    var tap_theme_borderColor: ThemeCgColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setBorderColorSelector) as? ThemeCgColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setBorderColorSelector, for: newValue) }
    }
    var tap_theme_shadowColor: ThemeCgColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setShadowColorSelector) as? ThemeCgColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setShadowColorSelector, for: newValue) }
    }
    
    var tap_theme_shadowRadius: ThemeCGFloatSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setShadowRadiusSelector) as? ThemeCGFloatSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setShadowRadiusSelector, for: newValue) }
    }
    
    var tap_theme_shadowOpacity: ThemeCGFloatSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setShadowOpacitySelector) as? ThemeCGFloatSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setShadowOpacitySelector, for: newValue) }
    }
    
    var tap_theme_strokeColor: ThemeCgColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setStrokeColorSelector) as? ThemeCgColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setStrokeColorSelector, for: newValue) }
    }
    var tap_theme_fillColor: ThemeCgColorSelector? {
        get { return self.themeSelector(for: SelectorsConstants.setFillColorSelector) as? ThemeCgColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setFillColorSelector, for: newValue) }
    }
    var tap_theme_cornerRadious: ThemeCGFloatSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setCornerRadiusSelector) as? ThemeCGFloatSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setCornerRadiusSelector, for: newValue) }
    }
}

// MARK:- UIToolbar
@objc public extension UIToolbar
{
    var tap_theme_barStyle: ThemeBarStyleSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setBarStyleSelector) as? ThemeBarStyleSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setBarStyleSelector, for: newValue) }
    }
    var tap_theme_barTintColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setBarTintColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setBarTintColorSelector, for: newValue) }
    }
}

// MARK:- UISegmentedControl
@objc public extension UISegmentedControl
{
    var tap_theme_selectedSegmentTintColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setSelectedSegmentTintColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with: SelectorsConstants.setSelectedSegmentTintColorSelector, for: newValue) }
    }
    func theme_setTitleTextAttributes(selector: ThemeStringAttributesSelector?, forState state: UIControl.State) {
        let selector = stateSelector(with: SelectorsConstants.setTitleTextAttributesForStateSelector, for: selector, to: state)
        self.setThemeSelector(with:  SelectorsConstants.setTitleTextAttributesForStateSelector, for: selector)
    }
}

// MARK:- UISwitch
@objc public extension UISwitch
{
    var tap_theme_onTintColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for: SelectorsConstants.setOnTintColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with: SelectorsConstants.setOnTintColorSelector, for: newValue) }
    }
    var tap_theme_thumbTintColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setThumbTintColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setThumbTintColorSelector, for: newValue) }
    }
}

// MARK:- UISlider
@objc public extension UISlider
{
    var tap_theme_thumbTintColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setThumbTintColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setThumbTintColorSelector, for: newValue) }
    }
    var tap_theme_minimumTrackTintColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setMinimumTrackTintColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setMinimumTrackTintColorSelector, for: newValue) }
    }
    var tap_theme_maximumTrackTintColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setMaximumTrackTintColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setMaximumTrackTintColorSelector, for: newValue) }
    }
}

// MARK:- UIPopoverPresentationController
@objc public extension UIPopoverPresentationController
{
    var tap_theme_backgroundColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setBackgroundColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setBackgroundColorSelector, for: newValue) }
    }
}

// MARK:- UIRefreshControl
@objc public extension UIRefreshControl
{
    var tap_theme_titleAttributes: ThemeStringAttributesSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.tap_setTitleAttributesSelector) as? ThemeStringAttributesSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.tap_setTitleAttributesSelector, for: newValue) }
    }
}

// MARK:- UIVisualEffectView
@objc public extension UIVisualEffectView
{
    var tap_theme_effect: ThemeVibranceBlurEffectSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setEffectSelector) as? ThemeVibranceBlurEffectSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setEffectSelector, for: newValue) }
    }
}

// MARK:- UINavigationBarAppearance
@available(iOS 13.0, *)
public extension UINavigationBarAppearance
{
    var tap_theme_titleTextAttributes: ThemeStringAttributesSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setTitleTextAttributesSelector) as? ThemeStringAttributesSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setTitleTextAttributesSelector, for: newValue) }
    }
    var tap_theme_largeTitleTextAttributes: ThemeStringAttributesSelector? {
        get { return self.themeSelector(for: SelectorsConstants.setLargeTitleTextAttributesSelector) as? ThemeStringAttributesSelector }
        set { self.setThemeSelector(with: SelectorsConstants.setLargeTitleTextAttributesSelector, for: newValue) }
    }
    var tap_theme_backIndicatorImage: ThemeImageSelector? {
        get { return self.themeSelector(for: SelectorsConstants.setBackIndicatorImageSelector) as? ThemeImageSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setBackIndicatorImageSelector, for: newValue) }
    }
}

// MARK:- UIBarAppearance
@available(iOS 13.0, *)
@objc public extension UIBarAppearance
{
    var tap_theme_backgroundColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setBackgroundColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setBackgroundColorSelector, for: newValue) }
    }
    var tap_theme_backgroundImage: ThemeImageSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setBackgroundImageSelector) as? ThemeImageSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setBackgroundImageSelector, for: newValue) }
    }
    var tap_theme_backgroundEffect: ThemeBlurEffectSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setBackgroundEffectSelector) as? ThemeBlurEffectSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setBackgroundEffectSelector, for: newValue) }
    }
    var tap_theme_shadowColor: ThemeUIColorSelector? {
        get { return self.themeSelector(for:  SelectorsConstants.setShadowColorSelector) as? ThemeUIColorSelector }
        set { self.setThemeSelector(with:  SelectorsConstants.setShadowColorSelector, for: newValue) }
    }
    var tap_theme_shadowImage: ThemeImageSelector? {
        get { return self.themeSelector(for: SelectorsConstants.setShadowImageSelector) as? ThemeImageSelector }
        set { self.setThemeSelector(with: SelectorsConstants.setShadowImageSelector, for: newValue) }
    }
}
