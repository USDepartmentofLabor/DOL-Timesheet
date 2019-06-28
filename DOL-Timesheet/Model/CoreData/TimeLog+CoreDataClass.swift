//
//  TimeLog+CoreDataClass.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/10/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(TimeLog)
public class TimeLog: NSManagedObject {
   
    public override func awakeFromInsert() {
        createdAt = Date()
    }

    var hoursLogged: Int {
        if let startTime = startTime, let endTime = endTime {
            let dateComponents = Calendar.current.dateComponents([.second], from: startTime, to: endTime)
            return (dateComponents.second ?? 0)
        }
        
        return 0
    }

    var hoursWorked: Int {
        if let startTime = startTime, let endTime = endTime {
            let dateComponents = Calendar.current.dateComponents([.second], from: startTime, to: endTime)
            if breakTime <= EmploymentModel.ALLOWED_BREAK_SECONDS {
                return (dateComponents.second ?? 0)
            }
            return (dateComponents.second ?? 0) - Int(breakTime)
        }
        
        return 0
    }
    
    var amountEarned: Double {
        return 0
    }
    
    func validate() -> String? {
        var errorStr: String? = nil
        
        if let startTime = startTime, let endTime = endTime {
            if startTime >= endTime {
                errorStr = NSLocalizedString("err_startTime_before_endtime", comment: "")
            }
        }
        
        return errorStr
    }
}

extension TimeLog: Comparable {
    
    static func == (lhs: TimeLog, rhs: TimeLog) -> Bool {
        return lhs.createdAt == rhs.createdAt
    }
    
    public static func < (lhs: TimeLog, rhs: TimeLog) -> Bool {
        guard let lhsDate = lhs.createdAt else { return true }
        guard let rhsDate = rhs.createdAt else { return false }
        
        return lhsDate < rhsDate
    }
}

