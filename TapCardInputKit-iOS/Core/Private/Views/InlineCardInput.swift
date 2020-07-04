//
//  InlineCardInput.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 08/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import class UIKit.UIStackView
import class UIKit.UIView
import struct UIKit.UIEdgeInsets
import struct UIKit.CGFloat
import struct UIKit.CGPoint
import struct UIKit.CGRect

/// This extension provides the methods needed to setupu the views in the case of inline card input mode
extension TapCardInput {
    
    
    /**
     This method does the logic of developing the correct layout constraint for all the sub views to make suer it looks as the provided UI
     */
    internal func setupInlineConstraints() {
        // The holder scroll view should full the super view. this will ve used to scroll horizontally to show all the fields
        scrollView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // The horizontal stack view will be used to layout the card fields horizontaly. It will be filling the scroll view with a padding on both sides
        stackView.snp.remakeConstraints { (make) in
            make.height.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalTo(inputLeftRightMargin)
            make.trailing.equalTo(inputLeftRightMargin)
        }
        
        // Defines the constrints for the scan card button
        scanButton.snp.remakeConstraints { (make) in
            make.width.equalTo(32)
            //make.height.equalTo(32)
        }

        
        // Defines the constrints for the card icon image vie
        icon.snp.remakeConstraints { (make) in
            make.width.equalTo(32)
            //make.height.equalTo(32)
        }
        
        
        // Defines the constrints for the card number field
        cardNumber.snp.remakeConstraints { (make) in
            // We set the card number width to the mimimum width based on its min visible characters attribute
            make.width.greaterThanOrEqualTo(cardNumber.calculatedWidth())
            make.height.equalTo(stackView)
        }
        
        // Defines the constrints for the card name field
        cardName.snp.remakeConstraints { (make) in
           // We set the card name width to the mimimum width based on its min visible characters attribute
            make.width.greaterThanOrEqualTo(cardName.calculatedWidth())
            make.height.equalTo(stackView)
        }
        
        // Defines the constrints for the card expiry field
        cardExpiry.snp.remakeConstraints { (make) in
            // We set the card expiry width to the mimimum width based on its min visible characters attribute
            make.width.greaterThanOrEqualTo(cardExpiry.calculatedWidth())
            make.height.equalTo(stackView)
        }
        
        // Defines the constrints for the card cvv field
        cardCVV.snp.remakeConstraints { (make) in
            // We set the card cvv width to the mimimum width based on its min visible characters attribute
            make.width.greaterThanOrEqualTo(cardCVV.calculatedWidth())
            make.height.equalTo(stackView)
        }
        
        
        layoutIfNeeded()
        
        calculateAutoMinWidths()
        
    }
    
    /// This method will add the subviews needed in the inline mode for the super view
    internal func addInlineViews() {
        
        // Set the scroll view attribtes
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.alwaysBounceVertical = false
        self.addSubview(scrollView)
        
        // Set the stack view attribtes
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.backgroundColor = .clear
        stackView.spacing = computedSpace
        stackView.distribution = .fillProportionally
        scrollView.addSubview(stackView)
        
        // Add the card fields to the stack view in order
        stackView.addArrangedSubview(icon)
        
        fields.forEach { (field) in
            stackView.addArrangedSubview(field)
        }
        stackView.addArrangedSubview(scanButton)
    }
    
    
    /// Call this method if you want to hide the card name field
    internal func removeCardName() {
        cardName.isHidden = true
        cardName.snp.makeConstraints { (make) in
            make.width.greaterThanOrEqualTo(0)
        }
    }
    
    /// This method will expand the fields that are declared to fill in the remainig empty space width wise. So if the parent view has empty space after adding all the views, then some fields will expand to fill in this space and gives better experience like card number or card name
    internal func calculateAutoMinWidths() {
        
        // Holds the last X point filled by a view
        var lastFilledPoint:CGFloat = 0
        // Holds all the fields that are declared to fill in the empty width, so we distribute the remaining space equally across them
        var fillingSpaceComponents:[TapCardTextField] = []
        
        // Loop through the stack view subviews INORDER to get the needed data in
        stackView.arrangedSubviews.forEach { (subView) in
            // Save the last filled X point while going in the loop
            lastFilledPoint = subView.frame.maxX
            
            // Check if the current field is of TapCardTextField
            if let cardField = subView as? TapCardTextField {
                // Check if it is delcared to fill in the empty space, if yes then marke it and save it
                if cardField.fillBiggestAvailableSpace {
                    fillingSpaceComponents.append(cardField)
                }
            }
        }
        
        // we need to make sure that the data we collected is correct. At some points, tghe method may be called before axctually laying out the views so we need to try again in a very short time
        if lastFilledPoint == 0 || self.scrollView.frame.width == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + (0.1)) { [weak self] in
                self?.calculateAutoMinWidths()
            }
            return
        }
        
        // If no field was delcared to fill in empty space, then we have nothing to do
        if fillingSpaceComponents.count == 0 {return}
        
        // Now it is the time to calculate the actual empty space we have beyond the last subview and distribute them across the marked fields
        
        // Get the total width
        let totalWidth = frame.width - computedSpace
        // Calculate the extra space that will add to the marked fields equally
        let extraSpaceWidthValue = (totalWidth - lastFilledPoint) / CGFloat(fillingSpaceComponents.count)
        
        // If there is no extra space to add then we can do nothing
        if extraSpaceWidthValue <= 0 {return}
        
        fillingSpaceComponents.forEach { (cardField) in
            // For each field add its share of the etxra space
            let newWidth = cardField.frame.width + extraSpaceWidthValue
            cardField.autoMinCalculatedWidth = newWidth
            cardField.snp.makeConstraints { (make) in
                make.width.greaterThanOrEqualTo(newWidth)
            }
            
        }
        
        self.scrollView.layoutIfNeeded()
    }
    
    
    
    internal func updateWidths(for subView:UIView?) {
        guard cardInputMode == .InlineCardInput else {return}
        if let nonNullView:TapCardTextField = subView as? TapCardTextField {
            //scrollView.layoutIfNeeded()
            layoutIfNeeded()
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                nonNullView.snp.updateConstraints( { make in
                    if let nonNullProtocolImplemented:CardInputTextFieldProtocol = nonNullView as? CardInputTextFieldProtocol {
                        make.width.greaterThanOrEqualTo(nonNullProtocolImplemented.calculatedWidth())
                    }
                })
                
                self?.layoutIfNeeded()
                
            }) { (done) in
                if nonNullView.isEditing {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                        var point = nonNullView.frame.origin
                        if self?.sharedLocalisationManager.localisationLocale == "ar" && nonNullView == self?.cardNumber {
                            point.x = (self?.scrollView.contentOffset.x)!
                            point.x += (self?.icon.frame.width ?? 0)
                            point.x += (self?.computedSpace ?? 0)
                            point.x += (self?.inputLeftRightMargin ?? 0)
                            self?.scrollView.setContentOffset(point, animated: true)
                            self?.scrollView.layoutIfNeeded()
                        }else {
                            point.x = point.x - 5
                            if self?.scrollView.contentOffset.x ?? 0 > point.x {
                                self?.scrollView.setContentOffset(point, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
}
