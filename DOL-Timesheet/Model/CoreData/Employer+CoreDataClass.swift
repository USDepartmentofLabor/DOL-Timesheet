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
            { guard let firstCreatedDate = $0.employee?.createdAt else { return false }
                guard let secondsCreatedDate = $1.employee?.createdAt else { return true }
                return firstCreatedDate > secondsCreatedDate })
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
