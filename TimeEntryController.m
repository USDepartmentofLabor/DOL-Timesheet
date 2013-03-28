//
//  TimeEntryController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "TimeEntryController.h"
#import "WHDAppDelegate.h"
#import "DateConversion.h"
#import "Employer.h"
#import "OtherBreaks.h"
#import <sqlite3.h>

@implementation TimeEntryController

+ (NSInteger)addTimeEntry:(TimeEntry *)timeEntry withBreaks:(NSMutableArray *)otherBreaks {
	
	WHDAppDelegate *appDelegate = (WHDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	sqlite3 *database;
	NSInteger sqlResult;
	NSInteger lastRowId;
	
	if (sqlite3_open([[appDelegate getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		//BEGIN TRANSACTION statement. This is an all or nothing situation.
		sqlite3_exec(database, "BEGIN TRANSACTION;", 0, 0, 0);
		
		
		//Validation to check that user is not exceeding 168 hours in a period
		NSDateFormatter *checkFormatter = [[NSDateFormatter alloc] init];
		[checkFormatter setDateFormat:@"yyyy-MM-dd"];
		
		
		
		const char *checkSQL = "SELECT ROUND(SumOfMealBreaks + SumOfTimeWorked + SumOfOtherBreaks), StartDate, EndDate FROM VW_TimeEntriesWeekSummary WHERE EmployerId = ? AND ? BETWEEN StartDate AND EndDate";
		
		sqlite3_stmt *checkStmt;
		
		sqlResult = sqlite3_prepare_v2(database, checkSQL, -1, &checkStmt, NULL);
		if(sqlResult != SQLITE_OK) {
			NSAssert1(0, @"Error while creating check statement. '%s'", sqlite3_errmsg(database));
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(checkStmt);
			sqlite3_close(database);
			return sqlResult;
		}
		
		sqlite3_bind_int(checkStmt, 1, timeEntry.employerId);
		sqlite3_bind_text(checkStmt, 2, [[checkFormatter stringFromDate:timeEntry.startTime] UTF8String], -1, SQLITE_TRANSIENT);
		
		[checkFormatter release];
		
		NSTimeInterval timeWorked;
		
		if (sqlite3_step(checkStmt) == SQLITE_ROW) {
			timeWorked = lroundf(sqlite3_column_double(checkStmt, 0));
		} else {
			timeWorked = 0;
		}
		
		unsigned int unitFlags = NSSecondCalendarUnit;
		
		NSDateComponents *conversionInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:timeEntry.startTime toDate:timeEntry.endTime options:0];
		
		NSTimeInterval newTime = [conversionInfo second];
		
		if (newTime + timeWorked > 604800.00) {
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(checkStmt);
			sqlite3_close(database);
			return -100;
		}
		
		sqlite3_finalize(checkStmt);
		//////////////////////////////////////////////////////////////////////
		
		
		const char *sql = "INSERT INTO TimeEntries (EmployerId, StartTime, EndTime, HourlyRate, Comments) VALUES (?, ?, ?, ?, ?);";
		
		sqlite3_stmt *addStmt;
		
		sqlResult = sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL);
		
		if(sqlResult != SQLITE_OK) {
			NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(addStmt);
			sqlite3_close(database);
			return sqlResult;
		}
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
		
		
		sqlite3_bind_int(addStmt, 1, timeEntry.employerId);
		sqlite3_bind_text(addStmt, 2, [[formatter stringFromDate:timeEntry.startTime] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 3, [[formatter stringFromDate:timeEntry.endTime] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_double(addStmt, 4, [timeEntry.hourlyRate doubleValue]);
		sqlite3_bind_text(addStmt, 5, [timeEntry.comments UTF8String], -1, SQLITE_TRANSIENT);
		
		
		[formatter release];
		
		sqlResult = sqlite3_step(addStmt);
		
		if (sqlResult != SQLITE_DONE) {
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(addStmt);
			sqlite3_close(database);
			return sqlResult;
		}
		
		lastRowId = sqlite3_last_insert_rowid(database);
		
		sqlite3_finalize(addStmt);

		//Now we must save the breaks
		
		if (otherBreaks != nil && [otherBreaks count] > 0) {
			const char *sql2 = "INSERT INTO OtherBreaks (TimeEntryId, BreakTime, BreakComments, BreakType) VALUES (?, ?, ?, ?);";
			
			sqlite3_stmt *addStmt2;
			
			sqlResult = sqlite3_prepare_v2(database, sql2, -1, &addStmt2, NULL);
			
			if(sqlResult != SQLITE_OK) {
				NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
				sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
				sqlite3_finalize(addStmt2);
				sqlite3_close(database);
				return sqlResult;
			}
			
			for (OtherBreaks *o in otherBreaks) {
				
				sqlite3_bind_int(addStmt2, 1, lastRowId);
				sqlite3_bind_double(addStmt2, 2, o.breakTime);
				sqlite3_bind_text(addStmt2, 3, [o.comments UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_int(addStmt2, 4, o.breakType);
				
				sqlResult = sqlite3_step(addStmt2);
				
				if (sqlResult != SQLITE_DONE) {
					sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
					sqlite3_finalize(addStmt2);
					sqlite3_close(database);
					return sqlResult;
				}
				sqlite3_reset(addStmt2);
				sqlite3_clear_bindings(addStmt2);
			}
			sqlite3_finalize(addStmt2);
		}
		sqlite3_exec(database, "COMMIT TRANSACTION", 0, 0, 0);
	}
	else {
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		sqlResult = -9999;
	}
	
	sqlite3_close(database);
	return lastRowId;
}

+ (NSInteger)updateTimeEntry:(TimeEntry *)timeEntry withBreaks:(NSMutableArray *)otherBreaks {
	
	WHDAppDelegate *appDelegate = (WHDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	sqlite3 *database;
	NSInteger sqlResult;
	
	if (sqlite3_open([[appDelegate getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		//BEGIN TRANSACTION statement. This is an all or nothing situation.
		sqlite3_exec(database, "BEGIN TRANSACTION;", 0, 0, 0);
		
		const char *sql = "UPDATE TimeEntries SET StartTime = ?, EndTime = ?, HourlyRate = ?, Comments = ? WHERE TimeEntryId = ?;";
		
		sqlite3_stmt *addStmt;
		
		sqlResult = sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL);
		
		if(sqlResult != SQLITE_OK) {
			NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(addStmt);
			sqlite3_close(database);
			return sqlResult;
		}
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
		
		sqlite3_bind_text(addStmt, 1, [[formatter stringFromDate:timeEntry.startTime] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 2, [[formatter stringFromDate:timeEntry.endTime] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_double(addStmt, 3, [timeEntry.hourlyRate doubleValue]);
		sqlite3_bind_text(addStmt, 4, [timeEntry.comments UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(addStmt, 5, timeEntry.timeEntryId);
		
		
		[formatter release];
		
		sqlResult = sqlite3_step(addStmt);
		
		if (sqlResult != SQLITE_DONE) {
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(addStmt);
			sqlite3_close(database);
			return sqlResult;
		}
		
		sqlite3_finalize(addStmt);
		
		NSInteger lastRowId = timeEntry.timeEntryId;
		
		
		//Remove previously saved breaks
		
		const char *sql3 = "DELETE FROM OtherBreaks WHERE TimeEntryId = ?;";
		sqlite3_stmt *addStmt3;
		
		sqlResult = sqlite3_prepare_v2(database, sql3, -1, &addStmt3, NULL);
		if(sqlResult != SQLITE_OK) {
			NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(addStmt3);
			sqlite3_close(database);
			return sqlResult;
		}
		
		sqlite3_bind_int(addStmt3, 1, lastRowId);
		
		sqlResult = sqlite3_step(addStmt3);
		
		if (sqlResult != SQLITE_DONE) {
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(addStmt3);
			sqlite3_close(database);
			return sqlResult;
		}
		
		sqlite3_finalize(addStmt3);
		
		
		//Now we must save the breaks
		
		if (otherBreaks != nil && [otherBreaks count] > 0) {
			const char *sql2 = "INSERT INTO OtherBreaks (TimeEntryId, BreakTime, BreakComments, BreakType) VALUES (?, ?, ?, ?);";
			
			sqlite3_stmt *addStmt2;
			
			sqlResult = sqlite3_prepare_v2(database, sql2, -1, &addStmt2, NULL);
			
			if(sqlResult != SQLITE_OK) {
				NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
				sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
				sqlite3_finalize(addStmt2);
				sqlite3_close(database);
				return sqlResult;
			}
			
			for (OtherBreaks *o in otherBreaks) {
				
				sqlite3_bind_int(addStmt2, 1, lastRowId);
				sqlite3_bind_double(addStmt2, 2, o.breakTime);
				sqlite3_bind_text(addStmt2, 3, [o.comments UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_int(addStmt2, 4, o.breakType);
				
				sqlResult = sqlite3_step(addStmt2);
				
				if (sqlResult != SQLITE_DONE) {
					sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
					sqlite3_finalize(addStmt2);
					sqlite3_close(database);
					return sqlResult;
				}
				sqlite3_reset(addStmt2);
				sqlite3_clear_bindings(addStmt2);
			}
			sqlite3_finalize(addStmt2);
		}
		
		
		//Validation to check that user is not exceeding 168 hours in a period
		NSDateFormatter *checkFormatter = [[NSDateFormatter alloc] init];
		[checkFormatter setDateFormat:@"yyyy-MM-dd"];
		
		
		
		const char *checkSQL = "SELECT ROUND(SumOfMealBreaks + SumOfTimeWorked + SumOfOtherBreaks), StartDate, EndDate FROM VW_TimeEntriesWeekSummary WHERE EmployerId = ? AND ? BETWEEN StartDate AND EndDate";
		
		sqlite3_stmt *checkStmt;
		
		sqlResult = sqlite3_prepare_v2(database, checkSQL, -1, &checkStmt, NULL);
		if(sqlResult != SQLITE_OK) {
			NSAssert1(0, @"Error while creating check statement. '%s'", sqlite3_errmsg(database));
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(checkStmt);
			sqlite3_close(database);
			return sqlResult;
		}
		
		sqlite3_bind_int(checkStmt, 1, timeEntry.employerId);
		sqlite3_bind_text(checkStmt, 2, [[checkFormatter stringFromDate:timeEntry.startTime] UTF8String], -1, SQLITE_TRANSIENT);
		
		[checkFormatter release];
		
		if (sqlite3_step(checkStmt) == SQLITE_ROW) {
			NSTimeInterval timeWorked = lroundf(sqlite3_column_double(checkStmt, 0));
			NSLog(@"%f", timeWorked);
			
			if (timeWorked > 604800.00) {
				sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
				sqlite3_finalize(checkStmt);
				sqlite3_close(database);
				return -100;
			}
		}
		
		sqlite3_finalize(checkStmt);
		//////////////////////////////////////////////////////////////////////
		
		
		sqlite3_exec(database, "COMMIT TRANSACTION", 0, 0, 0);
	}
	else {
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		sqlResult = -9999;
	}
	
	sqlite3_close(database);
	return sqlResult;
}

+ (NSArray *)getTimeEntriesForDay:(NSString *)date forEmployer:(NSInteger)employerId {
	
	WHDAppDelegate *appDelegate = (WHDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	sqlite3 *database;
	NSInteger sqlResult;
	
	NSMutableArray *results = [NSMutableArray array];
	
	if (sqlite3_open([[appDelegate getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		NSMutableString* datesString = [NSMutableString string];
		
		[datesString appendString:@"'"];
		[datesString appendString:date];
		[datesString appendString:@" 00:00'"];
		[datesString appendString:@" AND '"];
		[datesString appendString:date];
		[datesString appendString:@" 23:59'"];
		
		NSString *query = [NSMutableString stringWithFormat:@"SELECT TimeEntryId, StartTime, EndTime FROM TimeEntries WHERE EmployerId = %d AND StartTime BETWEEN %@;", employerId, datesString];
		sqlite3_stmt *stmt;
		
		sqlResult = sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, NULL);
		
		if(sqlResult != SQLITE_OK) {
			NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(stmt);
			sqlite3_close(database);
			return nil;
		}
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
		
		while(sqlite3_step(stmt) == SQLITE_ROW) {
			
			TimeEntry *te = [[TimeEntry alloc]init];
			
			te.timeEntryId = sqlite3_column_int(stmt, 0);
			
			char *startTime = (char *)sqlite3_column_text(stmt, 1);
			if (startTime != NULL) {
				te.startTime = [formatter dateFromString:[NSString stringWithUTF8String:startTime]];
			}
			
			char *endTime = (char *)sqlite3_column_text(stmt, 2);
			if (endTime != NULL) {
				te.endTime = [formatter dateFromString:[NSString stringWithUTF8String:endTime]];
			}
			
			//te.mealBreak = sqlite3_column_double(stmt, 3);
			//te.hourlyRate = [NSNumber numberWithDouble:sqlite3_column_double(stmt, 4)];
			
			//char *comments = (char *)sqlite3_column_text(stmt, 5);
			//if (comments != NULL) {
			//	te.comments = [NSString stringWithUTF8String:comments];
			//}
			
			[results addObject:te];
			[te release];
		}
		
		[formatter release];
		sqlite3_finalize(stmt);
	}
	else {
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		sqlResult = -9999;
		return nil;
	}
	
	sqlite3_close(database);
	return results;
}

+ (TimeEntry *)getTimeEntry:(NSInteger)timeEntryId {
	
	WHDAppDelegate *appDelegate = (WHDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	sqlite3 *database;
	NSInteger sqlResult;
	
	TimeEntry *te;
	
	if (sqlite3_open([[appDelegate getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		const char *query = "SELECT TimeEntryId, EmployerId, StartTime, EndTime, HourlyRate, Comments FROM TimeEntries WHERE TimeEntryId = ?";
		sqlite3_stmt *stmt;
		
		sqlResult = sqlite3_prepare_v2(database, query, -1, &stmt, NULL);
		
		if(sqlResult != SQLITE_OK) {
			NSAssert1(0, @"Error while creating select statement. '%s'", sqlite3_errmsg(database));
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(stmt);
			sqlite3_close(database);
			return nil;
		}
		
		sqlite3_bind_int(stmt, 1, timeEntryId);
		
		if(sqlite3_step(stmt) == SQLITE_ROW) {
			
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
			
			te = [[[TimeEntry alloc]init]autorelease];
			
			te.timeEntryId = sqlite3_column_int(stmt, 0);
			te.employerId = sqlite3_column_int(stmt, 1);
			
			char *startTime = (char *)sqlite3_column_text(stmt, 2);
			if (startTime != NULL) {
				te.startTime = [formatter dateFromString:[NSString stringWithUTF8String:startTime]];
			}
			
			char *endTime = (char *)sqlite3_column_text(stmt, 3);
			if (endTime != NULL) {
				te.endTime = [formatter dateFromString:[NSString stringWithUTF8String:endTime]];
			}
			
			te.hourlyRate = [NSNumber numberWithDouble:sqlite3_column_double(stmt, 4)];
			
			char *comments = (char *)sqlite3_column_text(stmt, 5);
			if (comments != NULL) {
				te.comments = [NSString stringWithUTF8String:comments];
			}
			
			[formatter release];
		}
		
		sqlite3_finalize(stmt);
	}
	else {
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		sqlResult = -9999;
		return nil;
	}
	
	sqlite3_close(database);
	return te;
}

+ (NSMutableArray *)getOtherBreaksForTimeEntryId:(NSInteger)timeEntryId {
	
	WHDAppDelegate *appDelegate = (WHDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSMutableArray *mealArray = [NSMutableArray array];
	NSMutableArray *otherArray = [NSMutableArray array];
	
	sqlite3 *database;
	NSInteger sqlResult;
	
	NSMutableArray *results = [NSMutableArray array];
	
	if (sqlite3_open([[appDelegate getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		NSString *query = @"SELECT OtherBreakId, TimeEntryId, BreakTime, BreakComments, BreakType FROM OtherBreaks WHERE TimeEntryId = ?;";
		sqlite3_stmt *stmt;
		
		sqlResult = sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, NULL);
		
		if(sqlResult != SQLITE_OK) {
			NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(stmt);
			sqlite3_close(database);
			return nil;
		}
		
		sqlite3_bind_int(stmt, 1, timeEntryId);
		
		
		while(sqlite3_step(stmt) == SQLITE_ROW) {
			
			OtherBreaks *ob = [[OtherBreaks alloc]initWithPrimaryKey:sqlite3_column_int(stmt, 0)];
	
			ob.timeEntryId = sqlite3_column_int(stmt, 1);
			ob.breakTime = sqlite3_column_double(stmt, 2);
			
			
			char *comments = (char *)sqlite3_column_text(stmt, 3);
			if (comments != NULL) {
				ob.comments = [NSString stringWithUTF8String:comments];
			}
			ob.breakType = sqlite3_column_int(stmt, 4);
			
			if ( ob.breakType == 0) {
				[mealArray addObject:ob];
			} else {
				[otherArray addObject:ob];
			}
			
			[ob release];
		}
		
		sqlite3_finalize(stmt);
	}
	else {
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		sqlResult = -9999;
		return nil;
	}
	
	sqlite3_close(database);
	
	[results addObject:mealArray];
	[results addObject:otherArray];
	return results;
}

+ (NSInteger)deleteTimeEntry:(TimeEntry *)t {
	WHDAppDelegate *appDelegate = (WHDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	sqlite3 *database;
	NSInteger sqlResult;
	
	if (sqlite3_open([[appDelegate getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		//BEGIN TRANSACTION statement. This is an all or nothing situation.
		sqlite3_exec(database, "BEGIN TRANSACTION;", 0, 0, 0);
		
		const char *sql = "DELETE FROM TimeEntries WHERE TimeEntryId = ?;";
		
		sqlite3_stmt *delStmt;
		
		sqlResult = sqlite3_prepare_v2(database, sql, -1, &delStmt, NULL);
		
		if(sqlResult != SQLITE_OK) {
			NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(delStmt);
			sqlite3_close(database);
			return sqlResult;
		}
		
		sqlite3_bind_int(delStmt, 1, t.timeEntryId);
		
		sqlResult = sqlite3_step(delStmt);
		
		if (sqlResult != SQLITE_DONE) {
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(delStmt);
			sqlite3_close(database);
			return sqlResult;
		}
		
		sqlite3_finalize(delStmt);
		
		//Now we must commit the transaction
		//The DB triggers will take care of deleting child table rows
		
		sqlite3_exec(database, "COMMIT TRANSACTION", 0, 0, 0);
	}
	else {
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		sqlResult = -9999;
	}
	
	sqlite3_close(database);
	return sqlResult;
}

+ (NSInteger)deleteTimeEntriesForMonth:(NSString *)month employer:(NSInteger)employerId{
	WHDAppDelegate *appDelegate = (WHDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	sqlite3 *database;
	NSInteger sqlResult;
	
	NSString *startDate;
	NSString *endDate;
	
	if (sqlite3_open([[appDelegate getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		NSString *query = @"SELECT StartDate, EndDate FROM VW_TimeSpanForMonth WHERE EmployerId = ? AND StartMonth = ?;";
		sqlite3_stmt *stmt;
		
		sqlResult = sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, NULL);
		
		if(sqlResult != SQLITE_OK) {
			NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(stmt);
			sqlite3_close(database);
			return -9999;
		}
		
		sqlite3_bind_int(stmt, 1, employerId);
		sqlite3_bind_text(stmt, 2, [month UTF8String], -1, SQLITE_TRANSIENT);
		
		
		if (sqlite3_step(stmt) == SQLITE_ROW) {
			char *start = (char *)sqlite3_column_text(stmt, 0);
			if (start != NULL) {
				startDate = [NSString stringWithUTF8String:start];
			}
				 
			char *end = (char *)sqlite3_column_text(stmt, 1);
			if (end != NULL) {
				 endDate = [NSString stringWithUTF8String:end];
			}
		}
		
		sqlite3_finalize(stmt);
	}
	else {
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		sqlResult = -9999;
		return sqlResult;
	}
	
	sqlite3_close(database);
	
	if (startDate != nil && endDate != nil) {
		return [self deleteTimeEntriesForEmployer:employerId fromDay:startDate toDay:endDate];
	} else {
		return 0;
	}
	
}

+ (NSInteger)deleteTimeEntriesForEmployer:(NSInteger)employerId fromDay:(NSString *)fDay toDay:(NSString *)tDay {
	WHDAppDelegate *appDelegate = (WHDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	sqlite3 *database;
	NSInteger sqlResult;
	
	if (sqlite3_open([[appDelegate getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		NSMutableString* datesString = [NSMutableString string];
		
		[datesString appendString:@"'"];
		[datesString appendString:fDay];
		[datesString appendString:@" 00:00'"];
		[datesString appendString:@" AND '"];
		[datesString appendString:tDay];
		[datesString appendString:@" 23:59'"];
		
				
		NSString *query = [NSMutableString stringWithFormat:@"DELETE FROM TimeEntries WHERE EmployerId = %d AND StartTime BETWEEN %@;", employerId, datesString];
		
		//BEGIN TRANSACTION statement. This is an all or nothing situation.
		sqlite3_exec(database, "BEGIN TRANSACTION;", 0, 0, 0);
		
		
		sqlite3_stmt *delStmt;
		
		sqlResult = sqlite3_prepare_v2(database, [query UTF8String], -1, &delStmt, NULL);
		
		if(sqlResult != SQLITE_OK) {
			NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(delStmt);
			sqlite3_close(database);
			return sqlResult;
		}
				
		sqlResult = sqlite3_step(delStmt);
		
		if (sqlResult != SQLITE_DONE) {
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(delStmt);
			sqlite3_close(database);
			return sqlResult;
		}
		
		sqlite3_finalize(delStmt);
		
		//Now we must commit the transaction
		//The DB triggers will take care of deleting child table rows
		
		sqlite3_exec(database, "COMMIT TRANSACTION", 0, 0, 0);
	}
	else {
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		sqlResult = -9999;
	}
	
	sqlite3_close(database);
	return sqlResult;
}

+ (NSArray *)exportTimeEntriesForEmployers:(NSArray *)employerIds FromDate:(NSDate *)fromDate ToDate:(NSDate *)toDate {
	
	WHDAppDelegate *appDelegate = (WHDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	sqlite3 *database;
	NSInteger sqlResult;
	
	NSMutableArray *finalArray = [NSMutableArray array];
	NSArray *row;
	
	if (sqlite3_open([[appDelegate getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		NSMutableString *inString = nil;
		
		if (employerIds != nil && [employerIds count] > 0) {
			inString =[NSMutableString string];
			BOOL firstColumn = YES;
			for (Employer *e in employerIds) {
				NSString *delimiter = !firstColumn?@",":@"";
				
				[inString appendFormat:@"%@%d", delimiter, e.employerId];
				firstColumn = NO;
			}
		}
		
		NSMutableString* datesString = nil;
		
		if (fromDate != nil && toDate != nil) {
			datesString = [NSMutableString string];
			
			NSDateFormatter *formatter = [[[NSDateFormatter alloc]init]autorelease];
			[formatter setDateFormat:@"yyyy-MM-dd"];
			
			[datesString appendString:@"'"];
			[datesString appendString:[formatter stringFromDate:fromDate]];
			[datesString appendString:@" 00:00'"];
			
			[datesString appendString:@" AND '"];
			[datesString appendString:[formatter stringFromDate:toDate]];
			[datesString appendString:@" 23:59'"];
		}
		
		NSMutableString *query = [NSMutableString stringWithString:@"SELECT EmployerName, StartTime, EndTime, TimeSpan, MealBreakTime, HourlyRate AS HourlyRate, BreakTime, TimeWorked, Comments, MealBreakComments, OtherBreakComments, Pay FROM VW_ExportTimeEntries"];
		
		
		if (inString != nil || datesString != nil) {
			[query appendString:@" WHERE "];
		}
		
		if (inString != nil) {
			[query appendFormat:@"EmployerId IN (%@)", inString];
		}
		
		if (datesString != nil) {
			if (inString != nil) {
				[query appendString:@" AND "];
			}
			[query appendFormat:@"StartTime BETWEEN %@", datesString];
		}
		
		[query appendString:@";"];
		
		sqlite3_stmt *stmt;
		
		sqlResult = sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, NULL);
		
		if(sqlResult != SQLITE_OK) {
			NSAssert1(0, @"Error while creating select statement. '%s'", sqlite3_errmsg(database));
			sqlite3_finalize(stmt);
			sqlite3_close(database);
			return nil;
		}
		
		//header row
		row = [NSArray arrayWithObjects:NSLocalizedString(@"Employer",@"Employer"),
			   NSLocalizedString(@"Started Work",@"Started Work"),
			   NSLocalizedString(@"Stopped Work",@"Stopped Work"),
			   NSLocalizedString(@"Hourly Rate",@"Hourly Rate"),
			   NSLocalizedString(@"Meal Breaks",@"Meal Breaks"),
			   NSLocalizedString(@"Meal Break Comments",@"Meal Break Comments"),
			   NSLocalizedString(@"Other Breaks",@"Other Breaks"),
			   NSLocalizedString(@"Other Break Comments",@"Other Break Comments"),
			   NSLocalizedString(@"Sub-Total", @"Sub-Total"),
			   NSLocalizedString(@"Total Work Hours",@"Total Work Hours"),			   
			   NSLocalizedString(@"Gross Pay",@"Gross Pay"),
			   NSLocalizedString(@"Comments",@"Comments"),
			   nil];
		[finalArray addObject:row];
		
		NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
		[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[currencyFormatter setCurrencyCode:@"USD"];
		[currencyFormatter setNegativeFormat:@"-¤#,##0.00"];
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		
		while(sqlite3_step(stmt) == SQLITE_ROW) {
			char *employerName = (char *)sqlite3_column_text(stmt, 0);
			char *startTime = (char *)sqlite3_column_text(stmt, 1);
			char *endTime = (char *)sqlite3_column_text(stmt, 2);
			NSTimeInterval timeSpan = lroundf(sqlite3_column_double(stmt, 3));
			NSTimeInterval mealBreaks = lroundf(sqlite3_column_double(stmt, 4));
			NSNumber *hourlyRate = [NSNumber numberWithDouble:sqlite3_column_double(stmt, 5)];
			NSTimeInterval breakTime = lroundf(sqlite3_column_double(stmt, 6));
			NSTimeInterval timeWorked = lroundf(sqlite3_column_double(stmt, 7));
			char *comments = (char *)sqlite3_column_text(stmt, 8);
			char *mb_comments = (char *)sqlite3_column_text(stmt, 9);
			char *ob_comments = (char *)sqlite3_column_text(stmt, 10);
			NSNumber *pay = [NSNumber numberWithDouble:sqlite3_column_double(stmt, 11)];
			
			NSString *c1, *c2, *c3, *c4, *c5, *c6, *c7, *c8, *c9, *c10, *c11, *c12;
			
			c1 = [NSString stringWithUTF8String:employerName];
			
			[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
			NSDate *dt = [dateFormatter dateFromString:[NSString stringWithUTF8String:startTime]];
			[dateFormatter setDateFormat:@"MM/dd/yyyy h:mm a"];
			c2 = [dateFormatter stringFromDate:dt];
			
			[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
			dt = [dateFormatter dateFromString:[NSString stringWithUTF8String:endTime]];
			[dateFormatter setDateFormat:@"MM/dd/yyyy h:mm a"];
			c3 = [dateFormatter stringFromDate:dt];
			
			c4 = [DateConversion timeIntervalToHoursAndMinutes:timeSpan];
			c5 = [DateConversion timeIntervalToHoursAndMinutes:mealBreaks];
			c6 = [DateConversion timeIntervalToHoursAndMinutes:breakTime];
			c7 = [DateConversion timeIntervalToHoursAndMinutes:timeWorked];
			c8 = [currencyFormatter stringFromNumber:hourlyRate];
		
			//Comments are the only ones that can be null so lets check to be safe
			if (comments != NULL) {
				c9 = [NSString stringWithUTF8String:comments];
			} else {
				c9 = @"";
			}
			
			if (mb_comments != NULL) {
				c10 = [NSString stringWithUTF8String:mb_comments];
			} else {
				c10 = @"";
			}
			
			if (ob_comments != NULL) {
				c11 = [NSString stringWithUTF8String:ob_comments];
			} else {
				c11 = @"";
			}
			
			c12 = [currencyFormatter stringFromNumber:pay];
			
			row = [NSArray arrayWithObjects:c1, c2, c3, c8, c5, c10, c6, c11, c4, c7, c12, c9, nil];
			[finalArray addObject:row];
		}
		[currencyFormatter release];
		[dateFormatter release];
		
		sqlite3_finalize(stmt);
	}
	else {
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		return nil;
	}
	
	sqlite3_close(database);
	return finalArray;
}

+ (NSMutableArray *)getClock {
	WHDAppDelegate *appDelegate = (WHDAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableArray *clockArray = [NSMutableArray array];
	
	
	sqlite3 *database;
	
	if (sqlite3_open([[appDelegate getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		const char *sql = "SELECT ClockId, EmployerId, StartTime, EndTime, Comments, Type FROM Clock";
		
		sqlite3_stmt *selectstmt;
		
		if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {
			
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
			
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
				NSInteger primaryKey = sqlite3_column_int(selectstmt, 0);
				Clock *clock = [[Clock alloc]initWithPrimaryKey:primaryKey];
				
				clock.employerId = sqlite3_column_int(selectstmt, 1);
				
				char *startTime = (char *)sqlite3_column_text(selectstmt, 2);
				if (startTime != NULL) {
					clock.startTime = [formatter dateFromString:[NSString stringWithUTF8String:startTime]];
				}
				
				char *endTime = (char *)sqlite3_column_text(selectstmt, 3);
				if (endTime != NULL) {
					clock.endTime = [formatter dateFromString:[NSString stringWithUTF8String:endTime]];
				}
				
				char *comments = (char *)sqlite3_column_text(selectstmt, 4);
				if (comments != NULL) {
					clock.comments = [NSString stringWithUTF8String:comments];
				}
				
				clock.clockType = sqlite3_column_int(selectstmt, 5);
				
				[clockArray addObject:clock];
				[clock release];
			}
			[formatter release];
		}
		else {
			sqlite3_close(database);
			NSAssert1(0, @"Failed to load clock from database with message '%s'.", sqlite3_errmsg(database));
		}
		sqlite3_finalize(selectstmt);
	}
	else {
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
	}
	
	sqlite3_close(database);
	return clockArray;
}

+ (void)insertClock:(Clock *)clock {
	WHDAppDelegate *appDelegate = (WHDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	sqlite3 *database;
	NSInteger sqlResult;
	
	if (sqlite3_open([[appDelegate getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		//BEGIN TRANSACTION statement. This is an all or nothing situation.
		sqlite3_exec(database, "BEGIN TRANSACTION;", 0, 0, 0);
		
		const char *sql = "INSERT INTO Clock(EmployerId, StartTime, EndTime, Comments, Type) VALUES (?, ?, ?, ?, ?);";
		
		sqlite3_stmt *addStmt;
		
		sqlResult = sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL);
		
		if(sqlResult != SQLITE_OK) {
			NSAssert1(0, @"Error while creating insert statement. '%s'", sqlite3_errmsg(database));
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(addStmt);
			sqlite3_close(database);
			return;
		}
		
			
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
		
		sqlite3_bind_int(addStmt, 1, clock.employerId);
		sqlite3_bind_text(addStmt, 2, [[formatter stringFromDate:clock.startTime] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 3, [[formatter stringFromDate:clock.endTime] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 4, [clock.comments UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(addStmt, 5, clock.clockType);
		
		[formatter release];
		
		sqlResult = sqlite3_step(addStmt);
		
		if (sqlResult != SQLITE_DONE) {
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(addStmt);
			sqlite3_close(database);
			return;
		}
		
		sqlite3_exec(database, "COMMIT TRANSACTION", 0, 0, 0);
		sqlite3_finalize(addStmt);
	}
	else {
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
	}
	
	sqlite3_close(database);
}

+ (void)stopClock:(ClockType)clockType {
	WHDAppDelegate *appDelegate = (WHDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	sqlite3 *database;
	NSInteger sqlResult;
	
	if (sqlite3_open([[appDelegate getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		//BEGIN TRANSACTION statement. This is an all or nothing situation.
		sqlite3_exec(database, "BEGIN TRANSACTION;", 0, 0, 0);
		
		const char *sql = "UPDATE Clock SET EndTime = ? WHERE Type = ? AND EndTime IS NULL;";
		
		sqlite3_stmt *addStmt;
		
		sqlResult = sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL);
		
		if(sqlResult != SQLITE_OK) {
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(addStmt);
			sqlite3_close(database);
			return;
		}
			
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
		
		sqlite3_bind_text(addStmt, 1, [[formatter stringFromDate:[NSDate date]] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(addStmt, 2, clockType);
		
		[formatter release];
		
		sqlResult = sqlite3_step(addStmt);
		
		if (sqlResult != SQLITE_DONE) {
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(addStmt);
			sqlite3_close(database);
			return;
		}
		
		sqlite3_exec(database, "COMMIT TRANSACTION", 0, 0, 0);
		sqlite3_finalize(addStmt);
	}
	else {
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_close(database);
}

+ (void)resetClock{
	WHDAppDelegate *appDelegate = (WHDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	sqlite3 *database;
	NSInteger sqlResult;
	
	if (sqlite3_open([[appDelegate getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		//BEGIN TRANSACTION statement. This is an all or nothing situation.
		sqlite3_exec(database, "BEGIN TRANSACTION;", 0, 0, 0);
		
		const char *sql = "DELETE FROM Clock;";
		
		sqlite3_stmt *stmt;
		
		sqlResult = sqlite3_prepare_v2(database, sql, -1, &stmt, NULL);
		
		if(sqlResult != SQLITE_OK) {
			NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(stmt);
			sqlite3_close(database);
			return;
		}
		
		sqlResult = sqlite3_step(stmt);
		
		if (sqlResult != SQLITE_DONE) {
			sqlite3_exec(database, "ROLLBACK TRANSACTION", 0, 0, 0); // Rollback Transaction
			sqlite3_finalize(stmt);
			sqlite3_close(database);
			return;
		}
		
		sqlite3_exec(database, "COMMIT TRANSACTION", 0, 0, 0);
		sqlite3_finalize(stmt);
	}
	else {
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_close(database);
}
@end
