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

class ExampleCardInputViewController: UIViewController {

    var cardInput: TapCardInput?
    @IBOutlet weak var expandedHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var cardCaontainerView: UIView!

    var themeDictionaty:NSDictionary?
    lazy var isInline:Bool = false
    lazy var lang:String = "en"
    let sharedLocalisationManager = TapLocalisationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        cardInput.translatesAutoresizingMaskIntoConstraints = false
        
        sharedLocalisationManager.localisationLocale = lang
        sharedLocalisationManager.localisationFilePath = URL(fileURLWithPath: Bundle.main.path(forResource: "CustomTapCardInputKitLocalisation", ofType: "json")!)
        self.title = isInline ? "Inline Input" : "Expanded Input"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        expandedHeightConstraint.constant = isInline ? 45 : 150
        refreshCardInputView()
        self.view.layoutIfNeeded()
    }
    @IBAction func languageChanged(_ sender: Any) {
        if let segment = sender as? UISegmentedControl {
            if segment.selectedSegmentIndex == 0 {
                sharedLocalisationManager.localisationLocale = "en"
            }else {
                sharedLocalisationManager.localisationLocale = "ar"
            }
            
            
            cardInput!.localize(shouldFlip: true)
            refreshCardInputView()
        }
        
    }
    
    func refreshCardInputView() {
        if let cardInput = cardInput {
            cardInput.removeFromSuperview()
        }
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: expandedHeightConstraint.constant)
        cardInput = TapCardInput(frame: frame)
        
//        cardInput!.translatesAutoresizingMaskIntoConstraints = false
        
        cardCaontainerView.addSubview(cardInput!)
        
        cardInput!.delegate = self
        cardInput!.setup(for: (isInline ? .InlineCardInput : .FullCardInput), withDictionaryTheme: themeDictionaty)
        self.view.layoutIfNeeded()
    }
    
}


extension ExampleCardInputViewController: TapCardInputProtocol {
   
    func cardDataChanged(tapCard: TapCard) {
        resultTextView.text = "Card Number : \(tapCard.tapCardNumber ?? "")\nCard Name : \(tapCard.tapCardName ?? "")\nCard Expiry : \(tapCard.tapCardExpiryMonth ?? "")/\(tapCard.tapCardExpiryYear ?? "")\nCard CVV : \(tapCard.tapCardCVV ?? "")\n\(resultTextView.text ?? "")\n"
    }
    
    func scanCardClicked() {
        resultTextView.text = "SCAN CLICKED\n\(resultTextView.text ?? "")\n";
    }
    
    
}
