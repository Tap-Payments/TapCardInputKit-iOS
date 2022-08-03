//
//  TapPhoneInput.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 7/8/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import SnapKit
import TapThemeManager2020
import class CommonDataModelsKit_iOS.TapCountry
import LocalisationManagerKit_iOS
import TapCardVlidatorKit_iOS

/// External protocol to allow the TapPhoneInput to pass back data and events to the parent UIViewController
@objc public protocol TapPhoneInputProtocol {
    /**
     This method will be called whenever the phone number  changed. It is being called in a live manner
     - Parameter phoneNumber: The new phone number after the last update done bu the user
     */
    @objc optional func phoneNumberChanged(phoneNumber:String)
    /**
     This method will be called whenever the a brand is detected based on the current data typed by the user in the phone form.
     - Parameter cardBrand: The detected phone brand
     - Parameter validation: Tells the validity of the detected brand, whether it is invalid, valid or still incomplete
     */
    @objc optional func phoneBrandDetected(for phoneBrand:CardBrand,with validation:CrardInputTextFieldStatusEnum)
    
    /// This method will be called whenever the user clicked on the country code
    @objc optional func countryCodeClicked()
    
    /// This method will be called whenever the user hits return on the phone text
    @objc optional func phoneReturned(with phone:String)
}


/// This represents the custom view for phone number input provided by Tap
@objc public class TapPhoneInput: UIView {
    
    /// The phone input image icon
    internal lazy var icon = UIImageView()
    /// The clear button
    internal lazy var clearButton = UIButton()
    /// The text field to enter the international country code
    internal lazy var countryCodeTextField  = UITextField()
    /// The text field to enter the phone number
    internal lazy var phoneNumberTextField  = UITextField()
    /// This defines in which path should we look into the theme based on the card input mode
    internal var themePath:String = "phoneCard"
    /// Configure the localisation Manager
    internal let sharedLocalisationManager = TapLocalisationManager.shared
    /// Defines the order of the fields they are shown in, this is important to implement the navigation (nexxt and previous) between fields from the keyboard itself
    internal lazy var fields:[UITextField] = [countryCodeTextField,phoneNumberTextField]
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// The tap country the user is allowed to fill in the number in, this will decide the country code + the correct phone number length
    internal var tapCountry:TapCountry?
    /// The placeholder color used in the fields read from theme file and black as fallback
    internal var textFieldsplaceHolderColor:UIColor {
        return TapThemeManager.colorValue(for: "\(themePath).textFields.placeHolderColor") ?? .green
    }
    
    /// A delegate listener to listen to the events fired from the phone input form fields
    @objc public var delegate:TapPhoneInputProtocol?
    
