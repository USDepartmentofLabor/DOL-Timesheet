//
//  Clock.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "Clock.h"


@implementation Clock

@synthesize clockId;
@synthesize employerId;
@synthesize startTime;
@synthesize endTime;
@synthesize comments;
@synthesize clockType;

- (id) initWithPrimaryKey:(NSInteger)pk {
	[super init];
	clockId = pk;
	
	return self;
}

- (void)dealloc {
	[startTime release];
	[endTime release];
	[comments release];
	[super dealloc];
}

@end
