//
//  TimeEntryController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <Foundation/Foundation.h>
#import "TimeEntry.h"
#import "OtherBreaks.h"
#import "Clock.h"

@interface TimeEntryController : NSObject {
	
}

+ (NSInteger)addTimeEntry:(TimeEntry *)timeEntry withBreaks:(NSMutableArray *)otherBreaks;
+ (NSInteger)updateTimeEntry:(TimeEntry *)timeEntry withBreaks:(NSMutableArray *)otherBreaks;
+ (NSInteger)deleteTimeEntry:(TimeEntry *)t;
+ (NSArray *)exportTimeEntriesForEmployers:(NSArray *)employerIds FromDate:(NSDate *)fromDate ToDate:(NSDate *)toDate;
+ (NSInteger)deleteTimeEntriesForMonth:(NSString *)month employer:(NSInteger)employerId;
+ (NSInteger)deleteTimeEntriesForEmployer:(NSInteger)employerId fromDay:(NSString *)fDay toDay:(NSString *)tDay;
+ (NSArray *)getTimeEntriesForDay:(NSString *)date forEmployer:(NSInteger)employerId;
+ (NSMutableArray *)getOtherBreaksForTimeEntryId:(NSInteger)timeEntryId;
+ (TimeEntry *)getTimeEntry:(NSInteger)timeEntryId;
+ (NSMutableArray *)getClock;
+ (void)insertClock:(Clock *)clock;
+ (void)stopClock:(ClockType)clockType;
+ (void)resetClock;
@end
