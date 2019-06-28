//
//  Salary+CoreDataClass.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/12/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Salary)
public class Salary: NSManagedObject {
    public override func awakeFromInsert() {
        createdAt = Date()
    }

    var salaryType: SalaryType {
        get {
            return SalaryType(rawValue: Int(salaryTypeValue)) ?? .annually
        }
        set {
            salaryTypeValue = Int16(newValue.rawValue)
        }
    }
}
