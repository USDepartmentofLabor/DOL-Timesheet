//
//  TimeEntryViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "TimeEntryViewController.h"
#import "TimeEntryController.h"
#import "DateConversion.h"
#import "UITableViewCellWithSubtitle.h"

#define RIGHT_LABEL_TAG 1001

@implementation TimeEntryViewController

@synthesize timeTableView;
@synthesize employer;
@synthesize timeEntry;
@synthesize otherBreaks;
@synthesize delegate;
@synthesize footerView;
@synthesize editMode;
@synthesize timeEntryId;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Create save Bar Button Item
	//UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed:)];
    //self.navigationItem.rightBarButtonItem = saveButton; //Assign save button as right button on Navigation Bar
	//[saveButton release]; //Release button retain, navigation bar is retaining it
	//****************************
	
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	//UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
	//[self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
	//[cancelButton release];
	
	//Set table view color to transparent so the background pattern is visible
	timeTableView.backgroundColor = [UIColor clearColor];
	
	//Set the view background color to our striped pattern image.
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripe3.png"]];
	
	self.timeTableView.allowsSelection = NO;
	self.timeTableView.allowsSelectionDuringEditing = YES;
	
	if (self.timeEntryId > 0) {
		self.timeEntry = [TimeEntryController getTimeEntry:self.timeEntryId];
		self.otherBreaks = [TimeEntryController getOtherBreaksForTimeEntryId:self.timeEntryId];
		self.title = NSLocalizedString(@"Summary", @"Summary");
	} else {
		self.title = NSLocalizedString(@"Time Entry", @"Time Entry view title");
		//assign the new time entry
		self.timeEntry = [[[TimeEntry alloc]init]autorelease];
		
		//Copy default hourly rate and employer
		self.timeEntry.hourlyRate = self.employer.hourlyRate;
		self.timeEntry.employerId = self.employer.employerId;
		
		self.editMode = YES;
		self.editing = YES;
	}
}

 - (void)viewWillAppear:(BOOL)animated {
	 [super viewWillAppear:animated];
	 
	 //Unselect the selected row if any. This will remove the row highlight when we return from a pushed screen.
	 NSIndexPath* selection = [self.timeTableView indexPathForSelectedRow];
	 if (selection) {
		 [self.timeTableView deselectRowAtIndexPath:selection animated:YES];
	 }
	 //********************
 }

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	NSInteger result;
	
	if (editing == NO ) {
		result = [self saveButtonPressed:nil];
		if (result == 0) {
			[super setEditing:editing animated:animated];
			[timeTableView setEditing:editing animated:animated];
			footerView.hidden = YES;
		}
	} else {
		[super setEditing:editing animated:animated];
		[timeTableView setEditing:editing animated:animated];
		if (!editing || self.timeEntry.timeEntryId == 0) {
			footerView.hidden = YES;
		} else {
			footerView.hidden = NO;
		}
	}
	[timeTableView reloadData];
}

-(void)deleteButtonPressed:(id)sender {
	UIActionSheet *deleteActionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") destructiveButtonTitle:NSLocalizedString(@"Delete",@"Delete") otherButtonTitles:nil];
	deleteActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[deleteActionSheet showInView:self.tabBarController.view];
	[deleteActionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 0) {
		[TimeEntryController deleteTimeEntry:self.timeEntry];
		[self.delegate didDelete:self];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath  *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

#pragma mark -
#pragma mark Custom Actions

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 1) {
		[self.delegate didCancelEntryToContactWHD:self];
	}
}

