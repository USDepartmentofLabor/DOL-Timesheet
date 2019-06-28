//
//  TimesheetViewModel.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/15/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation

class TimesheetViewModel {
    
    let managedObjectContext = CoreDataManager.shared().viewManagedContext

    var userProfileModel: ProfileViewModel
    
    var currentEmploymentModel: EmploymentModel? {
        get {
            if userProfileModel.currentEmploymentModel == nil || !userProfileModel.currentEmploymentModel!.isValid {
                userProfileModel.currentEmploymentModel = userProfileModel.employmentModels.first
            }
            
            return userProfileModel.currentEmploymentModel
        }
        set {
            userProfileModel.currentEmploymentModel = newValue
            updatePeriod()
        }
    }
    
    var currentPeriod: Period? {
        didSet {
            updateWorkWeeks()
        }
    }

    var workWeekViewModels: [WorkWeekViewModel]?
    
    init() {
        userProfileModel = ProfileViewModel(context: managedObjectContext)
        userProfileModel.currentEmploymentModel = userProfileModel.employmentModels.first
    }
    
    var userProfileExists: Bool {
        get {
            return userProfileModel.profileModel.profileExists
        }
    }
    
    func nextPeriod(direction: Calendar.SearchDirection = .forward) {
        guard let currentPeriod = currentPeriod else { return }
        
        let paymentFrequency: PaymentFrequency = currentEmploymentModel?.paymentFrequency ?? .weekly
        let calendar = Calendar(identifier: .gregorian)

        let multiplier = ((direction == .forward) ? 1 : -1)
        var components = DateComponents()
        switch paymentFrequency {
        case .daily:
            components.day = 1 * multiplier
        case .weekly:
            components.day = 7 * multiplier
        case .biWeekly:
            components.day = 14 * multiplier
        case .monthly:
            components.month = 1 * multiplier
        case .biMonthly:
            components.day = 16 * multiplier
        }

        let nextStartDate = calendar.date(byAdding: components, to: currentPeriod.startDate)!
        updatePeriod(currentDate: nextStartDate)
    }
    
    func updatePeriod(currentDate: Date = Date()) {
        let paymentFrequency: PaymentFrequency = currentEmploymentModel?.paymentFrequency ?? .weekly
        let workweekStartDay: Weekday = currentEmploymentModel?.workWeekStartDay ?? .sunday
        let startDate: Date
        let endDate: Date
        
        switch paymentFrequency {
        case .daily:
                startDate = currentDate // currentDate.next(workweekStartDay, direction: .backward)
                endDate = startDate
            case .weekly:
                startDate = currentDate.next(workweekStartDay, direction: .backward)
                endDate = Calendar.current.date(byAdding: .day, value: 6, to: startDate)!
            case .biWeekly:
                let employmentStartDate = currentEmploymentModel?.employmentInfo.startDate ?? Date()
                let employmentStartWeekDate = employmentStartDate.next(workweekStartDay, direction: .backward)
                
                let payPeriods = employmentStartWeekDate.diffInDays(toDate: currentDate) / 14
                startDate = Calendar.current.date(byAdding: .day, value: payPeriods * 14, to: employmentStartWeekDate)!
                endDate = Calendar.current.date(byAdding: .day, value: 13, to: startDate)!
            case .monthly:
                startDate = currentDate.startOfMonth()
                endDate = currentDate.endOfMonth()
            case .biMonthly:
                startDate = currentDate.startOfSemiMonth()
                endDate = currentDate.endOfSemiMonth()
            }
            
        currentPeriod = Period(startDate: startDate, endDate: endDate, workWeekStartDay: workweekStartDay, employmentInfo: currentEmploymentModel?.employmentInfo)
    }
    
    
    var selectedUserName: String {
        get {
            var selectUserName: String = ""
            
            if userProfileModel.isProfileEmployer {
                selectUserName = currentEmploymentModel?.employeeName ?? ""
            }
            else {
                selectUserName = currentEmploymentModel?.employerName ?? ""
            }
            return selectUserName
        }
    }
    
    func setCurrentEmploymentModel(for user: User) {
        currentEmploymentModel = userProfileModel.employmentModel(forUser:  user)
    }
}


// MARK: WorkWeek Model
extension TimesheetViewModel {
    func updateWorkWeeks() {
        workWeekViewModels = [WorkWeekViewModel]()
        
        guard let employmentInfo = currentEmploymentModel?.employmentInfo,
            let currentPeriod = currentPeriod else {return}
        
        currentPeriod.workWeeks.forEach {
            workWeekViewModels?.append(WorkWeekViewModel(employmentInfo: employmentInfo, period: currentPeriod, workWeek: $0))
        }
    }
    
