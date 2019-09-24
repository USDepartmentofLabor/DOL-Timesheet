//
//  UISegmentControl+Extension.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 9/23/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

extension UISegmentedControl {
    func setios12Style() {
        if #available(iOS 13.0, *) {
            selectedSegmentTintColor = UIColor(named: "appSecondaryColor")
            setTitleTextAttributes([.foregroundColor : tintColor as Any], for: .normal)
            setTitleTextAttributes([.foregroundColor : UIColor.white], for: .selected)
            layer.borderWidth = 1
            layer.borderColor = tintColor.cgColor
        }
    }
}
