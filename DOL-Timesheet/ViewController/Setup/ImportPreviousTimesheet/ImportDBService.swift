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

struct OldTimeEntry {
    var timeEntryId: Int
    var startTime: Date?
    var endTime: Date?
    var hourlyRate: NSNumber
    var comments: String?
}

struct OldBreakTime {
    var duration: Double
    var comments: String?
    var type: Int?
}

struct OldClock {
    var startTime: Date?
    var endTime: Date?
    var comments: String?
    var type: Int?
}

protocol ImportDBLogProtocol: class {
    func appendLog(logStr: String)
    func addDetailLogs(logStr: String)
}

class ImportDBService {
    
    let managedContext = CoreDataManager.shared().backgroundManagedContext
    var profileEmployee: Employee?

    static var dbPath: URL {
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
    static var dbExists: Bool {
        get {
            let fileExists = FileManager().fileExists(atPath: dbPath.path)
            return fileExists
        }
    }
    
    static var importLogPath: URL {
        get {
            let documentsURL = try! FileManager().url(for: .documentDirectory,
                                                      in: .userDomainMask,
                                                      appropriateFor: nil,
                                                      create: false)
            let logsPath = documentsURL.appendingPathComponent("Logs")
            do {
                try FileManager.default.createDirectory(atPath: logsPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                NSLog("Unable to create directory \(error.debugDescription)")
            }

            let logsURL = logsPath.appendingPathComponent("importDB.txt")
            return logsURL
        }
    }
    
    weak var logDelegate:ImportDBLogProtocol?
    
    func importDB() {
        let oldDb = ImportDBService.dbPath
        guard FileManager().fileExists(atPath: oldDb.path) else {
            logDelegate?.addDetailLogs(logStr: "\nOld DB file does not exist: \(oldDb.path)")
            return
        }
        
        let db: SQLiteDatabase
        do {
            logDelegate?.addDetailLogs(logStr: "\nImport Started")
            db = try SQLiteDatabase.open(path: oldDb.path)

            let employers = try db.getAllEmployers()
            load(db: db, employers: employers)
            
            logDelegate?.appendLog(logStr: "\nImport Finished")
            
        } catch SQLiteError.OpenDatabase(let message) {
            logDelegate?.addDetailLogs(logStr: "\nUnable to open database SQL Error: \(message)")
        } catch SQLiteError.Prepare(let message) {
            logDelegate?.addDetailLogs(logStr: "\nUnable to prepare stmt SQL Error: \(message)")
        } catch(let error) {
            logDelegate?.addDetailLogs(logStr: "\nUnable to open database Error: \(error.localizedDescription)")
        }
    }
    
    func load(db: SQLiteDatabase, employers: [OldEmployer]?) {
        managedContext.performAndWait {
            guard let employee = User.getCurrentUser(context: managedContext) as? Employee else {
                logDelegate?.addDetailLogs(logStr: "\nCurrent User does not exist")
                return
            }
            
            guard let employers = employers, employers.count > 0 else {
                logDelegate?.addDetailLogs(logStr: "\nNo employers exists in Old Database")
                return
            }
            
            logDelegate?.addDetailLogs(logStr: "\nFound \(employers.count) emoloyers")
            employers.forEach {
                // Add Employer
                addEmployer(db: db, for: employee, oldEmployer: $0)
                CoreDataManager.shared().saveContext(context: managedContext)
            }
        }
    }
    
    func addEmployer(db: SQLiteDatabase, for employee: Employee, oldEmployer: OldEmployer) {
        let logStr = "\nImporting Employer \(oldEmployer.name)"
        logDelegate?.appendLog(logStr: logStr)
        logDelegate?.addDetailLogs(logStr: logStr)
        
        let employer = Employer(context: managedContext)
        employer.name = oldEmployer.name
        employer.userId = Int32(oldEmployer.employerId)
        
        // Add Employment Info
        let employmentInfo = EmploymentInfo(context: managedContext)
        employmentInfo.payFrequency = .weekly
        employmentInfo.paymentType = .hourly
        employmentInfo.minimumWage = Util.FEDERAL_MINIMUM_WAGE
        employmentInfo.workWeekStartDay = Weekday(rawValue: oldEmployer.startOfWorkWeek + 1) ?? .sunday
        
        // Add Hourly Rate
        let hourlyRate = HourlyRate(context: managedContext)
        hourlyRate.value = oldEmployer.hourlyRate.doubleValue
        hourlyRate.name = "rate_name".localized + " 1"
        employmentInfo.addToHourlyRate(hourlyRate)
        
        employmentInfo.employer = employer
        employmentInfo.employee = employee
        employmentInfo.startDate = Date().startOfDay()
        
        addTimeLogs(db: db, employmentInfo: employmentInfo, oldEmployer: oldEmployer)
//        addClock(db: db, employmentInfo: employmentInfo, oldEmployer: oldEmployer)
    }
    
    func addTimeLogs(db: SQLiteDatabase, employmentInfo: EmploymentInfo, oldEmployer: OldEmployer) {

        do {
            guard let timeEntriesStartDate = try db.getStartDate(for: oldEmployer),
            let timeEntriesEndDate = try db.getEndDate(for: oldEmployer) else {
                employmentInfo.startDate = Date()
                return
           }

            employmentInfo.startDate = timeEntriesStartDate.startOfDay()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            logDelegate?.addDetailLogs(logStr: "StartDate : \(dateFormatter.string(from: timeEntriesStartDate))")
            logDelegate?.addDetailLogs(logStr: "EndDate : \(dateFormatter.string(from: timeEntriesEndDate))")
        
            var startDate = timeEntriesStartDate.startOfDay()
            while startDate.compare(timeEntriesEndDate) != .orderedDescending {
                let endDate = startDate.addDays(days: 30)
            
                addTimeLogs(db: db, employmentInfo: employmentInfo, oldEmployer: oldEmployer, startDate: startDate, endDate: endDate.endOfDay())
            
                startDate = endDate.addDays(days: 1).startOfDay()
            }
        } catch SQLiteError.Prepare(let message) {
            logDelegate?.addDetailLogs(logStr: "Unable to prepare stmt getStartDate, getEndDate, SQLError: \(message)")
        } catch SQLiteError.Bind(let message) {
            logDelegate?.addDetailLogs(logStr: "Unable to bind in getStartDate, getEndDate, SQLError: \(message)")
        } catch SQLiteError.Step(let message) {
            logDelegate?.addDetailLogs(logStr: "Unable to step in getStartDate, getEndDate, SQLError: \(message)")
        } catch (let error) {
            logDelegate?.addDetailLogs(logStr: "Error in getStartDate, getEndDate, Error: \(error.localizedDescription)")
        }
    }
    
    func addTimeLogs(db: SQLiteDatabase, employmentInfo: EmploymentInfo, oldEmployer: OldEmployer, startDate: Date, endDate: Date) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let logStr = "Importing TimeLog for date range \(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
        logDelegate?.appendLog(logStr: logStr)
        logDelegate?.addDetailLogs(logStr: logStr)
        

        do {
            guard let timeEntries =  try db.getTimeEntries(for: oldEmployer, startDate: startDate, endDate: endDate), timeEntries.count > 0 else {
                logDelegate?.addDetailLogs(logStr: "No time entries found")
                return
            }
        
            try timeEntries.forEach {
                guard let startTime = $0.startTime else {return}
            
                let dateLog = employmentInfo.log(forDate: startTime) ??
                employmentInfo.createLog(forDate: startTime)
                let timeLog = dateLog.createTimeLog()
                
                timeLog?.startTime = startTime
                timeLog?.endTime = $0.endTime
                let breakTimes = try db.getBreakTime(for: $0)
                let breakDuration = breakTimes?.reduce(0) {$0 + $1.duration} ?? 0
                timeLog?.addBreak(duration: breakDuration)
                
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
        } catch SQLiteError.Prepare(let message) {
            logDelegate?.addDetailLogs(logStr: "Unable to prepare stmt addTimeLogs, SQLError: \(message)")
        } catch SQLiteError.Bind(let message) {
            logDelegate?.addDetailLogs(logStr: "Unable to bind in addTimeLogs, SQLError: \(message)")
        } catch SQLiteError.Step(let message) {
                    logDelegate?.addDetailLogs(logStr: "Unable to step in addTimeLogs SQLError: \(message)")
        } catch (let error) {
            logDelegate?.addDetailLogs(logStr: "addTimeLogs, Error: \(error.localizedDescription)")
        }
    }
    
    func addClock(db: SQLiteDatabase, employmentInfo: EmploymentInfo, oldEmployer: OldEmployer) {
        
        do {
            let dbClocks = try db.getClock(for: oldEmployer)
            
            guard let clocks = dbClocks, clocks.count > 0 else { return }
        
            logDelegate?.appendLog(logStr: "Importing ClockTime")
            logDelegate?.addDetailLogs(logStr: "Importing ClockTime")

            let startWork = clocks.filter{$0.type == 0}.first
            if let startWork = startWork, let startTime = startWork.startTime {
                var hourlyRate: HourlyRate? = nil
                if let hourlyRates = employmentInfo.hourlyRate as? Set<HourlyRate> {
                        hourlyRate = hourlyRates.first
                }
                employmentInfo.startWork(hourlyRate: hourlyRate, at: startTime)
            
                var allComments = ""
                let breaks = clocks.filter{$0.type != 0}
                breaks.forEach {
                    if let comments = $0.comments {
                        allComments.append(" \(comments)")
                    }
                    if let breakStart = $0.startTime {
                        employmentInfo.startBreak(comments: allComments, at: breakStart)
                    }
                    if let endBreak = $0.endTime {
                        employmentInfo.endBreak(comments: allComments, at: endBreak)
                    }
                }
            }
        } catch SQLiteError.Prepare(let message) {
            logDelegate?.addDetailLogs(logStr: "Unable to prepare stmt addClock, SQLError: \(message)")
        } catch SQLiteError.Bind(let message) {
            logDelegate?.addDetailLogs(logStr: "Unable to bind in addClock, SQLError: \(message)")
        } catch SQLiteError.Step(let message) {
            logDelegate?.addDetailLogs(logStr: "Unable to step in addClock SQLError: \(message)")
        } catch (let error) {
            logDelegate?.addDetailLogs(logStr: "addClock, Error: \(error.localizedDescription)")
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
    func getAllEmployers() throws -> [OldEmployer]? {
        let querySql = "SELECT EmployerId, EmployerName, StartOfWorkWeek, HourlyRate FROM Employers ORDER BY EmployerId DESC"
        
        guard let queryStatement = try prepareStatement(sql: querySql) else {
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
    
    func getStartDate(for employer: OldEmployer) throws -> Date? {
        let querySql = "SELECT MIN(StartTime) from TimeEntries WHERE EmployerId = ?";
        var startDate: Date?
        
        guard let queryStatement = try prepareStatement(sql: querySql) else {
            return nil
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        guard sqlite3_bind_int(queryStatement, 1, Int32(employer.employerId)) == SQLITE_OK else {
            throw SQLiteError.Bind(message: errorMessage)
        }

        if sqlite3_step(queryStatement) == SQLITE_ROW,
            let sqlStartTime = sqlite3_column_text(queryStatement, 0) {
            let startTime = String(cString: sqlStartTime)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            startDate = dateFormatter.date(from: startTime)
            return startDate
        }
        else {
           throw SQLiteError.Step(message: errorMessage)
        }
    }
    
    func getEndDate(for employer: OldEmployer) throws -> Date? {
        let querySql = "SELECT MAX(EndTime) from TimeEntries WHERE EmployerId = ?";
        var endDate: Date?
        
        guard let queryStatement = try prepareStatement(sql: querySql) else {
            return nil
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        guard sqlite3_bind_int(queryStatement, 1, Int32(employer.employerId)) == SQLITE_OK else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        
        if sqlite3_step(queryStatement) == SQLITE_ROW,
            let sqlEndTime = sqlite3_column_text(queryStatement, 0) {
            let endTime = String(cString: sqlEndTime)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            endDate = dateFormatter.date(from: endTime)
            return endDate
        }
        else {
            throw SQLiteError.Step(message: errorMessage)
        }
    }

    func getTimeEntries(for employer: OldEmployer, startDate: Date, endDate: Date) throws -> [OldTimeEntry]? {
        
        let querySql = "SELECT TimeEntryId, EmployerId, StartTime, EndTime, HourlyRate, Comments FROM TimeEntries WHERE EmployerId = ? AND StartTime BETWEEN ? AND ?;"

        guard let queryStatement = try prepareStatement(sql: querySql) else {
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
            throw SQLiteError.Bind(message: errorMessage)
        }
        
        guard sqlite3_bind_text(queryStatement, 2, startDateStr.utf8String, -1, nil) == SQLITE_OK else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        guard sqlite3_bind_text(queryStatement, 3, endDateStr.utf8String, -1, nil) == SQLITE_OK else {
            throw SQLiteError.Bind(message: errorMessage)
        }

        var timeEntries = [OldTimeEntry]()
        while(sqlite3_step(queryStatement) == SQLITE_ROW),
            let sqlStartTime = sqlite3_column_text(queryStatement, 2),
            let sqlEndTime = sqlite3_column_text(queryStatement, 3) {
                
            let entryId = sqlite3_column_int(queryStatement, 0)
            _ = sqlite3_column_int(queryStatement, 1) // employerID
            let startTime = String(cString: sqlStartTime)
            let endTime = String(cString: sqlEndTime)
            let hourlyRate = NSNumber(value: sqlite3_column_double(queryStatement, 4))
            
            var comments: String? = nil
            if let sqlComments = sqlite3_column_text(queryStatement, 5) {
                comments = String(cString: sqlComments)
            }
            
            let timeEntry = OldTimeEntry(timeEntryId: Int(entryId), startTime: dateFormatter.date(from: startTime), endTime: dateFormatter.date(from: endTime), hourlyRate: hourlyRate, comments: comments)
            
            timeEntries.append(timeEntry)
        }
        
        return timeEntries
    }

    func getBreakTime(for timeEntry: OldTimeEntry) throws -> [OldBreakTime]? {
        
        let querySql = "SELECT OtherBreakId, TimeEntryId, BreakTime, BreakComments, BreakType FROM OtherBreaks WHERE TimeEntryId = ?;"
        
        guard let queryStatement = try prepareStatement(sql: querySql) else {
            return nil
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        guard sqlite3_bind_int(queryStatement, 1, Int32(timeEntry.timeEntryId)) == SQLITE_OK else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        
        var breakTimes = [OldBreakTime]()
        while(sqlite3_step(queryStatement) == SQLITE_ROW) {
            _ = sqlite3_column_int(queryStatement, 0) // OtherBreakID
            _ = sqlite3_column_int(queryStatement, 1) // TimeEntry ID
            
            let breakDuration = sqlite3_column_double(queryStatement, 2)
            var comments: String? = nil
            if let sqlComments = sqlite3_column_text(queryStatement, 3) {
                comments = String(cString: sqlComments)
            }
            let breakType = sqlite3_column_int(queryStatement, 4)

            let breakTime = OldBreakTime(duration: breakDuration, comments: comments, type: Int(breakType))
            breakTimes.append(breakTime)
        }
        
        return breakTimes
    }

    func getClock(for employer: OldEmployer) throws -> [OldClock]? {
        let querySql = "SELECT StartTime, EndTime, Comments, Type FROM Clock WHERE EmployerId = ?;"
        
        let queryStatement = try prepareStatement(sql: querySql)
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        guard sqlite3_bind_int(queryStatement, 1, Int32(employer.employerId)) == SQLITE_OK else {
            throw SQLiteError.Bind(message: errorMessage)
        }

        var clocks = [OldClock]()
        while(sqlite3_step(queryStatement) == SQLITE_ROW),
            let sqlStartTime = sqlite3_column_text(queryStatement, 0) {
                
            let startTime = String(cString: sqlStartTime)

            var endTime: String? = nil
            if let sqlEndTime = sqlite3_column_text(queryStatement, 1) {
                endTime = String(cString: sqlEndTime)
            }
                
            let type = sqlite3_column_int(queryStatement, 3) // Type
            
            var comments: String? = nil
            if let sqlComments = sqlite3_column_text(queryStatement, 2) {
                comments = String(cString: sqlComments)
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let startDate = dateFormatter.date(from: startTime)
            var endDate: Date? = nil
            
            if let endTime = endTime {
                endDate = dateFormatter.date(from: endTime)
            }

            
            let clock = OldClock(startTime: startDate, endTime: endDate, comments: comments, type: Int(type))
            clocks.append(clock)
        }
        
        return clocks
    }
}
