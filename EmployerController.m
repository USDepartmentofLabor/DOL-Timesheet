//
//  EmployerController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "EmployerController.h"
#import "WHDAppDelegate.h"
#import <sqlite3.h>
#import "Employer.h"

@implementation EmployerController

+ (NSMutableArray *)getEmployers {
	WHDAppDelegate *appDelegate = (WHDAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableArray *employersArray = [NSMutableArray array];
	
	
	sqlite3 *database;
	
	if (sqlite3_open([[appDelegate getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		const char *sql = "SELECT EmployerId, EmployerName, StartOfWorkWeek, HourlyRate FROM Employers";
		
		sqlite3_stmt *selectstmt;
		
		if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {
			
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
			
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
				NSInteger primaryKey = sqlite3_column_int(selectstmt, 0);
				Employer *emp = [[Employer alloc]initWithPrimaryKey:primaryKey];
				emp.employerName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 1)];
				emp.startOfWorkWeek = sqlite3_column_int(selectstmt, 2);
				emp.hourlyRate = [NSNumber numberWithDouble:sqlite3_column_double(selectstmt, 3)];
				
				[employersArray addObject:emp];
				
				[emp release];
			}
			[formatter release];
		}
		else {
			sqlite3_close(database);
			NSAssert1(0, @"Failed to load employers from database with message '%s'.", sqlite3_errmsg(database));
		}
		sqlite3_finalize(selectstmt);
	}
	else {
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
	}
	
	sqlite3_close(database);
	return employersArray;
}

+ (NSInteger)addEmployer:(Employer *)e {
	WHDAppDelegate *appDelegate = (WHDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	sqlite3 *database;
	NSInteger sqlResult;
	
	if (sqlite3_open([[appDelegate getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		const char *sql = "INSERT INTO Employers (EmployerName, StartOfWorkWeek, HourlyRate) VALUES (?, ?, ?)";
		
		sqlite3_stmt *addStmt;
		
		sqlResult = sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL);
		
		if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK) {
			
			NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
			sqlResult = -8888;
		}
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
		
		sqlite3_bind_text(addStmt, 1, [e.employerName UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(addStmt, 2, e.startOfWorkWeek);
		sqlite3_bind_double(addStmt, 3, [e.hourlyRate doubleValue]);
		
		[formatter release];
		
		sqlResult = sqlite3_step(addStmt);
		
		sqlite3_finalize(addStmt);
	}
	else {
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		sqlResult = -9999;
	}
	sqlite3_close(database);
	return sqlResult;
}

+ (NSInteger)updateEmployer:(Employer *)e {
	WHDAppDelegate *appDelegate = (WHDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	sqlite3 *database;
	NSInteger sqlResult;
	
	if (sqlite3_open([[appDelegate getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		const char *sql = "UPDATE Employers SET EmployerName=?, StartOfWorkWeek=?, HourlyRate=? WHERE EmployerId=?";
		
		sqlite3_stmt *addStmt;
		
		sqlResult = sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL);
		
		if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK) {
			
			NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
			sqlResult = -8888;
		}
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
		
		sqlite3_bind_text(addStmt, 1, [e.employerName UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(addStmt, 2, e.startOfWorkWeek);
		sqlite3_bind_double(addStmt, 3, [e.hourlyRate doubleValue]);
		sqlite3_bind_int(addStmt, 4, e.employerId);
		
		[formatter release];
		
		sqlResult = sqlite3_step(addStmt);
		
		sqlite3_finalize(addStmt);
	}
	else {
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		sqlResult = -9999;
	}
	sqlite3_close(database);
	return sqlResult;
}

+ (NSInteger)deleteEmployer:(Employer *)e {
	WHDAppDelegate *appDelegate = (WHDAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	sqlite3 *database;
	NSInteger sqlResult;
	
	if (sqlite3_open([[appDelegate getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		const char *sql = "DELETE FROM Employers WHERE EmployerId = ?";
		
		sqlite3_stmt *delStmt;
		
		sqlResult = sqlite3_prepare_v2(database, sql, -1, &delStmt, NULL);
		
		if(sqlite3_prepare_v2(database, sql, -1, &delStmt, NULL) != SQLITE_OK) {
			
			NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
			sqlResult = -8888;
		}
		
		sqlite3_bind_int(delStmt, 1, e.employerId);
		
		sqlResult = sqlite3_step(delStmt);
		
		sqlite3_finalize(delStmt);
	}
	else {
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		sqlResult = -9999;
	}
	sqlite3_close(database);
	return sqlResult;
}

@end
