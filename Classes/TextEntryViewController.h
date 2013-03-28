//
//  TextEntryViewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>

@protocol TextEntryViewControllerDelegate;

@interface TextEntryViewController : UIViewController<UITextFieldDelegate> {
	IBOutlet UITableView *textTableView;
	NSString *textValue;
	NSString *placeHolderText;
	NSInteger maxLength;
	id<TextEntryViewControllerDelegate>delegate;
}

@property(nonatomic, assign) id<TextEntryViewControllerDelegate>delegate;
@property(nonatomic, retain)UITableView *textTableView;
@property(nonatomic, copy)NSString *textValue;
@property(nonatomic, copy)NSString *placeHolderText;
@property(nonatomic, assign)NSInteger maxLength;

@end

@protocol TextEntryViewControllerDelegate<NSObject>

- (void)textEntryViewController:(TextEntryViewController *)controller didSaveText:(NSString *)text;
- (void)didCancelText:(TextEntryViewController *)controller;
@end