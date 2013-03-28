//
//  ReviewDaysViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "ReviewDaysViewController.h"
#import "TimeEntryController.h"
#import "GradientView.h"
#import "ClearLabelsCellView.h"
#import "TimeEntry.h"

@implementation ReviewDaysViewController

@synthesize employerId;
@synthesize date;
@synthesize timeEntries;
@synthesize timeTableView;
@synthesize employerName;
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
	timeTableView.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripe3.png"]];
	
	if (employerId != 0 && self.date != nil) {
		timeEntries = [[TimeEntryController getTimeEntriesForDay:self.date forEmployer:self.employerId]retain];
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

-(void)didCancelEntryToContactWHD:(TimeEntryViewController *)controller {
	[self.navigationController popViewControllerAnimated:YES];
	
	//[self.navigationController dismissModalViewControllerAnimated:YES];
	[self.tabBarController setSelectedIndex:4];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return [self.timeEntries count];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
		
    static NSString *CellIdentifier = @"Cell";
	
	ClearLabelsCellView *cell;
				
	TimeEntry *te = [timeEntries objectAtIndex:indexPath.row];
	
	cell = (ClearLabelsCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[ClearLabelsCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.backgroundView = [[[GradientView alloc] init] autorelease];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
		
	NSString *hoursString = [NSString stringWithFormat:@"%@ - %@ ", [formatter stringFromDate:te.startTime], [formatter stringFromDate:te.endTime]];
	cell.textLabel.text = hoursString;
	
	[formatter release];
	
	cell.isAccessibilityElement = YES;
	cell.accessibilityTraits = UIAccessibilityTraitButton;
	
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (timeEntries!=nil && [timeEntries count] > 0) {
		return self.employerName;
	} else {
		return @"";
	}

	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	TimeEntry *te = [timeEntries objectAtIndex:indexPath.row];
	
	TimeEntryViewController *controller = [[TimeEntryViewController alloc] initWithNibName:@"TimeEntryViewController" bundle:nil];
	
	controller.timeEntryId = te.timeEntryId;
	controller.editMode = NO;
	controller.delegate = self;
	
	[self.navigationController pushViewController:controller animated:YES];
	
	[controller release];
}

- (void)didDelete:(TimeEntryViewController *)controller {
	[timeEntries release];
	timeEntries = [[TimeEntryController getTimeEntriesForDay:self.date forEmployer:self.employerId]retain];
	[timeTableView reloadData];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)timeEntryViewController:(TimeEntryViewController *)controller didSaveTimeEntry:(NSInteger)result {
	if (employerId != 0 && self.date != nil) {
		[timeEntries release];
		timeEntries = [[TimeEntryController getTimeEntriesForDay:self.date forEmployer:self.employerId]retain];
	}
	[timeTableView reloadData];
}

-(void)didCancelTimeEntry:(TimeEntryViewController *)controller {
}

-(void)didCancelToContactWHD:(TimeEntryViewController *)controller {
	[self.navigationController popViewControllerAnimated:YES];
	[self.tabBarController setSelectedIndex:4];
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
	[date release];
	[timeEntries release];
	[timeTableView release];
	[employerName release];
    [super dealloc];
}


@end
