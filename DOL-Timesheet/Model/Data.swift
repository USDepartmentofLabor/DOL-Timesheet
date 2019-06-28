//
//  Data.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/12/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation

enum UserType : Int {
    case employee
    case employer
}

enum PaymentType: Int, OptionsProtocol, CaseIterable {
    case hourly
    case salary
//    case tipped
//    case paidPerUnit
    
    var title: String {
        let title: String
        
        switch self {
        case .hourly:
            title = NSLocalizedString("payment_type_hourly", comment: "Payment Type Hourly")
        case .salary:
            title = NSLocalizedString("payment_type_salary", comment: "Payment Type Salary")
//        case.tipped:
//            title = NSLocalizedString("payment_type_tips", comment: "Payment Type Tips")
//        case .paidPerUnit:
//            title = NSLocalizedString("payment_type_paid_per_unit", comment: "Payment Type Paid Per Unit")
        }
        return title
    }
    
    var desc: String {
        let desc: String
        
        switch self {
        case .hourly:
            desc = NSLocalizedString("payment_type_hourly_desc", comment: "")
        case .salary:
            desc = NSLocalizedString("payment_type_salary_desc", comment: "")
//        case .tipped:
//            desc = ""
//        case .paidPerUnit:
//            desc = ""
        }
        
        return desc
    }
    
}


enum PaymentFrequency: Int, OptionsProtocol, CaseIterable {
    case daily = 1
    case weekly
    case biWeekly
    case biMonthly
    case monthly
    
    var title: String {
        let title: String
        
        switch self {
        case .daily:
            title = NSLocalizedString("payment_frequency_daily", comment: "")
        case .weekly:
            title = NSLocalizedString("payment_frequency_weekly", comment: "")
        case.biWeekly:
            title = NSLocalizedString("payment_frequency_biweekly", comment: "")
        case .biMonthly:
            title = NSLocalizedString("payment_frequency_semimonthly", comment: "")
        case .monthly:
            title = NSLocalizedString("payment_frequency_monthly", comment: "")
        }
        return title
    }

}

enum SalaryType: Int, OptionsProtocol, CaseIterable {
    case annually
    case monthly
    case weekly
    
    var title: String {
        let title: String
        
        switch self {
        case .annually:
            title = NSLocalizedString("salary_annually", comment: "")
        case .monthly:
            title = NSLocalizedString("salary_monthly", comment: "")
        case.weekly:
            title = NSLocalizedString("salary_weekly", comment: "")
        }
        return title
    }
}

enum Weekday: Int, OptionsProtocol, CaseIterable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thurdsday
    case friday
    case saturday
    
    var title: String {
        let title: String
        
        switch self {
        case .sunday:
            title = NSLocalizedString("work_week_sunday", comment: "")
        case .monday:
            title = NSLocalizedString("work_week_monday", comment: "")
        case.tuesday:
            title = NSLocalizedString("work_week_tuesday", comment: "")
        case .wednesday:
            title = NSLocalizedString("work_week_wednesday", comment: "")
        case .thurdsday:
            title = NSLocalizedString("work_week_thursday", comment: "")
        case .friday:
            title = NSLocalizedString("work_week_friday", comment: "")
        case .saturday:
            title = NSLocalizedString("work_week_saturday", comment: "")
        }
        return title
    }
}


protocol OptionsProtocol {
    var title: String { get }
}
