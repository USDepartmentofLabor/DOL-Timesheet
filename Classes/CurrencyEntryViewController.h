//
//  CurrencyEntryViewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>

@protocol CurrencyEntryViewControllerDelegate;

@interface CurrencyEntryViewController : UIViewController<UITextFieldDelegate> {
	IBOutlet UITableView *textTableView;
	NSString *placeHolderText;
	NSInteger maxLength;
	NSNumber *currencyAmount;
	id<CurrencyEntryViewControllerDelegate>delegate;
}

@property(nonatomic, retain)UITableView *textTableView;
@property(nonatomic, copy)NSString *placeHolderText;
@property(nonatomic, retain)NSNumber *currencyAmount;
@property(nonatomic, assign)id<CurrencyEntryViewControllerDelegate>delegate;

@end

@protocol CurrencyEntryViewControllerDelegate<NSObject>

- (void)currencyEntryViewController:(CurrencyEntryViewController *)controller didSaveCurrency:(NSNumber *)amount;
- (void)didCancelCurrency:(CurrencyEntryViewController *)controller;

@end