//
//  HourlyRate+CoreDataClass.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/10/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(HourlyRate)
public class HourlyRate: NSManagedObject {
    public override func awakeFromInsert() {
        createdAt = Date()
    }
}

extension HourlyRate: OptionsProtocol {
    var title: String {
        let rateStr = NumberFormatter.localisedCurrencyStr(from: value)
        return "\(name ?? "") (\(rateStr))"
    }
}
