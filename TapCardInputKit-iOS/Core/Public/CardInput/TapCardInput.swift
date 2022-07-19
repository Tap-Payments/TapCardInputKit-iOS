//
//  TapCardInput.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 10/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//
import SnapKit
import TapThemeManager2020
import class CommonDataModelsKit_iOS.TapCard
import class CommonDataModelsKit_iOS.TapCommonConstants
import TapCardVlidatorKit_iOS
import LocalisationManagerKit_iOS
import MOLH
import Nuke

/// Internal protocl for all card text fields to implement to consolidate the logic and make sure all needed logic is implemented
internal protocol TapCardInputCommonProtocol {
    
    /// This method is responsible for adjusting the constraints to layout the view as needed
    func setupConstraints()
    /// This method is responsible for adding the required subviews
    func addViews()
    /**
     This method is responsible for expanding/shrinking the currently active or just became inactive view. Works in Inline mode.
     - Parameter subView: The view that  you want to expand or shrinkg
     **/
    func updateWidths(for subView:UIView?)
}

/// External protocol to allow the TapCardInput to pass back data and events to the parent UIViewController
@objc public protocol TapCardInputProtocol {
    /**
     This method will be called whenever the card data in the form has changed. It is being called in a live manner
     - Parameter tapCard: The TapCard model that hold sthe data the currently enetred by the user till now
     */
    func cardDataChanged(tapCard:TapCard)
    /**
     This method will be called whenever the a brand is detected based on the current data typed by the user in the card form.
     - Parameter cardBrand: The detected card brand
     - Parameter validation: Tells the validity of the detected brand, whether it is invalid, valid or still incomplete
     */
    func brandDetected(for cardBrand:CardBrand,with validation:CrardInputTextFieldStatusEnum)
    /// This method will be called once the user clicks on Scan button
    func scanCardClicked()
    /**
     This method will be called whenever the user change the status of the save card option
     - Parameter enabled: Will be true if the switch is enabled and false otherwise
     */
    func saveCardChanged(enabled:Bool)
    /**
     This method will be called whenever any text change occures
     - Parameter tapCard: The TapCard model that hold sthe data the currently enetred by the user till now
     */
    func dataChanged(tapCard:TapCard)
    
    /**
     This method will be called whenever the user tries to enter new digits inside the card number, then we need to the delegate to tell us if we can complete the card number.
     - Parameter with cardNumber: The card number after changes.
     - Returns: True if the entered card number till now less than 6 digits or the prefix matches the allowed types (credit or debit)
     */
    func shouldAllowChange(with cardNumber:String) -> Bool
}

/// This represents the custom view for card input provided by Tap
@objc public class TapCardInput: MOLHView {
    
    // Internal
    
