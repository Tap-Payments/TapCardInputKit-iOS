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
    internal lazy var cardNumber  = CardNumberTextField()
    internal lazy var cardName  = CardNameTextField()
    internal lazy var cardExpiry  = CardExpiryTextField()
    internal lazy var cardCVV     = CardCVVTextField()
    internal lazy var fields:[TapCardTextField] = [cardNumber,cardName,cardExpiry,cardCVV]
    internal lazy var applyingDefaultTheme:Bool = true
    internal var themingDictionary:NSDictionary?
    internal var spacing:CGFloat = 7 {
        didSet{
            
        }
    }
    // Public
    lazy var cardInputMode:CardInputMode = .InlineCardInput
    lazy var showCardName:Bool = true
    
    required init?(coder: NSCoder) {
        super.init(coder:coder)
        self.backgroundColor = .clear
        //self.addSubview(contentView!)
        setupViews()
    }
    
    
    /// Apply  the theme values from the theme file to the matching outlets
    @objc public func applyTheme(withDictionaryTheme:NSDictionary)
    {
        applyingDefaultTheme = false
        TapThemeManager.setTapTheme(themeDict: withDictionaryTheme)
        themingDictionary = TapThemeManager.currentTheme
    }
    
    /// Apply  the theme values from the theme file to the matching outlets
    @objc public func applyTheme(withJsonTheme:String)
    {
        applyingDefaultTheme = false
        TapThemeManager.setTapTheme(jsonName: withJsonTheme)
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
        applyTheme(withDictionaryTheme: jsonDict)
        applyingDefaultTheme = true
    }
    
    
    internal func setTextColors() {
        fields.forEach { (field) in
            // text colors
            field.normalTextColor = TapThemeManager.colorValue(for: "inlineCard.textFields.textColor") ?? .black
            // Error text colors
            field.errorTextColor = TapThemeManager.colorValue(for: "inlineCard.textFields.errorTextColor") ?? .black
            // placeholder colors
            field.placeHolderTextColor = TapThemeManager.colorValue(for: "inlineCard.textFields.placeHolderColor") ?? .black
        }
    }
    
    internal func setFonts() {
        
        fields.forEach { (field) in
            // Fonts
            field.tap_theme_font = "inlineCard.textFields.font"
        }
    }
    
    
    internal func setCommonUI() {
        // background
        self.tap_theme_backgroundColor = "inlineCard.commonAttributes.backgroundColor"
        self.layer.tap_theme_borderColor = "inlineCard.commonAttributes.borderColor"
        self.layer.tap_theme_borderWidth = "inlineCard.commonAttributes.borderWidth"
        self.layer.tap_theme_cornerRadious = "inlineCard.commonAttributes.cornerRadius"
    }
    
    
    internal func configureViews() {
        icon.image = UIImage(named: "bank", in: Bundle(for: type(of: self)), compatibleWith: nil)
        icon.contentMode = .scaleAspectFit
        cardNumber.setup(with: 4, maxVisibleChars: 16, placeholder: "Card Number", editingStatusChanged: { [weak self] (isEditing) in
            self?.updateWidths(for: self?.cardNumber)
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
            self?.updateWidths(for: self?.cardName)
        })
        cardExpiry.setup(placeholder: "MM/YY") {  [weak self] (isEditing) in
            self?.updateWidths(for: self?.cardExpiry)
            
        }
        cardCVV.setup(placeholder: "CVV") {  [weak self] (isEditing) in
            self?.updateWidths(for: self?.cardCVV)
            
        }
    }
    
    
    func addDoneButtonOnKeyboard(for field:TapCardTextField, previous:Bool = false, next:Bool = false, done:Bool = false) {
        
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
        setTextColors()
        setFonts()
        setCommonUI()
        
    }
    
    
    internal func setupViews() {
        applyDefaultTheme()
        
        matchThemeAttributes()
        
        addViews()
        
        configureViews()
        
        setupConstraints()
        
        addToolBarButtons()
        
        if !showCardName {
            removeCardName()
        }
        
        
    }
    
    
    internal func setupConstraints() {
        switch cardInputMode {
        case .InlineCardInput:
            setupInlineConstraints()
        default:
            return
        }
        
    }
    
    
    internal func addViews() {
        switch cardInputMode {
        case .InlineCardInput:
            addInlineViews()
        default:
            return
        }
    }
    
}
