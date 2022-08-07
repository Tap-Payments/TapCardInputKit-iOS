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
        cardInput.showCardBrandIcon = false
        
        sharedLocalisationManager.localisationLocale = lang
        //sharedLocalisationManager.localisationFilePath = URL(fileURLWithPath: Bundle.main.path(forResource: "CustomTapCardInputKitLocalisation", ofType: "json")!)
        self.title = isInline ? "Inline Input" : "Expanded Input"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        expandedHeightConstraint.constant = isInline ? 90 : 190
        leftConstraint.constant = isInline ? 0 : -2
        rightConstraint.constant = isInline ? 0 : -2
        
        self.view.layoutIfNeeded()
        
        cardInput.delegate = self
        
        let cardBrands:[Int] = [CardBrand.visa.rawValue,CardBrand.masterCard.rawValue,CardBrand.americanExpress.rawValue]//CardBrand.allCases.map{ $0.rawValue }
        
        cardInput.setup(for: (isInline ? .InlineCardInput : .FullCardInput),showCardName:true, showCardBrandIcon: true, allowedCardBrands: cardBrands, cardsIconsUrls: [CardBrand.visa.rawValue:"https://back-end.b-cdn.net//payment_methods//visa.png", CardBrand.masterCard.rawValue:"https://back-end.b-cdn.net//payment_methods//mastercard.png", CardBrand.americanExpress.rawValue:"https://back-end.b-cdn.net//payment_methods//american_express.png"], preloadCardHolderName: "OSAMA AHMED HELMY",editCardName: false)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
            self?.cardInput.setCardData(tapCard: .init(tapCardNumber: "4242424242424242",tapCardExpiryMonth: "12",tapCardExpiryYear: "23"), then: true)
        }
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
    @IBAction func fillTemplateCardClicked(_ sender: Any) {
        let alertController:UIAlertController = .init(title: "Which type?", message: "Choose a state", preferredStyle: .actionSheet)
        let valid:UIAlertAction = .init(title: "Valid card", style: .destructive) { [weak self] (_) in
            let card:TapCard = .init(tapCardNumber: "4242424242424242", tapCardName: "", tapCardExpiryMonth: "11", tapCardExpiryYear: "20", tapCardCVV: "100")
            self?.cardInput.setCardData(tapCard: card, then: false)
        }
        let inValid:UIAlertAction = .init(title: "Invalid card", style: .default) { [weak self] (_) in
            let card:TapCard = .init(tapCardNumber: "4242424242424211", tapCardName: "", tapCardExpiryMonth: "11", tapCardExpiryYear: "20", tapCardCVV: "100")
            self?.cardInput.setCardData(tapCard: card, then: false)
        }
        let cancel:UIAlertAction = .init(title: "Cancel", style: .cancel)
        
        alertController.addAction(valid)
        alertController.addAction(inValid)
        alertController.addAction(cancel)
        
        
        present(alertController, animated: true, completion: nil)
    }
    
}


extension ExampleCardInputViewController: TapCardInputProtocol {
    
    func shouldAllowChange(with cardNumber: String) -> Bool {
        return true
    }
    
    func dataChanged(tapCard: TapCard) {
        
    }
    
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
