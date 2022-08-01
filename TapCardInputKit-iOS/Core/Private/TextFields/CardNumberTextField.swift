//
//  CardNumberTextField.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 08/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapCardVlidatorKit_iOS
import LocalisationManagerKit_iOS
import CommonDataModelsKit_iOS
/// Represnts the card number text field
class CardNumberTextField:TapCardTextField {
    
    /**
     This is the block that will fire an event when a card brand is detected
     - Parameter CardBrand: The detected card brand
     */
    var cardBrandDetected: ((CardBrand?) -> ())? =  nil
    /**
     This is the block that will fire an event when a the card number has changed
     */
    var cardNumberChanged: ((String) -> ())? =  nil
    
    /**
     This method will be called whenever the user tries to enter new digits inside the card number, then we need to the delegate to tell us if we can complete the card number.
     */
    var shouldAllowChange: ((String) -> (Bool))? =  nil
    
    var allowedBrands:[Int] = []
    
    /**
     Method that is used to setup the field by providing the needed info and the obersvers for the events
     - Parameter minVisibleChars: Number of mimum charachters to be visible when the field is inactive, in Inline mode. Default is 4
     - Parameter maxVisibleChars: Number of maximum charachters to be visible when the field is inactive, in Inline mode. Default is 16
     - Parameter placeholder: The placeholder to show in this field. Default is ""
     - Parameter editingStatusChanged: Observer to listen to the event when the editing status changed, whether started or ended editing
     - Parameter cardBrandDetected: Observer to listen to the event when a card brand is detected based on user input till the moment
     - Parameter cardNumberChanged: Observer to listen to the event when a the card number is changed by user input till the moment
     - Parameter shouldAllowChange: This method will be called whenever the user tries to enter new digits inside the card number, then we need to the delegate to tell us if we can complete the card number.
     */
    func setup(with minVisibleChars: Int = 4, maxVisibleChars: Int = 16, placeholder:String = "", editingStatusChanged: ((Bool) -> ())? = nil,cardBrandDetected: ((CardBrand?) -> ())? =  nil,cardNumberChanged: ((String) -> ())? =  nil, shouldAllowChange: ((String) -> (Bool))? =  nil) {
        
        // Assign and save the passed attributes
        self.minVisibleChars = minVisibleChars
        self.maxVisibleChars = maxVisibleChars
        self.fillBiggestAvailableSpace = false
        self.cardNumberChanged = cardNumberChanged
        self.shouldAllowChange = shouldAllowChange
        
        // Set the place holder with the theme color
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: placeHolderTextColor])
        
        // Card number should have a numeric pad
        self.keyboardType = .phonePad
        
        // Listen to the event of text change
        self.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
        
        // Assign the observers and the blocks
        self.editingStatusChanged = editingStatusChanged
        self.cardBrandDetected = cardBrandDetected
        
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
}


extension CardNumberTextField:CardInputTextFieldProtocol {
    
    func calculatedWidth() -> CGFloat {
        // Calculate the width of the field based on it is active status, if it is activbe we calculaye the width needed to show the max visible charachters and if it is inactive we calculate width based on minimum visible characters
        return self.textWidth(textfield:self, text: generateFillingValueForWidth(with: (self.isEditing || !self.isValid()) ? maxVisibleChars : minVisibleChars))
    }
    
    func textFieldStatus(cardNumber:String? = nil) -> CrardInputTextFieldStatusEnum {
        // The card number field is considered valid only if it matches the regex of one of the known cards regex schemes
        
        // We assign the textx to validate to be text field text by removing all non numeric characters
        var nonNullCardNumber =  self.text?.onlyDigits() ?? ""
        if let _ = cardNumber {
            // Here, this means the caller wants to validate a certain given number not the text field's text
            nonNullCardNumber = cardNumber!
        }
        // We use the Valoidation kit to get the status of the number
        let definedCard = CardValidator.validate(cardNumber: nonNullCardNumber,preferredBrands: allowedBrands.map{ CardBrand.init(rawValue: $0)! })
        if let definedBrand = definedCard.cardBrand,
           allowedBrands.count > 0, !allowedBrands.contains(definedBrand.rawValue){
            return .Invalid
        }
        
        if nonNullCardNumber == "" {
            return .Invalid
        }
        
        let validationState = definedCard.validationState
        switch validationState {
        case .incomplete:
            return .Incomplete
        case .invalid:
            return .Invalid
        case .valid:
            return .Valid
        }
    }
    
    func isValid(cardNumber:String? = nil) -> Bool {
        
        return textFieldStatus(cardNumber:cardNumber) == .Valid
    }
}

extension CardNumberTextField:UITextFieldDelegate {
    
