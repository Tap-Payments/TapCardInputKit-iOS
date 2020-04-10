//
//  ThemeStateSelector.swift
//  TapThemeManager2020
//
//  Created by Osama Rabie on 08/03/2020.
//  Copyright © 2020 Osama Rabie. All rights reserved.
//


import class UIKit.UIControl

/// This is a class to define/fetch a theme details for a component in a certain state
final class ThemeStateSelector: ThemeSelector {
    
    typealias ValuesType = [UInt: ThemeSelector]
    
    var values = ValuesType()
    
    /// Define a theme selector with a certain UIControl state
    convenience init?(selector: ThemeSelector?, withState state: UIControl.State) {
        guard let selector = selector else { return nil }
        
        self.init(value: { 0 })
        values[state.rawValue] = selector
    }
    
    func setSelector(_ selector: ThemeSelector?, forState state: UIControl.State) -> Self {
        values[state.rawValue] = selector
        return self
    }
    
}

