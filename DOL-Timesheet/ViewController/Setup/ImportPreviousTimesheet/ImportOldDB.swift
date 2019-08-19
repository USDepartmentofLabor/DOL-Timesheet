//
//  ImportOldDB.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 7/31/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation
import SQLite3

struct OldEmployer {
    var employerId: Int
    var name: String
    var hourlyRate: NSNumber
    var startOfWorkWeek: Int
}

struct TimeEntry {
    var timeEntryId: Int
    var startTime: Date?
    var endTime: Date?
    var hourlyRate: NSNumber
    var comments: String?
}

struct BreakTime {
    var duration: Double
    var comments: String?
    var type: Int?
}

class ImportOldDB {
    
    let managedContext = CoreDataManager.shared().viewManagedContext

    var dbPath: URL {
        get {
            //Search for standard documents using NSSearchPathForDirectoriesInDomains
            //First Param = Searching the documents directory
            //Second Param = Searching the Users directory and not the System
            //Expand any tildes and identify home directories.
            let documentsURL = try! FileManager().url(for: .documentDirectory,
                                                      in: .userDomainMask,
                                                      appropriateFor: nil,
                                                      create: false)
            let whdURL = documentsURL.appendingPathComponent("whd.sqlite")
            return whdURL
        }
    }
    
    var exists: Bool {
        get {
            let fileExists = FileManager().fileExists(atPath: dbPath.path)
            return fileExists
        }
    }
    
    func importDB() {
        
        let oldDb = dbPath
        guard FileManager().fileExists(atPath: oldDb.path) else { return }
        
        let db: SQLiteDatabase
        do {
            db = try SQLiteDatabase.open(path: oldDb.path)

            let employers = db.getAllEmployers()
            load(db: db, employers: employers)
            
        } catch SQLiteError.OpenDatabase(let message) {
            print("Unable to open database. Verify that you created the directory described in the Getting Started section.")
            print(message)
        }
        catch(let error) {
            print(error)
        }
    }
    
    func load(db: SQLiteDatabase, employers: [OldEmployer]?) {
        guard let employers = employers, employers.count > 0 else {
            return
        }
        
        let employee = Employee(context: managedContext)
        employee.currentUser = true
        
        employers.forEach {
            // Add Employer
            addEmployer(db: db, for: employee, oldEmployer: $0)
        }
        
        CoreDataManager.shared().saveContext(context: managedContext)
    }
    
    func addEmployer(db: SQLiteDatabase, for employee: Employee, oldEmployer: OldEmployer) {
        let employer = Employer(context: managedContext)
        employer.name = oldEmployer.name
        employer.userId = Int32(oldEmployer.employerId)
        
        // Add Employment Info
        let employmentInfo = EmploymentInfo(context: managedContext)
        employmentInfo.payFrequency = .weekly
        employmentInfo.paymentType = .hourly
        employmentInfo.minimumWage = Util.FEDERAL_MINIMUM_WAGE
        employmentInfo.workWeekStartDay = Weekday(rawValue: oldEmployer.startOfWorkWeek) ?? .sunday
        
        // Add Hourly Rate
        let hourlyRate = HourlyRate(context: managedContext)
        hourlyRate.value = oldEmployer.hourlyRate.doubleValue
        hourlyRate.name = "Rate 1"
        employmentInfo.addToHourlyRate(hourlyRate)
        
        employmentInfo.employer = employer
        employmentInfo.employee = employee
        
        addTimeLogs(db: db, employmentInfo: employmentInfo, oldEmployer: oldEmployer)
    }
    