    /// The scroll view that holds the form whether horizontal in Inline or vertical in Full mode
    internal lazy var scrollView = UIScrollView()
    /// The main stack view that holds the inner components (card fields)
    internal lazy var stackView = UIStackView()
    /// The card brand image icon
    internal lazy var icon = UIImageView()
    /// The card brand last image icon, will be used to show it back after the CVV animation
    internal lazy var lastShownIcon:UIImage? = nil
    /// The scan button
    internal lazy var scanButton = UIButton()
    /// The text field to enter the card number
    internal lazy var cardNumber  = CardNumberTextField()
    /// The text field to enter the card  name
    internal lazy var cardName  = CardNameTextField()
    /// The text field to enter the card  expiry
    internal lazy var cardExpiry  = CardExpiryTextField()
    /// The text field to enter the card  cvv
    internal lazy var cardCVV     = CardCVVTextField()
    /// The save card label to be shown in full mode
    internal lazy var saveLabel:UILabel = UILabel()
    /// The save card switch to be shown in full mode
    internal lazy var saveSwitch:UISwitch = UISwitch()
    /// Defines the order of the fields they are shown in, this is important to implement the navigation (nexxt and previous) between fields from the keyboard itself
    internal lazy var fields:[TapCardTextField] = [cardNumber,cardExpiry,cardCVV,cardName]
    /// This defines in which path should we look into the theme based on the card input mode
    internal var themePath:String = "inlineCard"
    /// The item spacing between different fields inside the stack view
    internal var spacing:CGFloat = 7
    /// The left and right padding around the input card
    internal var inputLeftRightMargin:CGFloat = 15
    
    
    internal var computedSpace:CGFloat{
        get{
            return max(spacing,7)
        }
    }
    /// This should hold the card data entered by the user till the moment
    internal var tapCard:TapCard = .init()
    /// Configure the localisation Manager
    internal let sharedLocalisationManager = TapLocalisationManager.shared
    // Public
    /// This defines the mode required to show the card input view in whether Full or Inline
    @objc public var cardInputMode:CardInputMode = .FullCardInput {
        didSet{
            // When it is changed, we need to change the path in the theme we are utilising based on the new mode value
            switch cardInputMode {
            case .InlineCardInput:
                themePath = "inlineCard"
            case .FullCardInput:
                themePath = "fullCard"
            case .PhoneInput:
                themePath = "phoneCard"
            }
        }
    }
    /// States if the parent controller wants to show card number or not
    @objc public lazy var showCardName:Bool = false
    /// States if the parent controller wants to show save card option, only works wth full mode
    @objc public lazy var showSaveCardOption:Bool = false
    /// States if the parent controller wants to show a scanning option or not
    @objc public lazy var showScanningOption:Bool = true
    /// States if the parent controller wants to show a card brand icon or not
    @objc public lazy var showCardBrandIcon:Bool = false
    /// The delegate that wants to hear from the view on new data and events
    @objc public var delegate:TapCardInputProtocol?
    /// States if the parent controller wants to allow set of cards only
    @objc public var allowedCardBrands:[Int] = [] {
        didSet {
            cardNumber.allowedBrands = allowedCardBrands
        }
    }
    /// States if the parent controller wants to show a card image instead of placeholder when valid
    @objc public var cardIconUrl:String?
    
