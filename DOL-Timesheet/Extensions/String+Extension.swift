//
//  String+Extension.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/23/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation

extension String {
    
    // formatting text for currency
    func currencyAmount() -> NSNumber {
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        return NSNumber(value: (double / 100))
        
    }
}


extension NSMutableAttributedString {
    convenience init?(withLocalizedHTMLString: String) {

        let htmlStr = withLocalizedHTMLString.replacingOccurrences(of: "\n", with: "<br/>")
        let htmlData = NSString(string: htmlStr).data(using: String.Encoding.unicode.rawValue)
        
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType:
            NSAttributedString.DocumentType.html]
        try? self.init(data: htmlData ?? Data(),
                       options: options,
                       documentAttributes: nil)
//        let attributedString = try? NSMutableAttributedString(data: htmlData ?? Data(),
//                                                              options: options,
//                                                              documentAttributes: nil)
//
    }
}
