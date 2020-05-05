//
//  ViewController.swift
//  TapCardInputKit-Example
//
//  Created by Osama Rabie on 07/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import SheetyColors
import TapThemeManager2020

class ViewController: UIViewController {
    
    @IBOutlet weak var configTableView: UITableView!
    lazy var dataSource:[String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dataSource["backgroundColor"] = "#FFFFFF"
        dataSource["borderColor"] = "#0066FF"
        dataSource["cornerRadius"] = 10
        dataSource["borderWidth"] = 0
        dataSource["textColor"] = "#000000"
        dataSource["errorTextColor"] = "#FF0000"
        dataSource["placeHolderColor"] = "#00000055"
        dataSource["widthMargin"] = 15
        dataSource["labelTextFont"] = 15
        dataSource["labelTextColor"] = "#000000"
        dataSource["switchTintColor"] = "#FFFFFF"
        dataSource["switchThumbColor"] = "#FFFFFF"
        dataSource["switchOnThumbColor"] = "#2ACE00"
        
        configTableView.dataSource = self
        configTableView.delegate = self
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}

extension ViewController:UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return dataSource.count
        case 1:
            return 2
        default:
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Theme Details"
        case 1:
            return "Card Input Mode"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "configCell", for: indexPath)
        cell.detailTextLabel?.textColor = .black
        
        if indexPath.section == 0 {
            let key = (Array(dataSource.keys)[indexPath.row])
            cell.textLabel?.text = "Select \(key)"
            cell.detailTextLabel?.text = "Selected value \(dataSource[key]!)"
            do {
                cell.detailTextLabel?.textColor = try UIColor(tap_hex: dataSource[key]! as? String ?? "")
            }catch{
                print(error.localizedDescription)
            }
            
        }else if indexPath.section == 1 {
            cell.detailTextLabel?.text = ""
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Inline Mode"
            }else if indexPath.row == 1 {
                cell.textLabel?.text = "Expanded Mode"
            }
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let key = (Array(dataSource.keys)[indexPath.row])
            
            do {
                let currentColor = try UIColor(tap_hex: dataSource[key]! as? String ?? "")
                showColorPicker(with: currentColor, title: key) { [weak self] (selectedColor) in
                    
                    self?.dataSource[key] = selectedColor.toHexString()
                    DispatchQueue.main.async {[weak self] in
                        self?.configTableView.reloadData()
                    }
                }
                return
            }catch{
                print(error.localizedDescription)
            }
            
            let ac = UIAlertController(title: key, message: "Enter a numeric value", preferredStyle: .alert)
            ac.addTextField { (textField) in
                textField.keyboardType = .phonePad
            }
            // Define what to do when the user fills in the value
            let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac, weak self] _ in
                let answer = ac.textFields![0]
                
                if let floatValue = Float(answer.text  ?? "") {
                    self?.dataSource[key] = Int(floatValue)
                    DispatchQueue.main.async {[weak self] in
                        self?.configTableView.reloadData()
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            ac.addAction(submitAction)
            ac.addAction(cancelAction)
            DispatchQueue.main.async {[weak self] in
                self?.present(ac, animated: true, completion: nil)
            }
            
        }else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                showCardInput(isInline:true)
            case 1:
                showCardInput(isInline:false)
            default:
                return
            }
        }
    }
    
    
    internal func showColorPicker(with defaultColor:UIColor,title:String,selectedBlock: @escaping ((UIColor)->())) {
        
        // Create a SheetyColors view with your configuration
        let config = SheetyColorsConfig(alphaEnabled: true, hapticFeedbackEnabled: true, initialColor: defaultColor, title: title, type: .rgb)
        let sheetyColors = SheetyColorsController(withConfig: config)
        
        // Add a button to accept the selected color
        let selectAction = UIAlertAction(title: "Select Color", style: .destructive, handler: { _ in
            selectedBlock(sheetyColors.color)
        })
        
        sheetyColors.addAction(selectAction)
        
        // Add a cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheetyColors.addAction(cancelAction)
        
        // Now, present it to the user
        self.present(sheetyColors, animated: true, completion: nil)
        
    }
    
    
    
    func showCardInput(isInline:Bool) {
        
        if let path = Bundle.main.path(forResource: "Theme", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                let themeDict:NSMutableDictionary = NSMutableDictionary(dictionary:jsonResult as! NSDictionary)
                
                
                let inlineDict:NSMutableDictionary = NSMutableDictionary(dictionary:(themeDict["inlineCard"] as! NSDictionary))
                let inlineCommonAttributesDict:NSMutableDictionary = NSMutableDictionary(dictionary:inlineDict["commonAttributes"] as! NSDictionary)
                let inlineTextFieldAttributesDict:NSMutableDictionary = NSMutableDictionary(dictionary:inlineDict["textFields"] as! NSDictionary)
                
                inlineCommonAttributesDict["backgroundColor"] = dataSource["backgroundColor"]
                inlineCommonAttributesDict["borderColor"] = dataSource["borderColor"]
                inlineCommonAttributesDict["cornerRadius"] = dataSource["cornerRadius"]
                inlineCommonAttributesDict["borderWidth"] = dataSource["borderWidth"]
                
                inlineTextFieldAttributesDict["textColor"] = dataSource["textColor"]
                inlineTextFieldAttributesDict["errorTextColor"] = dataSource["errorTextColor"]
                inlineTextFieldAttributesDict["placeHolderColor"] = dataSource["placeHolderColor"]
                
                inlineDict["commonAttributes"] = inlineCommonAttributesDict
                inlineDict["textFields"] = inlineTextFieldAttributesDict
                themeDict["inlineCard"] = inlineDict
                
                
                let fullDict:NSMutableDictionary = NSMutableDictionary(dictionary:(themeDict["fullCard"] as! NSDictionary))
                let fullCommonAttributesDict:NSMutableDictionary = NSMutableDictionary(dictionary:fullDict["commonAttributes"] as! NSDictionary)
                let fullTextFieldAttributesDict:NSMutableDictionary = NSMutableDictionary(dictionary:fullDict["textFields"] as! NSDictionary)
                let saveCardOptionAttributesDict:NSMutableDictionary = NSMutableDictionary(dictionary:fullDict["saveCardOption"] as! NSDictionary)
                
                
                fullCommonAttributesDict["backgroundColor"] = dataSource["backgroundColor"]
                fullCommonAttributesDict["borderColor"] = dataSource["borderColor"]
                fullCommonAttributesDict["cornerRadius"] = dataSource["cornerRadius"]
                fullCommonAttributesDict["borderWidth"] = dataSource["borderWidth"]
                fullCommonAttributesDict["widthMargin"] = dataSource["widthMargin"]
                

                fullTextFieldAttributesDict["textColor"] = dataSource["textColor"]
                fullTextFieldAttributesDict["errorTextColor"] = dataSource["errorTextColor"]
                fullTextFieldAttributesDict["placeHolderColor"] = dataSource["placeHolderColor"]
                
                saveCardOptionAttributesDict["labelTextFont"] = dataSource["labelTextFont"]
                saveCardOptionAttributesDict["labelTextColor"] = dataSource["labelTextColor"]
                saveCardOptionAttributesDict["switchTintColor"] = dataSource["switchTintColor"]
                saveCardOptionAttributesDict["switchThumbColor"] = dataSource["switchThumbColor"]
                saveCardOptionAttributesDict["switchOnThumbColor"] = dataSource["switchOnThumbColor"]

                fullDict["commonAttributes"] = fullCommonAttributesDict
                fullDict["textFields"] = fullTextFieldAttributesDict
                fullDict["saveCardOption"] = saveCardOptionAttributesDict
                themeDict["fullCard"] = fullDict
                
                TapThemeManager.setDefaultTapTheme(lightModeDictTheme: themeDict, darkModeDictTheme: themeDict)
                
                if let example:ExampleCardInputViewController = storyboard?.instantiateViewController(withIdentifier: "ExampleCardInputViewController") as? ExampleCardInputViewController {
                    example.isInline = isInline
                    self.navigationController?.pushViewController(example, animated: true)
                }
                
            } catch {
                // handle error
            }
        }
        
        
    }
    
    
}

extension UIColor {
    func toHexString() -> String {
        let components = self.cgColor.components
        let alpha = self.cgColor.alpha
        let r:CGFloat = components?[0] ?? 0
        let g:CGFloat = components?[1] ?? 0
        let b:CGFloat = components?[2] ?? 0
        let a:CGFloat = alpha
        
        
        let rgba:Int =  (Int)(r*255)<<24 | (Int)(g*255)<<18 | (Int)(b*255)<<8 | (Int)(a*255)<<0
        
        return String(format:"#%08x", rgba)
    }
}
