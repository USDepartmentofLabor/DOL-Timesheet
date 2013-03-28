//
//  StartBreakViewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>

@protocol StartBreakViewControllerDelegate;

@interface StartBreakViewController : UIViewController<UITextViewDelegate> {
	IBOutlet UITableView *commentsTableView;
	IBOutlet UISegmentedControl *segment;
	id<StartBreakViewControllerDelegate>delegate;
	NSTimer *timer;
}
@property (nonatomic, retain) UITableView *commentsTableView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segment;
@property (nonatomic, assign)id<StartBreakViewControllerDelegate> delegate;
@property (nonatomic, retain) NSTimer *timer;

-(IBAction)segmentValueChanged:(id)sender;

@end

@protocol StartBreakViewControllerDelegate<NSObject>

- (void)startBreakViewController:(StartBreakViewController *)controller didSaveComments:(NSString *)comments forType:(NSInteger)breakType;
- (void)didCancelComments:(StartBreakViewController *)controller;

@end