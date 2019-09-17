//
//  UIBarButtonItem+extension.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/8/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation
import UIKit


extension UIBarButtonItem {
    convenience init(button: UIButton, target: Any?, action: Selector) {
        button.addTarget(target, action: action, for: .touchUpInside)
        self.init(customView: button)
    }
    
    class func infoButton(target: Any?, action: Selector) -> UIBarButtonItem {
        let infoButton = UIButton(type: .infoLight)
        return UIBarButtonItem(button: infoButton, target: target,
                               action: action)        
    }
    
    var isHidden: Bool {
        get {
            return tintColor == .clear
        }
        set {
            tintColor = newValue ? .clear : UIColor(named: "appPrimaryColor")
            isEnabled = !newValue
            isAccessibilityElement = !newValue
        }
    }
}
