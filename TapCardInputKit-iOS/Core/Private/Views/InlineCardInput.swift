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

extension TapCardInput {
   
    
    internal func setupInlineConstraints() {
        scrollView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        
        stackView.snp.remakeConstraints { (make) in
            //make.edges.equalToSuperview()
            make.height.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalTo(spacing)
            make.right.equalTo(-spacing)
        }
        
        icon.snp.remakeConstraints { (make) in
            make.width.equalTo(32)
            make.height.equalTo(icon.snp.width)
        }
        
        cardNumber.snp.remakeConstraints { (make) in
            make.width.greaterThanOrEqualTo(cardNumber.calculatedWidth())
            make.height.equalTo(stackView)
        }
        
        cardName.snp.remakeConstraints { (make) in
            make.width.greaterThanOrEqualTo(cardName.calculatedWidth())
            make.height.equalTo(stackView)
        }
        
        cardExpiry.snp.remakeConstraints { (make) in
            make.width.greaterThanOrEqualTo(cardExpiry.calculatedWidth())
            make.height.equalTo(stackView)
        }
        
        cardCVV.snp.remakeConstraints { (make) in
            make.width.greaterThanOrEqualTo(cardCVV.calculatedWidth())
            make.height.equalTo(stackView)
        }
        
        
        layoutIfNeeded()
        
        calculateAutoMinWidths()
        
    }
    
    
    internal func addInlineViews() {
        
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.alwaysBounceVertical = false
        
        self.addSubview(scrollView)
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.backgroundColor = .clear
        stackView.spacing = spacing
        stackView.distribution = .fillProportionally
        
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(icon)
        stackView.addArrangedSubview(cardNumber)
        stackView.addArrangedSubview(cardName)
        stackView.addArrangedSubview(cardExpiry)
        stackView.addArrangedSubview(cardCVV)
    }
    
    
    internal func removeCardName() {
        cardName.isHidden = true
        cardName.snp.makeConstraints { (make) in
            make.width.greaterThanOrEqualTo(0)
        }
    }
    
    internal func calculateAutoMinWidths() {
        
        var lastFilledPoint:CGFloat = 0
        var fillingSpaceComponents:[TapCardTextField] = []
        
        stackView.arrangedSubviews.forEach { (subView) in
            
            lastFilledPoint = subView.frame.maxX
            
            if let cardField = subView as? TapCardTextField {
                
                if cardField.fillBiggestAvailableSpace {
                    fillingSpaceComponents.append(cardField)
                }
            }
        }
        if lastFilledPoint == 0 || self.scrollView.frame.width == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + (0.1)) { [weak self] in
                self?.calculateAutoMinWidths()
            }
            return
        }
        
        if fillingSpaceComponents.count == 0 {return}
        
        let totalWidth = frame.width - spacing
        let extraSpaceWidthValue = (totalWidth - lastFilledPoint) / CGFloat(fillingSpaceComponents.count)
        
        if extraSpaceWidthValue <= 0 {return}
        
        fillingSpaceComponents.forEach { (cardField) in
            
            let newWidth = cardField.frame.width + extraSpaceWidthValue
            cardField.autoMinCalculatedWidth = newWidth
            cardField.snp.makeConstraints { (make) in
                make.width.greaterThanOrEqualTo(newWidth)
            }
            
        }
        
        self.scrollView.layoutIfNeeded()
    }
    
    internal func updateWidths(for subView:UIView?) {
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        var point = nonNullView.frame.origin
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
