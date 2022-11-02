//
//  EarningsModel.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/15/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation

class WorkWeekViewModel {
    var employmentInfo: EmploymentInfo
    var currentWorkWeek: WorkWeek
    var period: Period
    var isCollapsed: Bool
    var rateHours =  [Double: Int]()
    
    var isBelowMinimumWage: Bool {
        if totalHoursWorked > 0 {
            return regularRate < Util.FEDERAL_MINIMUM_WAGE ? true : false
        }
        return false
    }
    
    var isBelowSalaryWeeklyWage: Bool {
        if totalHoursWorked > 0 {
            if !employmentInfo.covered && employmentInfo.paymentType == .salary{
                return totalEarnings < Util.FEDERAL_MINIMUM_EXEMPT_WEEKLY_WAGE
            }
        }
        return false
    }
    
    // WorkWeek is Closed if week has ended or if it is last date of wrok week
    // or if hours worked >= 40
    var isWorkWeekClosed: Bool {
        let todaysDate = Date().removeTimeStamp()
        return (currentWorkWeek.endDate.compare(todaysDate) != .orderedDescending) ||
            totalTimeWorked >= WorkWeekViewModel.WORK_WEEK_SECONDS
    }
    
    init(employmentInfo: EmploymentInfo, period: Period, workWeek: WorkWeek) {
        self.employmentInfo = employmentInfo
        self.currentWorkWeek = workWeek
        self.period = period
        self.isCollapsed = true
        
        calculateEarnings()
    }
    
    var title: String {
        get {
            return "\(currentWorkWeek.title)"
        }
    }

    var minimumWageStr: String {
        get {
            return NumberFormatter.localisedRateStr(from: employmentInfo.minimumWage)
        }
    }

    var overtimeEligible: Bool {
        get {return employmentInfo.covered}
    }

    func calculateEarnings() {
        currentWorkWeek.days.forEach ({ (date) in
            let dateLog = employmentInfo.log(forDate: date)
            let timeLogs = dateLog?.sortedTimeLogs
            timeLogs?.forEach({ (timeLog) in
                if let hourlyLog = timeLog as? HourlyPaymentTimeLog {
                    let hourlyRate =  hourlyLog.value
                    let hours = rateHours[hourlyRate] ?? 0
                    rateHours[hourlyRate] = hours + timeLog.hoursWorked
                }
            })
        })
    }
}


// MARK: Totals
extension WorkWeekViewModel {
    var totalTimeWorked: Double {
        let hoursWorked = currentWorkWeek.days.reduce(0.0) {
            let dateLog = employmentInfo.log(forDate: $1)
            return $0 + (dateLog?.totalHoursWorked ?? 0)
        }
    
        return hoursWorked
//        if employmentInfo.paymentType == .hourly {
//            return rateHours.reduce(0) {$0 + $1.value}
//        }
    }
    
    var totalHoursWorked: Double {
        let timeWorked = totalTimeWorked
        if timeWorked > 0 {
            return timeWorked / 3600
        }
        
        return 0
    }
    
    var totalHoursWorkedStr: String {
        return Date.secondsToHoursMinutes(seconds: Double(totalTimeWorked))
    }
    
    var totalBreakTime: Double {
        return currentWorkWeek.days.reduce(0.0) {
            let dateLog = employmentInfo.log(forDate: $1)
            return $0 + (dateLog?.totalBreak ?? 0)
        }
    }
    
    var totalBreakStr: String {
       return Date.secondsToHoursMinutes(seconds: Double(totalBreakTime))
    }
    
    var totalEarnings: Double {
        return straightTimeAmount + overtimeAmount
    }
    
    var totalEarningsStr: String {
        return NumberFormatter.localisedCurrencyStr(from: totalEarnings)
    }
}


// MARK: Straight Time Earnings
extension WorkWeekViewModel {
    var straightTimeAmountStr: String {
        get {
            return NumberFormatter.localisedCurrencyStr(from: straightTimeAmount)
        }
    }
    
