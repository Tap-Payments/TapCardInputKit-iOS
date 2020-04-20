//
//  CardInputSelectionTableViewController.swift
//  TapCardInputKit-Example
//
//  Created by Osama Rabie on 13/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import MOLH

class CardInputSelectionTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MOLH.setLanguageTo("en")
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            selectLang(isInline:true)
        case 1:
            selectLang(isInline:false)
        case 2:
            showCustomInput()
        default:
            return
        }
    }
    
    
    func selectLang(isInline:Bool) {
        let ac:UIAlertController = UIAlertController(title: "Localise?", message: "Select language", preferredStyle: .alert)
        let enAction:UIAlertAction = UIAlertAction(title: "English", style: .default) { [weak self] (_) in
            DispatchQueue.main.async { [weak self] in
                //MOLH.setLanguageTo("en")
                self?.showDefaultInput(isInline: isInline, lang: "en")
            }
        }
        let arAction:UIAlertAction = UIAlertAction(title: "عربي", style: .default) { [weak self] (_) in
            DispatchQueue.main.async { [weak self] in
                //MOLH.setLanguageTo("ar")
                self?.showDefaultInput(isInline: isInline, lang: "ar")
            }
        }
        let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(enAction)
        ac.addAction(arAction)
        ac.addAction(cancelAction)
        DispatchQueue.main.async { [weak self] in
            self?.present(ac, animated: true, completion: nil)
        }
    }
    
    
    func showDefaultInput(isInline:Bool, lang:String = "en") {
        
        if let example:ExampleCardInputViewController = storyboard?.instantiateViewController(withIdentifier: "ExampleCardInputViewController") as? ExampleCardInputViewController {
            example.isInline = isInline
            example.lang = lang
            self.navigationController?.pushViewController(example, animated: true)
        }
    }
    
    func showCustomInput() {
        
        if let example:ViewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            self.navigationController?.pushViewController(example, animated: true)
        }
    }
}
