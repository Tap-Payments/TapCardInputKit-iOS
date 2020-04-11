//
//  FullCardInput.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 10/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

extension TapCardInput {
   
    
    internal func setupFullConstraints() {
        scrollView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        stackView.snp.remakeConstraints { (make) in
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        addFullCardViewStacks()
        
        icon.snp.remakeConstraints { (make) in
            make.width.equalTo(32)
        }
        scanButton.snp.remakeConstraints { (make) in
            make.width.equalTo(32)
            //make.height.equalTo(32)
        }
        cardNumber.setContentCompressionResistancePriority(.required, for: .horizontal)
        cardNumber.snp.remakeConstraints { (make) in
            //make.height.equalToSuperview()
        }
        
        cardName.snp.remakeConstraints { (make) in
            //make.width.equalToSuperview()
           // make.height.equalToSuperview()
        }
      
        
        cardExpiry.snp.remakeConstraints { (make) in
            //make.height.equalToSuperview()
        }
        
        cardCVV.snp.remakeConstraints { (make) in
            //make.height.equalToSuperview()
        }
        
        
        layoutIfNeeded()
    }
    
    
    internal func addFullViews() {
        
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        
        self.addSubview(scrollView)
        
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        stackView.spacing = spacing
        stackView.distribution = .fill
        stackView.alignment = .fill
        
        scrollView.addSubview(stackView)
        
        
    }
    
    
    internal func addFullCardViewStacks() {
        
        for i in 0...2 {
            
            let fieldsStackView:UIStackView = UIStackView()
            fieldsStackView.axis = .horizontal
            fieldsStackView.backgroundColor = .yellow
            fieldsStackView.spacing = max(spacing,7)
            
            stackView.addArrangedSubview(fieldsStackView)
            fieldsStackView.snp.remakeConstraints { (make) in
                //make.width.equalToSuperview()
                make.height.equalTo(40)
            }
            
            fieldsStackView.layoutMargins = UIEdgeInsets(top: 0, left: max(spacing, 7), bottom: 0, right: max(spacing, 7))
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
    }
    
    internal func add() {
        
    }
}
