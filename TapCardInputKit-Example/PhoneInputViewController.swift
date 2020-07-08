//
//  PhoneInputViewController.swift
//  TapCardInputKit-Example
//
//  Created by Osama Rabie on 7/8/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import CommonDataModelsKit_iOS
import TapCardInputKit_iOS
import TapThemeManager2020

class PhoneInputViewController: UIViewController {

    @IBOutlet weak var phoneInputView: TapPhoneInput!
    override func viewDidLoad() {
        super.viewDidLoad()
        TapThemeManager.setDefaultTapTheme()
        phoneInputView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        phoneInputView.setup(with: .init(nameAR: "الكويت", nameEN: "Kuwait", code: "965", phoneLength: 8))
    }
}

extension PhoneInputViewController:TapPhoneInputProtocol {
    func phoneNumberChanged(phoneNumber: String) {
        
    }
}
