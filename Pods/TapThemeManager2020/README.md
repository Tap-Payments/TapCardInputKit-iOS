# TapThemeManager-iOS 

A SDK that provides an interface to theme iOS application with responsiveness between different themes.

[![Platform](https://img.shields.io/cocoapods/p/TapThemeManager2020.svg?style=flat)](https://github.com/Tap-Payments/TapThemeManger-iOS)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/TapThemeManager2020.svg?style=flat)](https://img.shields.io/Tap-Payments/v/TapThemeManager2020)



## Requirements

To use the SDK the following requirements must be met:

1. **Xcode 11.0** or newer
2. **Swift 4.0** or newer (preinstalled with Xcode)
3. Deployment target SDK for the app: **iOS 12.0** or later



## Installation

------

### Installation with CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager, which automates and simplifies the process of using 3rd-party libraries in your projects.
You can install it with the following command:

```
$ gem install cocoapods
```

### Podfile

To integrate goSellSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```
platform :ios, '12.0'
use_frameworks!

source 'https://github.com/CocoaPods/Specs.git'

target 'MyApp' do
    
    pod 'TapThemeManager2020'

end
```

Then, run the following command:

```
$ pod update
```



## Setup

------

First of all, `TapThememanager` should be set up by providing the theme itself. This can be provided as Plist or JSON file(s) or a given Theme Dictionary.



### Set the current theme

Below the different ways you can attach a certain theme file to the shared ThemeManager and how to change the theme at run time.



#### JSON File

Make sure the JSON file in the main bundle of your project.

*Swift*:

```swift
TapThemeManager.setTapTheme(jsonName: "MyThemeFile")
```

*Objective-C*:

```objective-c
[TapThemeManager setTapThemeWithJsonName:@"MyThemeFile"];
```

#### PLIST File

Make sure the PLIST file in the main bundle of your project.

*Swift*:

```swift
TapThemeManager.setTapTheme(plistName: "MyThemeFile")
```

*Objective-C*:

```objective-c
[TapThemeManager setTapThemeWithPlistName:@"MyThemeFile"];
```

#### Theme Dictionary

*Swift*:

```swift
TapThemeManager.setTapTheme(themeDict: ["MyLabelFontSize":22])
```

*Objective-C*:

```objective-c
[TapThemeManager setTapThemeWithThemeDict:@{@"MyLabelFontSize":@(22)}];
```



Don't forget to import the framework at the beginning of the file:

*Swift*:

```swift
import TapThemeManager2020
```

*Objective-C*:

```objective-c
@import TapThemeManager2020;
```

or

```objective-c
#import <TapThemeManager2020/TapThemeManager2020.h>
```



## Theme Accepted Values

------

As stated in [Setup](#requirements), the SDK requires a Theme (file or object) and the SDK does the magic for matching the values in the given Theme to the UI attributes for the UIKit subclasses.Here we will state the rane of acceptable values in the Theme (file or object.)

| Type                      | Usage                                                        | Accepted Formats                                             | Examples                                                     |
| ------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Hex Color                 | When you need to change an attribute that accepts UIColor or CGColor like UIView.backgroundColor or UIBar.barTintColor | 3, 4, 6, 8 Hex color codes                                   | "#RGB", "#RGBA", "#RRGGBB", "#RRGGBBAA"                      |
| Number                    | When you need to change an attribute that accepts CGFloat or Double, like UIView.alpha or UIVIew.layer.borderWidth | +ve floats                                                   | 0, 0.3, 5, 10.2                                              |
| Font                      | When you need to change an attribute that accepts UIFont, like UILabel.font | "Font FamilyName, Size" or "Size"                            | "FontFamilyName,23"  -> Creates a font using the given font name and size, "23" -> Creates a font using the default fonr and the given size |
| UIBarStyle                | When you need to change an attribute that accepts UIBarStyle, like UIBarStyle.barStyle | "default","black","blackTranslucent"                         |                                                              |
| UIImage                   | When you need to change an attribute that accepts UIImage, like UIImageView.image | String represents the image name you want to apply           | "MyImage"                                                    |
| Keyboard Appearance       | When you need to change an attribute that accepts UIKeyboardAppearance | "default","dark","light","alert"                             |                                                              |
| Navigation Bar Appearance | When you need to change an attribute that accepts UINavigationBarAppearance. **Requires iOS 13+** | Title Text Attributes<br />Large Text Attributes<br />Compact Appearance |                                                              |
| Scroll View Indicator     | When you need to change an attribute that accepts UIScrollView.IndicatorStyle. | "default"<br />"black"<br />"white"                          |                                                              |
| Status Bar Style          | When you need to change an attribute that accepts UIStatusBarStyle | "default"<br />"lightcontent"<br />"darkcontent" **Requires iOS 13+** |                                                              |
| Vibrance Blur             | When you need to change an attribute that accepts UIVisualEffect | "dark"<br />"light"<br />"extralight"<br />"prominent" **Requires iOS 10+**<br />"regular"  **Requires iOS 10+** |                                                              |
| String Attributes         | When you need to change an attribute that accepts NSAttributedString | A dictionary that has the needed attributes using the values given previously Font, Color, etc. |                                                              |

## Themeable attributes

------

The SDK provides interfaces for various subclasses of the UIKit to easily apply the theme value from the theme provided to the corresponding attribute in the UIKit subclass. Provided below some of the attributes the SDK supports for different UIViews. *To know what attributes the sdk supports, for any UIView just type .tap_theme and all avaliable methods will show*



### UIView

| SDK usage                        | UIKit Selector applied | Accepted Theme Value | Example Theme Value |
| -------------------------------- | ---------------------- | :------------------- | ------------------- |
| UIView.tap_theme_alpha           | setAlpha:              | Float                | 0.4                 |
| UIView.tap_theme_backgroundColor | setBackgroundColor:    | Hex color            | "#FF00FF"           |
| UIView.tap_theme_tintColor       | setAlpha:              | Hex color            | "#FF00FF"           |



### UIApplication

| SDK usage                                 | UIKit Selector applied      | Accepted Theme Value | Example Theme Value |
| ----------------------------------------- | --------------------------- | :------------------- | ------------------- |
| UIApplication.tap_theme_setStatusBarStyle | setStatusBarStyle:animated: | Status Bar Style     | "default"           |

### UIBarItem

| SDK usage                                  | UIKit Selector applied           | Accepted Theme Value | Example Theme Value  |
| ------------------------------------------ | -------------------------------- | :------------------- | -------------------- |
| UIBarItem.tap_theme_image                  | setImage:                        | UIImage              | "MyImageName"        |
| UIBarItem.tap_theme_setTitleTextAttributes | setTitleTextAttributes:forState: | String Attributes    | "NavigationTitle": { |

### UIBarButtonItem

| SDK usage                           | UIKit Selector applied | Accepted Theme Value | Example Theme Value |
| ----------------------------------- | ---------------------- | :------------------- | ------------------- |
| UIBarButtonItem.tap_theme_tintColor | setTintColor:          | Hex color            | "#FF00FF"           |

### UILabel

| SDK usage                              | UIKit Selector applied           | Accepted Theme Value | Example Theme Value  |
| -------------------------------------- | -------------------------------- | :------------------- | -------------------- |
| UILabel.tap_theme_font                 | setFont:                         | Font                 | "MyFontName,24"      |
| UILabel.tap_theme_textColor            | setTextColor:                    | Hex color            | "#FF00FF"            |
| UILabel.tap_theme_highlightedTextColor | setTextColor:                    | Hex color            | "#FF00FF"            |
| UILabel.tap_theme_shadowColor          | setShadowColor:                  | Hex color            | "#FF00FF"            |
| UILabel.tap_theme_textAttributes       | setTitleTextAttributes:forState: | String Attributes    | "NavigationTitle": { |

### UINavigationBar

| SDK usage                                          | UIKit Selector applied  | Accepted Theme Value | Example Theme Value  |
| -------------------------------------------------- | ----------------------- | :------------------- | -------------------- |
| UINavigationBar.tap_theme_barStyle                 | setBarStyle:            | Bar Style            | "default"            |
| UINavigationBar.tap_theme_barTintColor             | setBarTintColor:        | Hex color            | "#FF00FF"            |
| UINavigationBar.tap_theme_titleTextAttributes      | setTitleTextAttributes: | String Attributes    | "NavigationTitle": { |
| UINavigationBar.tap_theme_largeTitleTextAttributes | setTitleTextAttributes: | String Attributes    | "NavigationTitle": { |

### UITabBar

| SDK usage                                  | UIKit Selector applied      | Accepted Theme Value | Example Theme Value |
| ------------------------------------------ | --------------------------- | :------------------- | ------------------- |
| UITabBar.tap_theme_barStyle                | setBarStyle:                | Bar Style            | "default"           |
| UITabBar.tap_theme_unselectedItemTintColor | setUnselectedItemTintColor: | Hex color            | "#FF00FF"           |
| UITabBar.tap_theme_barTintColor            | setBarTintColor:            | Hex color            | "#FF00FF"           |

### UITabBarItem

| SDK usage                            | UIKit Selector applied | Accepted Theme Value | Example Theme Value |
| ------------------------------------ | ---------------------- | :------------------- | ------------------- |
| UITabBarItem.tap_theme_selectedImage | setSelectedImage:      | UIImage              | "MyImage"           |

### UITableView

| SDK usage                                         | UIKit Selector applied          | Accepted Theme Value | Example Theme Value |
| ------------------------------------------------- | ------------------------------- | :------------------- | ------------------- |
| UITableView.tap_theme_separatorColor              | setSeparatorColor:              | Hex color            | "#FF00FF"           |
| UITableView.tap_theme_sectionIndexColor           | setSectionIndexColor:           | Hex color            | "#FF00FF"           |
| UITableView.tap_theme_sectionIndexBackgroundColor | setSectionIndexBackgroundColor: | Hex color            | "#FF00FF"           |

### UITextField

| SDK usage                                   | UIKit Selector applied                | Accepted Theme Value | Example Theme Value  |
| ------------------------------------------- | ------------------------------------- | :------------------- | -------------------- |
| UITextField.tap_theme_font                  | setFont:                              | UIFont               | "MyFont,22"          |
| UITextField.tap_theme_keyboardAppearance    | setKeyboardAppearance:                | Keyboard Appearance  | "default"            |
| UITextField.tap_theme_textColor             | setTextColor:                         | Hex color            | "#FF00FF"            |
| UITextField.tap_theme_placeholderAttributes | tap_setPlaceholderAttributesSelector: | String Attributes    | "NavigationTitle": { |

### UITextView

| SDK usage                               | UIKit Selector applied | Accepted Theme Value | Example Theme Value |
| --------------------------------------- | ---------------------- | :------------------- | ------------------- |
| UITextView.tap_theme_font               | setFont:               | UIFont               | "MyFont,22"         |
| UITextView.tap_theme_keyboardAppearance | setKeyboardAppearance: | Keyboard Appearance  | "default"           |
| UITextView.tap_theme_textColor          | setTextColor:          | Hex color            | "#FF00FF"           |

## Theme File Example

------

We provide here a sample theme file and how to access different vales in it and match it with the corrent UIView.

### Sample Theme File

```json
{
  "CustomButton": {
    "buttonTitleColorHighlighted": "#555",
    "buttonTitleColorNormal": "#FFFFFF",
    "buttonBackgroundColor": "#ABA6BF"
  },
  "CustomView1": {
      "backgroundColor": "#36688D",
      "borderColor": "#F3CD05",
      "cornerRadius":4,
      "borderWidth": 2
  },
  "CustomLabel1": {
    "textColor": "#F3CD05",
    "font":"24"
  },
  "CustomView2": {
      "backgroundColor": "#F49F05",
      "borderColor": "#F18904",
      "cornerRadius":10,
      "borderWidth": 1
  },
  "CustomLabel2": {
    "textColor": "#F18904",
    "font":"24"
  },
  "CustomSwitch2": {
    "onTint": "#F18904",
    "thumbTint":"#36688D"
  },
  "CustomView3": {
      "backgroundColor": "#BDA589",
  },
  "CustomLabel3": {
    "textColor": "#FFFFFF",
    "font":"24"
  },
  "CustomUIImageView3": {
    "image": "icon_theme_1"
  },
  "Global": {
      "UIStatusBarStyle": "LightContent",
      "NavigationTint": "#FF0000",
      "NavigationTitle": {
          "NavigationTitleColor": "#FFFFFF",
          "Font":"24"
      }
  }
}

```

### Apply theme values code examples

#### SWIFT

```swift
// Apply background color for UIView
customView1.tap_theme_backgroundColor = "CustomView1.backgroundColor"
// Apply border color for UIView
customView1.layer.tap_theme_borderColor = "CustomView1.borderColor"
// Apply text color for UILabel
customLabel1.tap_theme_textColor = "CustomLabel1.textColor"
// Apply title color for UIButton in normal state
customButton.tap_theme_setTitleColor(selector: "CustomButton.buttonTitleColorNormal", forState: .normal)
// Apply text attributes

// 1- Fetch the main directory that has the attributes
self.navigationBar.tap_theme_titleTextAttributes = ThemeStringAttributesSelector(keyPath: "Global.NavigationTitle", map: { (entry) -> [NSAttributedString.Key : Any]? in
            // 2- Returns an array of all needed attributes
            return [NSAttributedString.Key.foregroundColor:TapThemeManager.colorValue(for: "Global.NavigationTitle.NavigationTitleColor")!,
                    NSAttributedString.Key.font:TapThemeManager.fontValue(for: "Global.NavigationTitle.Font")!]
        })
```

#### Objective-C

```objective-c
// Apply background color for UIView
 _CustomView1.tap_theme_backgroundColor = [ThemeUIColorSelector selectorWithKeyPath:@"CustomView1.backgroundColor"];
// Apply border color for UIView
_CustomView1.layer.tap_theme_borderColor = [ThemeCgColorSelector selectorWithKeyPath:@"CustomView1.borderColor"];
// Apply text color for UILabel
_customLabel1.tap_theme_textColor = [ThemeUIColorSelector selectorWithKeyPath:@"CustomLabel1.textColor"];
// Apply title color for UIButton in normal state
[_customButton tap_theme_setTitleColorWithSelector:[ThemeUIColorSelector selectorWithKeyPath:@"CustomButton.buttonTitleColorNormal"] forState:UIControlStateNormal];

// Apply text attributes

// 1- Fetch the main directory that has the attributes
self.navigationBar.tap_theme_titleTextAttributes = [ThemeStringAttributesSelector selectorWithKeyPath:@"Global.NavigationTitle" map:^NSDictionary<NSAttributedStringKey,id> * _Nullable(id entry) {
        // 2- Returns an array of all needed attributes
        NSMutableDictionary *attributesDictionary = [NSMutableDictionary dictionary];
             
        [attributesDictionary setObject:[TapThemeManager fontValueFor:@"Global.NavigationTitle.Font"] forKey:NSFontAttributeName];
        [attributesDictionary setObject:[TapThemeManager colorValueFor:@"Global.NavigationTitle.NavigationTitleColor"] forKey:NSForegroundColorAttributeName];
        return attributesDictionary;
    }];
}
```

