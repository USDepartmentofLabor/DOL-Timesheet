//
//  TimeSummaryController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <Foundation/Foundation.h>


@interface TimeSummaryController : NSObject {

}

+ (NSMutableArray *)getTimeSummaryByDay;
+ (NSMutableArray *)getTimeSummaryByMonth;
+ (NSMutableArray *)getTimeSummaryByWeek;

@end
