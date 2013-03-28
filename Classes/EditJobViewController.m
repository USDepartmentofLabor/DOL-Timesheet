//
//  EditJobViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "EditJobViewController.h"
#import "EmployerController.h"
#import <sqlite3.h>

#define EMPLOYER_TEXTFIELD_TAG 1001
#define RATE_TEXTFIELD_TAG 1002

@implementation EditJobViewController

@synthesize jobTableView;
@synthesize txtEmployer;
@synthesize delegate;
@synthesize txtRate;
@synthesize employer;
@synthesize dayPickerView;
@synthesize dayPicker;
@synthesize currencyAmount;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed:)];
	[self.navigationItem setRightBarButtonItem:saveButton animated:NO];
	[saveButton release];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
	[self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
	[cancelButton release];
	
	jobTableView.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripe3.png"]];
	if (employer == nil) {
		employer = [[Employer alloc] init];
		employer.startOfWorkWeek = -1;
	} else {
		currencyAmount = [[NSNumber numberWithDouble:[[employer hourlyRate] doubleValue]]retain];
	}

	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 480);
	dayPickerView.transform = transform;
	[UIView commitAnimations];
	
	daysArray = [[NSArray arrayWithObjects:NSLocalizedString(@"Sunday", @"Sunday"), NSLocalizedString(@"Monday", @"Monday"), NSLocalizedString(@"Tuesday", @"Tuesday"), NSLocalizedString(@"Wednesday",@"Wednesday"), NSLocalizedString(@"Thursday",@"Thursday"), NSLocalizedString(@"Friday",@"Friday"), NSLocalizedString(@"Saturday", @"Saturday"), nil] retain];
	
	UILabel *titleLabel = [[[UILabel alloc]init]autorelease];
	
	if (employer.employerId != 0) {
		titleLabel.text = NSLocalizedString(@"Edit Employer",@"Edit Employer");
	} else {
		titleLabel.text = NSLocalizedString(@"Add Employer",@"Add Employer");
	}

	titleLabel.frame = CGRectMake(0, 0, 200, 40);
	
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.font = [UIFont boldSystemFontOfSize:20];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.adjustsFontSizeToFitWidth = YES;
	
	titleLabel.isAccessibilityElement = YES;
	titleLabel.accessibilityTraits = UIAccessibilityTraitStaticText;
	titleLabel.accessibilityLabel = [NSString stringWithFormat:@"%@.%@", titleLabel.text, NSLocalizedString(@"Heading",@"Heading")];
	
	self.navigationItem.titleView = titleLabel;
}

-(IBAction)saveButtonPressed:(id)sender
{
	//Get values from the text fields
	employer.employerName = txtEmployer.text;
	employer.hourlyRate = currencyAmount;
	
	UIAlertView *alert;
	
	if (employer.employerName == nil || [employer.employerName length] == 0) {
		alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Required field", @"Alert View title for errors") message:NSLocalizedString(@"Employer name is required.", @"Edit employer validations") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	if (employer.hourlyRate == nil) {
		alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Required field", @"Alert View title for errors") message:NSLocalizedString(@"Hourly rate is required.", @"Edit employer validations") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	if (employer.startOfWorkWeek == -1) {
		alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Required field", @"Alert View title for errors") message:NSLocalizedString(@"Start of workweek is required.", @"Edit employer validations") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	if ([employer.hourlyRate doubleValue] < 7.25 ) {
		alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Minimum Wage Alert Title", @"Alert View title when hourly rate is < minimum wage") message:NSLocalizedString(@"Minimum Wage Alert Message",@"Hourly rate warning alert view") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		//return;
	}
	
	NSInteger result;
	
	
	if (employer.employerId == 0) {
		result = [EmployerController addEmployer:employer];
	} else {
		result = [EmployerController updateEmployer:employer];
	}
	
	if (result == SQLITE_CONSTRAINT) {
		alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error adding employer",@"Title of alert diplayed when there is an error adding an employer") message: [NSString stringWithFormat:NSLocalizedString(@"An employer named '%@' already exists.", @"Alert text displayed when the employer name is a duplicate"), employer.employerName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	[self.delegate editJobViewController:self didSave:employer.employerName];

	
	if (employer.employerId) {
		
		
		if (result == SQLITE_CONSTRAINT) {
			alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error updating employer",@"Title of alert diplayed when there is an error updating an employer") message: [NSString stringWithFormat:NSLocalizedString(@"An employer named '%@' already exists.", @"Alert text displayed when the employer name is a duplicate"), employer.employerName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			return;
		}
		
		[self.delegate editJobViewController:self didSave:employer.employerName];
	}
}

-(IBAction)cancelButtonPressed:(id)sender
{
	[self.delegate didCancel:self];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	//Unselect the selected row if any. This will remove the row highlight when we return from a pushed screen.
	NSIndexPath* selection = [self.jobTableView indexPathForSelectedRow];
	if (selection) {
		[self.jobTableView deselectRowAtIndexPath:selection animated:YES];
	}

	//********************
}


 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
	 
 }
 

 - (void)viewWillDisappear:(BOOL)animated {
	 [super viewWillDisappear:animated];
 }
 
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

