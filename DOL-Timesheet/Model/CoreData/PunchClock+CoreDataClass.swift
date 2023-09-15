//
//  PunchClock+CoreDataClass.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 8/30/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

enum ClockAction: OptionsProtocol {
    case startWork
    case startBreak
    case endBreak
    case endWork
    case discardEntry
    
    var title: String {
        var title: String
        
        switch self {
        case .startWork:
            title = "start_work".localized
        case .endWork:
            title = "end_work".localized
        case .startBreak:
            title = "start_break".localized
        case .endBreak:
            title = "end_break".localized
        case .discardEntry:
            title = "discard".localized
        }
        
        return title
    }
}

enum ClockState {
    case notAllowed
    case none
    case clockedIn
    case inBreak
    
    var title: String {
        var title: String
        
        switch self {
        case .notAllowed:
            title = "Not Available"
        case .none:
            title = "Start Clock"
        case .clockedIn:
            title = "Clocked In"
        case .inBreak:
            title = "On Break"
        }
        
        return title
    }
}

@objc(PunchClock)
public class PunchClock: NSManagedObject {
    public override func awakeFromInsert() {
        createdAt = Date()
    }

    static func getClock(context: NSManagedObjectContext?) -> PunchClock? {
        guard let context = context else { return nil }
        
        var fetchResults: [PunchClock]?
        
        let fetchRequest: NSFetchRequest<PunchClock> = PunchClock.fetchRequest()
        
        do {
            fetchResults = try context.fetch(fetchRequest)
        } catch _ as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchResults?.first

    }
    
    func clockState() -> ClockState {
        var state = ClockState.none
        
        if currentBreak != nil {
            state = .inBreak
        }
        else if startTime != nil {
            state = .clockedIn
        }
        
        return state
    }
    
    var currentBreak: PunchBreakTime? {
        get {
            if let breakTimes = breakTimes as? Set<PunchBreakTime> {
                let lastBreak = breakTimes.sorted().last
                if lastBreak?.endTime == nil {
                    return lastBreak
                }
            }
            
            return nil
        }
    }
    
    var breaksSorted: [PunchBreakTime]? {
        get {
            if let breakTimes = breakTimes as? Set<PunchBreakTime> {
                return breakTimes.sorted()
            }
            
            return nil
        }
    }
    
    func totalBreakTime() -> TimeInterval {
        var timeInterval: TimeInterval = 0
        if let breakTimes = breakTimes as? Set<PunchBreakTime> {
            
            timeInterval = breakTimes.reduce(0) {
                if let startTime = $1.startTime {
                    // Check With Chandra
                    if let endTime = $1.endTime {
                        if endTime.timeIntervalSince(startTime) > EmploymentModel.ALLOWED_BREAK_SECONDS {
                            return $0 + endTime.timeIntervalSince(startTime)
                        }
                        else {
                            return $0
                        }
                    }
                    
                    return $0 + Date().removeSeconds().timeIntervalSince(startTime)
                }
                return $0
            }
        }
        return timeInterval
    }
    
    // Convert the Clock Break times to TimeLog times if they are > ALLOWED_BREAK_SECONDS
    func breakTimesEntries(for date: Date) -> [(startTime:Date, endTime:Date)]? {
        guard let breakTimes = breakTimes as? Set<PunchBreakTime> else {return nil}
        
        var breakTimeEntries: [(startTime:Date, endTime:Date)]? = nil
        
        breakTimes.forEach {
            if let startTime = $0.startTime {
                let endTime = $0.endTime ?? Date().removeSeconds()
                if endTime.timeIntervalSince(startTime) > EmploymentModel.ALLOWED_BREAK_SECONDS {
                    
                    let splitTimes = Date.splitTime(startTime: startTime, endTime: endTime)
                    splitTimes.forEach {
                        if $0.startTime.isEqualOnlyDate(date: date) {
                            if breakTimeEntries == nil {
                                breakTimeEntries = [(startTime:Date, endTime:Date)]()
                            }
                            breakTimeEntries?.append((startTime: $0.startTime, endTime: $0.endTime))
                        }
                    }
                }
            }
        }
        return breakTimeEntries
    }
    
    func totalHoursWorked() -> TimeInterval {
        var totalHours: TimeInterval = 0
        
        if let startTime = startTime {
            let currentEndTime = endTime ?? Date().removeSeconds()
            totalHours = currentEndTime.timeIntervalSince(startTime)
            totalHours = totalHours - totalBreakTime()
        }
        return totalHours
    }
}
