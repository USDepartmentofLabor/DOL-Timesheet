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
            title = "payment_type_hourly".localized
        case .salary:
            title = "payment_type_salary".localized
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
            desc = "payment_type_hourly_desc".localized
        case .salary:
            desc = "payment_type_salary_desc".localized
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
            title = "payment_frequency_daily".localized
        case .weekly:
            title = "payment_frequency_weekly".localized
        case.biWeekly:
            title = "payment_frequency_biweekly".localized
        case .biMonthly:
            title = "payment_frequency_semimonthly".localized
        case .monthly:
            title = "payment_frequency_monthly".localized
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
            title = "salary_annually".localized
        case .monthly:
            title = "salary_monthly".localized
        case.weekly:
            title = "salary_weekly".localized
        }
        return title
    }
}

enum Weekday: Int, OptionsProtocol, CaseIterable {
    case monday = 1
    case tuesday
    case wednesday
    case thurdsday
    case friday
    case saturday
    case sunday
    
    var title: String {
        let title: String
        
        switch self {
        case .sunday:
            title = "work_week_sunday".localized
        case .monday:
            title = "work_week_monday".localized
        case.tuesday:
            title = "work_week_tuesday".localized
        case .wednesday:
            title = "work_week_wednesday".localized
        case .thurdsday:
            title = "work_week_thursday".localized
        case .friday:
            title = "work_week_friday".localized
        case .saturday:
            title = "work_week_saturday".localized
        }
        return title
    }
}


protocol OptionsProtocol {
    var title: String { get }
}
