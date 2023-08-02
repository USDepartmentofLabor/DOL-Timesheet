//
//  NSNumberFormatter+Extension.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/17/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation

extension NumberFormatter {
    class var currencyFormatter: NumberFormatter {
        get {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = NSLocale(localeIdentifier: "en_US") as Locale
            formatter.maximumFractionDigits = 2
            return formatter
        }
    }

    class func localisedCurrencyStr(from value: Double) -> String {
        return localisedCurrencyStr(from: NSNumber(value:value))
    }

    class func localisedCurrencyStr(from value: NSNumber) -> String {
        return currencyFormatter.string(from: value) ?? "$0"
    }
    
    class func localisedRateStr(from value: Double) -> String {
        return localisedRateStr(from: NSNumber(value: value))
    }
    
    class func localisedRateStr(from value: NSNumber) -> String {
        var rateStr: String
        
        let currencyStr: String = localisedCurrencyStr(from: value)
        rateStr = "\(currencyStr) /hr"
        
        return rateStr
    }
}
