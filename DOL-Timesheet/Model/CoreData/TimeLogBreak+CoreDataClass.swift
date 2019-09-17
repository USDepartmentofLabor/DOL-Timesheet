//
//  TimeLogBreak+CoreDataClass.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 9/10/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(TimeLogBreak)
public class TimeLogBreak: NSManagedObject {

    var duration: Double {
        get {
            if manualEntry {
                return durationValue
            }
            else if let startTime = startTime,
                let endTime = endTime {
                return endTime.timeIntervalSince(startTime)
            }
            
            return 0
        }
        set {
            durationValue = newValue
            manualEntry = true
        }
    }
}
