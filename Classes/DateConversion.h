//
//  DateConversion.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <Foundation/Foundation.h>


@interface DateConversion : NSObject {

}

+ (NSString *)timeIntervalToHoursAndMinutes:(NSTimeInterval) interval;

+ (NSString *)timeElapsedFromDate:(NSDate *)date1 toDate:(NSDate *)date2;

+ (NSString *)timeElapsedFromDate:(NSDate *)date1 toDate:(NSDate *)date2 withBreaks:(NSTimeInterval)interval;
@end
