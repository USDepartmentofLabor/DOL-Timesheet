//
//  HourlyPaymentTimeLog+CoreDataClass.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/13/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(HourlyPaymentTimeLog)
public class HourlyPaymentTimeLog: TimeLog {

    override var amountEarned: Double {
        if let hourlyRate = hourlyRate {
            return Double(hoursWorked) * hourlyRate.value
        }
        
        return 0
    }
    
    override public var description: String {
        var desc: String = ""
        
        if let hourlyRate = hourlyRate {
            let hoursWorkedStr: String = Date.secondsToHoursMinutes(seconds: Double(hoursWorked))
            let rateStr = NumberFormatter.localisedRateStr(from: hourlyRate.value) 
            desc = "\(hoursWorkedStr) x \(rateStr)"
       }
        
        return desc
    }
    
    override func validate() -> String? {
        if let errorStr = super.validate() {
            return errorStr
        }
        
        if hourlyRate == nil {
            return "err_select_hourly_rate".localized
        }
        
        return nil
    }
}

