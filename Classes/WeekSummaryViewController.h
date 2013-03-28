//
//  WeekSummaryViewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "TimeSummary.h"

@interface WeekSummaryViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *detailsTable;
	TimeSummary *timeSummary;
}

@property(nonatomic, retain) IBOutlet UITableView *detailsTable;
@property(nonatomic, retain) TimeSummary *timeSummary;

@end
