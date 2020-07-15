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
import TapCardVlidatorKit_iOS

class EmailInputViewController: UIViewController {
    
    @IBOutlet weak var emaiInputView: TapEmailInput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TapThemeManager.setDefaultTapTheme()
        emaiInputView.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emaiInputView.setup()
    }
}

extension EmailInputViewController:TapEmailInputProtocol {
    
    func emailChanged(email: String, with validation: CrardInputTextFieldStatusEnum) {
        print(email)
    }
    
}
