//
//  UIView+Extension.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/15/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

extension UIView {
    func addBorder(borderColor: UIColor? = UIColor(named: "borderColor"),
                   borderWidth: CGFloat = 1.0,
                   cornerRadius: CGFloat = 3.0) {
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor?.cgColor
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }
}
