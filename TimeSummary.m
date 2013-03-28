//
//  TimeSummary.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "TimeSummary.h"


@implementation TimeSummary

@synthesize employerId;
@synthesize employerName;
@synthesize startDate;
@synthesize endDate;
@synthesize weekStart;
@synthesize sumOfMealBreaks;
@synthesize sumOfTimeWorked;
@synthesize sumOfOtherBreaks;
@synthesize regularTime;
@synthesize overTime;
@synthesize hourlyRate;
@synthesize pay;


- (void)dealloc {
	[employerName release];
	[startDate release];
	[weekStart release];
	[endDate release];
	[super dealloc];
}

@end
