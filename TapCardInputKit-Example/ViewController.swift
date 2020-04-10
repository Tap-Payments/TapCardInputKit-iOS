//
//  ViewController.swift
//  TapCardInputKit-Example
//
//  Created by Osama Rabie on 07/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapCardInputKit_iOS

class ViewController: UIViewController {

    @IBOutlet weak var smallInlineCardInput: InlineCardInput! {
        didSet{
           // smallInlineCardInput.applyTheme(withJsonTheme: "Theme")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

