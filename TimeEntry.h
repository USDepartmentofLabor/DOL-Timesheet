//
//  TimeEntry.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>


@interface TimeEntry : NSObject {
	NSInteger timeEntryId;
	NSInteger employerId;
	NSDate *startTime;
	NSDate *endTime;
	NSTimeInterval mealBreak;
	NSNumber *hourlyRate;
	NSString *comments;
}

@property (nonatomic, assign) NSInteger timeEntryId;
@property (nonatomic, assign) NSInteger employerId;
@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSDate *endTime;
@property (nonatomic, assign) NSTimeInterval mealBreak;
@property (nonatomic, retain) NSNumber *hourlyRate;
@property (nonatomic, copy) NSString *comments;

- (id)initWithPrimaryKey:(NSInteger)pk;

@end
