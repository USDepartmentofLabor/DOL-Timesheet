//
//  BreaksViewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "OtherBreaks.h"
#import "EditBreakViewController.h"

@protocol BreaksViewControllerDelegate;


@interface BreaksViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, EditBreakViewControllerDelegate> {
	IBOutlet UITableView *breaksTableView;
	NSInteger timeEntryId;
	NSMutableArray *dataList;
	id<BreaksViewControllerDelegate>delegate;
}

@property (nonatomic, retain) UITableView *breaksTableView;
@property (nonatomic, assign) NSInteger timeEntryId;
@property (nonatomic, retain) NSMutableArray *dataList;
@property (nonatomic, assign) id<BreaksViewControllerDelegate> delegate;

@end

@protocol BreaksViewControllerDelegate<NSObject>

- (void)breaksViewController:(BreaksViewController *)controller didSaveBreaks:(NSMutableArray *)breaks;

@end