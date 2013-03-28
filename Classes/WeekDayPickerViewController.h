//
//  WeekDayPickerViewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>

@protocol WeekDayPickerViewControllerDelegate;

@interface WeekDayPickerViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *daysTableView;
	NSArray *daysArray;
	NSInteger daySelected;
	id<WeekDayPickerViewControllerDelegate> delegate;
}

@property (nonatomic, retain) UITableView *daysTableView;
@property (nonatomic, retain) NSArray *daysArray;
@property (nonatomic, assign) NSInteger daySelected;
@property (nonatomic, assign) id<WeekDayPickerViewControllerDelegate> delegate;

@end

@protocol WeekDayPickerViewControllerDelegate<NSObject>

- (void)weekDayPickerViewController:(WeekDayPickerViewController *)controller didSave:(NSInteger)day;
- (void)didCancel:(WeekDayPickerViewController *)controller;

@end