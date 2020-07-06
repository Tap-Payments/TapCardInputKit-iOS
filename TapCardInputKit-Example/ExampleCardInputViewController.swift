//
//  ExampleCardInputViewController.swift
//  TapCardInputKit-Example
//
//  Created by Osama Rabie on 13/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapCardInputKit_iOS
import CommonDataModelsKit_iOS
import LocalisationManagerKit_iOS
import TapCardVlidatorKit_iOS

class ExampleCardInputViewController: UIViewController {

    @IBOutlet weak var cardInput: TapCardInput!
    @IBOutlet weak var expandedHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    
    var themeDictionaty:NSDictionary?
    lazy var isInline:Bool = false
    lazy var lang:String = "en"
    let sharedLocalisationManager = TapLocalisationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardInput.translatesAutoresizingMaskIntoConstraints = false
        cardInput.showSaveCardOption = true
        cardInput.showScanningOption = true
        sharedLocalisationManager.localisationLocale = lang
        //sharedLocalisationManager.localisationFilePath = URL(fileURLWithPath: Bundle.main.path(forResource: "CustomTapCardInputKitLocalisation", ofType: "json")!)
        self.title = isInline ? "Inline Input" : "Expanded Input"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        expandedHeightConstraint.constant = isInline ? 45 : 190
        leftConstraint.constant = isInline ? 0 : -2
        rightConstraint.constant = isInline ? 0 : -2
        
        self.view.layoutIfNeeded()
        
        cardInput.delegate = self
        cardInput.setup(for: (isInline ? .InlineCardInput : .FullCardInput),allowedCardBrands: [CardBrand.visa.rawValue],cardIconUrl: "https://img.icons8.com/color/2x/visa.png")
    }
    @IBAction func languageChanged(_ sender: Any) {
        if let segment = sender as? UISegmentedControl {
            if segment.selectedSegmentIndex == 0 {
                sharedLocalisationManager.localisationLocale = "en"
            }else {
                sharedLocalisationManager.localisationLocale = "ar"
            }
            cardInput.localize()
        }
    }
    
}


extension ExampleCardInputViewController: TapCardInputProtocol {
    func brandDetected(for cardBrand: CardBrand, with validation: CrardInputTextFieldStatusEnum) {
        resultTextView.text = "Brand detected for : \(cardBrand) with status of : \(validation)\n\(resultTextView.text ?? "")\n";
    }
    
    
    func saveCardChanged(enabled: Bool) {
        resultTextView.text = "SAVE CARD isENABLED : \(enabled)\n\(resultTextView.text ?? "")\n";
    }
    
   
    func cardDataChanged(tapCard: TapCard) {
        resultTextView.text = "Card Number : \(tapCard.tapCardNumber ?? "")\nCard Name : \(tapCard.tapCardName ?? "")\nCard Expiry : \(tapCard.tapCardExpiryMonth ?? "")/\(tapCard.tapCardExpiryYear ?? "")\nCard CVV : \(tapCard.tapCardCVV ?? "")\n\(resultTextView.text ?? "")\n"
    }
    
    func scanCardClicked() {
        resultTextView.text = "SCAN CLICKED\n\(resultTextView.text ?? "")\n";
    }
    
    
}
