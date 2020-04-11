//
//  TapCardInput.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 10/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import SnapKit
import TapThemeManager2020

internal protocol TapCardInputCommonProtocol {
    
    func setupConstraints()
    func addViews()
    func updateWidths(for subView:UIView?)
}

@objc public class TapCardInput: UIView {
    
    // Internal
    internal lazy var scrollView = UIScrollView()
    internal lazy var stackView = UIStackView()
    internal lazy var icon = UIImageView()
    internal lazy var scanButton = UIButton()
    internal lazy var cardNumber  = CardNumberTextField()
    internal lazy var cardName  = CardNameTextField()
    internal lazy var cardExpiry  = CardExpiryTextField()
    internal lazy var cardCVV     = CardCVVTextField()
    internal lazy var fields:[TapCardTextField] = [cardNumber,cardName,cardExpiry,cardCVV]
    internal lazy var applyingDefaultTheme:Bool = true
    internal var themingDictionary:NSDictionary?
    internal var themePath:String = "inlineCard"
    internal var spacing:CGFloat = 7
    // Public
    var cardInputMode:CardInputMode = .FullCardInput {
        didSet{
            switch cardInputMode {
            case .InlineCardInput:
                themePath = "inlineCard"
            case .FullCardInput:
                themePath = "fullCard"
            }
        }
    }
    //lazy var showCardName:Bool = true
    lazy var showScanningOption:Bool = true
    
    required init?(coder: NSCoder) {
        super.init(coder:coder)
        self.backgroundColor = .clear
        //self.addSubview(contentView!)
        //setupViews()
    }
    
    
    @objc public func setup(for cardInputMode:CardInputMode,withDictionaryTheme:NSDictionary) {
        
        applyingDefaultTheme = true
        self.cardInputMode = cardInputMode
        applyTheme(with: withDictionaryTheme)
        setupViews()
    }
    
    @objc public func setup(for cardInputMode:CardInputMode,withJsonTheme:String) {
        
        applyingDefaultTheme = true
        self.cardInputMode = cardInputMode
        applyTheme(with: withJsonTheme)
        setupViews()
    }
    
    @objc public func setup(for cardInputMode:CardInputMode) {
        
        applyingDefaultTheme = true
        self.cardInputMode = cardInputMode
        setupViews()
    }
    
    
    
       /// Apply  the theme values from the theme file to the matching outlets
       internal func applyTheme(with dictionaryTheme:NSDictionary)
       {
           applyingDefaultTheme = false
           TapThemeManager.setTapTheme(themeDict: dictionaryTheme)
           themingDictionary = TapThemeManager.currentTheme
       }
       
       /// Apply  the theme values from the theme file to the matching outlets
       internal func applyTheme(with jsonTheme:String)
       {
           applyingDefaultTheme = false
           TapThemeManager.setTapTheme(jsonName: jsonTheme)
           themingDictionary = TapThemeManager.currentTheme
       }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard applyingDefaultTheme else {
            return
        }
        
