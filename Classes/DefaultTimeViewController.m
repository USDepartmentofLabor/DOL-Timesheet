//
//  DefaultTimeViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "DefaultTimeViewController.h"


@implementation DefaultTimeViewController

@synthesize datePicker;
@synthesize defaultTableView;
@synthesize clearButton;
@synthesize toolbar;
@synthesize startTime;
@synthesize endTime;
@synthesize mealBreakTime;
@synthesize delegate;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		isStart = YES;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	[super viewDidLoad];
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveButtonPressed:)];
	[self.navigationItem setRightBarButtonItem:saveButton animated:NO];
	[saveButton release];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
	[self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
	[cancelButton release];
	
	defaultTableView.backgroundColor = [UIColor clearColor];
	defaultTableView.scrollEnabled = NO;
	defaultTableView.allowsSelection = YES;
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripe3.png"]];
	self.title = NSLocalizedString(@"Defaults", @"Defaults");
}

- (void)saveButtonPressed:(id)sender {
	
	NSMutableArray *dateValues = [NSMutableArray arrayWithCapacity:3];
	if (self.startTime != nil) {
		[dateValues addObject:self.startTime];
	} else {
		[dateValues addObject:[NSNull null]];
	}
	
	if (self.endTime != nil) {
		[dateValues addObject:self.endTime];
	} else {
		[dateValues addObject:[NSNull null]];
	}
	
	NSNumber *meal = [NSNumber numberWithDouble:self.mealBreakTime];
	[dateValues addObject:meal];
	
	[self.delegate defaultTimeViewController:self didSaveDefaults:dateValues];
}

- (void)cancelButtonPressed:(id)sender {
	[self.delegate didCancelDefaults:self];
}

- (IBAction)dateValueChanged:(id)sender {
	NSIndexPath *path = [defaultTableView indexPathForSelectedRow];
	
	switch (path.row) {
		case 0:
			self.startTime = [datePicker date];
			break;
		case 1:
			self.endTime = [datePicker date];
			break;
		case 2:
			self.mealBreakTime = [datePicker countDownDuration];
			break;
		default:
			break;
	}
	[defaultTableView reloadData];
	[defaultTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:path.row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (IBAction)clearButtonTapped:(id)sender {
	NSIndexPath *path = [defaultTableView indexPathForSelectedRow];
	
	switch (path.row) {
		case 0:
			self.startTime = nil;
			break;
		case 1:
			self.endTime = nil;
			break;
		case 2:
			self.mealBreakTime = 0;
			break;
			
		default:
			break;
	}
	[defaultTableView reloadData];
	[defaultTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:path.row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];	
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return 3;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.detailTextLabel.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    }
		
	cell.accessoryType = UITableViewCellAccessoryNone;
	switch (indexPath.section) {
		case 0:
			if (indexPath.row == 0) {
				cell.textLabel.text = NSLocalizedString(@"Time Arrived at Worksite", @"Time Arrived at Worksite");
				if (self.startTime == nil) {
					cell.detailTextLabel.text = @" ";
				} else {
					cell.detailTextLabel.text = [formatter stringFromDate:self.startTime];
				}
			} else if (indexPath.row == 1) {
				cell.textLabel.text = NSLocalizedString(@"Time Leaving Worksite", @"Time Leaving Worksite");
				if (self.endTime == nil) {
					cell.detailTextLabel.text = @" ";
				} else {
					cell.detailTextLabel.text = [formatter stringFromDate:self.endTime];
				}
			} else if (indexPath.row == 2) {
				cell.textLabel.text = NSLocalizedString(@"Meal Break", @"Meal Break");
				if (self.mealBreakTime == 0) {
					cell.detailTextLabel.text = @" ";
				} else {
					// Get the system calendar
					NSCalendar *sysCalendar = [NSCalendar currentCalendar];
					
					NSDate *d1 = [[NSDate alloc] init];
					NSDate *d2 = [[NSDate alloc] initWithTimeInterval:self.mealBreakTime sinceDate:d1];
					
					// Get conversion to months, days, hours, minutes
					unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
					
					NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:d1 toDate:d2 options:0];
					
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%dh %dm", [conversionInfo hour], [conversionInfo minute]];
					
					cell.detailTextLabel.isAccessibilityElement = YES;
					cell.detailTextLabel.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"%d hours and %d minutes", @"Accesibility for default meal break"), [conversionInfo hour], [conversionInfo minute]];
					
					[d1 release];
					[d2 release];
				}
			}
			break;
		default:
			break;
	}
	[formatter release];

	if (isStart) {
		[defaultTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
		if (self.startTime != nil) {
			datePicker.date = self.startTime;
		}
		
		isStart = NO;
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	 
	if (indexPath.section == 0 && indexPath.row < 2 ) {
		datePicker.datePickerMode = UIDatePickerModeTime;
		switch (indexPath.row) {
			case 0:
				if (self.startTime != nil) {
					datePicker.date = self.startTime;
				}
				break;
			case 1:
				if (self.endTime != nil) {
					datePicker.date = self.endTime;
				}
			default:
				break;
		}
	}
	if (indexPath.section == 0 && indexPath.row == 2) {
		datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
		if (self.mealBreakTime == 0) {
			datePicker.date = [formatter dateFromString:@"0:00 AM"];
		} else {
			datePicker.countDownDuration = self.mealBreakTime;
		}
	}
	[formatter release];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[datePicker release];
	[defaultTableView release];
	[clearButton release];
	[toolbar release];
	[startTime release];
	[endTime release];
    [super dealloc];
}


@end
