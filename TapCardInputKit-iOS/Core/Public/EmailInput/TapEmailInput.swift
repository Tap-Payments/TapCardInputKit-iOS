//
//  TapEmailInput.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 7/15/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import SnapKit
import TapThemeManager2020
import TapCardVlidatorKit_iOS
import LocalisationManagerKit_iOS
import class CommonDataModelsKit_iOS.TapCommonConstants

/// External protocol to allow the TapPhoneInput to pass back data and events to the parent UIViewController
@objc public protocol TapEmailInputProtocol {
    /**
     This method will be called whenever the email  changed. It is being called in a live manner
     - Parameter email: The new email after the last update done bu the user
     - Parameter validation: Tells the validity of the detected brand, whether it is invalid, valid or still incomplete
     */
    @objc optional func emailChanged(email:String,with validation:CrardInputTextFieldStatusEnum)
    
    /// This method will be called whenever the user hits return on the email text
    @objc optional func emailReturned(with email:String)
}


/// This represents the custom view for phone number input provided by Tap
@objc public class TapEmailInput: UIView {
    
    /// The phone input image icon
    internal lazy var icon = UIImageView()
    /// The clear button
    internal lazy var clearButton = UIButton()
    /// The text field to enter the phone number
    internal lazy var emailTextField  = UITextField()
    /// This defines in which path should we look into the theme based on the card input mode
    internal var themePath:String = "emailCard"
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// The placeholder color used in the fields read from theme file and black as fallback
    internal var textFieldsplaceHolderColor:UIColor {
        return TapThemeManager.colorValue(for: "\(themePath).textFields.placeHolderColor") ?? .green
    }
    internal let sharedLocalisationManager:TapLocalisationManager = .shared
    
    /// A delegate listener to listen to the events fired from the phone input form fields
    @objc public var delegate:TapEmailInputProtocol?
    
    
    // Mark:- Init methods
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    @objc public required init?(coder: NSCoder) {
        super.init(coder:coder)
        self.backgroundColor = .clear
        semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight
    }
    
    
    ///Call this method when you  need to setup the view
    @objc public func setup() {
        setupViews()
    }
    
    /**
     Gets the email in the email field
     - Returns: The typed email or an empty string
     */
    @objc public func email() -> String {
        return emailTextField.text ?? ""
    }
    
    /// Focuses the keyboard for the email input
    @objc public func focus() {
        emailTextField.becomeFirstResponder()
    }
    
    @objc public func validationStatus() -> CrardInputTextFieldStatusEnum {
        // Now we need to validate the email entered
        // So we validate it using the telecom brands we have available
        let validationStatus:Bool = emailTextField.text?.isValidEmail() ?? false
        return (validationStatus) ? .Valid : .Invalid
    }
    
    /// This method is the brain controller of showing the views, as it taks the process for adding subview, laying them out and applying the theme
    internal func setupViews() {
        // Match the theme attributes to the right views
        matchThemeAttributes()
        // Add the the subviews first to the parent view
        addViews()
        // Then we need to layout them properly by creating the correct layout constraints
        setupConstraints()
        // Configure the views
        configureViews()
    }
    
    /// The method that layouts the subviews properly by creating the correct layout constraints
    internal func setupConstraints() {
        
        icon.snp.remakeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(29)
            make.height.equalTo(19)
            make.width.equalTo(26)
        }
        
        
        clearButton.snp.remakeConstraints { (make) in
            make.width.equalTo(24)
            make.trailing.equalToSuperview().offset(-26)
            make.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        emailTextField.snp.remakeConstraints {(make) in
            make.centerY.equalTo(icon.snp.centerY).offset((TapLocalisationManager.shared.localisationLocale == "ar") ? 4 : 0)
            make.leading.equalToSuperview().offset(65)
            make.trailing.equalTo(clearButton.snp.leading).offset(10)
            make.height.equalToSuperview()
        }
        
    }
    
    
    /// The method that adds delegates and specific logic to each sub view in the phone input form
    internal func configureViews() {
        // Set the place holders values with the theme color
        adjustFieldsPlaceHolders()
        
        // Set the correct font type and colors
        adjustFieldsTextFonts()
        
        // Set the keyboard type for the fields
        emailTextField.keyboardType = .emailAddress
        
        emailTextField.delegate = self
        
        emailTextField.returnKeyType = .next
        
        emailTextField.autocorrectionType = .no
        
        emailTextField.spellCheckingType = .no
        
        emailTextField.textAlignment = (sharedLocalisationManager.localisationLocale == "ar") ? .right : .left
        
        clearButton.addTarget(self, action: #selector(clearEmailInput), for: .touchUpInside)
    }
    
    
    /// Handles the logic of clearing and reseting the component
    @objc public func clearEmailInput() {
        
        emailTextField.text = ""
        didChangeText(textField: emailTextField)
        
    }
    
    /// Set the place holders values with the theme color
    internal func adjustFieldsPlaceHolders() {
        let placeHolderAttributes = [NSAttributedString.Key.foregroundColor: textFieldsplaceHolderColor]
        
        
        // The default localisation file location
        let defaultLocalisationFilePath:URL = TapCommonConstants.pathForDefaultLocalisation()
        // Assign the localisation values
        
        emailTextField.attributedPlaceholder = NSAttributedString(string:sharedLocalisationManager.localisedValue(for: "TapCardInputKit.emailPlaceHolder", with: defaultLocalisationFilePath),  attributes: placeHolderAttributes)
        
        // Listen to the event of text change
        emailTextField.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
    }
    
    /// Sets the correct text fonts and colors to the associated textfields
    internal func adjustFieldsTextFonts() {
        emailTextField.tap_theme_font = ThemeFontSelector.init(stringLiteral: "\(themePath).textFields.font")
        emailTextField.tap_theme_textColor = ThemeUIColorSelector.init(stringLiteral: "\(themePath).textFields.textColor")
    }
    
    /// The method that adds the subviews
    internal func addViews() {
        addSubview(icon)
        addSubview(clearButton)
        addSubview(emailTextField)
    }
}


extension TapEmailInput {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        // background color
        self.tap_theme_backgroundColor = ThemeUIColorSelector.init(keyPath: "\(themePath).commonAttributes.backgroundColor")
        // The border color
        self.layer.tap_theme_borderColor = ThemeCgColorSelector.init(keyPath: "\(themePath).commonAttributes.borderColor")
        // The border width
        self.layer.tap_theme_borderWidth = ThemeCGFloatSelector.init(keyPath: "\(themePath).commonAttributes.borderWidth")
        // The border rounded corners
        self.layer.tap_theme_cornerRadious = ThemeCGFloatSelector.init(keyPath: "\(themePath).commonAttributes.cornerRadius")
        
