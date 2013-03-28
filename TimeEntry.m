//
//  TimeEntry.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "TimeEntry.h"


@implementation TimeEntry

@synthesize timeEntryId;
@synthesize employerId;
@synthesize startTime;
@synthesize endTime;
@synthesize mealBreak;
@synthesize hourlyRate;
@synthesize comments;

- (id) initWithPrimaryKey:(NSInteger)pk {
	[super init];
	timeEntryId = pk;
	
	return self;
}

- (void)dealloc {
	[startTime release];
	[endTime release];
	[hourlyRate release];
	[comments release];
	[super dealloc];
}
@end
