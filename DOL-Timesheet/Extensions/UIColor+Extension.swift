//
//  UIColor+Extension.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/22/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

extension UIColor {
    class var appPrimaryColor: UIColor? {
        get {
            return UIColor(named: "appPrimaryColor")
        }
    }
    
    var appSecondaryColor: UIColor? {
        get {
            return UIColor(named: "appSecondaryColor")
        }
    }
}
