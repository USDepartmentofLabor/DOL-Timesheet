//
//  ReviewHoursViewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "TimeSummary.h"

typedef enum {
	kDay,
	kWeek,
	kMonth
} DateGroup;

@interface ReviewHoursViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *reviewTableView;
	UIColor *defaultTintColor;
	DateGroup groupBy;
	
	NSMutableArray *timeData;
}

@property (nonatomic, retain) UITableView *reviewTableView;
@property (nonatomic, retain)NSMutableArray *timeData;

- (void)fetchData;
@end
