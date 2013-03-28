//
//  ExportViewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "JobListViewController.h"
#import "ExportDatesViewController.h"

@interface ExportViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate,
		ABPeoplePickerNavigationControllerDelegate, JobListViewControllerDelegate, UITextFieldDelegate, ExportDatesViewControllerDelegate> {
			IBOutlet UITableView *exportTableView;
			UIView *footerView;
			NSMutableArray *selectedEmployers;
			NSDate *startDate;
			NSDate *endDate;
			UITextField *emailTextField;
			UITextField *subjectTextField;
}

@property (nonatomic, retain) UITableView *exportTableView;
@property (nonatomic, retain) UIView *footerView;
@property (nonatomic, retain) NSMutableArray *selectedEmployers;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, retain) UITextField *emailTextField;
@property (nonatomic, retain) UITextField *subjectTextField;

-(NSString *)escapeString:(NSString *)s;

@end
