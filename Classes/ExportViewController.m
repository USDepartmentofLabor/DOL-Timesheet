//
//  ExportViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "ExportViewController.h"
#import "JobListViewController.h"
#import "Employer.h"
#import "ExportDatesViewController.h"
#import "TimeEntryController.h"
#import <MessageUI/MessageUI.h>


#define EMAIL_TEXTFIELD_TAG 1001
#define SUBJECT_TEXTFIELD_TAG 1002

@implementation ExportViewController
@synthesize exportTableView;
@synthesize footerView;
@synthesize selectedEmployers;
@synthesize startDate;
@synthesize endDate;
@synthesize emailTextField;
@synthesize subjectTextField;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	exportTableView.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripe3.png"]];
	
}

- (id)init {
	if (self = [super initWithNibName:@"ExportViewController" bundle:nil]) {
		self.title = NSLocalizedString(@"Email Report",@"Email Report");
		
		//Tab Bar item
		UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Email Report",@"Email Report Tabbar") image:[UIImage imageNamed:@"email-icon.png"] tag:2];
		self.tabBarItem = item;
		[item release];
	}
	return self;
}

- (void) sendButtonPressed:(id)sender {
	
	//Check to see if mail is setup
	if (![MFMailComposeViewController canSendMail]) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Can't send mail", @"Can't send mail") message:NSLocalizedString(@"The email client has not been setup on this device.", @"Email client not setup") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	//Add validation for required fields
	//Get the email textfield contents
	UITableViewCell *cell = [exportTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	UITextField *txt = (UITextField *)[cell viewWithTag:EMAIL_TEXTFIELD_TAG];
	NSString *email = txt.text;
	
	if ([email isEqualToString:@""]) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Required field", @"Required field") message:NSLocalizedString(@"Email is required.", @"Email is required.") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	//Get the Subject textfield contents
	cell = [exportTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
	txt = (UITextField *)[cell viewWithTag:SUBJECT_TEXTFIELD_TAG];
	NSString *subject = txt.text;
	
	NSString *trimmedSubject = [subject stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
	if ([trimmedSubject isEqualToString:@""]) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Required field", @"Required field") message:NSLocalizedString(@"Subject is required.", @"Subject is required.") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	//End of validation
	
	//Call DB controller to get data; pass filters
	NSArray *finalArray = [TimeEntryController exportTimeEntriesForEmployers:self.selectedEmployers FromDate:self.startDate ToDate:self.endDate];
	
	//If there is no data matching the filters specified, display alert
	if (finalArray == nil || [finalArray count] == 1) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No results",@"No results" ) message:NSLocalizedString(@"There are no records that match the filters specified",@"Email returned 0 records") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		//Get directory path
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
		NSString *documentsDir = [paths objectAtIndex:0];
		NSString *path = [documentsDir stringByAppendingPathComponent:@"TimesheetExport.csv"];
		
		//Create filemanager object for file creation
		NSFileManager *fileManager = [NSFileManager defaultManager];
		[fileManager createFileAtPath:path contents:nil attributes:nil];
		
		NSFileHandle *filehandle = [NSFileHandle fileHandleForWritingAtPath:path];
		
		//Loop through the results and write to file
		for (NSArray *row in finalArray) {
			NSMutableString * string = [NSMutableString string];
			BOOL firstColumn = YES;
			for (NSString *column in row) {
				NSString *delimiter = !firstColumn?@",":@"";
				[string appendFormat:@"%@%@", delimiter, [self escapeString:column]];
				firstColumn = NO;
			}
			[string appendString:@"\n"];
			[filehandle writeData:[string dataUsingEncoding:NSISOLatin1StringEncoding]];
		}
		//Add WHD contact information to the file
		//NSString *contact = NSLocalizedString(@"Contact Information",@"Contact Information");
		//[filehandle writeData:[contact dataUsingEncoding:NSUTF8StringEncoding]];
		
		//Close file handle
		[filehandle closeFile];
		
		//Get the email textfield contents
		//UITableViewCell *cell = [exportTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		//UITextField *txt = (UITextField *)[cell viewWithTag:EMAIL_TEXTFIELD_TAG];
		//NSString *email = txt.text;
		
		//Get the Subject textfield contents
		//cell = [exportTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
		//txt = (UITextField *)[cell viewWithTag:SUBJECT_TEXTFIELD_TAG];
		//NSString *subject = txt.text;
		
		NSMutableString *dateSpan = [NSMutableString stringWithString:subject];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		
		//If dates were selected add them to the subject line
		if (self.startDate != nil) {
			[dateSpan appendString:@" "];
			[dateSpan appendString:[dateFormatter stringFromDate:self.startDate]];
		}
		if (self.endDate != nil) {
			[dateSpan appendString:@" - "];
			[dateSpan appendString:[dateFormatter stringFromDate:self.endDate]];
		}
		[dateFormatter release];
		
		//If selected employer count > 0 add it to the subject line
		if ([selectedEmployers count] > 0) {
			[dateSpan appendString:@". "];
			for (Employer *e in selectedEmployers) {
				[dateSpan appendString:e.employerName];
				[dateSpan appendString:@", "];
			}
			dateSpan = [NSMutableString stringWithString:[dateSpan substringToIndex:[dateSpan length] -2]];
		}
		
		//Allocate built in mail client view controller
		MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
		controller.mailComposeDelegate = self;
		
		//If an email was specified, copy it to the mail view
		if (email) {
			[controller setToRecipients:[NSArray arrayWithObject:email]];
		}
		//set subject
		[controller setSubject:dateSpan];
		[controller setMessageBody:@"" isHTML:NO];
		
		//Attach the csv file we just created
		[controller addAttachmentData:[NSData dataWithContentsOfFile:path] mimeType:@"text/csv" fileName:@"TimesheetExport.csv"];
		
		//Add contact information to body
		[controller setMessageBody:NSLocalizedString(@"Contact Information",@"Contact Information") isHTML:NO];
		
		// Assign the same red tint to the Mail view
		controller.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
		
		//Show the mail window modally
		[self presentViewController:controller animated:YES completion:nil];
		[controller release];
	}
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:emailTextField.text forKey:@"email"];
}

-(NSString *)escapeString:(NSString *)s
{
    
    NSString * escapedString = s;
    
    //BOOL containsSeperator = !NSEqualRanges([s rangeOfString:@","], NSMakeRange(NSNotFound, 0));
    BOOL containsQuotes = !NSEqualRanges([s rangeOfString:@"\""], NSMakeRange(NSNotFound, 0));
    //BOOL containsLineBreak = !NSEqualRanges([s rangeOfString:@"\n"], NSMakeRange(NSNotFound, 0));
    
    
    if (containsQuotes) {
        escapedString = [escapedString stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
    }
    
	escapedString = [NSString stringWithFormat:@"\"%@\"", escapedString];
    
    return escapedString;
}


 - (void)viewWillAppear:(BOOL)animated {
	 [super viewWillAppear:animated];
	 //Unselect the selected row if any. This will remove the row highlight when we return from a pushed screen.
	 NSIndexPath* selection = [self.exportTableView indexPathForSelectedRow];
	 if (selection) {
		 [self.exportTableView deselectRowAtIndexPath:selection animated:YES];
	 }
 }

#pragma mark -
#pragma mark Mail Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self becomeFirstResponder];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case 0:
			return 2;
			break;
		case 1:
			return 2;
			break;
		default:
			return 1;
			break;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	static NSString *EmailCellIdentifier = @"EmailCell";
	static NSString *SubjectCellIdentifier = @"SubjectCell";
	
    
    UITableViewCell *cell;
	
	switch (indexPath.section) {
		case 0:
			if (indexPath.row == 0) { //Email field
				cell = [tableView dequeueReusableCellWithIdentifier:EmailCellIdentifier];
				
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:EmailCellIdentifier] autorelease];
					cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
					cell.detailTextLabel.text = @" ";
					cell.detailTextLabel.alpha = 0;
					
					if (emailTextField == nil) {
						emailTextField = [[[UITextField alloc] initWithFrame:CGRectMake(cell.frame.origin.x+10
																						, cell.frame.origin.y+25, 250, 30)] autorelease];
						emailTextField.placeholder = NSLocalizedString(@"example@email.com",@"example@email.com");
						emailTextField.adjustsFontSizeToFitWidth = YES;
						emailTextField.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
						emailTextField.clearsOnBeginEditing = NO;
						emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
						emailTextField.returnKeyType = UIReturnKeyDone;
						emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
						emailTextField.delegate = self;
						[emailTextField addTarget:self action:@selector(textDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
						emailTextField.tag = EMAIL_TEXTFIELD_TAG;
						emailTextField.font = [UIFont boldSystemFontOfSize:14];
						
						NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
						NSString *email = [prefs objectForKey:@"email"];
						
						if (email != nil) {
							emailTextField.text = email;
						}
					}
					
					cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
					// Always add subview at end. If you add Subview first then label text, the subview will be
					// covered by the label
					[cell.contentView addSubview:emailTextField];
				} else {
					emailTextField = (UITextField *)[cell viewWithTag:EMAIL_TEXTFIELD_TAG];
				}
				
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				[cell.textLabel setText:NSLocalizedString(@"Email",@"Email")];
				
				//Accesibility
				if (emailTextField.text != nil) {
					cell.textLabel.isAccessibilityElement = YES;
					cell.textLabel.accessibilityLabel = [NSString stringWithFormat:@"%@. %@", NSLocalizedString(@"Email",@"Email"), emailTextField.text];
				}
				
				//
				
			} else if (indexPath.row == 1) {
				
				cell = [tableView dequeueReusableCellWithIdentifier:SubjectCellIdentifier];
				
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SubjectCellIdentifier] autorelease];
					cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
					cell.detailTextLabel.text = @" ";
					cell.detailTextLabel.alpha = 0;
					
					if (subjectTextField == nil) {
						subjectTextField = [[[UITextField alloc] initWithFrame:CGRectMake(10, 25, 250, 30)] autorelease];
						subjectTextField.placeholder = NSLocalizedString(@"Required",@"Required");
						subjectTextField.adjustsFontSizeToFitWidth = YES;
						subjectTextField.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
						subjectTextField.clearsOnBeginEditing = NO;
						subjectTextField.keyboardType = UIKeyboardTypeDefault;
						subjectTextField.returnKeyType = UIReturnKeyDone;
						subjectTextField.text = NSLocalizedString(@"Timesheet Report",@"Timesheet Report");
						subjectTextField.delegate = self;
						[subjectTextField addTarget:self action:@selector(textDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
						subjectTextField.tag = SUBJECT_TEXTFIELD_TAG;
						
						subjectTextField.font = [UIFont boldSystemFontOfSize:14];
					}
					
					
					[cell.contentView addSubview:subjectTextField];
				} else {
					subjectTextField = (UITextField *)[cell viewWithTag:SUBJECT_TEXTFIELD_TAG];
				}
				
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				[cell.textLabel setText:NSLocalizedString(@"Subject",@"Subject")];
				
				//Accesibility
				if (subjectTextField.text != nil) {
					cell.textLabel.isAccessibilityElement = YES;
					cell.textLabel.accessibilityLabel = [NSString stringWithFormat:@"%@. %@", NSLocalizedString(@"Subject",@"Subject"), subjectTextField.text];
				}
			}
			break;
		case 1:
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
				cell.detailTextLabel.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
				cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
				cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			if (indexPath.row == 0) {
				
				NSMutableString *dateSpan = [NSMutableString stringWithString:@""];
				NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
				[dateFormatter setDateStyle:NSDateFormatterShortStyle];
				
				if (self.startDate != nil) {
					[dateSpan appendString:NSLocalizedString(@"From",@"From")];
					[dateSpan appendString:@" "];
					[dateSpan appendString:[dateFormatter stringFromDate:self.startDate]];
				}
				if (self.endDate != nil) {
					[dateSpan appendString:@" "];
					[dateSpan appendString:NSLocalizedString(@"To",@"To")];
					[dateSpan appendString:@" "];
					[dateSpan appendString:[dateFormatter stringFromDate:self.endDate]];
				}
				[dateFormatter release];
				
				
				[cell.textLabel setText:NSLocalizedString(@"Dates",@"Dates")];
				[cell.detailTextLabel setText:dateSpan];
				
				cell.isAccessibilityElement = YES;
				cell.accessibilityTraits = UIAccessibilityTraitButton;
				
			} else if (indexPath.row == 1) {
				
				[cell.textLabel setText:NSLocalizedString(@"Employer",@"Employer")];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				
				cell.isAccessibilityElement = YES;
				cell.accessibilityTraits = UIAccessibilityTraitButton;
				
				if (self.selectedEmployers != nil) {
					if ([self.selectedEmployers count] == 1) {
						Employer *e = [selectedEmployers objectAtIndex:0];
						cell.detailTextLabel.text = e.employerName;
					} else if ([self.selectedEmployers count] > 1) {
						cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d Employers Selected",@"Selected employers"), [self.selectedEmployers count]];;
					} else {
						cell.detailTextLabel.text = @"";
					}
				} else {
					cell.detailTextLabel.text = @"";
				}
				break;
			}
		default:
			break;
	}
	
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 50;
	} else {
		return 44;
	}

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return @"";
			break;
		case 1:
			return NSLocalizedString(@"Options",@"Options");
			break;
		default:
			return @"";
			break;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	if (section == 1) {
		return 50;
	}
	else {
		return 0;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {   // custom view for footer. will be adjusted to default or specified footer height
	
	if (section != 1) {return nil;}
	
	if (footerView == nil) {
		footerView = [[UIView alloc] init];
		
		//we would like to show a gloosy red button, so get the image first
       // UIImage *image = [[UIImage imageNamed:@"redButton.png"]
		//				  stretchableImageWithLeftCapWidth:12 topCapHeight:0];
		
		//create the button
		//ColorfulButton *disclaimerButton = [[ColorfulButton alloc] initWithFrame:CGRectMake(10, 10, 300, 44)];
		UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		//[sendButton setBackgroundImage:image forState:UIControlStateNormal];
        [sendButton setBackgroundColor:[UIColor colorWithRed:(255/255.0) green:(20/255.0) blue:(20/255.0) alpha:1]];
		
		
		//the button should be as big as a table view cell
        [sendButton setFrame:CGRectMake(10, 10, 300, 44)];
		
		//set title, font size and font color
        [sendButton setTitle:NSLocalizedString(@"Send Email",@"Send Email") forState:UIControlStateNormal];
        [sendButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		
		//set action of the button
        [sendButton addTarget:self action:@selector(sendButtonPressed:)
				   forControlEvents:UIControlEventTouchUpInside];
		
		[footerView addSubview:sendButton];
		
	}
	
	return footerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1 && indexPath.row == 1) {
		JobListViewController *controller = [[JobListViewController alloc]init];
		controller.delegate = self;
		
		if (self.selectedEmployers != nil) {
			controller.selectedEmployers = [[self.selectedEmployers mutableCopy]autorelease];
		}
		
		UINavigationController *navController = [[UINavigationController alloc]
												 
												 initWithRootViewController:controller];
		navController.navigationBar.tintColor = [UIColor colorWithRed:0.8f green:0.0 blue:0.0 alpha:1];
		
		
		navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self presentViewController:navController animated:YES completion:nil];
		
		[controller release];
		[navController release];
	}
	
	if (indexPath.section == 1 && indexPath.row == 0) {
		ExportDatesViewController *controller = [[ExportDatesViewController alloc]initWithNibName:@"ExportDatesViewController" bundle:nil];
		controller.delegate = self;
		
		controller.startDate = self.startDate;
		controller.endDate = self.endDate;
		
		UINavigationController *navController = [[UINavigationController alloc]
												 
												 initWithRootViewController:controller];
		navController.navigationBar.tintColor = [UIColor colorWithRed:0.8f green:0.0 blue:0.0 alpha:1];
		
		
		navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self presentViewController:navController animated:YES completion:nil];
		
		[controller release];
		[navController release];
	}
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			[emailTextField becomeFirstResponder];
		}else {
			[subjectTextField becomeFirstResponder];
		}

	}
}


