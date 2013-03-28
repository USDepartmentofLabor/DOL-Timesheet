//
//  ReviewDaysViewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "TimeEntryViewController.h"

@interface ReviewDaysViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, TimeEntryViewControllerDelegate> {
	NSInteger employerId;
	NSString *date;
	NSString *employerName;
	NSArray *timeEntries;
	IBOutlet UITableView *timeTableView;
}

@property (nonatomic,assign) NSInteger employerId;
@property (nonatomic,copy) NSString *date;
@property (nonatomic,copy) NSString *employerName;
@property (nonatomic,retain) NSArray *timeEntries;
@property (nonatomic,retain) IBOutlet UITableView *timeTableView;

@end
