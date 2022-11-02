//
//  HourlyTimeModel.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/8/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation
import CoreData

enum OrderingCheck {
    case ok
    case tooEarly
    case tooLate
}

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
            return "err_more_than_24_hours".localized
        }
        
        return nil
    }

    func isValid(breakTime: Double, for currentTimeLog: TimeLog?) -> String {
        var errStr: String = ""
        
        if currentTimeLog?.startTime != nil, currentTimeLog?.endTime != nil,
            breakTime > Double(currentTimeLog?.hoursLogged ?? 0) {
                errStr = "err_break_more_than_hours_worked".localized
        }
        
        return errStr
    }

    func isValid(time: Date, for currentTimeLog: TimeLog?, isStartTime: Bool = false) -> String {
        var errStr: String = ""
        
        // If this is end Time, make sure it is less that StartTime
        if !isStartTime, currentTimeLog?.startTime?.compare(time) != .orderedAscending {
            errStr = "err_startTime_before_endtime".localized
            return errStr
        }
        
        switch timeIsInOrder(time: time, for: currentTimeLog) {
        case .ok:
            errStr = ""
        case .tooEarly:
            errStr = "err_time_too_early".localized
            return errStr
        case .tooLate:
            errStr = "err_time_too_late".localized
        }
    
        return errStr
    }
    
    func timeIsInOrder(time: Date, for currentTimeLog: TimeLog?) -> OrderingCheck {
        var ordering: OrderingCheck = .ok
        var foundCurrent = false
        timeLogs?.forEach {
            if currentTimeLog == $0 {
                foundCurrent = true
                return
            }
            if !foundCurrent  {
                if let startTime = $0.startTime, time < startTime {
                    ordering = .tooEarly
                }
                if let endTime = $0.endTime,time < endTime  {
                    ordering = .tooEarly
                }
            } else {
                if let startTime = $0.startTime, time > startTime {
                    ordering = .tooLate
                }
                if let endTime = $0.endTime,time > endTime  {
                    ordering = .tooLate
                }
            }
        }
        return ordering
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
    // If the time spans over midnight then split the time
    // to startTime - 11.59 and next Day - 12:00 - endTime
    func splitTime(endTime: Date, for timeLog: TimeLog) {
        if let startTime = timeLog.startTime {
            timeLog.endTime = startTime.endOfDay()
            
            let nextDateEndTime =  endTime.addDays(days: 1)
            let nextDateStartTime = nextDateEndTime.startOfDay()
            
            let nextDayLog = dateLog.employmentInfo?.log(forDate: nextDateStartTime) ?? dateLog.employmentInfo?.createLog(forDate: nextDateStartTime)
            let nextTimeLog = nextDayLog?.createTimeLog()
            nextTimeLog?.startTime = nextDateStartTime
            nextTimeLog?.endTime = nextDateEndTime
            if let hourlyTimeLog = timeLog as? HourlyPaymentTimeLog,
                let nextHourlyTimeLog = nextTimeLog as? HourlyPaymentTimeLog {
                nextHourlyTimeLog.hourlyRate = hourlyTimeLog.hourlyRate
                nextHourlyTimeLog.value = hourlyTimeLog.value
            }
        }
    }
}

extension EnterTimeViewModel {
    func csv() -> String {
        var csvStr: String = ""
        dateLog.sortedTimeLogs?.forEach {
            csvStr.append(",\(dateLog.date?.formattedDate ?? ""),\($0.startTime?.formattedTime ?? ""),\($0.endTime?.formattedTime ?? ""),\(Date.secondsToHoursMinutes(seconds: $0.totalBreakTime)),\($0.comment ?? "")")
            
            if let hourlyTimeLog = $0 as? HourlyPaymentTimeLog {
                let rate = hourlyTimeLog.value //hourlyTimeLog.hourlyRate?.value
                csvStr.append(",\(NumberFormatter.localisedCurrencyStr(from: rate))")
            }
            
            csvStr.append(",\(comment ?? "")\n")
        }
        
        return csvStr
    }
}
