//
//  Job2ViewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "EditJobViewController.h"
#import "TimeEntryViewController.h"
#import "StartBreakViewController.h"

@interface JobViewController : UIViewController<StartBreakViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, EditJobViewControllerDelegate, TimeEntryViewControllerDelegate, UIActionSheetDelegate> {

	IBOutlet UITableView *jobsTableView;
	IBOutlet UIImageView *backgroundView;
	NSMutableArray *employersArray;
	NSMutableArray *clockArray;
	BOOL clockIsRunning;
	BOOL isOnMealBreak;
	BOOL isOnOtherBreak;
	NSDate *clockStart;
	NSDate *clockMealBreak;
	NSDate *clockOtherBreak;
	NSInteger clockEmployerId;
}

@property (nonatomic, retain) UITableView *jobsTableView;
@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, retain) NSMutableArray *employersArray;
@property (nonatomic, retain) NSMutableArray *clockArray;

@property (nonatomic, assign) BOOL clockIsRunning;
@property (nonatomic, assign) BOOL isOnMealBreak;
@property (nonatomic, assign) BOOL isOnOtherBreak;
@property (nonatomic, retain) NSDate *clockStart;
@property (nonatomic, retain) NSDate *clockMealBreak;
@property (nonatomic, retain) NSDate *clockOtherBreak;
@property (nonatomic, assign) NSInteger clockEmployerId;

-(void)reloadClock;
@end
