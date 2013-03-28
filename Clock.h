//
//  Clock.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <Foundation/Foundation.h>

typedef enum ClockType {
	Work,
	MealBreak,
	OtherBreak
} ClockType;

@interface Clock : NSObject {
	NSInteger clockId;
	NSInteger employerId;
	NSDate *startTime;
	NSDate *endTime;
	NSString *comments;
	ClockType clockType;
}

@property (nonatomic, assign) NSInteger clockId;
@property (nonatomic, assign) NSInteger employerId;
@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSDate *endTime;
@property (nonatomic, copy) NSString *comments;
@property (nonatomic, assign) ClockType clockType;

- (id)initWithPrimaryKey:(NSInteger)pk;

@end
