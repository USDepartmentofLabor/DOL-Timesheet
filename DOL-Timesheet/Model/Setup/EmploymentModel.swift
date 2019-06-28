//
//  EmploymentModel.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/30/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EmploymentModel {
    static let ALLOWED_BREAK_SECONDS: Double = 20 * 60
    
    var isWizard = false
    
    var employmentInfo: EmploymentInfo
    var managedObjectContext: NSManagedObjectContext?

    var isValid: Bool {
        return (employmentInfo.managedObjectContext != nil)
    }
    var employee: User? {
        get {return employmentInfo.employee}
    }
    var employer: User? {
        get {return employmentInfo.employer}
    }

    var supervisorName: String? {
        get { return employmentInfo.supervisorName }
        set { employmentInfo.supervisorName = newValue }
    }
    var employmentNumber: String? {
        get { return employmentInfo.employmentNumber }
        set { employmentInfo.employmentNumber = newValue }
    }
    var supervisorEmail: String? {
        get { return employmentInfo.supervisorEmail }
        set { employmentInfo.supervisorEmail = newValue }
    }

    var paymentType: PaymentType {
        get { return employmentInfo.paymentType }
        set { employmentInfo.paymentType = newValue }
    }
    
    var paymentTypeTitle: String {
        get { return employmentInfo.paymentType.title }
    }
    
    var workWeekStartDay: Weekday {
        get {return employmentInfo.workWeekStartDay}
        set {employmentInfo.workWeekStartDay = newValue}
    }
    
    var paymentFrequency: PaymentFrequency {
        get { return employmentInfo.payFrequency }
        set {
            employmentInfo.payFrequency = newValue
        }
    }
    
    var employmentStartDate: Date {
        get { return employmentInfo.startDate ?? Date()}
        set { employmentInfo.startDate = newValue }
    }

    var overtimeEligible: Bool {
        get {return employmentInfo.covered}
        set {employmentInfo.covered = newValue}
    }

    var minimumWage: NSNumber {
        get { return NSNumber(value: employmentInfo.minimumWage) }
        set { employmentInfo.minimumWage = newValue.doubleValue }
    }
    
    var minimumWageStr: String {
        get {
            return NumberFormatter.localisedRateStr(from: employmentInfo.minimumWage)
        }
    }

    var salary: (amount: NSNumber, salaryType: SalaryType) {
        get {
            let salary = employmentInfo.salary
            return (NSNumber(value: salary?.value ?? 0), salary?.salaryType ?? SalaryType.annually)
        }
        set {
            let (amount, salaryType) = newValue
            updateSalary(amount: amount, salaryType: salaryType)
        }
    }
    
    init(employmentInfo: EmploymentInfo) {
        self.employmentInfo = employmentInfo
        self.managedObjectContext = employmentInfo.managedObjectContext
    }
    
    var employeeName: String? {
        return employee?.name
    }
    var employeeAddress: Address? {
        return employee?.address
    }

    var employerName: String? {
        return employer?.name
    }
    var employerAddress: Address? {
        return employer?.address
    }
    
    var profileUser: User? {
        return isProfileEmployer ? employmentInfo.employer : employmentInfo.employee
    }

    var employmentUser: User? {
        return isProfileEmployer ? employmentInfo.employee : employmentInfo.employer
    }

    func newEmploymentUser() -> User? {
        guard let context = employmentInfo.managedObjectContext else { return nil}
        
        let user: User?
        
        if isProfileEmployer {
            employmentInfo.employee = Employee(context: context)
            user = employmentInfo.employee
        }
        else {
            employmentInfo.employer = Employer(context: context)
            user = employmentInfo.employer
        }
        
        return user
    }
    
    var isProfileEmployer: Bool {
        get {
            return employmentInfo.employer?.currentUser ?? false
        }
    }
    func save() {
        if let context = employmentInfo.managedObjectContext {
            CoreDataManager.shared().saveContext(context: context)
        }
    }
    
    var currentPaymentTypeTitle: String {
        get {return
            "\(paymentTypeTitle)/\(paymentFrequency.title)"}
    }
    
    var hourlyRates: [HourlyRate]? {
        get {
            return employmentInfo.sortedRates()
        }
    }
    
    func newHourlyRate() {
        if let context = employmentInfo.managedObjectContext {
            let hourlyRate = HourlyRate(context: context)
            let existingCount = employmentInfo.hourlyRate?.count ?? 0
            hourlyRate.name = "Rate \(existingCount + 1)"
            employmentInfo.addToHourlyRate(hourlyRate)
        }
    }
    
    func deleteHourlyRate(hourlyRate: HourlyRate) {
        employmentInfo.removeFromHourlyRate(hourlyRate)
        if let context = employmentInfo.managedObjectContext {
            context.delete(hourlyRate)
        }
    }
}

extension EmploymentModel {
    private func updateSalary(amount: NSNumber, salaryType: SalaryType) {
        guard let context = employmentInfo.managedObjectContext else { return }

        var salary: Salary? = employmentInfo.salary
        if salary == nil {
            salary = Salary(context: context)
            employmentInfo.salary = salary
        }
        
        salary?.salaryType = salaryType
        salary?.value = amount.doubleValue
    }
}


