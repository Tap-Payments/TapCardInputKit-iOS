//
//  ViewController.swift
//  TapCardInputKit-Example
//
//  Created by Osama Rabie on 07/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapCardInputKit_iOS
import class CommonDataModelsKit_iOS.TapCard

class ViewController: UIViewController {

    @IBOutlet weak var cardFull: TapCardInput!
    @IBOutlet weak var cardInline: TapCardInput!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cardFull.setup(for: .FullCardInput)
        cardFull.setCardData(tapCard: .init(tapCardNumber: "4242424242424242", tapCardExpiryMonth: "12",tapCardExpiryYear: "20", tapCardCVV: "11"))
        //cardInline.setup(for: .InlineCardInput)
    }


}

