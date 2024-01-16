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
    
    class var appTextColor: UIColor? {
        get {
            return UIColor(named: "appTextColor")
        }
    }
    
    class var appSecondaryColor: UIColor? {
        get {
            return UIColor(named: "appSecondaryColor")
        }
    }
    
    class var appNavBarColor: UIColor? {
        get {
            return UIColor(named: "appNavBarColor")
        }
    }
    
    class var linkColor: UIColor? {
        get {
            return UIColor(named: "linkColor")
        }
    }
    
    class var borderColor: UIColor {
        get {
            return UIColor(named: "borderColor") ?? UIColor.gray
        }
    }
}

extension UIColor {
    func toHex() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let redInt = Int(red * 255.0)
        let greenInt = Int(green * 255.0)
        let blueInt = Int(blue * 255.0)

        return String(format: "#%02X%02X%02X", redInt, greenInt, blueInt)
    }
}
