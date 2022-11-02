//
//  Util.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/20/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation
import UIKit


class Localizer {
    static let ENGLISH = "en"
    static let SPANISH = "es"
    static var currentLanguage = ENGLISH
    
    static func initialize() {
        if let lang = UserDefaults.standard.string(forKey: "selected_language") {
            currentLanguage = lang
        } else {
            if let langStr = Locale.current.languageCode {
                currentLanguage = langStr
            } else {
                currentLanguage = ENGLISH
            }
        }
    }
    
    static func updateCurrentLanguage(lang: String) {
        UserDefaults.standard.set(lang, forKey: "selected_language")
        UserDefaults.standard.synchronize()
        currentLanguage = lang
    }
}

extension String {
    var localized: String {
        
//        if let _ = UserDefaults.standard.string(forKey: "selected_language") {} else {
//            // we set a default, just in case
//            UserDefaults.standard.set("es", forKey: "selected_language")
//            UserDefaults.standard.synchronize()
//        }
//
//        let lang = UserDefaults.standard.string(forKey: "selected_language")
//        let path = Bundle.main.path(forResource: lang, ofType: "lproj")

        let path = Bundle.main.path(forResource: Localizer.currentLanguage, ofType: "lproj")
        let bundle = Bundle(path: path!)

        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}
