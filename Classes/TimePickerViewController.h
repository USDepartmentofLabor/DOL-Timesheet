//
//  TimePickerViewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>

@protocol TimePickerViewControllerDelegate;


@interface TimePickerViewController : UIViewController {
	IBOutlet UIButton *nowButton;
	IBOutlet UIButton *defaultButton;
	IBOutlet UILabel *messageLabel;
	IBOutlet UIDatePicker *datePicker;
	NSDate *defaultTime;
	NSDate *selectedDate;
	id<TimePickerViewControllerDelegate>delegate;
	NSString *displayText;
}

@property (nonatomic, retain)IBOutlet UIButton *nowButton;
@property (nonatomic, retain)IBOutlet UIButton *defaultButton;
@property (nonatomic, retain)IBOutlet UILabel *messageLabel;
@property (nonatomic, retain)IBOutlet UIDatePicker *datePicker;
@property (nonatomic, copy)NSDate *defaultTime;
@property (nonatomic, retain)NSDate *selectedDate;
@property (nonatomic, assign)id<TimePickerViewControllerDelegate>delegate;
@property (nonatomic, copy)NSString *displayText;

- (IBAction)nowBarButtonPressed:(id)sender;
- (IBAction)defaultBarButtonPressed:(id)sender;
- (IBAction)timeChanged:(id)sender; //Bug ID 2594

@end

@protocol TimePickerViewControllerDelegate<NSObject>

- (void)timePickerViewController:(TimePickerViewController *)controller didSaveDate:(NSDate *)dateChosen;
- (void)didCancelDate:(TimePickerViewController *)controller;

@end

