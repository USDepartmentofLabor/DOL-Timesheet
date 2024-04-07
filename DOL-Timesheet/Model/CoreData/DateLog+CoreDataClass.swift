//
//  DateLog+CoreDataClass.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/9/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(DateLog)
public class DateLog: NSManagedObject {

    public override func awakeFromInsert() {
        createdAt = Date()
    }
    
    var sortedTimeLogs: [TimeLog]? {
        let timeLogSet = timeLogs as? Set<TimeLog>
        return timeLogSet?.sorted  { (log1, log2) in
            if let startTime1 = log1.startTime, let startTime2 = log2.startTime {
                return startTime1 < startTime2
            } else if log1.startTime != nil {
                // log2.startTime is nil, so log1 should come after log2
                return true
            } else {
                // log1.startTime is nil or both are nil, so log1 should come before log2
                return false
            }
        }
    }
    
    func createTimeLog() -> TimeLog? {
        if employmentInfo?.paymentType == .hourly {
            let newTimeLog = HourlyPaymentTimeLog(context: managedObjectContext!)

//            if let date = date {
//                newTimeLog.startTime = Calendar.current.date(byAdding: .hour, value: 9, to: date)
//                newTimeLog.endTime = Calendar.current.date(byAdding: .hour, value: 8, to: newTimeLog.startTime!)
//            }
            
            if let rateOptions = employmentInfo?.sortedRates(), rateOptions.count == 1 {
                newTimeLog.hourlyRate = rateOptions[0]
                newTimeLog.value = rateOptions[0].value
            }
            
            addToTimeLogs(newTimeLog)
            return newTimeLog
        }
        else if employmentInfo?.paymentType == .salary {
            let newTimeLog = TimeLog(context: managedObjectContext!)
            
//            if let date = date {
//                newTimeLog.startTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: date)
//                newTimeLog.endTime = Calendar.current.date(byAdding: .hour, value: 8, to: newTimeLog.startTime!)
//            }            
            
            addToTimeLogs(newTimeLog)
            return newTimeLog
        }

        return nil
    }
    
    var totalHoursWorked: Double {
        let timeLogSet = timeLogs as? Set<TimeLog>
        let hoursLogged = timeLogSet?.reduce(0.0)
            { $0 + Double($1.hoursWorked) } ?? 0.0
        
        return hoursLogged
    }
    
    var totalBreak: Double {
        let timeLogSet = timeLogs as? Set<TimeLog>
        return timeLogSet?.reduce(0) {
            var breakTime = 0.0
            if $1.totalBreakTime > EmploymentModel.ALLOWED_BREAK_SECONDS {
                breakTime = $1.totalBreakTime
            }
            return ($0 ?? 0) + breakTime
        } ?? 0
    }
    
    var amountEarned: Double {
        let timeLogSet = timeLogs as? Set<TimeLog>
        return timeLogSet?.reduce(0) {$0 + $1.amountEarned } ?? 0
    }    
}

