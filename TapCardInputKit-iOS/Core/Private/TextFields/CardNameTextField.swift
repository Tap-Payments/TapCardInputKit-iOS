//
//  CardNumberTextField.swift
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

/// Represnts the card name text field
class CardNameTextField:TapCardTextField {
    
    let disposeBag:DisposeBag = .init()
    let isValidSubject:PublishRelay<Bool> = .init()
    
    /**
    Method that is used to setup the field by providing the needed info and the obersvers for the events
    - Parameter minVisibleChars: Number of mimum charachters to be visible when the field is inactive, in Inline mode. Default is 4
    - Parameter maxVisibleChars: Number of maximum charachters to be visible when the field is inactive, in Inline mode. Default is 16
    - Parameter placeholder: The placeholder to show in this field. Default is ""
    */
    func setup(with minVisibleChars: Int = 4, maxVisibleChars: Int = 16, placeholder:String = "") {
        // Assign and save the passed attributes
        self.minVisibleChars = minVisibleChars
        self.maxVisibleChars = maxVisibleChars
        // Card number should have a default keyboard
        self.keyboardType = .default
        // This indicates that this field should fill in the remaining width in the case of the inline mode
        self.fillBiggestAvailableSpace = true
        // Set the place holder with the theme color
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: placeHolderTextColor])
        
        self.rx.text.map{ $0 ?? ""}
            .distinctUntilChanged()
            .map{ [weak self] _ in self?.isValid() ?? false }.bind(to: isValidSubject).disposed(by: disposeBag)
        
        isValidSubject.map{ [weak self] in $0 ? self?.normalTextColor : self?.errorTextColor }
            .map{ $0 ?? UIColor.black }.distinctUntilChanged()
            .subscribe(onNext: { [weak self] (newColor) in
                self?.textColor = newColor
            }).disposed(by: disposeBag)
        
        isValidSubject.filter{ $0 }.map{ [weak self] _ in self?.text?.uppercased() ?? ""}
            .distinctUntilChanged().subscribe(onNext: { cardName in
                let tapCard:TapCard = TapCardInput.tapCardInputCardSubject.value
                tapCard.tapCardName = cardName
                TapCardInput.tapCardInputCardSubject.accept(tapCard)
            }).disposed(by: disposeBag)
        
        self.rx.text.map{ ($0 ?? "").alphabetOnly().uppercased() }
            .map{ $0.count >= 26 ? $0.substring(to: 26) : $0}.asDriver(onErrorJustReturn: "")
            .drive(self.rx.text).disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
}


extension CardNameTextField: CardInputTextFieldProtocol {
    
    func textFieldStatus(cardNumber:String? = nil) -> CrardInputTextFieldStatusEnum {
         if let text = self.text {
            // Make sure it is valid where there is a text and the text contains only alphabets
            if text.alphabetOnly() == text.lowercased() && (text.count >= 2 && text.count <= 26) {
                 return .Valid
             }
         }
         return .Invalid
     }
     
     func calculatedWidth() -> CGFloat {
         // Calculate the width of the field based on it is active status, if it is activbe we calculaye the width needed to show the max visible charachters and if it is inactive we calculate width based on minimum visible characters
         
         return self.textWidth(textfield:self, text: generateFillingValueForWidth(with: (self.isEditing) ? maxVisibleChars : minVisibleChars))
     }
    
    func isValid(cardNumber:String? = nil) -> Bool {
        
        return textFieldStatus() == .Valid
     }
}
