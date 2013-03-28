//
//  TimerViewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>

@protocol TimerViewControllerDelegate;

@interface TimerViewController : UIViewController {
	IBOutlet UIDatePicker *timerPicker;
	IBOutlet UIButton *defaultButton;
	IBOutlet UIButton *noneButton;
	NSTimeInterval defaultValue;
	NSTimeInterval selectedValue;
	id<TimerViewControllerDelegate>delegate;
}

@property (nonatomic, retain) IBOutlet UIDatePicker *timerPicker;
@property (nonatomic, retain) IBOutlet UIButton *defaultButton;
@property (nonatomic, retain) IBOutlet UIButton *noneButton;
@property (nonatomic, assign) NSTimeInterval defaultValue;
@property (nonatomic, assign) NSTimeInterval selectedValue;
@property (nonatomic, assign) id<TimerViewControllerDelegate>delegate;

- (IBAction)defaultButtonPressed:(id)sender;
- (IBAction)noneButtonPressed:(id)sender;

@end

@protocol TimerViewControllerDelegate<NSObject>

- (void)timerViewController:(TimerViewController *)controller didSaveTimer:(NSTimeInterval)timer;
- (void)didCancelTimer:(TimerViewController *)controller;

@end