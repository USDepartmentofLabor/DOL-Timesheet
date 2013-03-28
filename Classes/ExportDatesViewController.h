//
//  ExportDatesViewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>

@protocol ExportDatesViewControllerDelegate;

@interface ExportDatesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *datesTableView;
	IBOutlet UIDatePicker *datePicker;
	IBOutlet UIBarButtonItem *clearButton;
	NSDate *startDate;
	NSDate *endDate;
	BOOL isStart;
	id<ExportDatesViewControllerDelegate> delegate;
}

@property (nonatomic, retain)IBOutlet UITableView *datesTableView;
@property (nonatomic, retain)IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain)IBOutlet UIBarButtonItem *clearButton;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, assign) id<ExportDatesViewControllerDelegate> delegate;

- (IBAction)dateValueChanged:(id)sender;
- (IBAction)clearButtonTapped:(id)sender;

@end

@protocol ExportDatesViewControllerDelegate<NSObject>
- (void)exportDatesViewController:(ExportDatesViewController *)controller didSaveDates:(NSMutableArray *)values;
- (void)didCancelDates:(ExportDatesViewController *)controller;
@end