- (void)weekDayPickerViewController:(WeekDayPickerViewController *)controller didSave:(NSInteger)day {
	[self.navigationController popViewControllerAnimated:YES];
	self.employer.startOfWorkWeek = day;
	[jobTableView reloadData];
}

- (void)didCancel:(WeekDayPickerViewController *)controller {
	//User cancelled the week day picker view. Just release it and keep current value.
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
		case 0:
			return 3;
			break;
		case 1:
			return 1;
			break;
		default:
			return 0;
			break;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *EmployerCellIdentifier = @"EmployerCell";
	static NSString *RateCellIdentifier = @"RateCell";
	static NSString *DayCellIdentifier = @"DayCell";
	
	UITableViewCell *cell;
	
	switch (indexPath.row) {
		case 0:
			cell = [tableView dequeueReusableCellWithIdentifier:EmployerCellIdentifier];
			
			if (cell==nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:EmployerCellIdentifier] autorelease];
				cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
				cell.detailTextLabel.text = @" ";
				cell.detailTextLabel.alpha = 0;
				
				if (txtEmployer == nil) {
					txtEmployer = [[[UITextField alloc] initWithFrame:CGRectMake(cell.frame.origin.x+10
																				 , cell.frame.origin.y+22, 280, 30)] autorelease];
					//txtEmployer.placeholder = NSLocalizedString(@"Required",@"Required");
					txtEmployer.adjustsFontSizeToFitWidth = YES;
					txtEmployer.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
					txtEmployer.clearsOnBeginEditing = NO;
					txtEmployer.keyboardType = UIKeyboardTypeDefault;
					txtEmployer.returnKeyType = UIReturnKeyDone;
					txtEmployer.autocorrectionType = UITextAutocorrectionTypeNo;
					txtEmployer.delegate = self;
					[txtEmployer addTarget:self action:@selector(keyboardDonePressed:) forControlEvents:UIControlEventEditingDidEndOnExit];
					txtEmployer.tag = EMPLOYER_TEXTFIELD_TAG;
					txtEmployer.font = [UIFont systemFontOfSize:14];
					
					if (employer.employerName != nil) {
						txtEmployer.text = employer.employerName;
					}
				}
				
				cell.accessoryType = UITableViewCellAccessoryNone;
				// Always add subview at end. If you add Subview first then label text, the subview will be
				// covered by the label
				[cell.contentView addSubview:txtEmployer];
			} else {
				txtEmployer = (UITextField *)[cell viewWithTag:EMPLOYER_TEXTFIELD_TAG];
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.text  = NSLocalizedString(@"Employer", @"Employer");
			
			break;
		case 1:
			cell = [tableView dequeueReusableCellWithIdentifier:RateCellIdentifier];
			
			if (cell==nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:RateCellIdentifier] autorelease];
				cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
				cell.detailTextLabel.text = @" ";
				cell.detailTextLabel.alpha = 0;
				
				if (txtRate == nil) {
					txtRate = [[[UITextField alloc] initWithFrame:CGRectMake(cell.frame.origin.x+10
																				 , cell.frame.origin.y+22, 280, 30)] autorelease];
					//txtRate.placeholder = NSLocalizedString(@"Required",@"Required");
					txtRate.adjustsFontSizeToFitWidth = YES;
					txtRate.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
					txtRate.clearsOnBeginEditing = NO;
					txtRate.keyboardType = UIKeyboardTypeNumberPad;
					txtRate.autocorrectionType = UITextAutocorrectionTypeNo;
					txtRate.delegate = self;
					[txtRate addTarget:self action:@selector(keyboardDonePressed:) forControlEvents:UIControlEventEditingDidEndOnExit];
					txtRate.tag = RATE_TEXTFIELD_TAG;
					txtRate.font = [UIFont systemFontOfSize:14];
					
					NSNumberFormatter *_currencyFormatter = [[NSNumberFormatter alloc] init];
					[_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
					[_currencyFormatter setCurrencyCode:@"USD"];
					[_currencyFormatter setNegativeFormat:@"-¤#,##0.00"];
					if (employer.hourlyRate != nil) {
						txtRate.text = [_currencyFormatter stringFromNumber:employer.hourlyRate];
						
					} else {
						txtRate.text = [_currencyFormatter stringFromNumber:[NSNumber numberWithInt:0]];
					}
					[_currencyFormatter release];
				}
				
				cell.accessoryType = UITableViewCellAccessoryNone;
				// Always add subview at end. If you add Subview first then label text, the subview will be
				// covered by the label
				[cell.contentView addSubview:txtRate];
			} else {
				txtRate = (UITextField *)[cell viewWithTag:RATE_TEXTFIELD_TAG];
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.text = NSLocalizedString(@"Hourly Rate", @"Hourly Rate");
			break;
		case 2:
			cell = [tableView dequeueReusableCellWithIdentifier:DayCellIdentifier];
			
			if (cell==nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:DayCellIdentifier] autorelease];
				cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
				cell.detailTextLabel.text = @" ";
				
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.text = NSLocalizedString(@"Start of Workweek", @"Start of Workweek");
			cell.detailTextLabel.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
			if (employer.startOfWorkWeek != -1) {
				[cell.detailTextLabel setText:(NSString *)[daysArray objectAtIndex:employer.startOfWorkWeek]];
			} else {
				[cell.detailTextLabel setText:@" "];
			}
			break;
		default:
			break;
	}
    return cell;
}

