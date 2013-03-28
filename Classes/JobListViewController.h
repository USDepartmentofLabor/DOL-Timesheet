//
//  JobListViewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>

@protocol JobListViewControllerDelegate;

@interface JobListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *jobsTableView;
	NSMutableArray *employersArray;
	id<JobListViewControllerDelegate>delegate;
	NSMutableArray *selectedEmployers;
}

@property (nonatomic, retain) IBOutlet UITableView *jobsTableView;
@property (nonatomic, retain) NSMutableArray *employersArray;
@property (nonatomic, assign) id<JobListViewControllerDelegate>delegate;
@property (nonatomic, retain) NSMutableArray *selectedEmployers;

@end

@protocol JobListViewControllerDelegate<NSObject>

- (void)jobListViewController:(JobListViewController *)controller didSaveJobs:(NSMutableArray *)employers;
- (void)didCancelJobs:(JobListViewController *)controller;

@end