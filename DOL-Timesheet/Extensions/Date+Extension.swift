//
//  Date+Extension.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/7/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation

extension Date {
    func next(_ weekday: Weekday,
                     direction: Calendar.SearchDirection = .forward) -> Date
    {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(weekday: weekday.rawValue)
        
        if calendar.component(.weekday, from: self) == weekday.rawValue {
            return self
        }
        
        return calendar.nextDate(after: self,
                                 matching: components,
                                 matchingPolicy: .nextTime,
                                 direction: direction)!
    }
    
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth())!
    }
    
    // Returns 15th of the month
    func midOfMonth() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: DateComponents(day: 14), to: startOfMonth())!
    }
    
    // If current date is 1-15, return start of Month
    // Else return 16th of the month
    func startOfSemiMonth() -> Date {
        let calendar = Calendar(identifier: .gregorian)

        if calendar.component(.day, from: self) <= 15 {
            return startOfMonth()
        }

        return calendar.date(byAdding: DateComponents(day: 1), to: midOfMonth())!
    }
    
    // If current date is 1-15, return 15th of the month
    // Else return end of Month
    func endOfSemiMonth() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        
        if calendar.component(.day, from: self) <= 15 {
            // This should return 15th
            return midOfMonth()
        }
        
        return endOfMonth()
    }

    var formattedWeekday: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            
            return dateFormatter.string(from: self)
        }
    }
    
    var formattedDate: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            
            return dateFormatter.string(from: self)
        }
    }
    var csvformattedDate: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMddyyyy"
            
            return dateFormatter.string(from: self)
        }
    }

    var formattedTime: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            
            return dateFormatter.string(from: self)
        }
    }

    func diffInDays(toDate date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: self, to: date).day!
    }
    
    func addDays(days: Int) -> Date {
        return Calendar.current.date(byAdding: DateComponents(day: days), to: self)!
    }
}


extension Date {
    static func secondsToHoursMinutes(seconds: Double) -> (Int, Int) {
        let hours: Int = Int(seconds / 3600)
        
        let minutes: Int = Int(seconds.truncatingRemainder(dividingBy: 3600) / 60)
        
        return (hours, minutes)
    }
    
    static func secondsToHoursMinutes(seconds: Double) -> String {
        let (hours, minutes) = secondsToHoursMinutes(seconds: seconds)

        var title: String = ""
        if hours > 0 {
            title.append("\(hours) hrs ")
        }
        if minutes > 0 {
            title.append("\(minutes) min")
        }

        return title.isEmpty ? "0 hrs" : title
    }
}

extension Date {
    func removeSeconds() -> Date {
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        guard let date = Calendar.current.date(from: dateComponents)
            else {return self}
        
        return date
    }
    
    func removeTimeStamp() -> Date {
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)
        guard let date = Calendar.current.date(from: dateComponents)
            else {return self}
        
        return date
    }
    
    func isBetween(startDate: Date, endDate: Date) -> Bool {
        return (startDate ... endDate).contains(self)
    }
    
    func isLeapYear() -> Bool {
        let dateComponents = Calendar.current.dateComponents([.year], from: self)
        guard let year = dateComponents.year else {
            return false
        }
        
        if year%400 == 0 {
            return true
        }
        else if year%100 == 0 {
            return false
        }
        else if year%4 == 0 {
            return true
        }
        
        return false
    }
    
    func isEqualOnlyDate(date: Date) -> Bool {
        return self.removeTimeStamp() == date.removeTimeStamp()
    }
}

extension Date {
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func endOfDay() -> Date {
        return startOfDay().addingTimeInterval(24*60*60)
    }
    
    func isMidnight() -> Bool {
        let dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
        
        return (dateComponents.hour == 0 &&
            dateComponents.minute == 0 &&
            dateComponents.second == 0) ? true : false
    }
}

extension Date {
    static func splitTime(startTime: Date, endTime: Date) -> [(startTime: Date, endTime: Date)] {
        var timeRanges = [(startTime: Date, endTime: Date)]()
        
        var currentStartTime = startTime
        while currentStartTime.removeTimeStamp() != endTime.removeTimeStamp() {
            let currentEndTime = currentStartTime.endOfDay()
            timeRanges.append((startTime: currentStartTime, endTime: currentEndTime))
            currentStartTime = currentEndTime
        }
        timeRanges.append((startTime: currentStartTime, endTime: endTime))
        
        return timeRanges
    }
}
