//
//  TimeEntryReviewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "TimeEntry.h"
#import "OtherBreaks.h"

@protocol TimeEntryReviewControllerDelegate;

@interface TimeEntryReviewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
	IBOutlet UITableView *timeTableView;
	TimeEntry *timeEntry;
	NSArray *otherBreaks;
	UIView *footerView;
	id<TimeEntryReviewControllerDelegate>delegate;
}

@property (nonatomic, retain) IBOutlet UITableView *timeTableView;
@property (nonatomic, retain) TimeEntry *timeEntry;
@property (nonatomic, retain) NSArray *otherBreaks;
@property (nonatomic, retain) UIView *footerView;
@property (nonatomic, assign) id<TimeEntryReviewControllerDelegate>delegate;

@end

@protocol TimeEntryReviewControllerDelegate<NSObject>

- (void)didDelete:(TimeEntryReviewController *)controller;

@end

