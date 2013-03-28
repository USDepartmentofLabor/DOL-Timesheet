//
//  EditJobViewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "WeekDayPickerViewController.h"
#import "Employer.h"
#import "TextEntryViewController.h"
#import "CurrencyEntryViewController.h"

@protocol EditJobViewControllerDelegate;

@interface EditJobViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
	IBOutlet UITableView *jobTableView;
	IBOutlet UITextField *txtEmployer;
	IBOutlet UITextField *txtRate;
	id<EditJobViewControllerDelegate> delegate;
	IBOutlet UIView *dayPickerView;
	IBOutlet UIPickerView *dayPicker;
	NSNumber *currencyAmount;
	
	Employer *employer;
	NSArray *daysArray;
}

@property (nonatomic, retain) UITableView *jobTableView;
@property (nonatomic, retain) IBOutlet UITextField *txtEmployer;
@property (nonatomic, retain) IBOutlet UITextField *txtRate;
@property (nonatomic, retain) Employer *employer;
@property (nonatomic, retain) IBOutlet UIView *dayPickerView;
@property (nonatomic, retain) IBOutlet UIPickerView *dayPicker;
@property (nonatomic, retain) NSNumber *currencyAmount;

@property (nonatomic, assign) id<EditJobViewControllerDelegate> delegate;

-(IBAction)saveButtonPressed:(id)sender;
-(IBAction)cancelButtonPressed:(id)sender;
-(IBAction)keyboardDonePressed:(id)sender;
-(IBAction)hideButtonPressed:(id)sender;
-(IBAction)pickerShow;
@end

@protocol EditJobViewControllerDelegate<NSObject>

- (void)editJobViewController:(EditJobViewController *)controller didSave:(NSString *)text;
- (void)didCancel:(EditJobViewController *)controller;
- (void)didCancelToContactWHD:(EditJobViewController *)controller;
@end