- (NSInteger)saveButtonPressed:(id)sender {
	
	UIAlertView *alert;
	if (timeEntry.startTime == nil) {
		alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Required field", @"Required field") message:NSLocalizedString(@"Started Work is required.", @"Started Work is required.") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return -1;
	}
	
	if (timeEntry.endTime == nil) {
		alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Required field", @"Required field") message:NSLocalizedString(@"Stopped Work is required.", @"Stopped Work is required.") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return -1;
	}
	
	if (timeEntry.hourlyRate == nil) {
		alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Required field", @"Required field") message:NSLocalizedString(@"Hourly rate is required.", @"Time entry validation messages") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return -1;
	}
	
	//if ([timeEntry.hourlyRate doubleValue] < 7.25 ) {
	//	alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Minimum Wage Alert Title", @"Alert View title when hourly rate is < minimum wage") message:NSLocalizedString(@"Minimum Wage Alert Message",@"Hourly rate warning alert view") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	//	[alert show];
	//	[alert release];
	//	return -1;
	//}
	
	//Compare dates - Start must be less than Stop
	if ([timeEntry.startTime compare:timeEntry.endTime] == NSOrderedDescending) {
		alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid Start Time",@"Invalid Start Time") message:NSLocalizedString(@"Started Work must be earlier than Stopped Work.", @"Started Work must be earlier than Stopped Work.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return -1;
	}
	
	NSMutableArray *combinedArray = [NSMutableArray array];
	
	if (self.otherBreaks != nil && [otherBreaks count] == 2) {
		[combinedArray addObjectsFromArray:[self.otherBreaks objectAtIndex:0]];
		[combinedArray addObjectsFromArray:[self.otherBreaks objectAtIndex:1]];
	}
	
	NSInteger result;
	if (timeEntry.timeEntryId == 0) {
		result = [TimeEntryController addTimeEntry:self.timeEntry withBreaks:combinedArray];
		
		if (result == -100) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Hours per week exceeded",@"Hours per week exceeded") message:NSLocalizedString(@"The total amount of hours in a 7 day period cannot exceed 168 hours.",@"The total amount of hours in a 7 day period cannot exceed 168 hours.") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"OK") otherButtonTitles:nil];
			[alert show];
			
			[alert release];
			
			return -1;
		}
		
		timeEntry.timeEntryId = result;
	} else {
		result = [TimeEntryController updateTimeEntry:self.timeEntry withBreaks:combinedArray];
		if (result == -100) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Hours per week exceeded",@"Hours per week exceeded") message:NSLocalizedString(@"The total amount of hours in a 7 day period cannot exceed 168 hours.",@"The total amount of hours in a 7 day period cannot exceed 168 hours.") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"OK") otherButtonTitles:nil];
			[alert show];
			
			[alert release];
			
			return -1;
		}
	}
	
	[self.delegate timeEntryViewController:self didSaveTimeEntry:result];
	return 0;
}