    var numberOfWorkWeeks: Int {
        return workWeekViewModels?.count ?? 0
    }
    
    func workWeekViewModel(at index: Int) -> WorkWeekViewModel? {
        guard let workWeekViewModels = workWeekViewModels,
            index < workWeekViewModels.count else {
            return nil
        }
        
        return workWeekViewModels[index]
    }
    
    var totalEarnings: Double {
        get {
            return (currentPeriod?.straightTimeAmount ?? 0) + periodOvertimeAmount
        }
    }
    
    var periodOvertimeAmount: Double {
        get {
            let overtimeAmount = workWeekViewModels?.reduce(0.0) {
                var weekOvertimeAmount = 0.0
                if currentPeriod?.isDateInPeriod(date: $1.currentWorkWeek.endDate) ?? false {
                    weekOvertimeAmount = $1.overtimeAmount
                }
                return weekOvertimeAmount + ($0 ?? 0)
                } ?? 0.0
            
            return overtimeAmount
        }
    }
    
    var totalEarningsStr: String {
        return NumberFormatter.localisedCurrencyStr(from: totalEarnings)
    }

    var periodOvertimeAmountStr: String {
        return NumberFormatter.localisedCurrencyStr(from: periodOvertimeAmount)
    }
}

// MARK: Totals for Date
extension TimesheetViewModel {
    func totalBreakTime(forDate date: Date) -> Double {
        guard let employmentModel = currentEmploymentModel else {
            return 0.0
        }
        
        if let dateLog = employmentModel.employmentInfo.log(forDate: date) {
            return dateLog.totalBreak
        }
        return 0.0
    }
    
    func totalBreakTime(forDate date: Date) -> String {
        let breakTime: Double = totalBreakTime(forDate: date)
        return Date.secondsToHoursMinutes(seconds: breakTime)
    }
    
    func totalHoursTime(forDate date: Date) -> Double {
        guard let employmentModel = currentEmploymentModel else {
            return 0.0
        }
        
        if let dateLog = employmentModel.employmentInfo.log(forDate: date) {
            return dateLog.totalHoursWorked
        }
        
        return 0.0
    }
    
    func totalHoursTime(forDate date: Date) -> String {
        let hoursWorked: Double = totalHoursTime(forDate: date)
        return Date.secondsToHoursMinutes(seconds: hoursWorked)
    }
    
    func totalAmount(forDate date: Date) -> Double {
        guard let employmentModel = currentEmploymentModel else {
            return 0.0
        }
        
        if let dateLog = employmentModel.employmentInfo.log(forDate: date) {
            return dateLog.amountEarned
        }
        return 0
    }
}

// MARK: Totals for Period
extension TimesheetViewModel {
    
    // Total Break Time
    func totalBreakTime() -> Double {
        var totalBreak = 0.0
        
        guard let currentPeriod = currentPeriod else { return totalBreak }
        
        var index = 0
        while index < currentPeriod.numberOfDays() {
            totalBreak += totalBreakTime(forDate: currentPeriod.date(at: index))
            index += 1
        }
        return totalBreak
    }
    
    func totalBreakTime() -> String {
        let breakTime: Double = totalBreakTime()
        return Date.secondsToHoursMinutes(seconds: breakTime)
    }
    
    // Total Hours Worked
    func totalHoursTime() -> Double {
        guard let currentPeriod = currentPeriod else {return 0}
        
        var totalTime = 0.0
        var index = 0
        while index < currentPeriod.numberOfDays() {
            totalTime += totalHoursTime(forDate: currentPeriod.date(at: index))
            index += 1
        }
        return totalTime
    }
    
    func totalHoursTime() -> String {
        let totalTime: Double = totalHoursTime()
        return Date.secondsToHoursMinutes(seconds: totalTime)
    }
}

// MARK: WorkWeek
extension TimesheetViewModel {
    // Days in WorkWeek can be before or After Pay Period
    // Ex - PayPeriod 05/01/2019-05/31/2019 has following workweeks
    // WorkWeek1 - 04/28/2019 - 05/04/2019
    // WorkWeek2 - 05/05/2019 - -5/11/2019
    // WorkWeek3 - 05/12/2019 - -5/18/2019
    // WorkWeek4 - 05/19/2019 - -5/25/2019
    // WorkWeek5 - 05/26/2019 - -6/01/2019
    func hoursWorked(workWeek index: Int) -> Double {
        guard let currentPeriod = currentPeriod else { return 0 }
        
        let workWeek = currentPeriod.workWeeks[index]
        
        let workWeekDaysInPeriod = workWeek.days
        let hoursWorked = workWeekDaysInPeriod.reduce(0) {$0 + totalHoursTime(forDate: $1)}
        return hoursWorked
    }
    
