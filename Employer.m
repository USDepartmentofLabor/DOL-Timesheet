//
//  Employer.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "Employer.h"

@implementation Employer

@synthesize employerId;
@synthesize employerName;
@synthesize startOfWorkWeek;
@synthesize hourlyRate;

- (id) initWithPrimaryKey:(NSInteger)pk {
	[super init];
	employerId = pk;
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	Employer *employerCopy = [[[Employer allocWithZone:zone]initWithPrimaryKey:employerId] autorelease];
	
	employerCopy.employerName = employerName;
	employerCopy.startOfWorkWeek = startOfWorkWeek;
	employerCopy.hourlyRate = hourlyRate;
	
	return employerCopy;
}

- (void) dealloc {
	
	[employerName release];
	[hourlyRate release];
	[super dealloc];
}

@end
