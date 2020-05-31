//
//  CardNumberTextField.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 08/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapCardValidator
import RxSwift
import RxCocoa

/// Represnts the card number text field
class CardNumberTextField:TapCardTextField {
    
    
    internal let disposeBag:DisposeBag = .init()
    /**
     Method that is used to setup the field by providing the needed info and the obersvers for the events
     - Parameter minVisibleChars: Number of mimum charachters to be visible when the field is inactive, in Inline mode. Default is 4
     - Parameter maxVisibleChars: Number of maximum charachters to be visible when the field is inactive, in Inline mode. Default is 16
     - Parameter placeholder: The placeholder to show in this field. Default is ""
     - Parameter cardBrandDetected: Observer to listen to the event when a card brand is detected based on user input till the moment
     */
    func setup(with minVisibleChars: Int = 4, maxVisibleChars: Int = 16, placeholder:String = "") {
        
        // Assign and save the passed attributes
        self.minVisibleChars = minVisibleChars
        self.maxVisibleChars = maxVisibleChars
        self.fillBiggestAvailableSpace = false
        
        // Set the place holder with the theme color
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: placeHolderTextColor])
 
        // Card number should have a numeric pad
        self.keyboardType = .phonePad
        
        // Listen to the event of text change
        
        let textChangeObservable = self.rx.text
            .map{ text -> String in text ?? ""}
            .share()
            
        let validCardNumberInput:Observable<Bool> =
            textChangeObservable.distinctUntilChanged()
                .map { $0.digitsWithSpaces() == $0 && CardValidator.validate(cardNumber:   $0.onlyDigits()).validationState != .invalid }
        
        
        let textInput = Observable.zip(textChangeObservable, validCardNumberInput).distinctUntilChanged {
            let (textOne,_) = $0, (textTwo,_) = $1
            return textTwo == textOne
        }
        
        // Deal withconfigutations based on validity
        
        // Set the text field colour based on the valid status
        validCardNumberInput.map{ $0 ? self.normalTextColor : self.errorTextColor }
            .distinctUntilChanged()
            .subscribe(onNext: { self.textColor = $0 }).disposed(by: disposeBag)
        
        
        // Set the text field text based on valid, if valid set the spacing , if invalid remove invalid charachters
        validCardNumberInput
            .map{ valid -> String in
                guard let text = self.text else { return "" }
                return valid ? text.cardFormat(with: CardValidator.cardSpacing(cardNumber: text)) : text.digitsWithSpaces()
            }
            .asDriver(onErrorJustReturn: "")
            .drive(self.rx.text).disposed(by: disposeBag)
       
        // Whenever the status is valid, detect the brand otherwise, keep it nil
        validCardNumberInput.map { _ in CardValidator.validate(cardNumber: (self.text ?? "").onlyDigits()).cardBrand }.distinctUntilChanged().bind(to: TapCardInput.tapCardInputcardBrandSubject).disposed(by: disposeBag)
        
        
        // Update the global card number whenver the input is valid
        validCardNumberInput.filter{ $0 }.subscribe(onNext: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>, onError: <#T##((Error) -> Void)?##((Error) -> Void)?##(Error) -> Void#>, onCompleted: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>, onDisposed: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
        /*validCardNumberInput.filter{ (valid,text) in !valid }
            .subscribe(onNext: { [weak self] (_, text) in
                self?.textColor =  self?.errorTextColor
                self?.text = text
            }).disposed(by: disposeBag)
        
        validCardNumberInput.filter{ (valid,text) in valid }
            .distinctUntilChanged({ (inputOne, inputTwo) -> Bool in
                let (_,textOne) = inputOne
                let (_,textTwo) = inputTwo
                return textOne == textTwo
            })
        .subscribe(onNext: { [weak self] (_, text) in
            self?.textColor =  self?.normalTextColor
            self?.text = text
        }).disposed(by: disposeBag)*/
            
            /*textChangeObservable
            .distinctUntilChanged()
            .map{ text -> String in
                let newTapCard = TapCardInput.tapCardInputCardSubject.value
                newTapCard.tapCardNumber = text
                TapCardInput.tapCardInputCardSubject.accept(newTapCard)
                return text.cardFormat(with: CardValidator.cardSpacing(cardNumber: text))
            }
            .distinctUntilChanged()
            .bind(to: self.rx.text)
            .disposed(by: disposeBag)*/
        
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
        return self.textWidth(textfield:self, text: generateFillingValueForWidth(with: (self.isEditing) ? maxVisibleChars : minVisibleChars))
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
        let validationState = CardValidator.validate(cardNumber: nonNullCardNumber).validationState
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        // add their new text to the existing text
        let updatedText:String = currentText.replacingCharacters(in: stringRange, with: string)
        // Check if the new string is a valid one to allow writing it to the card number field
        return true //changeText(with: updatedText)
    }
    
    /**
     This method does the logic required to check if a given text is allowed to be written to the card number field or not
     - Parameter updatedText: The text we want to validate and write to the card number text field
     - Parameter setTextAfterValidation: States if the caller wants to write the text if is correcly validated
     - Returns: True if the text is valid and can be written to the card number field and false otherwise
     */
    internal func changeText(with updatedText:String, setTextAfterValidation:Bool = false) -> Bool {
        
        // In card number we only allow digits and spaces. The spaces will come from the formatting we are applying
        let filteredText:String = updatedText.digitsWithSpaces()
        // Validae the state of the number by trimming all non numeric charachters
        let validation = CardValidator.validate(cardNumber: filteredText.onlyDigits())
        // If there is a detected brand and the card brand deteced block is assigned, we need to fire this event
        TapCardInput.tapCardInputcardBrandSubject.accept(validation.cardBrand)
        
        // The text is only valid and allowed to be written if it does contain only digits and spaces & the validation kit is not stating it is an invalid card number format
        let shouldUpdate:Bool = (updatedText == filteredText && validation.validationState != .invalid)
        
        if shouldUpdate {
            // If we are going to write the text, we need now to color the text based on the status is it valid or incomplete
            self.textColor = (validation.validationState == .valid) ? normalTextColor : errorTextColor
        }
        
        if setTextAfterValidation {
            // If the caller wants us to write the text after validating it, then we do so here
            self.text = updatedText
            //didChangeText(textField:self)
        }
        
        return shouldUpdate
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
