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
import class CommonDataModelsKit_iOS.TapCard

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
        
        // Deal with configutations based on validity
        
        // Set the text field colour based on the valid status or if the user ended up editing we need to check if the card is valid. While typing we consider incomplpete as ok but it is invalid if ended typing
        
        Observable.from([validCardNumberInput,self.rx.controlEvent(.editingDidEnd).map{ self.isValid() }]).merge()
            .map{ $0 ? self.normalTextColor : self.errorTextColor }
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
        validCardNumberInput.filter{ $0 }.map{ _ -> String in (self.text ?? "").onlyDigits() }
            .distinctUntilChanged().filter{ $0 != "" }
            .map{ cardNumber -> TapCard in
                let tapCard = TapCardInput.tapCardInputCardSubject.value
                tapCard.tapCardNumber = cardNumber
                return tapCard
            }.bind(to: TapCardInput.tapCardInputCardSubject)
            .disposed(by: disposeBag)
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
