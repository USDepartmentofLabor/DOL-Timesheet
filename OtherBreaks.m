//
//  OtherBreaks.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "OtherBreaks.h"


@implementation OtherBreaks

@synthesize otherBreaksId;
@synthesize timeEntryId;
@synthesize breakTime;
@synthesize comments;
@synthesize breakType;

- (id)initWithPrimaryKey:(NSInteger)pk {
	[super init];
	otherBreaksId = pk;
	return self;
}

- (void)dealloc {
	[comments release];
	[super dealloc];
}
@end