-(void)cancelButtonPressed:(id)sender {
	[self.delegate didCancelTimeEntry:self];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
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
		case 2:
			return 1;
			break;
		default:
			return 0;
			break;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellWithSubtitle *cell;
    //UILabel *rightLabel; // Label that will display the cell value
	
    static NSString *CellIdentifier = @"Cell";
	static NSString *commentsCellIdentifier = @"CommentsCell";
    
	
	// Create cell
	// Section 0: Data Entry
	// Section 1: Comments
	if (indexPath.section == 0) { //Data entry section
		cell = (UITableViewCellWithSubtitle *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier]; // Request a cell from the queue
		if (cell == nil) { // If no cell is available, create a new one
			cell = [[[UITableViewCellWithSubtitle alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease]; // Create reusable cell
			cell.detailTextLabel.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
			cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
		}
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"EEEE MMM d, yyyy h:mm a"];

		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = NSLocalizedString(@"Started Work",@"Started Work");
				cell.textLabel.adjustsFontSizeToFitWidth = YES; // To fix text in spanish
				cell.detailTextLabel.text = [dateFormatter stringFromDate:self.timeEntry.startTime];
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				break;
			case 1:
				cell.textLabel.text = NSLocalizedString(@"Stopped Work", @"Stopped Work");
				cell.detailTextLabel.text = [dateFormatter stringFromDate:self.timeEntry.endTime];
				cell.textLabel.adjustsFontSizeToFitWidth = YES; // To fix text in spanish
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				break;
			default:
				break;
		}
		[dateFormatter release];
	} else if (indexPath.section == 1) {
		cell = (UITableViewCellWithSubtitle *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier]; // Request a cell from the queue
		if (cell == nil) { // If no cell is available, create a new one
			cell = [[[UITableViewCellWithSubtitle alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease]; // Create reusable cell
			cell.detailTextLabel.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
			cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
		}
		
		if (indexPath.row == 0) {
			NSTimeInterval mealInterval = 0;
			NSTimeInterval otherInterval = 0;
			
			if (otherBreaks != nil && [otherBreaks count] == 2) {
				NSMutableArray *mealArray = [otherBreaks objectAtIndex:0];
				NSMutableArray *otherArray = [otherBreaks objectAtIndex:1];
				
				for ( OtherBreaks *ob in mealArray) {
					mealInterval += ob.breakTime;
				}
				
				for ( OtherBreaks *ob in otherArray) {
					otherInterval += ob.breakTime;
				}
			}
			
			
			cell.textLabel.text = NSLocalizedString(@"Breaks",@"Breaks");
			
			unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
			
			NSDate *d1 = [[NSDate alloc] init];
			NSDate *d2 = [[NSDate alloc] initWithTimeInterval:(mealInterval) sinceDate:d1];
			
			NSDateComponents *conversionInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:d1 toDate:d2 options:0];
			[d1 release];
			[d2 release];
			
			NSString *mealString = [NSString stringWithFormat:@"%@: %02dh %02dm", NSLocalizedString(@"Meal",@"Meal"), [conversionInfo hour], [conversionInfo minute]];
			//Accesibility
			//cell.detailTextLabel.isAccessibilityElement = YES;
			//cell.detailTextLabel.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"Meal Breaks. %d hours and %d minutes", @"Accesibility for Time Entry"), [conversionInfo hour], [conversionInfo minute]];
			//
			
			//Build Accesibility Label
			NSMutableString *accesibilityLabel = [NSMutableString stringWithString:NSLocalizedString(@"Meal Breaks", "Meal Breaks")];
			[accesibilityLabel appendString:@". "];
			[accesibilityLabel appendFormat:NSLocalizedString(@"%d hours and %d minutes", @"Accesibility for Time Entry"), [conversionInfo hour], [conversionInfo minute]];
			[accesibilityLabel appendString:@". "];
			//
			
			// Other Breaks
			
			d1 = [[NSDate alloc] init];
			d2 = [[NSDate alloc] initWithTimeInterval:(otherInterval) sinceDate:d1];
			
			conversionInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:d1 toDate:d2 options:0];
			[d1 release];
			[d2 release];
			
			NSString *otherString = [NSString stringWithFormat:@"%@: %02dh %02dm", NSLocalizedString(@"Other", @"Other"), [conversionInfo hour], [conversionInfo minute]];
			
			//Add Other breaks to Accesibility Label
			[accesibilityLabel appendString:NSLocalizedString(@"Other Breaks", "Other Breaks")];
			[accesibilityLabel appendString:@". "];
			[accesibilityLabel appendFormat:NSLocalizedString(@"%d hours and %d minutes", @"Accesibility for Time Entry"), [conversionInfo hour], [conversionInfo minute]];
			[accesibilityLabel appendString:@". "];
			//
			
			//Assign Accesibility Label
			cell.detailTextLabel.isAccessibilityElement = YES;
			cell.detailTextLabel.accessibilityLabel = accesibilityLabel;
			
			cell.detailTextLabel.numberOfLines = 2;
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@", mealString, otherString];
			
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		} else {
			cell.textLabel.text = NSLocalizedString(@"Hourly Rate",@"Hourly Rate");
			
			NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
			[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
			[currencyFormatter setCurrencyCode:@"USD"];
			[currencyFormatter setNegativeFormat:@"-¤#,##0.00"];
			
			cell.detailTextLabel.text = [currencyFormatter stringFromNumber:timeEntry.hourlyRate];
			
			[currencyFormatter release];
			
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		}
	}
	else if (indexPath.section == 2){ // Comments section
		cell = (UITableViewCellWithSubtitle *)[tableView dequeueReusableCellWithIdentifier:commentsCellIdentifier]; // Request a cell from the queue
		
		if (cell == nil) { // If no cell is available, create a new one
			cell = [[[UITableViewCellWithSubtitle alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:commentsCellIdentifier] autorelease];
			cell.detailTextLabel.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
			cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
		}
		
		cell.textLabel.text = NSLocalizedString(@"Comments", @"Comments");
		cell.detailTextLabel.numberOfLines = 0;
		
		cell.detailTextLabel.text = timeEntry.comments;
	}
	
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (section == 0) {
		
		unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
		NSDateComponents *conversionInfo;
		if (timeEntry.startTime == nil || timeEntry.endTime == nil) {
			conversionInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:timeEntry.startTime toDate:timeEntry.startTime options:0];
		} else {
			conversionInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:timeEntry.startTime toDate:timeEntry.endTime options:0];
		}
		
		UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 28)] autorelease];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont systemFontOfSize:15];
		label.textAlignment = UITextAlignmentCenter;
		label.textColor = [UIColor darkGrayColor];
		label.text = [NSString stringWithFormat:NSLocalizedString(@"Sub-Total: %02dh %02dm",@"Sub-Total"), [conversionInfo hour], [conversionInfo minute]];
		//Accesibility
		label.isAccessibilityElement = YES;
		label.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"Sub-Total, %d hours and %d minutes", @"Accesibility for time entry"), [conversionInfo hour], [conversionInfo minute]];
		//
		return label;
	} else if (section == 1) {
		
		NSTimeInterval mealInterval = 0;
		NSTimeInterval otherInterval = 0;
		
		if (otherBreaks != nil && [otherBreaks count] == 2) {
			NSMutableArray *mealArray = [otherBreaks objectAtIndex:0];
			NSMutableArray *otherArray = [otherBreaks objectAtIndex:1];
			
			for ( OtherBreaks *ob in mealArray) {
				mealInterval += ob.breakTime;
			}
			
			for ( OtherBreaks *ob in otherArray) {
				//if (ob.breakTime > 1200) { //Removed 20 minute rule as per client request.
					otherInterval += ob.breakTime;
				//}
			}
		}
		
		NSDateComponents *conversionInfo;
		
		if (timeEntry.startTime == nil || timeEntry.endTime == nil) {
			conversionInfo = [[NSCalendar currentCalendar] components: NSSecondCalendarUnit fromDate:timeEntry.startTime toDate:timeEntry.startTime options:0];
		} else {
			conversionInfo = [[NSCalendar currentCalendar] components: NSSecondCalendarUnit fromDate:timeEntry.startTime toDate:timeEntry.endTime options:0];
		}
		
		NSTimeInterval worked = [[NSNumber numberWithUnsignedInt:[conversionInfo second]] doubleValue];
		
		worked -= (mealInterval + otherInterval);
		
		NSDate *d1 = [[NSDate alloc] init];
		NSDate *d2 = [[NSDate alloc] initWithTimeInterval:(worked) sinceDate:d1];
		
		unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
		
		conversionInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:d1 toDate:d2 options:0];
		
		[d1 release];
		[d2 release];
		
		UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 28)] autorelease];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont systemFontOfSize:15];
		label.textAlignment = UITextAlignmentCenter;
		label.textColor = [UIColor darkGrayColor];
		label.text = [NSString stringWithFormat:NSLocalizedString(@"Total Hours: %02dh %02dm", @"Accesibility for time entry"), [conversionInfo hour], [conversionInfo minute]];
		
		//Accesibility
		label.isAccessibilityElement = YES;
		label.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"Total Hours, %d hours and %d minutes", @"Accesibility for time entry"), [conversionInfo hour], [conversionInfo minute]];
		//
		return label;
	} else {
		if (!self.editing || self.timeEntry.timeEntryId == 0) {
			return nil;
		}
		if (footerView == nil) {
			footerView = [[UIView alloc] init];
			
			//we would like to show a gloosy red button, so get the image first
			UIImage *image = [[UIImage imageNamed:@"redButton.png"]
							  stretchableImageWithLeftCapWidth:12 topCapHeight:0];
			
			//create the button
			//ColorfulButton *disclaimerButton = [[ColorfulButton alloc] initWithFrame:CGRectMake(10, 10, 300, 44)];
			UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			[sendButton setBackgroundImage:image forState:UIControlStateNormal];
			
			
			//the button should be as big as a table view cell
			[sendButton setFrame:CGRectMake(10, 10, 300, 44)];
			
			//set title, font size and font color
			[sendButton setTitle:NSLocalizedString(@"Delete",@"Delete") forState:UIControlStateNormal];
			[sendButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
			[sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			
			//set action of the button
			[sendButton addTarget:self action:@selector(deleteButtonPressed:)
				 forControlEvents:UIControlEventTouchUpInside];
			
			[footerView addSubview:sendButton];
			
		}
		
		footerView.hidden = !self.editing || self.timeEntry.timeEntryId == 0;
		return footerView;
	}

}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section <= 1) {
		return 28;
	} else {
		return 80;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *titleText;
	NSString *subtitleText;
	
	CGSize titleSize;
	CGSize subtitleSize;
	
	if (indexPath.section == 1 && indexPath.row == 0) {
		return 65;
	}
	
	if(indexPath.section != 2){
		return 50;
	} else {
		titleText = @"Comments";
		if ([timeEntry.comments length] > 0) {
			subtitleText = timeEntry.comments;
		} else {
			subtitleText = NSLocalizedString(@"No comments",@"No comments");
		}
	}
	CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
	
	subtitleSize = [subtitleText sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	titleSize = [titleText sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	
	return titleSize.height + subtitleSize.height + 20;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (indexPath.row == 0 || indexPath.row == 1) {
			TimePickerViewController *timePickerViewController = [[TimePickerViewController alloc] initWithNibName:@"TimePickerViewController" bundle:nil];
			
			if(indexPath.row == 0){
				timePickerViewController.displayText = NSLocalizedString(@"Started Work", @"Started Work");
				
				if (timeEntry.startTime != nil) {
					timePickerViewController.selectedDate = timeEntry.startTime;
				}
			}
			if(indexPath.row == 1){
				timePickerViewController.displayText = NSLocalizedString(@"Stopped Work",@"Stopped Work");
				
				if (timeEntry.endTime != nil) {
					timePickerViewController.selectedDate = timeEntry.endTime;
				} else if (timeEntry.startTime != nil) {
					timePickerViewController.selectedDate = timeEntry.startTime;
				}
			}
			
			timePickerViewController.delegate = self;
			[self.navigationController pushViewController:timePickerViewController animated:YES];
			[timePickerViewController release];
		}
		
	} else if (indexPath.section == 1) {
		
		/* if (indexPath.row == 0) {
					TimerViewController *timerController = [[TimerViewController alloc] initWithNibName:@"TimerViewController" bundle:nil];
					timerController.selectedValue = timeEntry.mealBreak;
					timerController.delegate = self;
					[self.navigationController pushViewController:timerController animated:YES];
				} */
		if (indexPath.row == 0) {
			BreaksViewController *breaksViewController = [[BreaksViewController alloc] initWithNibName:@"BreaksViewController" bundle:nil];
			breaksViewController.dataList = self.otherBreaks;
			breaksViewController.delegate = self;
			[self.navigationController pushViewController:breaksViewController animated:YES];
			[breaksViewController release];
		}
		if (indexPath.row == 1) {
			[self.timeTableView deselectRowAtIndexPath:indexPath animated:YES];
			CurrencyEntryViewController *currencyViewController = [[CurrencyEntryViewController alloc] initWithNibName:@"CurrencyEntryViewController" bundle:nil];
			 currencyViewController.delegate = self;
			 currencyViewController.placeHolderText = NSLocalizedString(@"Hourly Rate",@"Hourly Rate");
			 currencyViewController.title = NSLocalizedString(@"Hourly Rate",@"Hourly Rate");
			 
			 currencyViewController.currencyAmount = timeEntry.hourlyRate;
			 
			 [self.navigationController pushViewController:currencyViewController animated:YES];
		}
	} else {
		CommentsEntryViewController *commentsEntryViewController = [[CommentsEntryViewController alloc] initWithNibName:@"CommentsEntryViewController" bundle:nil];
		commentsEntryViewController.delegate = self;
		
		//Set current value
		if (self.timeEntry.comments != nil) {
			commentsEntryViewController.commentsValue = self.timeEntry.comments;
		}
		
		[self.navigationController pushViewController:commentsEntryViewController animated:YES];
		[commentsEntryViewController release];
	}

}

- (void)didCancelDate:(TimePickerViewController *)controller {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)timePickerViewController:(TimePickerViewController *)controller didSaveDate:(NSDate *)dateChosen {
	
	
	NSDateComponents *dc = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:dateChosen];
						   
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:[dc year]];
	[comps setMonth:[dc month]];
	[comps setDay:[dc day]];
	[comps setHour:[dc hour]];
	[comps setMinute:[dc minute]];
	[comps setSecond:0]; // Discard seconds because this can lead to miscalculatins e.g. 59m instead of 1h
	NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];
	[comps release];
						   
	NSIndexPath* selection = [self.timeTableView indexPathForSelectedRow];
	if (selection) {
		if (selection.row == 0) {
			self.timeEntry.startTime = date;
		} else if (selection.row == 1) {
			self.timeEntry.endTime = date;
		}
	}

	[self.navigationController popViewControllerAnimated:YES];
	
	[timeTableView reloadData];
}