    // Mark:- Init methods
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder:coder)
        self.backgroundColor = .clear
    }
    
    /**
     Call this method when you  need to setup the view with a custom theme json file. Setup method is reponsible for laying out the view,  adding subviews and applying the default theme
     - Parameter cardInputMode: Defines the card input mode required whether Inline or Full mode
     - Parameter showCardName: States if the parent controller wants to show card number or not, default is false
     - Parameter showCardBrandIcon: States if the parent controller wants to show a card brand icon or not
     - Parameter allowedCardBrands: States if the parent controller wants to allow set of cards only
     - Parameter cardIconUrl: States if the parent controller wants to show a card image instead of placeholder when valid
     */
    @objc public func setup(for cardInputMode:CardInputMode,showCardName:Bool = false, showCardBrandIcon:Bool = false,allowedCardBrands:[Int] = [],cardIconUrl:String? = nil) {
        
        self.cardInputMode = cardInputMode
        self.showCardName = showCardName
        self.showCardBrandIcon = showCardBrandIcon
        // After applying the theme, we need now to actually setup the views
        //FlurryLogger.logEvent(with: "Tap_Card_Input_Setup_Called", timed:false , params:["defaultTheme":"true","cardInputMode":"\(cardInputMode)"])
        self.cardIconUrl = cardIconUrl
        defer {
            self.allowedCardBrands = allowedCardBrands
        }
        setupViews()
    }
    
    /**
     Call this method when you  need to fill in the text fields with data.
     - Parameter tapCard: The TapCard that holds the data needed to be filled into the textfields
     - Parameter then focusCardNumber: Indicate whether we need to focus the card number after setting the card data
     - Parameter shouldRemoveCurrentCard: Indicate If there is a card number, first thing to do now is to clear the fields
     */
    @objc public func setCardData(tapCard:TapCard,then focusCardNumber:Bool,shouldRemoveCurrentCard:Bool = true) {
        // Match the tapCard attributes to the different card fields
        
        // First then, we check if there is a card number provided
        guard let providedCardNumber:String = tapCard.tapCardNumber, providedCardNumber != "" else { return }
        
        if shouldRemoveCurrentCard {
            // If there is a card number, first thing to do now is to clear the fields
            clearButtonClicked()
        }
        
        // Then we set the card number and check if it is valid or not
        guard cardNumber.changeText(with: providedCardNumber, setTextAfterValidation: true) else {
            cardNumber.resignFirstResponder()
            return
        }
        
        if focusCardNumber {
            cardNumber.becomeFirstResponder()
        }else {
            cardNumber.resignFirstResponder()
        }
        updateWidths(for: cardNumber)
        
        // Then we set the card expiry and check if it is valid or not
        guard cardExpiry.changeText(with: tapCard.tapCardExpiryMonth, year: tapCard.tapCardExpiryYear) else {
            cardExpiry.text = ""
            if !focusCardNumber {
                cardExpiry.becomeFirstResponder()
            }
            return
        }
        
        cardExpiry.resignFirstResponder()
        updateWidths(for: cardExpiry)
        
        // Then check if the usder provided a correct cvv
        guard cardCVV.changeText(with: tapCard.tapCardCVV ?? "", setTextAfterValidation: true) else {
            cardCVV.text = ""
            if !focusCardNumber {
                cardCVV.becomeFirstResponder()
            }
            return
        }
        
        cardCVV.resignFirstResponder()
        updateWidths(for: cardCVV)
        
        if focusCardNumber {
            cardNumber.becomeFirstResponder()
        }else if !cardNumber.isValid(cardNumber: providedCardNumber) {
            cardNumber.becomeFirstResponder()
        }else if !cardExpiry.isValid() {
            cardExpiry.becomeFirstResponder()
        }else if !cardCVV.isValid() {
            cardCVV.becomeFirstResponder()
        }
        
        //FlurryLogger.logEvent(with: "Tap_Card_Input_Fill_Data_Called", timed:false , params:["card_number":tapCard.tapCardNumber ?? "","card_name":tapCard.tapCardName ?? "","card_month":tapCard.tapCardExpiryMonth ?? "","card_year":tapCard.tapCardExpiryYear ?? ""])
        
    }
    
    /**
     Decicdes the status of the current card number
     - Returns: tuble of(Card brand and Validation state) to tell if there is a brand detected, and if any what is the validation status of this brand
     */
    public func cardBrandWithStatus() -> (CardBrand?,CardValidationState) {
        return cardNumber.cardBrand(for: tapCard.tapCardNumber ?? "")
    }
    
    /**
     Decides if each field is a valid one or not
     - Returns: tuble of (card number valid or not, card expiry valid or not, card cvv is valid or not, card name is valid or not)
     */
    public func fieldsValidationStatuses() -> (Bool,Bool,Bool, Bool) {
        return (cardNumber.isValid(cardNumber: tapCard.tapCardNumber),cardExpiry.isValid(),cardCVV.isValid(), showCardName ? cardName.isValid() : true)
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        matchThemeAttributes()
    }
    
    /// Helper method to natch the text, error and palceholder colors from the theme to all the cards fields
    internal func setTextColors() {
        // Set the color of the text fields
        fields.forEach { (field) in
            // text colors
            field.normalTextColor = TapThemeManager.colorValue(for: "\(themePath).textFields.textColor") ?? .black
            // Error text colors
            field.errorTextColor = TapThemeManager.colorValue(for: "\(themePath).textFields.errorTextColor") ?? .black
            // placeholder colors
            field.placeHolderTextColor = TapThemeManager.colorValue(for: "\(themePath).textFields.placeHolderColor") ?? .black
        }
        // Set the color of the save label
        saveLabel.tap_theme_textColor = ThemeUIColorSelector.init(keyPath: "\(themePath).saveCardOption.labelTextColor")
    }
    
    /// Helper method to natch the fonts from the theme to all the cards fields
    internal func setFonts() {
        fields.forEach { (field) in
            // Fonts
            field.tap_theme_font = ThemeFontSelector.init(stringLiteral: "\(themePath).textFields.font")
        }
        
        // Set the font of the save label
        saveLabel.tap_theme_font = ThemeFontSelector.init(stringLiteral: "\(themePath).saveCardOption.labelTextFont")
    }
    
    /// Helper method to natch the localized values
    @objc public func localize(shouldFlip:Bool = true) {
        // The default localisation file location
        let defaultLocalisationFilePath:URL = TapCommonConstants.pathForDefaultLocalisation()
        // Assign the localisation values
        cardName.fieldPlaceHolder = sharedLocalisationManager.localisedValue(for: "TapCardInputKit.cardNamePlaceHolder", with: defaultLocalisationFilePath)
        
        cardNumber.fieldPlaceHolder = sharedLocalisationManager.localisedValue(for: "TapCardInputKit.cardNumberPlaceHolder", with: defaultLocalisationFilePath)
        
        cardCVV.fieldPlaceHolder = sharedLocalisationManager.localisedValue(for: "TapCardInputKit.cardCVVPlaceHolder", with: defaultLocalisationFilePath)
        
        cardExpiry.placeholder = sharedLocalisationManager.localisedValue(for: "TapCardInputKit.cardExpiryPlaceHolder", with: defaultLocalisationFilePath)
        
        saveLabel.text = sharedLocalisationManager.localisedValue(for: "TapCardInputKit.cardSaveLabel", with: defaultLocalisationFilePath)
        
        
        if shouldFlip {
            // Change the alignments
            fields.forEach { (field) in
                field.alignment = (sharedLocalisationManager.localisationLocale == "ar") ? .right : .left
            }
            
            saveLabel.textAlignment = (sharedLocalisationManager.localisationLocale == "ar") ? .right : .left
            MOLH.setLanguageTo(sharedLocalisationManager.localisationLocale ?? "en")
        }
        
    }
    
    /// Helper method to match the common theming values to the view from the theme file
    internal func setCommonUI() {
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
        
        self.spacing = CGFloat(TapThemeManager.numberValue(for: "\(themePath).commonAttributes.itemSpacing")?.floatValue ?? 0)
        self.inputLeftRightMargin = CGFloat(TapThemeManager.numberValue(for: "\(themePath).commonAttributes.widthMargin")?.floatValue ?? 0)
        // The default card brand icon
        icon.image = TapThemeManager.imageValue(for: "\(themePath).iconImage.image",from: Bundle(for: type(of: self)))
        icon.contentMode = .scaleAspectFit
        
        // Defines an action handler to the scan button
        self.scanButton.addTarget(self, action: #selector(scanButtonClicked), for: .touchUpInside)
        scanButton.setTitle("", for: .normal)
        // Defines scan button icon
        scanButton.setImage(TapThemeManager.imageValue(for: "\(themePath).scanImage.image",from: Bundle(for: type(of: self))), for: .normal)
        scanButton.imageView?.contentMode = .scaleAspectFit
        scanButton.backgroundColor = .clear
        scanButton.tintColor = .clear
        scanButton.setBackgroundColor(color: .clear, forState: .highlighted)
        scanButton.setBackgroundColor(color: .clear, forState: .selected)
        scanButton.setBackgroundColor(color: .clear, forState: .focused)
        
        saveSwitch.tap_theme_tintColor = ThemeUIColorSelector.init(keyPath: "\(themePath).saveCardOption.switchTintColor")
        saveSwitch.tap_theme_thumbTintColor = ThemeUIColorSelector.init(keyPath: "\(themePath).saveCardOption.switchThumbColor")
        saveSwitch.tap_theme_onTintColor = ThemeUIColorSelector.init(keyPath: "\(themePath).saveCardOption.switchOnThumbColor")
        
        
        updateShadow()
    }
    
    /// The method is responsible for configuring and setup the card text fields
    internal func configureViews() {
        
        // Setup the card number field with the needed data and listeners
        cardNumber.setup(with: 4, maxVisibleChars: 16, placeholder: "Card Number") { [weak self] (isEditing) in
            // We will glow the shadow if needed
            self?.updateShadow()
            // We will need to adjuust the width for the field when it is being active or inactive in the Inline mode
            self?.updateWidths(for: self?.cardNumber)
        } cardBrandDetected: { [weak self] (brand) in
            // If a card brand is detected we need to pudate the card icon image and update the allowed length of the CVV
            self?.cardBrandDetected(with:brand)
        } cardNumberChanged: { [weak self] (cardNumber) in
            // If the card number changed, we change the holding TapCard and we fire the logic needed to do when the card data changed
            self?.tapCard.tapCardNumber = cardNumber
            self?.cardDatachanged()
            if self?.cardInputMode == .InlineCardInput, self?.cardNumber.isValid() ?? false {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self?.cardExpiry.becomeFirstResponder()
                }
            }
            self?.handleOneBrandIcon(with: cardNumber)
        } shouldAllowChange: { [weak self] (updatedCardNumber) -> (Bool) in
            return self?.delegate?.shouldAllowChange(with: updatedCardNumber) ?? true
        }
        
        // Setup the card name field with the needed data and listeners
        cardName.setup(with: 4, maxVisibleChars: 16, placeholder: "Card Holder Name", editingStatusChanged: { [weak self] (isEditing) in
            // We will glow the shadow if needed
            self?.updateShadow()
            // We will need to adjuust the width for the field when it is being active or inactive in the Inline mode
            self?.updateWidths(for: self?.cardName)
        },cardNameChanged: { [weak self] (cardName) in
            // If the card name changed, we change the holding TapCard and we fire the logic needed to do when the card data changed
            self?.tapCard.tapCardName = cardName
            self?.cardDatachanged()
            //self?.cardName.resignFirstResponder()
        })
        
        // Setup the card expiry field with the needed data and listeners
        cardExpiry.setup(with: 5, placeholder: "",editingStatusChanged: {[weak self] (isEditing) in
            // We will glow the shadow if needed
            self?.updateShadow()
            // We will need to adjuust the width for the field when it is being active or inactive in the Inline mode
            self?.updateWidths(for: self?.cardExpiry)
        }, cardExpiryChanged: {  [weak self] (cardMonth,cardYear) in
            // If the card expiry changed, we change the holding TapCard and we fire the logic needed to do when the card data changed
            self?.tapCard.tapCardExpiryMonth = cardMonth
            self?.tapCard.tapCardExpiryYear = cardYear
            if self?.cardExpiry.isValid() ?? false {
                self?.cardCVV.becomeFirstResponder()
            }
            self?.cardDatachanged()
        })
        
        // Setup the card cvv field with the needed data and listeners
        cardCVV.setup(placeholder: "CVV",editingStatusChanged: { [weak self] (isEditing) in
            // We will glow the shadow if needed
            self?.updateShadow()
            // We will need to adjuust the width for the field when it is being active or inactive in the Inline mode
            self?.updateWidths(for: self?.cardCVV)
        },cardCVVChanged: {  [weak self] (cardCVV) in
            // If the card cvv changed, we change the holding TapCard and we fire the logic needed to do when the card data changed
            self?.tapCard.tapCardCVV = cardCVV
            self?.cardDatachanged()
            if self?.cardCVV.isValid() ?? false {
                // Check if there is a name to collect
                if self?.showCardName ?? false {
                    // Then we need to move to filling the card name
                    self?.cardName.becomeFirstResponder()
                }else{
                    // We finished collecting the names, let us hide the keyboard :)
                    self?.cardCVV.resignFirstResponder()
                }
            }
        })
        
        fields.forEach{ $0.textChanged = { [weak self] _ in self?.delegate?.dataChanged(tapCard: self!.tapCard) }}
        
        saveSwitch.addTarget(self, action: #selector(saveCardSwitchChanged), for: .valueChanged)
        handleOneBrandIcon()
        localize()
    }
    
    
    internal func handleOneBrandIcon(with cardNumber:String = "") {
        if let iconString:String = cardIconUrl, let iconURL:URL = URL(string: iconString) {
            // Meaning, we have an icon to set, we check if it is not invalid we show the icon otherwise, the palceholder icon
            let validationStatus = self.cardNumber.textFieldStatus(cardNumber: cardNumber)
            if validationStatus == .Invalid && cardNumber != "" {
                icon.image = TapThemeManager.imageValue(for: "\(themePath).iconImage.image",from: Bundle(for: type(of: self)))
            }else {
                let options = ImageLoadingOptions(
                    transition: .fadeIn(duration: 0.2)
                )
                // Time to load the image iconf rom the given URL
                Nuke.loadImage(with: iconURL,options:options, into: icon)
            }
        }
    }
    
    @objc func saveCardSwitchChanged(_ sender:Any) {
        if let nonNullDelegate = delegate {
            // If there is a delegate then we call the related method
            nonNullDelegate.saveCardChanged(enabled: saveSwitch.isOn)
        }
    }
    
    @objc public func reset() {
        clearButtonClicked()
    }
    
    
    /**
     The method that holds the logic needed to do when a card brand is detected
     - Parameter brand: The detected card brand
     */
    internal func cardBrandDetected(with brand:CardBrand?) {
        if let nonNullBrand = brand {
            if showCardBrandIcon {
                // Set the new icon based on the detected card brand
                self.icon.image = UIImage(named: nonNullBrand.cardImageName(), in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            // Update the cvv allowed length based on the detected card brand
            self.cardCVV.cvvLength = CardValidator.cvvLength(for: nonNullBrand)
            //let brandName:String = "\(nonNullBrand)"
            //FlurryLogger.logEvent(with: "Tap_Card_Input_Brand_Detected", timed:false , params:["brandName":brandName])
        }else {
            // At any problem as fall back we set the default values again
            if cardInputMode == .FullCardInput {
                self.icon.image = TapThemeManager.imageValue(for: "\(self.themePath).iconImage.image",from: Bundle(for: type(of: self)))
            }else {
                //self.scanButton.setImage(TapThemeManager.imageValue(for: "\(themePath).scanImage.image"), for: .normal)
                self.scanButton.isUserInteractionEnabled = true
            }
            
            self.cardCVV.cvvLength = 3
        }
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
    
    /// The method that holds the logic needed to do when any of the card fields changed
    internal func cardDatachanged() {
        adjustScanButton()
        if let nonNullDelegate = delegate {
            // If there is a delegate then we call the related method
            nonNullDelegate.cardDataChanged(tapCard: tapCard)
            let (detectedBrand, _) = cardNumber.cardBrand(for: tapCard.tapCardNumber ?? "")
            nonNullDelegate.brandDetected(for: detectedBrand ?? .unknown, with: cardNumber.textFieldStatus(cardNumber: tapCard.tapCardNumber))
        }
        //FlurryLogger.logEvent(with: "Tap_Card_Input_Data_Changed", timed:false , params:["card_number":tapCard.tapCardNumber ?? "","card_name":tapCard.tapCardName ?? "","card_month":tapCard.tapCardExpiryMonth ?? "","card_year":tapCard.tapCardExpiryYear ?? ""])
        adjustExpiryCvv()
    }
    
    
    internal func adjustExpiryCvv() {
        guard cardInputMode == .InlineCardInput else { return }
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.cardCVV.alpha = (self?.cardNumber.isEditing ?? false || !(self?.cardNumber.isValid(cardNumber: self?.tapCard.tapCardNumber) ?? false)) ? 0 : 1
            self?.cardExpiry.alpha = (self?.cardNumber.isEditing ?? false || !(self?.cardNumber.isValid(cardNumber: self?.tapCard.tapCardNumber) ?? false)) ? 0 : 1
        })
    }
    
    /// The method that holds the logic needed to do when any of the scan button is clicked
    @objc internal func scanButtonClicked() {
        if let nonNullDelegate = delegate {
            // If there is a delegate then we call the related method
            nonNullDelegate.scanCardClicked()
        }
        //FlurryLogger.logEvent(with: "Tap_Card_Input_Scan_Clicked")
        self.scanButton.setImage(TapThemeManager.imageValue(for: "\(themePath).scanImage.selected",from: Bundle(for: type(of: self))), for: .normal)
    }
    
    /// The method that holds the logic needed to do when any of the scan button is clicked
    @objc public func scannerClosed() {
        adjustScanButton()
    }
    
    
    @objc internal func clearButtonClicked() {
        
        tapCard.tapCardCVV = nil
        tapCard.tapCardNumber = nil
        tapCard.tapCardExpiryYear = nil
        tapCard.tapCardExpiryMonth = nil
        tapCard.tapCardName = nil
        
        fields.forEach{
            $0.text = ""
            updateWidths(for: $0)
            $0.resignFirstResponder()
        }
        cardDatachanged()
    }
    
    
    internal func adjustScanButton() {
        scanButton.removeTarget(self, action: #selector(scanButtonClicked), for: .touchUpInside)
        scanButton.removeTarget(self, action: #selector(clearButtonClicked), for: .touchUpInside)
        
        
        if (fields.filter{ ($0.text?.count ?? 0) > 0}.count > 0) {
            self.scanButton.setImage(TapThemeManager.imageValue(for: "\(themePath).clearImage.image",from: Bundle(for: type(of: self))), for: .normal)
            self.scanButton.addTarget(self, action: #selector(clearButtonClicked), for: .touchUpInside)
        }else {
            self.scanButton.setImage(TapThemeManager.imageValue(for: "\(themePath).scanImage.image",from: Bundle(for: type(of: self))), for: .normal)
            self.scanButton.addTarget(self, action: #selector(scanButtonClicked), for: .touchUpInside)
        }
    }
}


extension TapCardInput {
    /**
     Method that adds navigation buttons on the keyboard for a given field. Helps in easing going from one field to another while typing instead of the need to click on each field by itself
     - Parameter field  The current textfield we are adding the buttons to its keyboard
     - Parameter previous: Defines if we shall add a previous button
     - Parameter next: Defines if we shall add a next button
     - Parameter done: Defines if we shall add a done button
     */
    internal func addDoneButtonOnKeyboard(for field:TapCardTextField, previous:Bool = false, next:Bool = false, done:Bool = false) {
        // We first define the toolbar frame we will show on top of the keyboard
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        // The default localisation file location
        let defaultLocalisationFilePath:URL = TapCommonConstants.pathForDefaultLocalisation()
        
        // We create the previos, netx and done buttons and assign their action handlers
        let doneButton: TapCardBarButton = TapCardBarButton(title: sharedLocalisationManager.localisedValue(for: "Common.done", with: defaultLocalisationFilePath), style: .done, target: self, action:#selector(doneAction(sender:)))
        let previousButton: TapCardBarButton = TapCardBarButton(title: sharedLocalisationManager.localisedValue(for: "Common.previous", with: defaultLocalisationFilePath), style: .done, target: self, action: #selector(previousAction(sender:)))
        let nextButton: TapCardBarButton = TapCardBarButton(title: sharedLocalisationManager.localisedValue(for: "Common.next", with: defaultLocalisationFilePath), style: .done, target: self, action: #selector(nextAction(sender:)))
        
        // Attach the buttons to the given text field
        doneButton.cardField      = field
        nextButton.cardField      = field
        previousButton.cardField  = field
        
        // Based on the given fields in the call we choose which buttons we will add to the toolbar
        var items:[UIBarButtonItem] = []
        
        if previous {
            items.append(previousButton)
        }
        if next {
            items.append(nextButton)
        }
        if done {
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            items.append(doneButton)
        }
        // Assign the decided items to the created toolbar
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        // Assign the created toolbar to the keyboard of the given text field
        field.inputAccessoryView = doneToolbar
    }
    
    
    /**
     The action handler when the done button in the toolbar of the keyboard is clicked
     - Parameter sender: The bar button item that was clicked
     */
    @objc internal func doneAction(sender:TapCardBarButton) {
        if let field = sender.cardField {
            // Defensive code to make sure all good, and the textfield is being passed with the clicked button
            
            // Done means we need to hide the keyboard
            field.resignFirstResponder()
        }
    }
    
    /**
     The action handler when the next button in the toolbar of the keyboard is clicked
     - Parameter sender: The bar button item that was clicked
     */
    @objc internal func nextAction(sender:TapCardBarButton) {
        if let field = sender.cardField,
           let currentFieldIndex = fields.firstIndex(of: field) {
            // Defensive code to make sure all good, and the textfield is being passed with the clicked button and there is NEXT field in the row that we can navigate to
            
            // If all good, then the next field is now active
            fields[currentFieldIndex+1].becomeFirstResponder()
        }
    }
    
    /**
     The action handler when the previous button in the toolbar of the keyboard is clicked
     - Parameter sender: The bar button item that was clicked
     */
    @objc internal func previousAction(sender:TapCardBarButton) {
        if let field = sender.cardField,
           let currentFieldIndex = fields.firstIndex(of: field) {
            // Defensive code to make sure all good, and the textfield is being passed with the clicked button and there is previous field in the row that we can navigate to
            
            // If all good, then the previous field is now active
            fields[currentFieldIndex-1].becomeFirstResponder()
        }
    }
    
    /// This is the method that adds all required navigation buttons for the keyboards for all card fields
    internal func addToolBarButtons() {
        
        // Based on the card input mode, we define the ordering of the card fields
        /*switch cardInputMode {
         case .InlineCardInput:
         fields = [cardNumber,cardExpiry,cardCVV,cardName]
         case .FullCardInput:
         fields = [cardNumber,cardExpiry,cardCVV,cardName]
         }*/
        
        // For each field, we add the appropriate navigation buttons
        for (index, cardField) in fields.enumerated() {
            var showPrevious = false, showNext = false, showDone = false
            showPrevious = (index > 0)// We show previous button only if there is field before us
            showDone = (index == (fields.count - 1)) // Next is shown if there is a next field in the items array
            showNext = !showDone // We show DONE only when we are not showing next, meaning we are at the end of the items
            addDoneButtonOnKeyboard(for: cardField, previous: showPrevious, next: showNext, done: showDone)
        }
    }
}

extension TapCardInput:TapCardInputCommonProtocol {
    
    /**
     Helper method to load image assets when it is not known from which bundle it should be loaded, the pod bundle or the app bundle.
     - Parameter resourceName: The name of the image to be loaded
     */
    internal func loadImage(with resourceName:String) -> UIImage {
        if let image = UIImage(named: resourceName, in: Bundle(for: type(of: self)), compatibleWith: nil) {
            // Now the image is loaded from the bundle of the pod, then we return this
            return image
        }
        if let image = UIImage(named: resourceName) {
            // Otherwise,  he image is loaded from the bundle of the main app, then we return this
            return image
        }
        
        // Fallback we return an empty image when it is not found in any bundle
        return UIImage()
    }
    
    
    /// The method that deals with mapping and applying the theming attributes to the different fields
    internal func matchThemeAttributes() {
        
        // Based on the cardInputMode we first define the theme path in the theme
        switch cardInputMode {
        case .InlineCardInput:
            themePath = "inlineCard"
        case .FullCardInput:
            themePath = "fullCard"
        case .PhoneInput:
            themePath = "phoneCard"
        }
        // We then call the logic required to apply different parts of the theme in success
        setTextColors()
        setFonts()
        setCommonUI()
        
    }
    
    /// This method is the brain controller of showing the views, as it taks the process for adding subview, laying them out and applying the theme
    internal func setupViews() {
        
        // Match the theme attributes to the right views
        matchThemeAttributes()
        
        // Add the the subviews first to the parent view
        addViews()
        
        // Now we need to configure the card fields and create the listeners for their blocks and data changes
        configureViews()
        
        // Then we need to layout them properly by creating the correct layout constraints
        setupConstraints()
        
        // Finally, we implement the keybaord (next and previousu) navigation logic for the different card fields
        if cardInputMode != .InlineCardInput {
            addToolBarButtons()
        }
        
        if !showCardName {
            removeCardName()
        }
    }
    
    /// The method that layouts the subviews properly by creating the correct layout constraints
    internal func setupConstraints() {
        // Based on the card mode we choose which layout constraints we will apply
        switch cardInputMode {
        case .InlineCardInput:
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
                self?.setupInlineConstraints()
            }
        case .FullCardInput:
            setupFullConstraints()
        default:
            return
        }
        
    }
    
    /// The method that adds the subviews
    internal func addViews() {
        // Based on the card mode we choose which subviews we are going to add
        switch cardInputMode {
        case .InlineCardInput:
            addInlineViews()
        case .FullCardInput:
            addFullViews()
        default:
            return
        }
    }
}


internal extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
}