    func hoursWorked(workWeek index: Int) -> String {
        return Date.secondsToHoursMinutes(seconds: hoursWorked(workWeek: index))
    }
    
    func overTimeHours(workWeek index: Int) -> Double {
        guard let currentPeriod = currentPeriod else { return 0 }
        
        let workWeek = currentPeriod.workWeeks[index]
        let totalHoursWorked = workWeek.days.reduce(0) {$0 + totalHoursTime(forDate: $1)}
        let expectedWorkTime: Double = WorkWeekViewModel.WORK_WEEK_SECONDS
        return totalHoursWorked > expectedWorkTime ? totalHoursWorked - expectedWorkTime : 0
    }
    
    func overTimeHours(workWeek index: Int) -> String {
        return Date.secondsToHoursMinutes(seconds: overTimeHours(workWeek: index))
    }
}

extension TimesheetViewModel {
    func createEnterTimeViewModel(forDate date: Date) -> EnterTimeViewModel? {
       let childContext = managedObjectContext.childManagedObjectContext()
        
        guard let currentEmploymentModel = currentEmploymentModel,
            let childEmploymentInfo = childContext.object(with: currentEmploymentModel.employmentInfo.objectID) as? EmploymentInfo
            else {return nil}
        
        let dateLog = childEmploymentInfo.log(forDate: date) ?? childEmploymentInfo.createLog(forDate: date)
        
        return EnterTimeViewModel(dateLog: dateLog)
    }
}

extension TimesheetViewModel {
    
    var minimumWageErrStr: String? {
        get {
            var minWageErr: String = ""
            workWeekViewModels?.forEach {
                if $0.isBelowMinimumWage {
                    minWageErr.append("\($0.title) Below minimum wage\n")
                }
            }
            return minWageErr.isEmpty ? nil : minWageErr
        }
    }
    
    func isBelowMinimumWage() -> Bool {
        var belowMinWage = false
        workWeekViewModels?.forEach {
            if $0.isBelowMinimumWage && $0.isWorkWeekClosed {
                belowMinWage = true
                return
            }
        }
        return belowMinWage
    }
}

extension TimesheetViewModel {
    func csv() -> URL? {
        guard let employmentModel = currentEmploymentModel,
            let period = currentPeriod else {
                return nil
        }
        
        var employeeName = employmentModel.employee?.name ?? ""
        employeeName = employeeName.replacingOccurrences(of: " ", with: "_")
        let fileName = "\(employeeName)_\(period.startDate.csvformattedDate)-\(period.endDate.csvformattedDate).csv"
        
        // Employee/Employer Information
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)!
        var csvStr = "\n,Start Date,End Date,Employer,Employer Address,Employee,Employee Number,Employee Address,Payment Type,Payment Frequency,Total Earnings,Straight Time Earnings,Overtime\n"
        csvStr.append(",\(period.startDate.formattedDate),\(period.endDate.formattedDate),")
        csvStr.append("\(employmentModel.employer?.name ?? ""),\(employmentModel.employer?.address?.csv ?? ""),")
        csvStr.append("\(employmentModel.employee?.name ?? ""),\(employmentModel.employmentNumber ?? ""),\(employmentModel.employee?.address?.csv ?? ""),")
        csvStr.append("\(employmentModel.paymentType.title),")
        csvStr.append("\(employmentModel.paymentFrequency.title),")
        csvStr.append("\(totalEarningsStr.replacingOccurrences(of: ",", with: "")),")
        let straightTimeEarningsCSV = (currentPeriod?.straightTimeAmountStr ?? "").replacingOccurrences(of: ",", with: "")
        csvStr.append("\(straightTimeEarningsCSV),")
        csvStr.append("\(periodOvertimeAmountStr.replacingOccurrences(of: ",", with: ""))")

        // Each Days Time Log
        csvStr.append("\n\n")
        csvStr.append(",Date,StartTime,EndTime,Break,Comments,Rate,Daily Comment\n")
        for index in 0...period.numberOfDays() {
            let date = period.date(at: index)
            let timeModel = createEnterTimeViewModel(forDate: date)
            csvStr.append("\(timeModel?.csv() ?? "")")
        }
        

        // Totals
        csvStr.append("\n\n")
        csvStr.append(",Work Week,Total Hours Worked,Total Break Hours,Overtime Hours,Straight Time Earnings,Regular Rate, Overtime Pay\n")
        workWeekViewModels?.forEach {
            csvStr.append(",\($0.csv())\n")
        }
        
        do {
            try csvStr.write(to: path, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        
        return path
    }
}
