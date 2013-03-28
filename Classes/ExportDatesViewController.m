//
//  ExportDatesViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "ExportDatesViewController.h"


@implementation ExportDatesViewController

@synthesize datePicker;
@synthesize datesTableView;
@synthesize clearButton;
@synthesize startDate;
@synthesize endDate;
@synthesize delegate;

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
	
	datesTableView.backgroundColor = [UIColor clearColor];
	datesTableView.scrollEnabled = NO;
	datesTableView.allowsSelection = YES;
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripe3.png"]];
	self.title = NSLocalizedString(@"Report Dates",@"Report Dates");
}

- (void)saveButtonPressed:(id)sender {
	
	if ([self.startDate compare:self.endDate] == NSOrderedDescending) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid From Date",@"Invalid From Date") message:NSLocalizedString(@"From date must be less than the To date.", @"Date validation message") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		NSMutableArray *dateValues = [NSMutableArray arrayWithCapacity:2];
		if (self.startDate != nil) {
			[dateValues addObject:self.startDate];
		} else {
			[dateValues addObject:[NSNull null]];
		}
		
		if (self.endDate != nil) {
			[dateValues addObject:self.endDate];
		} else {
			[dateValues addObject:[NSNull null]];
		}
		
		[self.delegate exportDatesViewController:self didSaveDates:dateValues];
	}
}

- (void)cancelButtonPressed:(id)sender {
	[self.delegate didCancelDates:self];
}

- (IBAction)dateValueChanged:(id)sender {
	NSIndexPath *path = [datesTableView indexPathForSelectedRow];
	
	switch (path.row) {
		case 0:
			self.startDate = [datePicker date];
			if (self.endDate == nil) {
				self.endDate = [datePicker date];
			}
			break;
		case 1:
			self.endDate = [datePicker date];
			if (self.startDate == nil) {
				self.startDate = [datePicker date];
			}
			break;	
		default:
			break;
	}
	[datesTableView reloadData];
	[datesTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:path.row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (IBAction)clearButtonTapped:(id)sender {
	self.startDate = nil;
	self.endDate = nil;
	
	[datesTableView reloadData];
	
	[datesTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];	
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return 2;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init]autorelease];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
	
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	switch (indexPath.section) {
		case 0:
			if (indexPath.row == 0) {
				[cell.textLabel setText:NSLocalizedString(@"From",@"From")];
				if (self.startDate == nil) {
					[cell.detailTextLabel setText:@" "];
				} else {
					[cell.detailTextLabel setText:[formatter stringFromDate:self.startDate]];
				}
			} else if (indexPath.row == 1) {
				[cell.textLabel setText:NSLocalizedString(@"To",@"To")];
				if (self.endDate == nil) {
					[cell.detailTextLabel setText:@" "];
				} else {
					[cell.detailTextLabel setText:[formatter stringFromDate:self.endDate]];
				}
			}
			break;
		default:
			break;
	}
	
	if (isStart) {
		[datesTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
		if (self.startDate != nil) {
			datePicker.date = self.startDate;
		} else {
			self.startDate = [NSDate date];
			self.endDate = [NSDate date];
			datePicker.date = self.startDate;
			
			[cell.detailTextLabel setText:[formatter stringFromDate:self.startDate]];
		}
		
		isStart = NO;
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	switch (indexPath.row) {
		case 0:
			if (self.startDate != nil) {
				[datePicker setDate:self.startDate animated:YES];
			}
			break;
		case 1:
			if (self.endDate != nil) {
				[datePicker setDate:self.endDate animated:YES];
			}
		default:
			break;
	}
}


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
	[datesTableView release];
	[clearButton release];
	[startDate release];
	[endDate release];
    [super dealloc];
}


@end