    /// Adds a DONE button to the card number field so the user can hide the keyboard and see the rest of the fields in case of editing the valid card number
    func addDoneButtonOnKeyboard()
    {
        // The default localisation file location
        let defaultLocalisationFilePath:URL = TapCommonConstants.pathForDefaultLocalisation()
        // Assign the localisation values
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let done: UIBarButtonItem = UIBarButtonItem(title: TapLocalisationManager.shared.localisedValue(for: "Common.done", with: defaultLocalisationFilePath), style: UIBarButtonItem.Style.done, target: self, action: #selector(doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
        
    }
    
    
    /**button action generate following two way both are working great but use any one**/
    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // If the editing changed block is assigned, we need to fire this event as the editing now started for the field
        if let nonNullEditingBlock = editingStatusChanged {
            nonNullEditingBlock(true)
        }
        addDoneButtonOnKeyboard()
        print("Number # TRUE")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        // If the editing changed block is assigned, we need to fire this event as the editing now ended for the field
        if let nonNullEditingBlock = editingStatusChanged {
            nonNullEditingBlock(false)
        }
        print("Number # FALSE")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
        // For the card number we need to apply the formatting of every four digits scheme before assigning the text
        let spacing = CardValidator.cardSpacing(cardNumber: textField.text!.onlyDigits())
        print("SPACING : \(spacing)")
        textField.text = textField.text!.cardFormat(with: spacing)
        if let nonNullBlock = cardNumberChanged {
            // If the card number changed block is assigned, we need to fire this event
            nonNullBlock(textField.text!.onlyDigits())
        }
        if let nonNullTextChangeBlock = textChanged {
            nonNullTextChangeBlock(self.text ?? "")
        }
    }
    
    /**
     This method does the logic required to check if a given text is allowed to be written to the card number field or not
     - Parameter updatedText: The text we want to validate and write to the card number text field
     - Parameter setTextAfterValidation: States if the caller wants to write the text if is correcly validated
     - Returns: True if the text is valid and can be written to the card number field and false otherwise
     */
    internal func changeText(with updatedText:String, setTextAfterValidation:Bool = false) -> Bool {
        
        // Let us first make sure the delegate doesn't have an issue with the text
        guard shouldAllowChange?(updatedText.onlyDigits()) ?? true else { return false }
        
        // In card number we only allow digits and spaces. The spaces will come from the formatting we are applying
        let filteredText:String = updatedText.digitsWithSpaces()
        // Validae the state of the number by trimming all non numeric charachters
        let validation = CardValidator.validate(cardNumber: filteredText.onlyDigits(),preferredBrands: allowedBrands.map{ CardBrand.init(rawValue: $0)! })
        
        
        if let nonNullCardBrandBlock = cardBrandDetected {
            // If there is a detected brand and the card brand deteced block is assigned, we need to fire this event
            nonNullCardBrandBlock(validation.cardBrand)
        }
        
        // The text is only valid and allowed to be written if it does contain only digits and spaces & the validation kit is not stating it is an invalid card number format
        let shouldUpdate:Bool = (updatedText == filteredText && validation.validationState != .invalid)
        
        if shouldUpdate {
            // If we are going to write the text, we need now to color the text based on the status is it valid or incomplete
            self.textColor = (validation.validationState == .valid) ? normalTextColor : errorTextColor
        }
        
        if setTextAfterValidation {
            // If the caller wants us to write the text after validating it, then we do so here
            self.text = updatedText
            didChangeText(textField:self)
        }
        if let nonNullTextChangeBlock = textChanged {
            nonNullTextChangeBlock(self.text ?? "")
        }
        return shouldUpdate
    }
    
    /// Call this method to revalidate and detect the brand. It will call the callback of brand detected if was set before
    internal func reValidate(tapCardNumber:String?) {
        // Make sure we do have a text to validate
        // In card number we only allow digits and spaces. The spaces will come from the formatting we are applying
        guard let filteredText:String = tapCardNumber?.digitsWithSpaces(),
              !filteredText.isEmpty else { return }
        
        // Validae the state of the number by trimming all non numeric charachters
        let validation = CardValidator.validate(cardNumber: filteredText.onlyDigits(),preferredBrands: allowedBrands.map{ CardBrand.init(rawValue: $0)! })
        
        
        if let nonNullCardBrandBlock = cardBrandDetected {
            // If there is a detected brand and the card brand deteced block is assigned, we need to fire this event
            nonNullCardBrandBlock(validation.cardBrand)
        }
        
        if let nonNullBlock = cardNumberChanged {
            // If the card number changed block is assigned, we need to fire this event
            nonNullBlock(filteredText.onlyDigits())
        }
    }
    
    internal func cardBrand(for cardNumber:String) -> (CardBrand?,CardValidationState) {
        // OSAA VALIDATE HERE
        let validation = CardValidator.validate(cardNumber: cardNumber.onlyDigits(),preferredBrands: allowedBrands.map{ CardBrand.init(rawValue: $0)! })
        return (validation.cardBrand,validation.validationState)
    }
}


extension CardBrand {
    
    /**
     Method extending the tap validation kit to provide back an image name to be used for each card brand
     - Returns: An image name (asset) that represents the current card brand
     */
    func cardImageName() -> String {
        
        switch self {
        case .visa,.visaElectron:
            return "visa"
        case .americanExpress:
            return "american-express"
        case .discover:
            return "discover"
        case .dinersClub:
            return "diners-club"
        case .jcb:
            return "jcb"
        case .masterCard,.maestro:
            return "mastercard"
        case .unionPay:
            return "unionpay"
        default:
            return "bank"
        }
    }
}
