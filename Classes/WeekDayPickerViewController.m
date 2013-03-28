//
//  WeekDayPickerViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "WeekDayPickerViewController.h"
#import "GradientView.h"
#import "ClearLabelsCellView.h"

@implementation WeekDayPickerViewController

@synthesize daysTableView;
@synthesize daysArray;
@synthesize daySelected;
@synthesize delegate;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	daysArray = [[NSArray arrayWithObjects:NSLocalizedString(@"Sunday", @"Sunday"), NSLocalizedString(@"Monday", @"Monday"), NSLocalizedString(@"Tuesday", @"Tuesday"), NSLocalizedString(@"Wednesday",@"Wednesday"), NSLocalizedString(@"Thursday",@"Thursday"), NSLocalizedString(@"Friday",@"Friday"), NSLocalizedString(@"Saturday", @"Saturday"), nil] retain];
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveButtonPressed:)];
	[self.navigationItem setRightBarButtonItem:saveButton animated:NO];
	[saveButton release];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
	[self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
	[cancelButton release];
	
	self.title = NSLocalizedString(@"Week Start", @"Week Start");
	//daysTableView.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripe3.png"]];
}

- (IBAction)saveButtonPressed:(id)sender {
	[self.delegate weekDayPickerViewController:self didSave:self.daySelected];
}

- (IBAction)cancelButtonPressed:(id)sender {
	[self.delegate didCancel:self];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 7;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
    
    // Configure the cell...
	
	NSString *day = [daysArray objectAtIndex:indexPath.row];
	
	if (indexPath.row == self.daySelected) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	[cell.textLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
	[cell.textLabel setText:day];
	
    return cell;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell;
	
	self.daySelected = indexPath.row;
	for (int i=0; i < 7; i++) {
		cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
		if ( i != indexPath.row ) {
			cell.accessoryType = UITableViewCellAccessoryNone;
		} else {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
	}
	
	// Deselect the row
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
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
	[daysTableView release];
	[daysArray release];
    [super dealloc];
}


@end