        applyDefaultTheme()
        matchThemeAttributes()
    }
    
    
    internal func applyDefaultTheme() {
        // Check if the file exists
        let bundle:Bundle = Bundle(for: type(of: self))
        let themeFile:String = (self.traitCollection.userInterfaceStyle == .dark) ? "DefaultDarkTheme" : "DefaultLightTheme"
        
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
        applyTheme(with: jsonDict)
        applyingDefaultTheme = true
    }
    
    
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
    
    internal func setFonts() {
        fields.forEach { (field) in
            // Fonts
            field.tap_theme_font = ThemeFontSelector.init(stringLiteral: "\(themePath).textFields.font")
        }
    }
    
    
    internal func setCommonUI() {
        // background
        self.tap_theme_backgroundColor = ThemeUIColorSelector.init(keyPath: "\(themePath).commonAttributes.backgroundColor")
        self.layer.tap_theme_borderColor = ThemeCgColorSelector.init(keyPath: "\(themePath).commonAttributes.borderColor")
        self.layer.tap_theme_borderWidth = ThemeCGFloatSelector.init(keyPath: "\(themePath).commonAttributes.borderWidth")
        self.layer.tap_theme_cornerRadious = ThemeCGFloatSelector.init(keyPath: "\(themePath).commonAttributes.cornerRadius")
        self.spacing = CGFloat(TapThemeManager.numberValue(for: "\(themePath).commonAttributes.itemSpacing")?.floatValue ?? 0)
    }
    
    
    internal func configureViews() {
        icon.image = UIImage(named: "bank", in: Bundle(for: type(of: self)), compatibleWith: nil)
        icon.contentMode = .scaleAspectFit
        
        scanButton.setTitle("", for: .normal)
        scanButton.setImage(UIImage(named: "scanIcon", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        scanButton.contentMode = .scaleAspectFit
        
        cardNumber.setup(with: 4, maxVisibleChars: 16, placeholder: "Card Number", editingStatusChanged: { [weak self] (isEditing) in
            if self?.cardInputMode == .InlineCardInput {
                self?.updateWidths(for: self?.cardNumber)
            }
        }) { [weak self] (brand) in
            if let nonNullSelf = self {
                if let nonNullBrand = brand {
                    nonNullSelf.icon.image = UIImage(named: nonNullBrand.cardImageName(), in: Bundle(for: type(of: nonNullSelf)), compatibleWith: nil)
                }else {
                    nonNullSelf.icon.image = UIImage(named: "bank", in: Bundle(for: type(of: nonNullSelf)), compatibleWith: nil)
                }
            }
        }
        cardName.setup(with: 4, maxVisibleChars: 16, placeholder: "Holder Name", editingStatusChanged: { [weak self] (isEditing) in
            if self?.cardInputMode == .InlineCardInput {
                self?.updateWidths(for: self?.cardName)
            }
        })
        cardExpiry.setup(placeholder: "MM/YY") {  [weak self] (isEditing) in
            if self?.cardInputMode == .InlineCardInput {
                self?.updateWidths(for: self?.cardExpiry)
            }
            
        }
        cardCVV.setup(placeholder: "CVV") {  [weak self] (isEditing) in
            if self?.cardInputMode == .InlineCardInput {
                self?.updateWidths(for: self?.cardCVV)
            }
            
        }
    }
    
    
    internal func addDoneButtonOnKeyboard(for field:TapCardTextField, previous:Bool = false, next:Bool = false, done:Bool = false) {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        //let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton: TapCardBarButton = TapCardBarButton(title: "Done", style: .done, target: self, action:#selector(doneAction(sender:)))
        let previousButton: TapCardBarButton = TapCardBarButton(title: "Previous", style: .done, target: self, action: #selector(previousAction(sender:)))
        let nextButton: TapCardBarButton = TapCardBarButton(title: "Next", style: .done, target: self, action: #selector(nextAction(sender:)))
        
        doneButton.cardField      = field
        nextButton.cardField      = field
        previousButton.cardField  = field
        
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
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        field.inputAccessoryView = doneToolbar
    }
    
    
    
    @objc internal func doneAction(sender:TapCardBarButton) {
           if let field = sender.cardField {
               field.resignFirstResponder()
           }
       }
       
       
       @objc internal func nextAction(sender:TapCardBarButton) {
            if let field = sender.cardField,
               let currentFieldIndex = fields.firstIndex(of: field) {
                fields[currentFieldIndex+1].becomeFirstResponder()
            }
       }
       
       @objc internal func previousAction(sender:TapCardBarButton) {
           if let field = sender.cardField,
              let currentFieldIndex = fields.firstIndex(of: field) {
               fields[currentFieldIndex-1].becomeFirstResponder()
           }
       }
    
    internal func addToolBarButtons() {
        
        switch cardInputMode {
        case .InlineCardInput:
            fields = [cardNumber,cardName,cardExpiry,cardCVV]
        case .FullCardInput:
            fields = [cardNumber,cardExpiry,cardCVV,cardName]
        }
        
        for (index, cardField) in fields.enumerated() {
            var showPrevious = false, showNext = false, showDone = false
            showPrevious = (index > 0)
            showDone = (index == (fields.count - 1))
            showNext = !showDone
            addDoneButtonOnKeyboard(for: cardField, previous: showPrevious, next: showNext, done: showDone)
        }
    }
}



extension TapCardInput:TapCardInputCommonProtocol {
   
    
    internal func matchThemeAttributes() {
        
        switch cardInputMode {
        case .InlineCardInput:
            themePath = "inlineCard"
        case .FullCardInput:
            themePath = "fullCard"
        }
        
        setTextColors()
        setFonts()
        setCommonUI()
        
    }
    
    
    internal func setupViews() {
        
        if applyingDefaultTheme { applyDefaultTheme() }
        
        matchThemeAttributes()
        
        addViews()
        
        configureViews()
        
        setupConstraints()
        
        addToolBarButtons()
        
        /*if !showCardName {
            removeCardName()
        }*/
        
        
    }
    
    
    internal func setupConstraints() {
        switch cardInputMode {
        case .InlineCardInput:
            setupInlineConstraints()
        case .FullCardInput:
            setupFullConstraints()
        default:
            return
        }
        
    }
    
    
    internal func addViews() {
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
