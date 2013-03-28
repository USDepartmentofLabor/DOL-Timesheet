//
//  DateConversion.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "DateConversion.h"


@implementation DateConversion

+ (NSString *)timeIntervalToHoursAndMinutes:(NSTimeInterval) interval {	
	
	unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
	
	NSDate *d1 = [[NSDate alloc] init];
	NSDate *d2 = [[NSDate alloc] initWithTimeInterval:(interval) sinceDate:d1];
	
	NSDateComponents *conversionInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:d1 toDate:d2 options:0];
	
	NSString *hoursString = [NSMutableString stringWithFormat:@"%02dh %02dm", [conversionInfo hour], [conversionInfo minute]];
	
	[d1 release];
	[d2 release];
	
	return hoursString;
}

+ (NSString *)timeElapsedFromDate:(NSDate *)date1 toDate:(NSDate *)date2 {
	
	if (date1 == nil || date2 == nil) {
		return @"00h 00m";
	}
	
	unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
	
	NSDateComponents *conversionInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:date1 toDate:date2 options:0];
	
	NSString *hoursString = [NSMutableString stringWithFormat:@"%02dh %02dm", [conversionInfo hour], [conversionInfo minute]];
	
	return hoursString;
}

+ (NSString *)timeElapsedFromDate:(NSDate *)date1 toDate:(NSDate *)date2 withBreaks:(NSTimeInterval)interval {
	
	if (date1 == nil || date2 == nil) {
		return @"00h 00m";
	}
	
	NSDateComponents *conversionInfo = [[NSCalendar currentCalendar] components: NSSecondCalendarUnit fromDate:date1 toDate:date2 options:0];
	NSTimeInterval worked = [[NSNumber numberWithUnsignedInt:[conversionInfo second]] doubleValue];
	
	worked -= interval;
	
	NSDate *d1 = [[NSDate alloc] init];
	NSDate *d2 = [[NSDate alloc] initWithTimeInterval:(worked) sinceDate:d1];
	
	unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
	
	conversionInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:d1 toDate:d2 options:0];
	
	NSString *hoursString = [NSMutableString stringWithFormat:@"%02dh %02dm", [conversionInfo hour], [conversionInfo minute]];
	
	[d1 release];
	[d2 release];
	
	return hoursString;
}

@end