class Period {
    var employmentInfo: EmploymentInfo?
    var startDate: Date
    var endDate: Date
    var workWeekStartDay: Weekday
    var workWeeks: [WorkWeek]
    var days: [Date] {
        get {
            var currentDate = startDate
            var days = [Date]()
            
            while currentDate <= endDate {
                days.append(currentDate)
                currentDate = currentDate.addDays(days: 1)
            }
            return days
        }
    }
    
    var rateHours: [Double: Int] {
        get {
            var rateWithHours = [Double: Int]()
            
            guard let employmentInfo = employmentInfo else {
                return rateWithHours
            }
            
            days.forEach ({ (date) in
                let dateLog = employmentInfo.log(forDate: date)
                let timeLogs = dateLog?.sortedTimeLogs
                timeLogs?.forEach({ (timeLog) in
                    if let hourlyLog = timeLog as? HourlyPaymentTimeLog {
                        let hourlyRate =  hourlyLog.value
                        let hours = rateWithHours[hourlyRate] ?? 0
                        rateWithHours[hourlyRate] = hours + timeLog.hoursWorked
                    }
                })
            })
            
            return rateWithHours
        }
    }
    
    
    init(startDate: Date, endDate: Date, workWeekStartDay: Weekday, employmentInfo: EmploymentInfo?) {
        self.startDate = startDate.removeTimeStamp()
        self.endDate = endDate.removeTimeStamp()
        self.workWeekStartDay = workWeekStartDay
        self.employmentInfo = employmentInfo
        
        self.workWeeks = [WorkWeek]()
        var currentDate = self.startDate
        repeat {
            let startOfWorkWeekDate = currentDate.next(workWeekStartDay, direction: .backward)
            workWeeks.append(WorkWeek(startDate: startOfWorkWeekDate))
            currentDate = startOfWorkWeekDate.addDays(days: 7)
        } while currentDate <= self.endDate
    }
    
    var title: String {
        get { return "Period of \(startDate.formattedDate) - \(endDate.formattedDate)"}
    }
    
    func numberOfDays() -> Int {
        return startDate.diffInDays(toDate: endDate) + 1
    }
    
    func date(at index: Int) -> Date {
        return startDate.addDays(days: index)
    }
    
    func numberOfWorkWeeks(period: Period) -> Int {
        return workWeeks.count
    }
    
    func workWeek(at index: Int) -> WorkWeek? {
        return workWeeks[index]
    }
    func workWeekTitle(at index: Int) -> String {
        return "Work Week \(index+1): \(workWeeks[index].title)"
    }
    
    func isDateInPeriod(date: Date) -> Bool {
        if date >= startDate && date <= endDate {
            return true
        }
        
        return false
    }
}

// MARK: Straight Time Earnings In Period
extension Period {
    var straightTimeAmountStr: String {
        get {
            return NumberFormatter.localisedCurrencyStr(from: straightTimeAmount)
        }
    }
    
    var straightTimeAmount: Double {
        get {
            guard let employmentInfo = employmentInfo else {
                return 0.0
            }
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
                let paymentFrequency = employmentInfo.payFrequency
                
                if salaryType == .annually {
                    if paymentFrequency == .monthly {
                        totalAmount = salaryAmount / 12
                    }
                    else if paymentFrequency == .biMonthly {
                        totalAmount = salaryAmount / 24
                    }
                    else if paymentFrequency == .weekly {
                        totalAmount = salaryAmount / 52
                    }
                    else if paymentFrequency == .biWeekly {
                        totalAmount = salaryAmount / 26
                    }
                    else if paymentFrequency == .daily {
                        totalAmount = salaryAmount / (startDate.isLeapYear() ? 366 : 365)
                    }
                }
                else if salaryType == .monthly {
                    if paymentFrequency == .monthly {
                        totalAmount = salaryAmount
                    }
                    else if paymentFrequency == .biMonthly {
                        totalAmount = salaryAmount / 2
                    }
                    else if paymentFrequency == .weekly {
                        totalAmount = (salaryAmount * 12)  / 52
                    }
                    else if paymentFrequency == .biWeekly {
                        totalAmount = (salaryAmount * 12) / 26
                    }
                    else if paymentFrequency == .daily {
                        totalAmount = (salaryAmount * 12) / (startDate.isLeapYear() ? 366 : 365)
                    }
                }
                else if salaryType == .weekly {
                    if paymentFrequency == .monthly {
                        totalAmount = (salaryAmount * 52) / 12
                    }
                    else if paymentFrequency == .biMonthly {
                        totalAmount = (salaryAmount * 52) / 24
                    }
                    else if paymentFrequency == .weekly {
                        totalAmount = salaryAmount
                    }
                    else if paymentFrequency == .biWeekly {
                        totalAmount = (salaryAmount * 2)
                    }
                    else if paymentFrequency == .daily {
                        totalAmount = salaryAmount / 7
                    }
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



class WorkWeek {
    var startDate: Date
    var endDate: Date
   
    var days: [Date] {
        get {
            var currentDate = startDate
            var days = [Date]()
            
            while currentDate <= endDate {
                days.append(currentDate)
                currentDate = currentDate.addDays(days: 1)
            }
            return days
        }
    }

    init(startDate: Date) {
        self.startDate = startDate
        self.endDate = startDate.addDays(days: 6)
    }
    
    var title: String {
        get { return "\(startDate.formattedDate) - \(endDate.formattedDate)"}
    }
    
}
