//
//  NSAttributedString+Extension.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 12/6/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {

    public func setAsLink(textToFind:String, linkURL:String) -> Bool {

        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
}
