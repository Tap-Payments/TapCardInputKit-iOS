//
//  CardInputMode.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 10/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation

/// Sets the mode of the card input view
@objc public enum CardInputMode:Int {
    
    /// This when you want show one line card input
    case InlineCardInput = 0
    /// This when you want show full multline card input
    case FullCardInput = 1
    /// This when you want show a phone number input
    case PhoneInput = 2
}


/// Sets the UI mode of the card input
@objc public enum CardInputUIStatus:Int {
    /// This when you want show the UI of the normal card. Empty fields, where user will have to fill them
    case NormalCard = 0
    /// This when you want to show the UI of a saved card
    case SavedCard = 1
}
