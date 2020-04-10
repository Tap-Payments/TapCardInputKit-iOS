//
//  TapCardInput.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 10/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import SnapKit

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
    lazy var showCardName:Bool = true

}
