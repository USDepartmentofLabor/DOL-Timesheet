//
//  PunchBreakTime+CoreDataClass.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 9/6/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(PunchBreakTime)
public class PunchBreakTime: NSManagedObject {
    public override func awakeFromInsert() {
        createdAt = Date()
    }    
}

extension PunchBreakTime: Comparable {
    
    static func == (lhs: PunchBreakTime, rhs: PunchBreakTime) -> Bool {
        return lhs.createdAt == rhs.createdAt
    }
    
    public static func < (lhs: PunchBreakTime, rhs: PunchBreakTime) -> Bool {
        guard let lhsDate = lhs.createdAt else { return true }
        guard let rhsDate = rhs.createdAt else { return false }
        
        return lhsDate < rhsDate
    }
}

