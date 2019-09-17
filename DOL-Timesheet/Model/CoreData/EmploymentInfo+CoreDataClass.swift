//
//  EmploymentInfo+CoreDataClass.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/12/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(EmploymentInfo)
public class EmploymentInfo: NSManagedObject {
    public override func awakeFromInsert() {
        createdAt = Date()
        covered = true
    }

    var paymentType: PaymentType {
        get {
            return PaymentType(rawValue: Int(typeValue)) ?? .hourly
        }
        set {
            typeValue = Int16(newValue.rawValue)
        }
    }
    
    var payFrequency: PaymentFrequency {
        get {
            return PaymentFrequency(rawValue: Int(payFrequencyValue)) ?? .weekly
        }
        set {
            payFrequencyValue = Int16(newValue.rawValue)
        }
    }
    
    var workWeekStartDay: Weekday {
        get {
            return Weekday(rawValue: Int(workWeekStartDayValue)) ?? .sunday
        }
        set {
            workWeekStartDayValue = Int16(newValue.rawValue)
        }
    }
    
    // Get DateLog for date
    func log(forDate date: Date) ->  DateLog? {
        let dateLogSet = dateLogs as? Set<DateLog>
        return (dateLogSet?.filter{$0.date?.removeTimeStamp() == date.removeTimeStamp()}.first)
    }
    
    func createLog(forDate date: Date) -> DateLog {
        let dateLog =  DateLog(context: managedObjectContext!)
        dateLog.date = date.removeTimeStamp()
        addToDateLogs(dateLog)
        
        return dateLog
    }
    
    public func sortedRates() -> [HourlyRate]? {
        let rates = hourlyRate as? Set<HourlyRate>
        return rates?.sorted(by:
            { let firstDate = $0.createdAt ?? Date()
                let secondDate = $1.createdAt ?? Date()
                return firstDate < secondDate } )
    }
}

extension EmploymentInfo {
    func startWork(hourlyRate: HourlyRate?, at date: Date? = nil) {
        clock = PunchClock(context: managedObjectContext!)
        clock?.startTime = date?.removeSeconds() ?? Date().removeSeconds()
        clock?.hourlyRate = hourlyRate
    }
    
    func startBreak(comments: String?, at date: Date? = nil) {
        let breakClock = PunchBreakTime(context: managedObjectContext!)
        breakClock.startTime = date?.removeSeconds() ?? Date().removeSeconds()
        clock?.addToBreakTimes(breakClock)
        clock?.comments = comments
    }
    func endBreak(comments: String?, at date: Date? = nil) {
        if let currentBreak = clock?.currentBreak {
            currentBreak.endTime = date?.removeSeconds() ?? Date().removeSeconds()
        }
        clock?.comments = comments
    }

    func endWork(comments: String?) {
        clock?.comments = comments
    }
    
    func discardClock() {
        if let clock = clock {
            managedObjectContext?.delete(clock)
        }
        
        clock = nil
    }    
}