-(IBAction)keyboardDonePressed:(id)sender {
	[sender resignFirstResponder];
}

#pragma mark -
#pragma mark Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	switch (indexPath.row) {
		case 0:
			[txtEmployer becomeFirstResponder];
			break;
		case 1:
			[txtRate becomeFirstResponder];
			break;
		case 2:
			[self.view endEditing:YES];
			[self pickerShow];
			break;
		default:
			break;
	}
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
	[self hideButtonPressed:nil];
}

- (void)didCancelCurrency:(CurrencyEntryViewController *)controller {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)currencyEntryViewController:(CurrencyEntryViewController *)controller didSaveCurrency:(NSNumber *)amount {
	employer.hourlyRate = [amount copy];
	[jobTableView reloadData];	
	[self.navigationController popViewControllerAnimated:YES];
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//	if(buttonIndex == 1) {
//		[self.delegate didCancelToContactWHD:self];
//	}
//}

- (void)textEntryViewController:(TextEntryViewController *)controller didSaveText:(NSString *)text {
	employer.employerName = text;
	[self.navigationController popViewControllerAnimated:YES];
	
	[jobTableView reloadData];
}

- (void)didCancelText:(TextEntryViewController *)controller {
	[self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)hideButtonPressed:(id)sender {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 480);
	dayPickerView.transform = transform;
	[UIView commitAnimations];	
}



#pragma mark -
#pragma mark UIPickerView

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return 7;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [daysArray objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	employer.startOfWorkWeek = row;
	[jobTableView reloadData];
}

-(IBAction)pickerShow{
	if (employer.startOfWorkWeek == -1) {
		employer.startOfWorkWeek = 0; // Default to sunday
		[jobTableView reloadData];
	}
	
	[dayPicker selectRow:employer.startOfWorkWeek inComponent:0 animated:NO];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 156);
	dayPickerView.transform = transform;
	[self.view addSubview:dayPickerView];
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark TextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if (textField == txtEmployer) {
		if (textField.text.length >= 30 && range.length == 0)
		{
			return NO; // return NO to not change text
		}
		else {
			return YES;
		}
	} else{
		// Clear all characters that are not numbers
		// (like currency symbols or dividers)
		NSString *cleanCentString = [[textField.text
									  componentsSeparatedByCharactersInSet:
									  [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
									 componentsJoinedByString:@""];
		// Parse final integer value
		NSInteger centAmount = cleanCentString.integerValue;
		// Check the user input
		if (string.length > 0)
		{
			// Digit added
			centAmount = centAmount * 10 + string.integerValue;
		}
		else
		{
			// Digit deleted
			centAmount = centAmount / 10;
		}
		
		if (centAmount < 100000) {
			// Update call amount value
			self.currencyAmount = [[[NSNumber alloc] initWithFloat:(float)centAmount / 100.0f] autorelease];
			// Write amount with currency symbols to the textfield
			NSNumberFormatter *_currencyFormatter = [[NSNumberFormatter alloc] init];
			[_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
			[_currencyFormatter setCurrencyCode:@"USD"];
			[_currencyFormatter setNegativeFormat:@"-¤#,##0.00"];
			textField.text = [_currencyFormatter stringFromNumber:self.currencyAmount];
			[_currencyFormatter release];
		}
		// Since we already wrote our changes to the textfield
		// we don't want to change the textfield again
		return NO;
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
	[employer release];
	[daysArray release];
	[jobTableView release];
	[currencyAmount release];
	[dayPicker release];
	[dayPickerView release];
    [super dealloc];
}


@end

