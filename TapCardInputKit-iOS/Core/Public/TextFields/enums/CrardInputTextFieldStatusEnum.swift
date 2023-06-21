//
//  CrardInputTextFieldStatusEnum.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 08/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import TapCardVlidatorKit_iOS

/// This defines the status of the card textfield
@objc public enum CrardInputTextFieldStatusEnum:Int,CaseIterable {
    
    /// The textfield contains a valid value
    case Valid
    /// This textfield contains invalid value
    case Invalid
    /// This textfield is incomplete
    case Incomplete
    /// This textfield is being edited now
    case isEditing
    
    
    
    public init(status:CardValidationState) {
        switch status {
        case .incomplete:
            self = .Incomplete
        case .invalid:
            self = .Invalid
        case .valid:
            self = .Valid
        }
    }
}
