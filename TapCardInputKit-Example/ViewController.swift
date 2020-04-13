//
//  ViewController.swift
//  TapCardInputKit-Example
//
//  Created by Osama Rabie on 07/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var configTableView: UITableView!
    lazy var dataSource:[String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dataSource["backgroundColor"] = "#FFFFFF"
        dataSource["borderColor"] = "#0066FF"
        dataSource["cornerRadius"] = 10
        dataSource["borderWidth"] = 1
        dataSource["textColor"] = "#000000"
        dataSource["errorTextColor"] = "#FF0000"
        dataSource["placeHolderColor"] = "#00000055"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }


}

