//
//  Employer+CoreDataClass.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/30/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Employer)
public class Employer: User {

}

extension Employer {
    public func sortedEmployments() -> [EmploymentInfo]? {
        let employments: Set<EmploymentInfo> = employees as! Set<EmploymentInfo>
        return employments.sorted(by:
            {
                guard let firstCreatedDate = $0.startDate, let secondsCreatedDate = $1.startDate else
                {
                    return ($0.employee?.name ?? "") < ($1.employee?.name ?? "")
                }
                if firstCreatedDate == secondsCreatedDate {
                    return ($0.employee?.name ?? "") < ($1.employee?.name ?? "")
                }
            return firstCreatedDate > secondsCreatedDate
        })
    }
    
    public func employmentInfo(for user: Employee) -> EmploymentInfo? {
        let employments: Set<EmploymentInfo> = employees as! Set<EmploymentInfo>
        return employments.filter{
            if let employee = $0.employee, employee.name == user.name {
                return true
            }
            return false }.first
    }

}
