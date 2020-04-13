//
//  ExampleCardInputViewController.swift
//  TapCardInputKit-Example
//
//  Created by Osama Rabie on 13/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapCardInputKit_iOS

class ExampleCardInputViewController: UIViewController {

    @IBOutlet weak var cardInput: TapCardInput!
    @IBOutlet weak var expandedHeightConstraint: NSLayoutConstraint!
    
    var themeDictionaty:NSDictionary?
    lazy var isInline:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardInput.translatesAutoresizingMaskIntoConstraints = false
        
        self.title = isInline ? "Inline Input" : "Expanded Input"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        expandedHeightConstraint.constant = isInline ? 45 : 250
        self.view.layoutIfNeeded()
        
        cardInput.setup(for: (isInline ? .InlineCardInput : .FullCardInput), withDictionaryTheme: themeDictionaty)
    }

}
