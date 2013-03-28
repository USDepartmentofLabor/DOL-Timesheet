//
//  TimeSummary.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <Foundation/Foundation.h>


@interface TimeSummary : NSObject {
	NSInteger employerId;
	NSString *employerName;
	NSString *startDate;
	NSString *endDate;
	NSString *weekStart;
	NSTimeInterval sumOfMealBreaks;
	NSTimeInterval sumOfTimeWorked;
	NSTimeInterval sumOfOtherBreaks;
	NSTimeInterval regularTime;
	NSTimeInterval overTime;
	double hourlyRate;
	double pay;
}

@property (nonatomic, assign) NSInteger employerId;
@property (nonatomic, copy) NSString *employerName;
@property (nonatomic, copy) NSString *startDate;
@property (nonatomic, copy)	NSString *endDate;
@property (nonatomic, copy)	NSString *weekStart;
@property (nonatomic, assign) NSTimeInterval sumOfMealBreaks;
@property (nonatomic, assign) NSTimeInterval sumOfTimeWorked;
@property (nonatomic, assign) NSTimeInterval sumOfOtherBreaks;
@property (nonatomic, assign) NSTimeInterval regularTime;
@property (nonatomic, assign) NSTimeInterval overTime;
@property (nonatomic, assign) double hourlyRate;
@property (nonatomic, assign) double pay;

@end