- (void)textDidEndOnExit:(id)sender{
	[sender resignFirstResponder];
	[exportTableView reloadData];
}

- (void)jobListViewController:(JobListViewController *)controller didSaveJobs:(NSMutableArray *)employers {
	
	self.selectedEmployers = employers;
	[exportTableView reloadData];
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)didCancelJobs:(JobListViewController *)controller {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	ABPeoplePickerNavigationController *controller = [[ABPeoplePickerNavigationController alloc]init];
	[controller setDisplayedProperties:[NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]]];
	controller.peoplePickerDelegate = self;
	
	controller.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
	[self.navigationController presentViewController:controller animated:YES completion:nil];
	[controller release];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
	if (property == kABPersonEmailProperty) {
		ABMultiValueRef emails = ABRecordCopyValue(person, property);
		
		CFStringRef emailValueSelected = ABMultiValueCopyValueAtIndex(emails, identifier);
		
		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
		
		UITableViewCell *cell = [exportTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		UITextField *emailtext = (UITextField *)[cell viewWithTag:EMAIL_TEXTFIELD_TAG];
		
		emailtext.text = (NSString *)emailValueSelected;
		
		[emailtext resignFirstResponder];
		[exportTableView reloadData];
		
		return NO;
	}
	return YES;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)exportDatesViewController:(ExportDatesViewController *)controller didSaveDates:(NSMutableArray *)values {
	if ([values count] == 2) {
		if ([[values objectAtIndex:0] isKindOfClass:[NSDate class]]) {
			self.startDate = (NSDate *)[values objectAtIndex:0];
		} else {
			self.startDate = nil;
		}
		
		if ([[values objectAtIndex:1] isKindOfClass:[NSDate class]]) {
			self.endDate = (NSDate *)[values objectAtIndex:1];
		} else {
			self.endDate = nil;
		}
	}
	[exportTableView reloadData];
	
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelDates:(ExportDatesViewController *)controller {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	self.selectedEmployers = nil;
	[exportTableView reloadData];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[exportTableView release];
	[footerView release];
	[selectedEmployers release];
	[startDate release];
	[endDate release];
	[emailTextField release];
	[subjectTextField release];
    [super dealloc];
}


@end

