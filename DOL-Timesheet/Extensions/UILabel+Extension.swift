//
//  UILabel+Extension.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/31/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    func scaleFont(forDataType type: Style.DataType) {
        font = Style.scaledFont(forDataType: type)
        adjustsFontForContentSizeCategory = true
    }
}

extension UITextView {
    func scaleFont(forDataType type: Style.DataType) {
        font = Style.scaledFont(forDataType: type)
        adjustsFontForContentSizeCategory = true
    }
}

extension UITextField {
    func scaleFont(forDataType type: Style.DataType) {
        font = Style.scaledFont(forDataType: type)
        adjustsFontForContentSizeCategory = true
    }
}