        // The shadow details
        self.layer.shadowRadius = CGFloat(TapThemeManager.numberValue(for: "\(themePath).commonAttributes.shadow.radius")?.floatValue ?? 0)
        self.layer.tap_theme_shadowColor = ThemeCgColorSelector.init(keyPath: "\(themePath).commonAttributes.shadow.color")
        self.layer.shadowOffset = CGSize(width: CGFloat(TapThemeManager.numberValue(for: "\(themePath).commonAttributes.shadow.offsetWidth")?.floatValue ?? 0), height: CGFloat(TapThemeManager.numberValue(for: "\(themePath).commonAttributes.shadow.offsetHeight")?.floatValue ?? 0))
        self.layer.shadowOpacity = 0//Float(TapThemeManager.numberValue(for: "\(themePath).commonAttributes.shadow.opacity")?.floatValue ?? 0)
        self.layer.masksToBounds = false
        self.clearButton.setImage(TapThemeManager.imageValue(for: "\(themePath).clearImage.image",from: Bundle(for: type(of: self))), for: .normal)
        self.clearButton.alpha = emailTextField.text == "" ? 0 : 1
        
        // The default card brand icon
        icon.image = TapThemeManager.imageValue(for: "\(themePath).iconImage.image",from: Bundle(for: type(of: self)))
        icon.contentMode = .scaleAspectFit
        
        configureViews()
        
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        
        guard lastUserInterfaceStyle != self.traitCollection.userInterfaceStyle else {
            return
        }
        lastUserInterfaceStyle = self.traitCollection.userInterfaceStyle
        applyTheme()
    }
    
    
    /// Method that glows or the dims the card input view based on the shadow theme provided and if any of the fields is active
    internal func  updateShadow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // The final value we will animate the shadow opacity , default is 0
            var finalShadowOpacity:Float = 0.0
            // Calculate the starting valye which is the current opacity level
            let startingValue:Float = self.layer.shadowOpacity
            // Check if any of the fields is active first
            if self.emailTextField.isEditing {
                // Now we found one that is active, then we need to glow it based on the value provided from the theme
                finalShadowOpacity = Float(TapThemeManager.numberValue(for: "\(self.themePath).commonAttributes.shadow.opacity")?.floatValue ?? 0
                )
            }
            // If the value we want to animate to is the current one, then we have to do nothing
            if finalShadowOpacity == startingValue { return }
            
            // Animate the change of the shadow opacity
            let shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
            shadowAnimation.fromValue = startingValue
            shadowAnimation.toValue = finalShadowOpacity
            shadowAnimation.duration = 0.5
            self.layer.add(shadowAnimation, forKey: "shadowOpacity")
            self.layer.shadowOpacity = finalShadowOpacity
        }
    }
    
    internal func changeText(with emailString:String) -> Bool {
        // no restrictions on the email values
        return true
    }
}

extension TapEmailInput: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        // add their new text to the existing text
        let updatedText:String = currentText.replacingCharacters(in: stringRange, with: string)
        // Check if the new string is a valid one to allow writing it to the card number field
        return changeText(with: updatedText)
    }
    
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField == emailTextField else { return true }
        
        delegate?.emailReturned?(with: emailTextField.text ?? "")
        
        return true
    }
    
    
    /**
     This method does the logic required when a text change event is fired for the text field
     - Parameter textField: The text field that has its text changed
     */
    @objc func didChangeText(textField:UITextField) {
        guard textField == emailTextField else { return }
        
        clearButton.alpha = emailTextField.text == "" ? 0 : 1
        
        // Now we need to validate the email entered
        // So we validate it using the telecom brands we have available
        let validationStatus:Bool = emailTextField.text?.isValidEmail() ?? false
        
        // Inform the delegat that the email is changed and if it is a valid one or not
        guard let delegate = delegate else { return }
        delegate.emailChanged?(email: emailTextField.text ?? "", with: (validationStatus) ? .Valid : .Invalid)
    }
    
}


internal extension String {
    /**
     Checks if the provided string is a valid email format
     - Returns: True if the string matches X@Y.com format and false otherwise
     */
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
}
