//
//  InlineCardInput.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 08/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapThemeManager2020

internal class InlineCardInput: TapCardInput {
    
   
    
    override var themingDictionary:NSDictionary? {
        didSet{
            matchThemeAttributes()
        }
    }
   
    
    required init?(coder: NSCoder) {
        super.init(coder:coder)
        applyDefaultTheme()
        matchThemeAttributes()
        setupViews()
    }
    
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard applyingDefaultTheme else {
            return
        }
        
        applyDefaultTheme()
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
    
    internal func matchThemeAttributes() {
        setTextColors()
        setFonts()
        setCommonUI()
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
    
    func setupViews() {
        
        addViews()
        
        configureViews()
        
        setupConstraints()
        
        addToolBarButtons()
        
        if !showCardName {
            removeCardName()
        }
        
        calculateAutoMinWidths()
        
    }
    
    
    internal func setupConstraints() {
        scrollView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        
        stackView.snp.remakeConstraints { (make) in
            //make.edges.equalToSuperview()
            make.height.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalTo(spacing)
            make.right.equalTo(-spacing)
        }
        
        icon.snp.remakeConstraints { (make) in
            make.width.equalTo(32)
            make.height.equalTo(icon.snp.width)
        }
        
        cardNumber.snp.remakeConstraints { (make) in
            make.width.greaterThanOrEqualTo(cardNumber.calculatedWidth())
            make.height.equalTo(stackView)
        }
        
        cardName.snp.remakeConstraints { (make) in
            make.width.greaterThanOrEqualTo(cardName.calculatedWidth())
            make.height.equalTo(stackView)
        }
        
        cardExpiry.snp.remakeConstraints { (make) in
            make.width.greaterThanOrEqualTo(cardExpiry.calculatedWidth())
            make.height.equalTo(stackView)
        }
        
        cardCVV.snp.remakeConstraints { (make) in
            make.width.greaterThanOrEqualTo(cardCVV.calculatedWidth())
            make.height.equalTo(stackView)
        }
        
        
        layoutIfNeeded()
        
    }
    
    internal func configureViews() {
        icon.image = UIImage(named: "bank", in: Bundle(for: type(of: self)), compatibleWith: nil)
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .yellow
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
    
    internal func addViews() {
        
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.alwaysBounceVertical = false
        
        self.addSubview(scrollView)
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.backgroundColor = .clear
        stackView.spacing = spacing
        stackView.distribution = .fillProportionally
        
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(icon)
        stackView.addArrangedSubview(cardNumber)
        stackView.addArrangedSubview(cardName)
        stackView.addArrangedSubview(cardExpiry)
        stackView.addArrangedSubview(cardCVV)
    }
    
    internal func addToolBarButtons() {
        for (index, element) in stackView.arrangedSubviews.enumerated() {
            // Check it is a text field
            if let cardField:TapCardTextField = element as? TapCardTextField {
                var showPrevious = false, showNext = false, showDone = false
                
                // Check if we need to add previous button
                if let _:TapCardTextField = stackView.arrangedSubviews[index-1] as? TapCardTextField {
                    showPrevious = true
                }
                // Check of we have next field inline
                if (index+1) < stackView.arrangedSubviews.count {
                    if let _:TapCardTextField = stackView.arrangedSubviews[index+1] as? TapCardTextField {
                        showNext = true
                    }else{
                        showDone = true
                    }
                }else{
                    showDone = true
                }
                addDoneButtonOnKeyboard(for: cardField, previous: showPrevious, next: showNext, done: showDone)
            }
        }
    }
    
    internal func removeCardName() {
        cardName.isHidden = true
        cardName.snp.makeConstraints { (make) in
            make.width.greaterThanOrEqualTo(0)
        }
    }
    
    internal func calculateAutoMinWidths() {
        
        var lastFilledPoint:CGFloat = 0
        var fillingSpaceComponents:[TapCardTextField] = []
        
        stackView.arrangedSubviews.forEach { (subView) in
            
            lastFilledPoint = subView.frame.maxX
            
            if let cardField = subView as? TapCardTextField {
                
                if cardField.fillBiggestAvailableSpace {
                    fillingSpaceComponents.append(cardField)
                }
            }
        }
        if lastFilledPoint == 0 || self.scrollView.frame.width == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + (0.1)) { [weak self] in
                self?.calculateAutoMinWidths()
            }
            return
        }
        
        if fillingSpaceComponents.count == 0 {return}
        
        let totalWidth = frame.width - spacing
        let extraSpaceWidthValue = (totalWidth - lastFilledPoint) / CGFloat(fillingSpaceComponents.count)
        
        if extraSpaceWidthValue <= 0 {return}
        
        fillingSpaceComponents.forEach { (cardField) in
            
            let newWidth = cardField.frame.width + extraSpaceWidthValue
            cardField.autoMinCalculatedWidth = newWidth
            cardField.snp.makeConstraints { (make) in
                make.width.greaterThanOrEqualTo(newWidth)
            }
            
        }
        
        self.scrollView.layoutIfNeeded()
    }
    
    
    
    func addDoneButtonOnKeyboard(for field:TapCardTextField, previous:Bool = false, next:Bool = false, done:Bool = false) {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        //let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action:#selector(doneAction(sender:)))
        let previousButton: UIBarButtonItem = UIBarButtonItem(title: "Previous", style: .done, target: self, action: #selector(previousAction(sender:)))
        let nextButton: UIBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(nextAction(sender:)))
        
        doneButton.tag      = stackView.arrangedSubviews.firstIndex(of: field) ?? 0
        nextButton.tag      = (stackView.arrangedSubviews.firstIndex(of: field) ?? stackView.arrangedSubviews.count) + 1
        previousButton.tag  = (stackView.arrangedSubviews.firstIndex(of: field) ?? 0) - 1
        
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
    
    
    internal func updateWidths(for subView:UIView?) {
        if let nonNullView:TapCardTextField = subView as? TapCardTextField {
            //scrollView.layoutIfNeeded()
            layoutIfNeeded()
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                nonNullView.snp.updateConstraints( { make in
                    if let nonNullProtocolImplemented:CardInputTextFieldProtocol = nonNullView as? CardInputTextFieldProtocol {
                        make.width.greaterThanOrEqualTo(nonNullProtocolImplemented.calculatedWidth())
                    }
                })
                
                self?.layoutIfNeeded()
                
                
            }) { (done) in
                if nonNullView.isEditing {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        var point = nonNullView.frame.origin
                        point.x = point.x - 5
                        if self?.scrollView.contentOffset.x ?? 0 > point.x {
                            self?.scrollView.setContentOffset(point, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    
    @objc internal func doneAction(sender:UIView) {
        if let field = stackView.arrangedSubviews[sender.tag] as? TapCardTextField {
            field.resignFirstResponder()
        }
    }
    
    
    @objc internal func nextAction(sender:UIView) {
        if sender.tag < stackView.arrangedSubviews.count,
            let field = stackView.arrangedSubviews[sender.tag] as? TapCardTextField {
            field.becomeFirstResponder()
        }
    }
    
    @objc internal func previousAction(sender:UIView) {
        if sender.tag >= 0,
            let field = stackView.arrangedSubviews[sender.tag] as? TapCardTextField {
            field.becomeFirstResponder()
        }
    }
    
}
