//
//  CardExpiryTextField.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 08/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import struct UIKit.CGFloat
import struct UIKit.CGRect
import class UIKit.UITextField
import protocol UIKit.UITextFieldDelegate
import class CommonDataModelsKit_iOS.TapCard
import RxCocoa
import RxSwift

/// Represnts the card cvv text field
class CardCVVTextField:TapCardTextField {
    let disposeBag:DisposeBag = .init()
    let isValidSubject:PublishRelay<Bool> = .init()
    
    /// Defines the length of the cvv length allowed based on the brand detected
    var cvvLength:Int = 3 {
        didSet{
            // If the cvv length changed, then we need to make sure, if the user did input more than that then we need to trim it to the allowed max new length
            if let text = self.text,
                text.count > cvvLength {
                self.text = text.substring(to: cvvLength)
            }
        }
    }
    
    
    /**
    Method that is used to setup the field by providing the needed info and the obersvers for the events
    - Parameter minVisibleChars: Number of mimum charachters to be visible when the field is inactive, in Inline mode. Default is 4
    - Parameter maxVisibleChars: Number of maximum charachters to be visible when the field is inactive, in Inline mode. Default is 16
    - Parameter placeholder: The placeholder to show in this field. Default is ""
    */
    func setup(with minVisibleChars: Int = 3, maxVisibleChars: Int = 3, placeholder:String = "") {
        // Set the place holder with the theme color
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: placeHolderTextColor])
        // Assign and save the passed attributes
        // Card number should have a numeric pad
        self.keyboardType = .phonePad
        self.minVisibleChars = minVisibleChars
        self.maxVisibleChars = maxVisibleChars
        
        isValidSubject.distinctUntilChanged().map{ $0 ? self.normalTextColor : self.errorTextColor}
            .subscribe(onNext: { [weak self] (newColor) in
                self?.textColor = newColor
            }).disposed(by: disposeBag)
        
        // Uodare rge global card CVV for any valid input
        isValidSubject.filter{ $0 }.map{ [weak self] _ in self?.text ?? "" }.filter{ $0 != ""}.distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                let tapCard:TapCard = TapCardInput.tapCardInputCardSubject.value
                tapCard.tapCardCVV = self?.text
                TapCardInput.tapCardInputCardSubject.accept(tapCard)
            }).disposed(by: disposeBag)
        
        // Set the text color bbased on validaty and editing status. When we end editing it has to be valid otherwise it will be errored out. But, when the user is still editing we show it as normal colour
        Observable.from(
            [self.rx.controlEvent(.editingDidBegin).map{ true },
             self.rx.controlEvent(.editingDidEnd).map{ self.isValid() },
             self.rx.text.map{ _ in self.isValid() }])
            .merge().bind(to: isValidSubject).disposed(by: disposeBag)
        
        // Apply needed formatting and validation to the text the user is writing
        self.rx.text.map{ $0 ?? ""}
            .map{ $0.onlyDigits() }
            .map{ $0.count >= self.cvvLength ? $0.substring(to: self.cvvLength) : $0 }
            .asDriver(onErrorJustReturn: "").drive(self.rx.text).disposed(by: disposeBag)
        
        //self.rx.controlEvent(.editingDidBegin).
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
}

extension CardCVVTextField:CardInputTextFieldProtocol {
    
    func calculatedWidth() -> CGFloat {
        
        return self.textWidth(textfield:self, text: generateFillingValueForWidth(with: (self.isEditing) ? maxVisibleChars : minVisibleChars))
    }
    
    func textFieldStatus(cardNumber:String? = nil) -> CrardInputTextFieldStatusEnum {
        // Chevk if we can get the text from the text field first
        guard let text:String = self.text else{ return .Invalid }
        // Check first if its only digits, shouldn't happend but defensive code
        guard text.onlyDigits() == text else { return .Invalid }
        // The card number field is considered valid only if it matches the length of the allowed CVV for the current card brand
        
        if text.count < 3 {
            // Minimum is 3 digits for the cvv, if not yet reached then it is still incomplete
            return .Incomplete
        }
        
        if text.count > cvvLength {
            // Defensive code, but make sure if it is more than the allowed cvv length then it is invalid
            return .Invalid
        }
        
        if text.count == cvvLength {
            // If it matches the cvv length then it is valid
            return .Valid
        }
        
        return .Invalid
    }
    
    func isValid(cardNumber:String? = nil) -> Bool {
        
        return textFieldStatus() == .Valid
    }
}


internal extension String {

    /**
     Method to calculate  the index to start of when taking a substring
     - Parameter from: The starting position ew need to start with
     */
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    /**
     Extension to get a substring from a string starting from a given position
     - Parameter from: The index you want to start taking the substrin from
     - Returns: The substring of the given string starting from the given index
     */
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    /**
    Extension to get a substring from a string starting from 0 till a given position
    - Parameter from: The index you want to end taking the substrin to
    - Returns: The substring of the given string starting from 0 to the given index
    */
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}
