//
//  DefaultTimeViewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>

@protocol DefaultTimeViewControllerDelegate;

@interface DefaultTimeViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *defaultTableView;
	IBOutlet UIDatePicker *datePicker;
	IBOutlet UIBarButtonItem *clearButton;
	IBOutlet UIToolbar *toolbar;
	NSDate *startTime;
	NSDate *endTime;
	NSTimeInterval mealBreakTime;
	BOOL isStart;
	id<DefaultTimeViewControllerDelegate> delegate;
}

@property (nonatomic, retain)IBOutlet UITableView *defaultTableView;
@property (nonatomic, retain)IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain)IBOutlet UIBarButtonItem *clearButton;
@property (nonatomic, retain)IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSDate *endTime;
@property (nonatomic, assign) NSTimeInterval mealBreakTime;
@property (nonatomic, assign) id<DefaultTimeViewControllerDelegate> delegate;

- (IBAction)dateValueChanged:(id)sender;
- (IBAction)clearButtonTapped:(id)sender;

@end

@protocol DefaultTimeViewControllerDelegate<NSObject>
- (void)defaultTimeViewController:(DefaultTimeViewController *)controller didSaveDefaults:(NSArray *)values;
- (void)didCancelDefaults:(DefaultTimeViewController *)controller;
@end
