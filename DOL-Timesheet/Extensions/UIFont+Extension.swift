//
//  UIFont+Extension.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/31/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }
}

