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

    @IBOutlet weak var cardFull: TapCardInput!
    @IBOutlet weak var cardInline: TapCardInput!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //cardFull.setup(for: .FullCardInput)
        cardInline.setup(for: .InlineCardInput)
    }


}