    func addTimeLogs(db: SQLiteDatabase, employmentInfo: EmploymentInfo, oldEmployer: OldEmployer) {

        guard let timeEntriesStartDate = db.getStartDate(for: oldEmployer),
            let timeEntriesEndDate = db.getEndDate(for: oldEmployer) else { return }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        var startDate = timeEntriesStartDate.startOfDay()
        while startDate.compare(timeEntriesEndDate) != .orderedDescending {
            let endDate = startDate.addDays(days: 30)
            addTimeLogs(db: db, employmentInfo: employmentInfo, oldEmployer: oldEmployer, startDate: startDate, endDate: endDate.endOfDay())
            
            startDate = endDate.addDays(days: 1).startOfDay()
        }
    }
    
    func addTimeLogs(db: SQLiteDatabase, employmentInfo: EmploymentInfo, oldEmployer: OldEmployer, startDate: Date, endDate: Date) {
        
        guard let timeEntries =  db.getTimeEntries(for: oldEmployer, startDate: startDate, endDate: endDate), timeEntries.count > 0 else { return }
        
        timeEntries.forEach {
            guard let startTime = $0.startTime else {return}
        
            let dateLog = employmentInfo.log(forDate: startTime) ??
            employmentInfo.createLog(forDate: startTime)
            let timeLog = dateLog.createTimeLog()
            timeLog?.startTime = startTime
            timeLog?.endTime = $0.endTime
            let breakTimes = db.getBreakTime(for: $0)
            timeLog?.breakTime = breakTimes?.reduce(0) {$0 + $1.duration} ?? 0

            if let hourlyTimeLog = timeLog as? HourlyPaymentTimeLog {
                hourlyTimeLog.value = $0.hourlyRate.doubleValue
            }
            let breakComments = breakTimes?.reduce("") {
                var allComments = $0 ?? ""
                if let comments = $1.comments {
                    if !allComments.isEmpty {
                        allComments.append("\n")
                    }
                    allComments.append(comments)
                }
                return allComments
            }
            
            var allComments = $0.comments ?? ""
            if !allComments.isEmpty {
                allComments.append("\n")
            }
            timeLog?.comment = allComments + (breakComments ?? "")
        }
    }
}

enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

class SQLiteDatabase {
    fileprivate let dbPointer: OpaquePointer?
    
    fileprivate var errorMessage: String {
        if let errorPointer = sqlite3_errmsg(dbPointer) {
            let errorMessage = String(cString: errorPointer)
            return errorMessage
        } else {
            return "No error message provided from sqlite."
        }
    }
    
    private init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    
    deinit {
        sqlite3_close(dbPointer)
    }
    
    static func open(path: String) throws -> SQLiteDatabase {
        var db: OpaquePointer? = nil
        // 1
        if sqlite3_open(path, &db) == SQLITE_OK {
            // 2
            return SQLiteDatabase(dbPointer: db)
        } else {
            // 3
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            
            if let errorPointer = sqlite3_errmsg(db) {
                let message = String.init(cString: errorPointer)
                throw SQLiteError.OpenDatabase(message: message)
            } else {
                throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
    }
}

//MARK: Preparing Statements

extension SQLiteDatabase {
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        
        return statement
    }
}

extension SQLiteDatabase {
    func getAllEmployers() -> [OldEmployer]? {
        let querySql = "SELECT EmployerId, EmployerName, StartOfWorkWeek, HourlyRate FROM Employers"
        
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            return nil
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        var employers = [OldEmployer]()
        while(sqlite3_step(queryStatement) == SQLITE_ROW) {
            let primaryKey = sqlite3_column_int(queryStatement, 0)
            let employerName = String(cString: sqlite3_column_text(queryStatement, 1))
            let startOfWorkWeek = sqlite3_column_int(queryStatement, 2)
            let hourlyRate = NSNumber(value: sqlite3_column_double(queryStatement, 3))
            
            let employer = OldEmployer(employerId: Int(primaryKey), name: employerName, hourlyRate: hourlyRate, startOfWorkWeek: Int(startOfWorkWeek))
            
            employers.append(employer)
        }
        
        return employers
    }
    
