//
//  TimeEntryViewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "CommentsEntryViewController.h"
#import "TimePickerViewController.h"
#import "CurrencyEntryViewController.h"
#import "TimerViewController.h"
#import "TimeEntryController.h"
#import "BreaksViewController.h"
#import "Employer.h"
#import "TimeEntry.h"
#import "OtherBreaks.h"

@protocol TimeEntryViewControllerDelegate;

@interface TimeEntryViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,
		TimePickerViewControllerDelegate, CommentsEntryViewControllerDelegate, CurrencyEntryViewControllerDelegate, 
		TimerViewControllerDelegate, BreaksViewControllerDelegate, UIActionSheetDelegate> {
			IBOutlet UITableView *timeTableView;
			Employer *employer;
			TimeEntry *timeEntry;
			NSMutableArray *otherBreaks;
			id<TimeEntryViewControllerDelegate>delegate;
			UIView *footerView;
			BOOL editMode;
			NSInteger timeEntryId;
}

@property (nonatomic, retain) IBOutlet UITableView *timeTableView;
@property (nonatomic, retain) Employer *employer;
@property (nonatomic, retain) TimeEntry *timeEntry;
@property (nonatomic, retain) NSMutableArray *otherBreaks;
@property (nonatomic, assign) id<TimeEntryViewControllerDelegate>delegate;
@property (nonatomic, retain) UIView *footerView;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, assign) NSInteger timeEntryId;

-(NSInteger)saveButtonPressed:(id)sender;
-(void)deleteButtonPressed:(id)sender;

@end

@protocol TimeEntryViewControllerDelegate<NSObject>

- (void)timeEntryViewController:(TimeEntryViewController *)controller didSaveTimeEntry:(NSInteger)result;
- (void)didCancelTimeEntry:(TimeEntryViewController *)controller;
- (void)didDelete:(TimeEntryViewController *)controller;
- (void)didCancelEntryToContactWHD:(TimeEntryViewController *)controller;

@end

