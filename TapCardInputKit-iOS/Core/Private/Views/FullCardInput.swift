//
//  FullCardInput.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 10/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import class UIKit.UIStackView
import class UIKit.UIView
import class UIKit.UISwitch
import class UIKit.UILabel
import struct UIKit.UIEdgeInsets
import struct UIKit.CGSize
import struct UIKit.CGFloat

/// This extension provides the methods needed to setupu the views in the case of full card input mode
extension TapCardInput {
   
    /**
    This method does the logic of developing the correct layout constraint for all the sub views to make suer it looks as the provided UI
    */
    internal func setupFullConstraints() {
        // The holder scroll view should full the super view. this will ve used to scroll vertically to show all the fields
        scrollView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        // The vertical stack view will be used to layout the card fields vertical. It will be filling the scroll view with a padding on both sides
        stackView.snp.remakeConstraints { (make) in
            make.width.equalToSuperview().offset(-inputLeftRightMargin*2)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        // Now we need to add the card fields inside the stackview in order
        addFullCardViewStacks()
        // Defines the constrints for the card icon image vie
        icon.snp.remakeConstraints { (make) in
            make.width.equalTo(32)
        }
        // Defines the constrints for the scan button icon image vie
        scanButton.snp.remakeConstraints { (make) in
            make.width.equalTo(32)
            //make.height.equalTo(32)
        }
        
        if showSaveCardOption {
            // Adjust the save card views
            
            // Make the save label full height
            saveLabel.snp.remakeConstraints { (make) in
                make.height.equalToSuperview()
                make.trailing.equalTo(saveSwitch.snp.leading).offset(-computedSpace)
                make.leading.equalToSuperview().offset(computedSpace)
                make.centerY.equalToSuperview()
            }
            saveSwitch.snp.remakeConstraints { (make) in
                make.trailing.equalToSuperview().offset(-computedSpace)
                make.centerY.equalToSuperview()
            }
        }
        
        
        // Define that we want the card nummber to fill as much width as possible
        cardNumber.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        layoutIfNeeded()
    }
    
    /// This method will add the subviews needed in the full mode for the super view
    internal func addFullViews() {
        
        // Set the scroll view attribtes
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        self.addSubview(scrollView)
        
        // Set the stack view attribtes
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        stackView.spacing = spacing
        stackView.distribution = .fill
        stackView.alignment = .fill
        scrollView.addSubview(stackView)
        
        
    }
    
    /**
     Method that adds in order the card fields in the full mode, each subview is considered as a row in the vertical stackview
     */
    internal func addFullCardViewStacks() {
        
        // We have three rows, card number + icon, card exxpiry + cvv and card name
        for i in 0...2 {
           
            let fieldsStackView:UIStackView = UIStackView()
            fieldsStackView.axis = .horizontal
            fieldsStackView.backgroundColor = .yellow
            fieldsStackView.spacing = computedSpace
            
            stackView.addArrangedSubview(fieldsStackView)
            fieldsStackView.snp.remakeConstraints { (make) in
                make.width.equalToSuperview()
                make.height.equalTo(40)
            }
            
            fieldsStackView.layoutMargins = UIEdgeInsets(top: 0, left: computedSpace, bottom: 0, right: computedSpace)
            fieldsStackView.isLayoutMarginsRelativeArrangement = true
            
            
            
            if i == 0 {
                // Card and icon row
                fieldsStackView.addArrangedSubview(cardNumber)
                fieldsStackView.addArrangedSubview(icon)
                fieldsStackView.addArrangedSubview(scanButton)
            }else if i == 1 {
                // expiry and cvv
                fieldsStackView.distribution = .fillProportionally
                fieldsStackView.addArrangedSubview(cardExpiry)
                
                let horizontalSeparatorView:UIView = UIView()
                horizontalSeparatorView.tap_theme_backgroundColor = "fullCard.commonAttributes.separatorColor"
                fieldsStackView.addArrangedSubview(horizontalSeparatorView)
                fieldsStackView.addArrangedSubview(cardCVV)
                horizontalSeparatorView.snp.remakeConstraints { (make) in
                    make.height.equalToSuperview()
                    make.width.equalTo(1)
                    //make.right.equalTo(cardCVV.snp.left).offset(-7)
                }
            }else if i == 2 {
                // name
                fieldsStackView.addArrangedSubview(cardName)
            }
            
            let verticalSeparatorView:UIView = UIView()
            verticalSeparatorView.tap_theme_backgroundColor = "fullCard.commonAttributes.separatorColor"
            stackView.addArrangedSubview(verticalSeparatorView)
            verticalSeparatorView.snp.remakeConstraints { (make) in
                make.height.equalTo(1)
                make.width.equalToSuperview()
            }
        }
        
        // Save card option
        // Check if the parent caller wants to show it
        if showSaveCardOption {
            addSaveOptionsView()
        }
    }
    
    
    internal func addSaveOptionsView() {
        let saveCardView:UIView = UIView()
        saveCardView.backgroundColor = .clear
        stackView.addArrangedSubview(saveCardView)
        
        saveLabel.numberOfLines = 2
        saveLabel.minimumScaleFactor = 0.5
        
        let maxLabelWidth: CGFloat = self.frame.width
        let neededSize = saveLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: CGFloat.greatestFiniteMagnitude))
        
        saveCardView.snp.remakeConstraints { (make) in
            make.height.equalTo(neededSize.height + 3*computedSpace)
            make.width.equalToSuperview()
        }
        
        
        
        saveCardView.addSubview(saveLabel)
        saveCardView.addSubview(saveSwitch)
        
    }
}