    func getStartDate(for employer: OldEmployer) -> Date? {
        let querySql = "SELECT MIN(StartTime) from TimeEntries";
        var startDate: Date?
        
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            return nil
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        while(sqlite3_step(queryStatement) == SQLITE_ROW) {
            let startTime = String(cString: sqlite3_column_text(queryStatement, 0))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            startDate = dateFormatter.date(from: startTime)
        }
        
        return startDate
    }
    func getEndDate(for employer: OldEmployer) -> Date? {
        let querySql = "SELECT MAX(StartTime) from TimeEntries";
        var endDate: Date?
        
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            return nil
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        while(sqlite3_step(queryStatement) == SQLITE_ROW) {
            let endTime = String(cString: sqlite3_column_text(queryStatement, 0))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            endDate = dateFormatter.date(from: endTime)
        }
        
        return endDate
    }

    func getTimeEntries(for employer: OldEmployer, startDate: Date, endDate: Date) -> [TimeEntry]? {
        
        let querySql = "SELECT TimeEntryId, EmployerId, StartTime, EndTime, HourlyRate, Comments FROM TimeEntries WHERE EmployerId = ? AND StartTime BETWEEN ? AND ?;"

        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            return nil
        }

        defer {
            sqlite3_finalize(queryStatement)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        let startDateStr = dateFormatter.string(from: startDate) as NSString
        let endDateStr = dateFormatter.string(from: endDate) as NSString
        
        guard sqlite3_bind_int(queryStatement, 1, Int32(employer.employerId)) == SQLITE_OK else {
            return nil
        }
        
        guard sqlite3_bind_text(queryStatement, 2, startDateStr.utf8String, -1, nil) == SQLITE_OK else {
            return nil
        }
        guard sqlite3_bind_text(queryStatement, 3, endDateStr.utf8String, -1, nil) == SQLITE_OK else {
            return nil
        }

        var timeEntries = [TimeEntry]()
        while(sqlite3_step(queryStatement) == SQLITE_ROW) {
            let entryId = sqlite3_column_int(queryStatement, 0)
            _ = sqlite3_column_int(queryStatement, 1) // employerID
            let startTime = String(cString: sqlite3_column_text(queryStatement, 2))
            let endTime = String(cString: sqlite3_column_text(queryStatement, 3))
            let hourlyRate = NSNumber(value: sqlite3_column_double(queryStatement, 4))
            
            var comments: String? = nil
            if let sqlComments = sqlite3_column_text(queryStatement, 5) {
                comments = String(cString: sqlComments)
            }
            
            let timeEntry = TimeEntry(timeEntryId: Int(entryId), startTime: dateFormatter.date(from: startTime), endTime: dateFormatter.date(from: endTime), hourlyRate: hourlyRate, comments: comments)
            
            timeEntries.append(timeEntry)
        }
        
        return timeEntries
    }

    func getBreakTime(for timeEntry: TimeEntry) -> [BreakTime]? {
        
        let querySql = "SELECT OtherBreakId, TimeEntryId, BreakTime, BreakComments, BreakType FROM OtherBreaks WHERE TimeEntryId = ?;"
        
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            return nil
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        guard sqlite3_bind_int(queryStatement, 1, Int32(timeEntry.timeEntryId)) == SQLITE_OK else {
            return nil
        }
        
        var breakTimes = [BreakTime]()
        while(sqlite3_step(queryStatement) == SQLITE_ROW) {
            _ = sqlite3_column_int(queryStatement, 0) // OtherBreakID
            _ = sqlite3_column_int(queryStatement, 1) // TimeEntry ID
            
            let breakDuration = sqlite3_column_double(queryStatement, 2)
            var comments: String? = nil
            if let sqlComments = sqlite3_column_text(queryStatement, 3) {
                comments = String(cString: sqlComments)
            }
            let breakType = sqlite3_column_int(queryStatement, 4)

            let breakTime = BreakTime(duration: breakDuration, comments: comments, type: Int(breakType))
            breakTimes.append(breakTime)
        }
        
        return breakTimes
    }

}
