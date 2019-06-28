//
//  HourlyTimeModel.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/8/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation
import CoreData

struct EnterTimeViewModel {
    var dateLog: DateLog
    var managedObjectContext: NSManagedObjectContext?
    
    init(dateLog: DateLog) {
        self.dateLog = dateLog
        managedObjectContext = dateLog.managedObjectContext
    }
    
    var title: String {
        get { let currentDate = dateLog.date ?? Date()
        return "\(currentDate.formattedWeekday) \(currentDate.formattedDate)"
        }
    }
    
    var paymentType: PaymentType? {
        get {return dateLog.employmentInfo?.paymentType}
    }
    
    func save() {
        guard let context = dateLog.managedObjectContext else { return }
        
        CoreDataManager.shared().saveContext(context: context)
    }
    
    // Validate TimeLogs and return Error String
    func validate() -> String? {
        guard let timeLogs = dateLog.timeLogs as? Set<TimeLog>  else {
            return nil
        }
        
        for timeLog in timeLogs {
            if let errorStr = timeLog.validate() {
                return errorStr
            }
        }

        // If Total Hours Worked + breaktime should be less that 24 hours
        if dateLog.totalHoursWorked + dateLog.totalBreak > (24 * 60 * 60) {
            return NSLocalizedString("err_more_than_24_hours", comment: "")
        }
        
        return nil
    }

    func isValid(breakTime: Double, for currentTimeLog: TimeLog?) -> String {
        var errStr: String = ""
        
        if currentTimeLog?.startTime != nil, currentTimeLog?.endTime != nil,
            breakTime > Double(currentTimeLog?.hoursLogged ?? 0) {
                errStr = NSLocalizedString("err_break_more_than_hours_worked", comment: "Break time can not be more that Hours worked")
        }
        
        return errStr
    }

    func isValid(time: Date, for currentTimeLog: TimeLog?, isStartTime: Bool = false) -> String {
        var errStr: String = ""
        
        // If this is end Time, make sure it is less that StartTime
        if !isStartTime, currentTimeLog?.startTime?.compare(time) != .orderedAscending {
            errStr = NSLocalizedString("err_startTime_before_endtime", comment: "EndTime Should be more than startTime")
            return errStr
        }
        
        timeLogs?.forEach {
            if currentTimeLog != $0, let startTime = $0.startTime,
                let endTime = $0.endTime, time.isBetween(startDate: startTime, endDate: endTime) {
                
                // If this is startTime, it can be equal to endTime
                if isStartTime, time.compare(endTime) == .orderedSame {
                    return
                }
                
                if !isStartTime, time.compare(startTime) == .orderedSame {
                    return
                }
 
                let errorMsg = NSLocalizedString("err_time_between_start_endtime", comment: "Time between range")
                if !errStr.isEmpty {
                    errStr.append("\n")
                }
                errStr.append(String(format: errorMsg, time.formattedTime, startTime.formattedTime, endTime.formattedTime))
            }
        }
        
        return errStr
    }
    
    var comment: String? {
        get {return dateLog.comment}
        set {dateLog.comment = newValue}
    }
    
    var numberOfTimeLogs: Int? {
        return dateLog.timeLogs?.count
    }
    
    var timeLogs: [TimeLog]? {
        get {
            return dateLog.sortedTimeLogs
        }
    }
    
    func addTimeLog() -> TimeLog? {
        return dateLog.createTimeLog()
    }
    
    func removeTimeLog(timeLog: TimeLog) {
        dateLog.removeFromTimeLogs(timeLog)
        timeLog.managedObjectContext?.delete(timeLog)
    }
}

extension EnterTimeViewModel {
    func csv() -> String {
        var csvStr: String = ""
        dateLog.sortedTimeLogs?.forEach {
            csvStr.append(",\(dateLog.date?.formattedDate ?? ""),\($0.startTime?.formattedTime ?? ""),\($0.endTime?.formattedTime ?? ""),\(Date.secondsToHoursMinutes(seconds: $0.breakTime)),\($0.comment ?? "")")
            
            if let hourlyTimeLog = $0 as? HourlyPaymentTimeLog {
                let rate = hourlyTimeLog.value //hourlyTimeLog.hourlyRate?.value
                csvStr.append(",\(NumberFormatter.localisedCurrencyStr(from: rate))")
            }
            
            csvStr.append(",\(comment ?? "")\n")
        }
        
        return csvStr
    }
}
