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
import TapCardValidator

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
    /// This method will be called once the user clicks on Scan button
    func scanCardClicked()
}

/// This represents the custom view for card input provided by Tap
@objc public class TapCardInput: UIView {
    
    // Internal
    
    /// The scroll view that holds the form whether horizontal in Inline or vertical in Full mode
    internal lazy var scrollView = UIScrollView()
    /// The main stack view that holds the inner components (card fields)
    internal lazy var stackView = UIStackView()
    /// The card brand image icon
    internal lazy var icon = UIImageView()
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
    /// Defines the order of the fields they are shown in, this is important to implement the navigation (nexxt and previous) between fields from the keyboard itself
    internal lazy var fields:[TapCardTextField] = [cardNumber,cardName,cardExpiry,cardCVV]
    /// States if the view is using the default TAP theme or a custom one
    internal lazy var applyingDefaultTheme:Bool = true
    /// The current theme being applied
    internal var themingDictionary:NSDictionary?
    /// This defines in which path should we look into the theme based on the card input mode
    internal var themePath:String = "inlineCard"
    /// The item spacing between different fields inside the stack view
    internal var spacing:CGFloat = 7
    /// This should hold the card data entered by the user till the moment
    internal var tapCard:TapCard = .init()
    
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
            }
        }
    }
    //lazy var showCardName:Bool = true
    /// States if the parent controller wants to show a scanning option or not
    @objc public lazy var showScanningOption:Bool = true
    /// The delegate that wants to hear from the view on new data and events
    @objc public  var delegate:TapCardInputProtocol?
    
    required init?(coder: NSCoder) {
        super.init(coder:coder)
        self.backgroundColor = .clear
    }
    
    /**
     Call this method when you  need to setup the view with a custom theme dictionary. Setup method is reponsible for laying out the view,  adding subviews and applying the given theme
     - Parameter cardInputMode: Defines the card input mode required whether Inline or Full mode
     - Parameter withDictionaryTheme: Defines the theme needed to be applied as a dictionary
     */
    @objc public func setup(for cardInputMode:CardInputMode,withDictionaryTheme:NSDictionary?) {
        
        // Set default values
        applyingDefaultTheme = true
        self.cardInputMode = cardInputMode
        
        if let nonNullThemeDict = withDictionaryTheme {
            // If the given dictionary is a valid theme, then we apply this given theme
            applyTheme(with: nonNullThemeDict)
        }
        // After applying the theme, we need now to actually setup the views
        setupViews()
    }
    
    /**
     Call this method when you  need to setup the view with a custom theme json file. Setup method is reponsible for laying out the view,  adding subviews and applying the given theme
     - Parameter cardInputMode: Defines the card input mode required whether Inline or Full mode
     - Parameter withJsonTheme: Defines the theme needed to be applied as a json file file name
     */
    @objc public func setup(for cardInputMode:CardInputMode,withJsonTheme:String) {
        // Set default values
        applyingDefaultTheme = true
        self.cardInputMode = cardInputMode
        applyTheme(with: withJsonTheme)
        // After applying the theme, we need now to actually setup the views
        setupViews()
    }
    
    /**
     Call this method when you  need to setup the view with a custom theme json file. Setup method is reponsible for laying out the view,  adding subviews and applying the default theme
     - Parameter cardInputMode: Defines the card input mode required whether Inline or Full mode
     */
    @objc public func setup(for cardInputMode:CardInputMode) {
        
        applyingDefaultTheme = true
        self.cardInputMode = cardInputMode
        // After applying the theme, we need now to actually setup the views
        setupViews()
    }
    
    /**
     Call this method when you  need to fill in the text fields with data.
     - Parameter tapCard: The TapCard that holds the data needed to be filled into the textfields
     */
    @objc public func setCardData(tapCard:TapCard) {
        // Match the tapCard attributes to the different card fields
        cardName.text = tapCard.tapCardName ?? ""
        let _ = cardNumber.changeText(with: tapCard.tapCardNumber ?? "", setTextAfterValidation: true)
        let _ = cardCVV.changeText(with: tapCard.tapCardCVV ?? "", setTextAfterValidation: true)
        cardExpiry.changeText(with: tapCard.tapCardExpiryMonth, year: tapCard.tapCardExpiryYear)
    }
    
    
    /**
     Internal helper method to apply  a theme from a given dictionary
     - Parameter dictionaryTheme: Defines the theme needed to be applied as a dictionary
     */
    internal func applyTheme(with dictionaryTheme:NSDictionary)
    {
        applyingDefaultTheme = false
        TapThemeManager.setTapTheme(themeDict: dictionaryTheme)
        themingDictionary = TapThemeManager.currentTheme
    }
    
    /**
     Internal helper method to apply  a theme from a given json file name
     - Parameter dictionaryTheme: Defines the theme needed to be applied as a json file file name
     */
    internal func applyTheme(with jsonTheme:String)
    {
        applyingDefaultTheme = false
        TapThemeManager.setTapTheme(jsonName: jsonTheme)
        themingDictionary = TapThemeManager.currentTheme
    }
    
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // In here we do listen to the trait collection change event :), this leads to changing the theme based on dark or light mode activated by the user at run time.
        guard applyingDefaultTheme else {
            // We will do nothing, if the view is using a customised given theme as it should be handled by the caller.
            return
        }
        // If the view is set to use the default theme, hence, we change the theme based on the dark or light mode is activated
        applyDefaultTheme()
        matchThemeAttributes()
    }
    
    
    /// Internal helper method to apply the default theme
    internal func applyDefaultTheme() {
        // Check if the file exists
        let bundle:Bundle = Bundle(for: type(of: self))
        // Based on the current display mode, we decide which default theme file we will use
        let themeFile:String = (self.traitCollection.userInterfaceStyle == .dark) ? "DefaultDarkTheme" : "DefaultLightTheme"
        // Defensive code to make sure all is loaded correctly
        guard let jsonPath = bundle.path(forResource: themeFile, ofType: "json") else {
            print("TapThemeManager WARNING: Can't find json 'DefaultTheme'")
            return
        }
        // Check if the file is correctly parsable
        guard
            let data = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)),
            let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed),
            let jsonDict = json as? NSDictionary else {
                print("TapThemeManager WARNING: Can't read json 'DefaultTheme' at: \(jsonPath)")
                return
        }
        // Apply the loaded default theme
        applyTheme(with: jsonDict)
        applyingDefaultTheme = true
    }
    
    /// Helper method to natch the text, error and palceholder colors from the theme to all the cards fields
    internal func setTextColors() {
        fields.forEach { (field) in
            // text colors
            field.normalTextColor = TapThemeManager.colorValue(for: "\(themePath).textFields.textColor") ?? .black
            // Error text colors
            field.errorTextColor = TapThemeManager.colorValue(for: "\(themePath).textFields.errorTextColor") ?? .black
            // placeholder colors
            field.placeHolderTextColor = TapThemeManager.colorValue(for: "\(themePath).textFields.placeHolderColor") ?? .black
        }
    }
    
    /// Helper method to natch the fonts from the theme to all the cards fields
    internal func setFonts() {
        fields.forEach { (field) in
            // Fonts
            field.tap_theme_font = ThemeFontSelector.init(stringLiteral: "\(themePath).textFields.font")
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
        self.spacing = CGFloat(TapThemeManager.numberValue(for: "\(themePath).commonAttributes.itemSpacing")?.floatValue ?? 0)
        // The default card brand icon
        icon.image = TapThemeManager.imageValue(for: "\(themePath).iconImage.image")
        icon.contentMode = .scaleAspectFit
        
        // Defines an action handler to the scan button
        self.scanButton.addTarget(self, action: #selector(scanButtonClicked), for: .touchUpInside)
        scanButton.setTitle("", for: .normal)
        // Defines scan button icon
        scanButton.setImage(TapThemeManager.imageValue(for: "\(themePath).scanImage.image"), for: .normal)
        scanButton.contentMode = .scaleAspectFit
    }
    
    /// The method is responsible for configuring and setup the card text fields
    internal func configureViews() {
        
        // Setup the card number field with the needed data and listeners
        cardNumber.setup(with: 4, maxVisibleChars: 16, placeholder: "Card Number", editingStatusChanged: { [weak self] (isEditing) in
            // We will need to adjuust the width for the field when it is being active or inactive in the Inline mode
            self?.updateWidths(for: self?.cardNumber)
            },cardBrandDetected: { [weak self] (brand) in
                // If a card brand is detected we need to pudate the card icon image and update the allowed length of the CVV
                self?.cardBrandDetected(with:brand)
            },cardNumberChanged: { [weak self] (cardNumber) in
                // If the card number changed, we change the holding TapCard and we fire the logic needed to do when the card data changed
                self?.tapCard.tapCardNumber = cardNumber
                self?.cardDatachanged()
        })
        
        // Setup the card name field with the needed data and listeners
        cardName.setup(with: 4, maxVisibleChars: 16, placeholder: "Holder Name", editingStatusChanged: { [weak self] (isEditing) in
            // We will need to adjuust the width for the field when it is being active or inactive in the Inline mode
            self?.updateWidths(for: self?.cardName)
            },cardNameChanged: { [weak self] (cardName) in
                // If the card name changed, we change the holding TapCard and we fire the logic needed to do when the card data changed
                self?.tapCard.tapCardName = cardName
                self?.cardDatachanged()
        })
        
        // Setup the card expiry field with the needed data and listeners
        cardExpiry.setup(placeholder: "MM/YY",editingStatusChanged: {[weak self] (isEditing) in
            // We will need to adjuust the width for the field when it is being active or inactive in the Inline mode
            self?.updateWidths(for: self?.cardExpiry)
            }, cardExpiryChanged: {  [weak self] (cardMonth,cardYear) in
                // If the card expiry changed, we change the holding TapCard and we fire the logic needed to do when the card data changed
                self?.tapCard.tapCardExpiryMonth = cardMonth
                self?.tapCard.tapCardExpiryYear = cardYear
                self?.cardDatachanged()
        })
        
        // Setup the card cvv field with the needed data and listeners
        cardCVV.setup(placeholder: "CVV",editingStatusChanged: { [weak self] (isEditing) in
            // We will need to adjuust the width for the field when it is being active or inactive in the Inline mode
            self?.updateWidths(for: self?.cardCVV)
            },cardCVVChanged: {  [weak self] (cardCVV) in
                // If the card cvv changed, we change the holding TapCard and we fire the logic needed to do when the card data changed
                self?.tapCard.tapCardCVV = cardCVV
                self?.cardDatachanged()
        })
    }
    
    /**
     The method that holds the logic needed to do when a card brand is detected
    - Parameter brand: The detected card brand
    */
    internal func cardBrandDetected(with brand:CardBrand?) {
        if let nonNullBrand = brand {
            // Set the new icon based on the detected card brand
            self.icon.image = UIImage(named: nonNullBrand.cardImageName(), in: Bundle(for: type(of: self)), compatibleWith: nil)
            // Update the cvv allowed length based on the detected card brand
            self.cardCVV.cvvLength = CardValidator.cvvLength(for: nonNullBrand)
        }else {
            // At any problem as fall back we set the default values again
            self.icon.image = TapThemeManager.imageValue(for: "\(self.themePath).iconImage.image")
            self.cardCVV.cvvLength = 3
        }
    }
    
    /// The method that holds the logic needed to do when any of the card fields changed
    internal func cardDatachanged() {
        if let nonNullDelegate = delegate {
            // If there is a delegate then we call the related method
            nonNullDelegate.cardDataChanged(tapCard: tapCard)
        }
    }
    
    /// The method that holds the logic needed to do when any of the scan button is clicked
    @objc internal func scanButtonClicked() {
        if let nonNullDelegate = delegate {
            // If there is a delegate then we call the related method
            nonNullDelegate.scanCardClicked()
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
        
        // We create the previos, netx and done buttons and assign their action handlers
        let doneButton: TapCardBarButton = TapCardBarButton(title: "Done", style: .done, target: self, action:#selector(doneAction(sender:)))
        let previousButton: TapCardBarButton = TapCardBarButton(title: "Previous", style: .done, target: self, action: #selector(previousAction(sender:)))
        let nextButton: TapCardBarButton = TapCardBarButton(title: "Next", style: .done, target: self, action: #selector(nextAction(sender:)))
        
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
        switch cardInputMode {
        case .InlineCardInput:
            fields = [cardNumber,cardName,cardExpiry,cardCVV]
        case .FullCardInput:
            fields = [cardNumber,cardExpiry,cardCVV,cardName]
        }
        
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
        }
        // We then call the logic required to apply different parts of the theme in success
        setTextColors()
        setFonts()
        setCommonUI()
        
    }
    
    /// This method is the brain controller of showing the views, as it taks the process for adding subview, laying them out and applying the theme
    internal func setupViews() {
        
        // Apply the default theme if needed
        if applyingDefaultTheme { applyDefaultTheme() }
        
        // Match the theme attributes to the right views
        matchThemeAttributes()
        
        // Add the the subviews first to the parent view
        addViews()
        
        // Now we need to configure the card fields and create the listeners for their blocks and data changes
        configureViews()
        
        // Then we need to layout them properly by creating the correct layout constraints
        setupConstraints()
        
        // Finally, we implement the keybaord (next and previousu) navigation logic for the different card fields
        addToolBarButtons()
        
        /*if !showCardName {
         removeCardName()
         }*/
        
        
    }
    
    /// The method that layouts the subviews properly by creating the correct layout constraints
    internal func setupConstraints() {
        // Based on the card mode we choose which layout constraints we will apply
        switch cardInputMode {
        case .InlineCardInput:
            setupInlineConstraints()
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