    var straightTimeAmount: Double {
        get {
            var totalAmount = 0.0
            if employmentInfo.paymentType == .hourly {
                rateHours.forEach {
                    let hourlyRate = $0.key
                    let amountForRate = (Double($0.value)/3600) * hourlyRate
                    totalAmount += amountForRate
                }
            }
            else if employmentInfo.paymentType == .salary,
                let salaryType = employmentInfo.salary?.salaryType,
                let salaryAmount = employmentInfo.salary?.value {
                if salaryType == .annually {
                    totalAmount = salaryAmount / 52
                }
                else if salaryType == .monthly {
                    totalAmount = (salaryAmount * 12) / 52
                }
                else if salaryType == .weekly {
                    totalAmount = salaryAmount
                }
            }
            return totalAmount
        }
    }
    
    var straightTimeCalculationsStr: String {
        get {
            var straightTimeCalculationsStr = ""
            rateHours.forEach {
                let hourlyRate = $0.key
                let amountForRate = (Double($0.value)/3600) * hourlyRate
                
                if !straightTimeCalculationsStr.isEmpty {
                    straightTimeCalculationsStr.append("\n")
                }
                
                let hoursWorkedStr: String = Date.secondsToHoursMinutes(seconds: Double($0.value))
                let atRateStr: String = NumberFormatter.localisedRateStr(from: hourlyRate)
                let amountForRateStr: String = NumberFormatter.localisedCurrencyStr(from: amountForRate)
                straightTimeCalculationsStr.append("\(hoursWorkedStr) x \(atRateStr) = \(amountForRateStr)")
            }
            
            return straightTimeCalculationsStr
        }
    }
}

// MARK: Regular Rate
extension WorkWeekViewModel {
    // Regular Rate = Staright Time Hours / Total Hours Worked
    var regularRate: Double {
        get {
            if totalHoursWorked > 0 {
                return straightTimeAmount / Double(totalHoursWorked)
            }
            
            return 0.0
        }
    }
    var regularRateStr: String {
        return NumberFormatter.localisedRateStr(from: regularRate)
    }
    
    var regularRateCalculationStr: String {
        
        return "\(straightTimeAmountStr) / \(totalHoursWorkedStr) = \(regularRateStr)"
    }
}

// MARK: Overtime
extension WorkWeekViewModel {
    static let WORK_WEEK_SECONDS: Double = 40 * 60 * 60

    var isEndingInPeriod: Bool {
        get {
            return period.isDateInPeriod(date: currentWorkWeek.endDate)
        }
    }
    var overtime: Double {
        if totalTimeWorked > WorkWeekViewModel.WORK_WEEK_SECONDS {
            return Double(totalTimeWorked) - (WorkWeekViewModel.WORK_WEEK_SECONDS)
        }
        
        return 0
    }
    var overtimeHours: Double {
        return overtime/3600
    }
    
    var overtimeHoursStr: String {
        return Date.secondsToHoursMinutes(seconds: overtime)
    }
    
    var overtimeAmount: Double {
        if overtimeEligible {
            return regularRate * 0.5 * overtimeHours
        }
        else {
            return 0
        }
    }
    
    var overtimeAmountStr: String {
        return NumberFormatter.localisedCurrencyStr(from: overtimeAmount)
    }
    
    var overtimeCalculationStr: String {
        return "\(regularRateStr) x 0.5 x \(overtimeHoursStr)"
    }
    
    var overtimePaymentTimeInfo : String {
        var overtimeInfo = ""
        if overtimeAmount > 0, !isEndingInPeriod {
            if employmentInfo.payFrequency == .daily {
                let msg = "overtime_on_date".localized
                overtimeInfo = String(format: msg, currentWorkWeek.endDate.formattedDate)
            }
            else {
                overtimeInfo = "overtime_next_pay_period".localized
            }
        }
        return overtimeInfo
    }
}

extension WorkWeekViewModel {
    func csv() -> String {
        var csvStr = currentWorkWeek.title
        let straightTimeCSV = straightTimeAmountStr.replacingOccurrences(of: ",", with: "")
        let regularRateCSV = regularRateStr.replacingOccurrences(of: ",", with: "")
        let overtimeAmountCSV = overtimeAmountStr.replacingOccurrences(of: ",", with: "")
    csvStr.append(",\(totalHoursWorkedStr),\(totalBreakStr),\(overtimeHoursStr),\(straightTimeCSV),\(regularRateCSV),\(overtimeAmountCSV)")
        return csvStr
    }
}
