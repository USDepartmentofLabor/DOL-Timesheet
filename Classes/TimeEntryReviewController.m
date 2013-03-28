//
//  TimeEntryReviewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "TimeEntryReviewController.h"
#import "BreaksReviewController.h"
#import "TimeEntryController.h"

@implementation TimeEntryReviewController

@synthesize timeTableView;
@synthesize timeEntry;
@synthesize otherBreaks;
@synthesize footerView;
@synthesize delegate;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Set view title
	self.title = NSLocalizedString(@"Time Entry", @"Time Entry view title");;
	
	//Set table view color to transparent so the background pattern is visible
	timeTableView.backgroundColor = [UIColor clearColor];
	
	//Set the view background color to our striped pattern image.
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripe3.png"]];
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
	UITableViewCell *cell;
    //UILabel *rightLabel; // Label that will display the cell value
	
    static NSString *CellIdentifier = @"Cell";
	static NSString *commentsCellIdentifier = @"CommentsCell";
    
	
	// Create cell
	// Section 0: Data Entry
	// Section 1: Comments
	if (indexPath.section == 0) { //Data entry section
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; // Request a cell from the queue
		if (cell == nil) { // If no cell is available, create a new one
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease]; // Create reusable cell
			cell.detailTextLabel.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
			cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
		}
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"EEEE MMM d, yyyy h:mm a"];
		
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = NSLocalizedString(@"Time Arrived at Worksite",@"Time Arrived at Worksite");
				
				cell.detailTextLabel.text = [dateFormatter stringFromDate:self.timeEntry.startTime];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.accessoryType = UITableViewCellAccessoryNone;
				break;
			case 1:
				cell.textLabel.text = NSLocalizedString(@"Time Leaving Worksite", @"Time Leaving Worksite");
				cell.detailTextLabel.text = [dateFormatter stringFromDate:self.timeEntry.endTime];
				
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.accessoryType = UITableViewCellAccessoryNone;
				break;
			default:
				break;
		}
		[dateFormatter release];
	} else if (indexPath.section == 1) {
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; // Request a cell from the queue
		if (cell == nil) { // If no cell is available, create a new one
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease]; // Create reusable cell
			cell.detailTextLabel.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
			cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
		}
		
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = NSLocalizedString(@"Meal Break",@"Meal Break");
				
				if (self.timeEntry.mealBreak > 0) {
					
					unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
					
					NSDate *d1 = [[NSDate alloc] init];
					NSDate *d2 = [[NSDate alloc] initWithTimeInterval:(self.timeEntry.mealBreak) sinceDate:d1];
					
					NSDateComponents *conversionInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:d1 toDate:d2 options:0];
					[d1 release];
					[d2 release];
					
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%02dh %02dm", [conversionInfo hour], [conversionInfo minute]];
					//Accesibility
					cell.detailTextLabel.isAccessibilityElement = YES;
					cell.detailTextLabel.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"%d hours and %d minutes", @"Accesibility for Time Entry"), [conversionInfo hour], [conversionInfo minute]];
					//
					
				} else {
					cell.detailTextLabel.text = @"";
				}
				
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.accessoryType = UITableViewCellAccessoryNone;
				break;
			case 1:
				cell.textLabel.text = NSLocalizedString(@"Other Breaks", @"Other Breaks");
				
				NSTimeInterval breaksInterval = 0;
				
				for ( OtherBreaks *ob in otherBreaks) {
					breaksInterval += ob.breakTime;
				}
				
				if (breaksInterval > 0) {
					
					unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
					
					NSDate *d1 = [[NSDate alloc] init];
					NSDate *d2 = [[NSDate alloc] initWithTimeInterval:(breaksInterval) sinceDate:d1];
					
					NSDateComponents *conversionInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:d1 toDate:d2 options:0];
					[d1 release];
					[d2 release];
					
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%02dh %02dm", [conversionInfo hour], [conversionInfo minute]];
					//Accesibility
					cell.detailTextLabel.isAccessibilityElement = YES;
					cell.detailTextLabel.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"%d hours and %d minutes ", @"Accesibility for Time Entry"), [conversionInfo hour], [conversionInfo minute]];
					
				} else {
					cell.detailTextLabel.text = @"";
				}
				
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			case 2:
				cell.textLabel.text = NSLocalizedString(@"Hourly Rate",@"Hourly Rate");
				
				NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
				[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
				[currencyFormatter setCurrencyCode:@"USD"];
				[currencyFormatter setNegativeFormat:@"-¤#,##0.00"];
				
				cell.detailTextLabel.text = [currencyFormatter stringFromNumber:timeEntry.hourlyRate];
				
				[currencyFormatter release];
				
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.accessoryType = UITableViewCellAccessoryNone;
				break;
			default:
				break;
		}
	}
	else if (indexPath.section == 2){ // Comments section
		cell = [tableView dequeueReusableCellWithIdentifier:commentsCellIdentifier]; // Request a cell from the queue
		
		if (cell == nil) { // If no cell is available, create a new one
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:commentsCellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.detailTextLabel.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
			cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
		}
		
		cell.textLabel.text = NSLocalizedString(@"Comments", @"Comments");
		cell.detailTextLabel.numberOfLines = 0;
		
		cell.detailTextLabel.text = timeEntry.comments;
	}
	
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
		
		NSTimeInterval breaksInterval = 0;
		
		for ( OtherBreaks *ob in otherBreaks) {
			if (ob.breakTime > 1200) {
				breaksInterval += ob.breakTime;
			}
		}
		
		NSDateComponents *conversionInfo;
		
		if (timeEntry.startTime == nil || timeEntry.endTime == nil) {
			conversionInfo = [[NSCalendar currentCalendar] components: NSSecondCalendarUnit fromDate:timeEntry.startTime toDate:timeEntry.startTime options:0];
		} else {
			conversionInfo = [[NSCalendar currentCalendar] components: NSSecondCalendarUnit fromDate:timeEntry.startTime toDate:timeEntry.endTime options:0];
		}
		
		NSTimeInterval worked = [[NSNumber numberWithUnsignedInt:[conversionInfo second]] doubleValue];
		
		worked -= (timeEntry.mealBreak + breaksInterval);
		
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
		
		return footerView;
	}
	
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
	if (indexPath.section == 1) {
		if (indexPath.row == 1) {
			BreaksReviewController *breaksViewController = [[BreaksReviewController alloc] initWithNibName:@"BreaksReviewController" bundle:nil];
			breaksViewController.dataList = [NSMutableArray arrayWithArray:self.otherBreaks];
			[self.navigationController pushViewController:breaksViewController animated:YES];
			[breaksViewController release];
		}
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
	[timeTableView release];
	[timeEntry release];
	[otherBreaks release];
	[footerView release];
    [super dealloc];
}


@end
