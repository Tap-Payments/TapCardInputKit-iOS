//
//  CardInputSelectionTableViewController.swift
//  TapCardInputKit-Example
//
//  Created by Osama Rabie on 13/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

class CardInputSelectionTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            showDefaultInput(isInline:true)
        case 1:
            showDefaultInput(isInline:false)
        case 2:
            showCustomInput()
        default:
            return
        }
    }
    
    
    func showDefaultInput(isInline:Bool) {
        
        if let example:ExampleCardInputViewController = storyboard?.instantiateViewController(withIdentifier: "ExampleCardInputViewController") as? ExampleCardInputViewController {
            example.isInline = isInline
            self.navigationController?.pushViewController(example, animated: true)
        }
    }
    
    func showCustomInput() {
        
        if let example:ViewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            self.navigationController?.pushViewController(example, animated: true)
        }
    }
}