- (void)commentsEntryViewController:(CommentsEntryViewController *)controller didSaveComments:(NSString *)comments {
	
	if ([comments length] == 0) {
		self.timeEntry.comments = nil;
	} else {
		self.timeEntry.comments = comments;
	}
	
	[self.navigationController popViewControllerAnimated:YES];
	
	[timeTableView reloadData];
}

- (void)didCancelComments:(CommentsEntryViewController *)controller {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)didCancelCurrency:(CurrencyEntryViewController *)controller {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)currencyEntryViewController:(CurrencyEntryViewController *)controller didSaveCurrency:(NSNumber *)amount {
	self.timeEntry.hourlyRate = amount;
	[self.navigationController popViewControllerAnimated:YES];
	
	[self.timeTableView reloadData];
	
	if ([amount doubleValue] < 7.25) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Minimum Wage Alert Title", @"Alert View title when hourly rate is < minimum wage") message:NSLocalizedString(@"Minimum Wage Alert Message",@"Hourly rate warning alert view") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void) didCancelTimer:(TimerViewController *)controller {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)timerViewController:(TimerViewController *)controller didSaveTimer:(NSTimeInterval)timer {
	self.timeEntry.mealBreak = timer;
	[self.navigationController popViewControllerAnimated:YES];
	
	[self.timeTableView reloadData];
}

- (void)breaksViewController:(BreaksViewController *)controller didSaveBreaks:(NSMutableArray *)breaks {
	self.otherBreaks = breaks;
	[self.navigationController popViewControllerAnimated:YES];
	
	[self.timeTableView reloadData];
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
	[timeTableView release];
	[employer release];
	[timeEntry release];
	[otherBreaks release];
	[footerView release];
    [super dealloc];
}


@end

