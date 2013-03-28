//
//  EditBreakViewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "OtherBreaks.h"

@protocol EditBreakViewControllerDelegate;

@interface EditBreakViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate> {
	IBOutlet UITableView *breakTableView;
	IBOutlet UIDatePicker *timerPicker;
	UIView *footerView;
	OtherBreaks *otherBreak;
	id<EditBreakViewControllerDelegate>delegate;
	NSInteger breakType;
	
	NSTimeInterval selectedValue;
	NSString *commentsValue;
	
	CGFloat animatedDistance;
}

@property (nonatomic, retain) IBOutlet UITableView *breakTableView;
@property (nonatomic, retain) IBOutlet UIDatePicker *timerPicker;
@property (nonatomic, retain) UIView *footerView;
@property (nonatomic, retain) OtherBreaks *otherBreak;
@property (nonatomic, assign) id<EditBreakViewControllerDelegate>delegate;

@property (nonatomic, copy) NSString *commentsValue;
@property (nonatomic, assign) NSTimeInterval selectedValue;
@property (nonatomic, assign) NSInteger breakType;

- (IBAction)disclaimerTap:(id)sender;

@end

@protocol EditBreakViewControllerDelegate<NSObject>

- (void)editBreakViewController:(EditBreakViewController *)controller didSaveBreak:(OtherBreaks *)aBreak;
- (void)didCancelBreak:(EditBreakViewController *)controller;

@end