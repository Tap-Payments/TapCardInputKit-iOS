//
//  TapCardBarButton.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 10/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import class UIKit.UIBarButtonItem

/// Represents the bar button item used in navigating between fields in the card fields view
internal class TapCardBarButton: UIBarButtonItem {
    /// The card field associated with this bar button item
    internal weak var cardField:TapCardTextField?
}
