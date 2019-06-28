//
//  Util.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/20/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation
import UIKit

class Util {
    
    static func isValidPostalCode(postalCode: String) -> Bool {
        let postalcodeRegex = "^[0-9]{5}(?:-[0-9]{4})?$"
        let pinPredicate = NSPredicate(format: "SELF MATCHES %@", postalcodeRegex)
        return pinPredicate.evaluate(with: postalCode)
    }

    static func isValidEmailAddress(emailAddress: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: emailAddress)
    }
    
    static var isVoiceOverRunning: Bool {
        get {
            return UIAccessibility.isVoiceOverRunning
        }
    }
}
