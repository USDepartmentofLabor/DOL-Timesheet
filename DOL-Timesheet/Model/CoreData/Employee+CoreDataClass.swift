//
//  Employee+CoreDataClass.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/30/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Employee)
public class Employee: User {

}

extension Employee {
    public func sortedEmployments() -> [EmploymentInfo]? {
        let employments: Set<EmploymentInfo> = employers as! Set<EmploymentInfo>
        return employments.sorted(by:
            {
                guard let firstCreatedDate = $0.startDate, let secondsCreatedDate = $1.startDate else
                {
                    return ($0.employer?.name ?? "") < ($1.employer?.name ?? "")
                }
                if firstCreatedDate == secondsCreatedDate {
                    return ($0.employer?.name ?? "") < ($1.employer?.name ?? "")
                }
                return firstCreatedDate > secondsCreatedDate
            }
        )
    }
    
    public func employmentInfo(for user: Employer) -> EmploymentInfo? {
        let employments: Set<EmploymentInfo> = employers as! Set<EmploymentInfo>
        return employments.filter{
            if let employer = $0.employer, employer.name == user.name {
                return true
            }
            return false }.first
    }
}
