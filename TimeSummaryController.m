//
//  TimeSummaryController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "TimeSummaryController.h"
#import "WHDAppDelegate.h"
#import "TimeSummary.h"
#import <sqlite3.h>


@implementation TimeSummaryController: NSObject {
}

+ (NSMutableArray *)getTimeSummaryByDay {
	WHDAppDelegate *appDelegate = (WHDAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableArray *timeArray = nil;
	
	NSMutableArray *listOfItems = [[[NSMutableArray alloc]init]autorelease];
	
	NSString *currentDay = nil;
	
	sqlite3 *database;
	
	if (sqlite3_open([[appDelegate getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		const char *sql = "SELECT EmployerId, EmployerName, StartDate, SumOfMealBreaks, SumOfTimeWorked, SumOfOtherBreaks, Pay FROM VW_TimeEntriesByDay";
		
		sqlite3_stmt *selectstmt;
		
		if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {
			
			
			
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
				
				TimeSummary *ts = [[TimeSummary alloc]init];
				
				ts.employerId = sqlite3_column_int(selectstmt, 0);
				
				char *name = (char *)sqlite3_column_text(selectstmt, 1);
				if (name != NULL) {
					ts.employerName = [NSString stringWithUTF8String:name];
				}
				 
				char *startDate = (char *)sqlite3_column_text(selectstmt, 2);
				if (startDate != NULL) {
					ts.startDate = [NSString stringWithUTF8String:startDate];
				}
				
				ts.sumOfMealBreaks = lroundf(sqlite3_column_double(selectstmt, 3));
				ts.sumOfTimeWorked = lroundf(sqlite3_column_double(selectstmt, 4));
				ts.sumOfOtherBreaks = lroundf(sqlite3_column_double(selectstmt, 5));
				ts.pay = sqlite3_column_double(selectstmt, 6);
				
				if (currentDay == nil) {
					currentDay = ts.startDate;
					timeArray = [[NSMutableArray alloc]initWithObjects:ts, nil];
				} else {
					if ([currentDay isEqualToString:ts.startDate]) {
						[timeArray addObject:ts];
					} else {
						NSDictionary *dictionary = [NSDictionary dictionaryWithObject:timeArray forKey:@"Times"];
						[listOfItems addObject:dictionary];
						
						[timeArray release];
						timeArray = [[NSMutableArray alloc]initWithObjects:ts, nil];
						
						currentDay = ts.startDate;
					}
				}
				
				[ts release];
			}
			
			//Add last one
			if (timeArray != nil) {
				NSDictionary *dictionary = [NSDictionary dictionaryWithObject:timeArray forKey:@"Times"];
				[listOfItems addObject:dictionary];
				
				[timeArray release];				
			}
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
	return listOfItems;
}

+ (NSMutableArray *)getTimeSummaryByMonth {
	WHDAppDelegate *appDelegate = (WHDAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableArray *timeArray = nil;
	
	NSMutableArray *listOfItems = [[[NSMutableArray alloc]init]autorelease];
	
	NSString *currentDay = nil;
	
	sqlite3 *database;
	
	if (sqlite3_open([[appDelegate getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		const char *sql = "SELECT EmployerId, EmployerName, StartDate, SumOfMealBreaks, SumOfTimeWorked, SumOfOtherBreaks, Pay FROM VW_TimeEntriesByMonth";
		
		sqlite3_stmt *selectstmt;
		
		if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {
			
			
			
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
				
				TimeSummary *ts = [[TimeSummary alloc]init];
				
				ts.employerId = sqlite3_column_int(selectstmt, 0);
				
				char *name = (char *)sqlite3_column_text(selectstmt, 1);
				if (name != NULL) {
					ts.employerName = [NSString stringWithUTF8String:name];
				}
				
				char *startDate = (char *)sqlite3_column_text(selectstmt, 2);
				if (startDate != NULL) {
					ts.startDate = [NSString stringWithUTF8String:startDate];
				}
				
				ts.sumOfMealBreaks = lroundf(sqlite3_column_double(selectstmt, 3));
				ts.sumOfTimeWorked = lroundf(sqlite3_column_double(selectstmt, 4));
				ts.sumOfOtherBreaks = lroundf(sqlite3_column_double(selectstmt, 5));
				ts.pay = sqlite3_column_double(selectstmt, 6);
				
				if (currentDay == nil) {
					currentDay = ts.startDate;
					timeArray = [[NSMutableArray alloc]initWithObjects:ts, nil];
				} else {
					if ([currentDay isEqualToString:ts.startDate]) {
						[timeArray addObject:ts];
					} else {
						NSDictionary *dictionary = [NSDictionary dictionaryWithObject:timeArray forKey:@"Times"];
						[listOfItems addObject:dictionary];
						
						[timeArray release];
						timeArray = [[NSMutableArray alloc]initWithObjects:ts, nil];
						
						currentDay = ts.startDate;
					}
				}
				
				[ts release];
			}
			
			//Add last one
			if (timeArray != nil) {
				NSDictionary *dictionary = [NSDictionary dictionaryWithObject:timeArray forKey:@"Times"];
				[listOfItems addObject:dictionary];
				
				[timeArray release];				
			}
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
	return listOfItems;
}

+ (NSMutableArray *)getTimeSummaryByWeek {
	WHDAppDelegate *appDelegate = (WHDAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableArray *timeArray = nil;
	
	NSMutableArray *listOfItems = [[[NSMutableArray alloc]init]autorelease];
	
	NSString *currentDay = nil;
	
	sqlite3 *database;
	
	if (sqlite3_open([[appDelegate getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		const char *sql = "SELECT EmployerId, EmployerName, WeekStart, StartDate, EndDate, SumOfMealBreaks, SumOfTimeWorked, SumOfOtherBreaks, HourlyRate, RegularTime, OverTime, Pay FROM VW_TimeEntriesWeekSummary";
		
		sqlite3_stmt *selectstmt;
		
		if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {
			
			
			TimeSummary *ts;
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
				
				ts = [[TimeSummary alloc]init];
				
				ts.employerId = sqlite3_column_int(selectstmt, 0);
				
				char *name = (char *)sqlite3_column_text(selectstmt, 1);
				if (name != NULL) {
					ts.employerName = [NSString stringWithUTF8String:name];
				}
				
				char *weekStart = (char *)sqlite3_column_text(selectstmt, 2);
				if (weekStart != NULL) {
					ts.weekStart = [NSString stringWithUTF8String:weekStart];
				}
				
				char *startDate = (char *)sqlite3_column_text(selectstmt, 3);
				if (startDate != NULL) {
					ts.startDate = [NSString stringWithUTF8String:startDate];
				}
				
				char *endDate = (char *)sqlite3_column_text(selectstmt, 4);
				if (endDate != NULL) {
					ts.endDate = [NSString stringWithUTF8String:endDate];
				}
				
				ts.sumOfMealBreaks = lroundf(sqlite3_column_double(selectstmt, 5));
				ts.sumOfTimeWorked = lroundf(sqlite3_column_double(selectstmt, 6));
				ts.sumOfOtherBreaks = lroundf(sqlite3_column_double(selectstmt, 7));
				
				ts.hourlyRate = sqlite3_column_double(selectstmt, 8);
				ts.regularTime = lroundf(sqlite3_column_double(selectstmt, 9));
				ts.overTime = lroundf(sqlite3_column_double(selectstmt, 10));
				ts.pay = sqlite3_column_double(selectstmt, 11);
				
				if (currentDay == nil) {
					currentDay = ts.weekStart;
					timeArray = [[NSMutableArray alloc]initWithObjects:ts, nil];
				} else {
					if ([currentDay isEqualToString:ts.weekStart]) {
						[timeArray addObject:ts];
					} else {
						NSDictionary *dictionary = [NSDictionary dictionaryWithObject:timeArray forKey:@"Times"];
						[listOfItems addObject:dictionary];
						
						[timeArray release];
						timeArray = [[NSMutableArray alloc]initWithObjects:ts, nil];
						
						currentDay = ts.weekStart;
					}
				}
				
				[ts release];
				ts= nil;
			}
			
			//Add last one
			if (timeArray != nil) {
				NSDictionary *dictionary = [NSDictionary dictionaryWithObject:timeArray forKey:@"Times"];
				[listOfItems addObject:dictionary];
				
				[timeArray release];
			}
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
	return listOfItems;
}


@end
