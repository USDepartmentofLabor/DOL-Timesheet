//
//  CommentsEntryViewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>

@protocol CommentsEntryViewControllerDelegate;

@interface CommentsEntryViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate> {
	IBOutlet UITableView *commentsTableView;
	id<CommentsEntryViewControllerDelegate>delegate;
	NSString *commentsValue;
}

@property (nonatomic, retain) UITableView *commentsTableView;
@property (nonatomic, assign)id<CommentsEntryViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *commentsValue;

@end

@protocol CommentsEntryViewControllerDelegate<NSObject>

- (void)commentsEntryViewController:(CommentsEntryViewController *)controller didSaveComments:(NSString *)comments;
- (void)didCancelComments:(CommentsEntryViewController *)controller;

@end