    // Mark:- Init methods
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    @objc public required init?(coder: NSCoder) {
        super.init(coder:coder)
        self.backgroundColor = .clear
        semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight
    }
    
    
    /**
     Call this method when you  need to setup the view with the new country
     - Parameter tapCountry: The tap country the user is allowed to fill in the number in, this will decide the country code + the correct phone number length
     */
    @objc public func setup(with tapCountry:TapCountry? = nil) {
        self.tapCountry = tapCountry
        setupViews()
    }
    
    
    @objc public func validationStatus() -> CrardInputTextFieldStatusEnum {
        // Now we need to validate the phone entered matching country length
        let validationStatus:Bool = tapCountry?.phoneLength ?? -1 == phoneNumberTextField.text?.count
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
            make.height.equalTo(24)
            make.width.equalTo(18)
        }
        
        
        clearButton.snp.remakeConstraints { (make) in
            make.width.equalTo(24)
            make.trailing.equalToSuperview().offset(-26)
            make.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        countryCodeTextField.snp.remakeConstraints {(make) in
            make.centerY.equalTo(icon.snp.centerY).offset((TapLocalisationManager.shared.localisationLocale == "ar") ? 4 : 0)
            make.leading.equalToSuperview().offset(65)
            make.width.equalTo(countryCodeTextField.textWidth(text: "\(tapCountry?.code ?? "999")9"))
            make.height.equalToSuperview()
        }
        
        phoneNumberTextField.snp.remakeConstraints {(make) in
            make.centerY.equalTo(countryCodeTextField.snp.centerY)
            make.leading.equalTo(countryCodeTextField.snp.trailing)
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
        fields.forEach {
            $0.keyboardType = .numberPad
            $0.delegate = self
            $0.textAlignment = (sharedLocalisationManager.localisationLocale == "ar") ? .right : .left
        }
        
        clearButton.addTarget(self, action: #selector(clearPhoneInput), for: .touchUpInside)
    }
    
    
    /// Handles the logic of clearing and reseting the component
    @objc public func clearPhoneInput() {
        
        fields.forEach { $0.text = "" }
        didChangeText(textField: phoneNumberTextField)
        
    }
    
    /// Set the place holders values with the theme color
    internal func adjustFieldsPlaceHolders() {
        let placeHolderAttributes = [NSAttributedString.Key.foregroundColor: textFieldsplaceHolderColor]
        
        countryCodeTextField.attributedPlaceholder = NSAttributedString(string: tapCountry?.code ?? "965", attributes: placeHolderAttributes)
        
        phoneNumberTextField.attributedPlaceholder = NSAttributedString(string: String(repeating: "0", count: tapCountry?.phoneLength ?? 8), attributes: placeHolderAttributes)
        
        // Listen to the event of text change
        phoneNumberTextField.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
    }
    
    /// Sets the correct text fonts and colors to the associated textfields
    internal func adjustFieldsTextFonts() {
        fields.forEach {
            $0.tap_theme_font = ThemeFontSelector.init(stringLiteral: "\(themePath).textFields.font")
            $0.tap_theme_textColor = ThemeUIColorSelector.init(stringLiteral: "\(themePath).textFields.textColor")
        }
    }
    
    /// The method that adds the subviews
    internal func addViews() {
        addSubview(icon)
        addSubview(clearButton)
        addSubview(countryCodeTextField)
        addSubview(phoneNumberTextField)
    }
}


extension TapPhoneInput {
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
        self.clearButton.alpha = phoneNumberTextField.text == "" ? 0 : 1
        
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
    
    /// Focuses the keyboard for the phone input
    @objc public func focus() {
        phoneNumberTextField.becomeFirstResponder()
    }
    
    /**
     Gets the phone in the phone field
     - Returns: The typed phone or an empty string
     */
    @objc public func phone() -> String {
        return phoneNumberTextField.text ?? ""
    }
    
    /// Method that glows or the dims the card input view based on the shadow theme provided and if any of the fields is active
    internal func  updateShadow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // The final value we will animate the shadow opacity , default is 0
            var finalShadowOpacity:Float = 0.0
            // Calculate the starting valye which is the current opacity level
            let startingValue:Float = self.layer.shadowOpacity
            // Check if any of the fields is active first
            for field in self.fields {
                if field.isEditing {
                    // Now we found one that is active, then we need to glow it based on the value provided from the theme
                    finalShadowOpacity = Float(TapThemeManager.numberValue(for: "\(self.themePath).commonAttributes.shadow.opacity")?.floatValue ?? 0
                    )
                    break
                }
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
    
    internal func changeText(with phoneNumber:String) -> Bool {
        // In card number we only allow digits and spaces. The spaces will come from the formatting we are applying
        let filteredText:String = phoneNumber.onlyDigits()
        
        return filteredText == phoneNumber && phoneNumber.count <= tapCountry?.phoneLength ?? 0
    }
}

extension TapPhoneInput: UITextFieldDelegate {
    
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        
        guard textField != countryCodeTextField else {
            // Report back that the country code is clicked
            delegate?.countryCodeClicked?()
            phoneNumberTextField.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField == phoneNumberTextField else { return true }
        
        delegate?.phoneReturned?(with: phoneNumberTextField.text ?? "")
        
        return true
    }
    
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
    
    
    /**
     This method does the logic required when a text change event is fired for the text field
     - Parameter textField: The text field that has its text changed
     */
    @objc func didChangeText(textField:UITextField) {
        guard textField == phoneNumberTextField else { return }
        
        // The country code should reflect the same state of the phone field, i the phone field is showing laceholder then country code will do
        let countryCodePlaceHolder:String = tapCountry?.code ?? "965"
        
        // We set the country code text field based on the new text of the phone field. They wether show data ot placeholders
        countryCodeTextField.text = phoneNumberTextField.text == "" ? "" : countryCodePlaceHolder
        clearButton.alpha = phoneNumberTextField.text == "" ? 0 : 1
        
        // Now we need to validate the phone number to know under which telecom operator it is
        // So we validate it using the telecom brands we have available
        let detectedBrand:DefinedCardBrand = CardValidator.validate(cardNumber: phoneNumberTextField.text, preferredBrands: CardBrand.allCases.filter{ $0.brandSegmentIdentifier == "telecom" })
        
        // Inform the delegat that the number is changed and a brand is detected if any
        guard let delegate = delegate else { return }
        delegate.phoneNumberChanged?(phoneNumber: phoneNumberTextField.text ?? "")
        delegate.phoneBrandDetected?(for: detectedBrand.cardBrand ?? .unknown, with: .init(status: detectedBrand.validationState))
        
    }
    
}
