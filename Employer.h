//
//  Employer.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//	Employer database object

#import <UIKit/UIKit.h>

@interface Employer : NSObject<NSCopying> {

	NSInteger employerId;
	NSString *employerName;
	NSInteger startOfWorkWeek;
	NSNumber *hourlyRate;
}

@property (nonatomic, readonly) NSInteger employerId;
@property (nonatomic, copy) NSString *employerName;
@property (nonatomic, assign) NSInteger startOfWorkWeek;
@property (nonatomic, copy) NSNumber *hourlyRate;

- (id)initWithPrimaryKey:(NSInteger)pk;
- (id)copyWithZone:(NSZone *) zone;

@end
