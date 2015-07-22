//
//  JobListViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "JobListViewController.h"
#import "EmployerController.h"
#import "Employer.h"

@implementation JobListViewController
@synthesize delegate;
@synthesize jobsTableView;
@synthesize employersArray;
@synthesize selectedEmployers;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.title = NSLocalizedString(@"Employers",@"Employers");
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveButtonPressed:)];
	[self.navigationItem setRightBarButtonItem:saveButton animated:NO];
	[saveButton release];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
	[self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
	[cancelButton release];
	
	jobsTableView.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripe3.png"]];
	
	//Data Load
	employersArray = [[NSMutableArray alloc] init];
	[employersArray addObjectsFromArray:[EmployerController getEmployers]];
	
	if (selectedEmployers == nil) {
		selectedEmployers = [[NSMutableArray alloc]init];
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	// Unselect the selected row if any
	NSIndexPath* selection = [self.jobsTableView indexPathForSelectedRow];
	if (selection)
		[self.jobsTableView deselectRowAtIndexPath:selection animated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [employersArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	BOOL found = NO;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
    
	Employer *e = (Employer *)[employersArray objectAtIndex:indexPath.row];
	
	[cell.textLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
	[cell.textLabel setText:e.employerName];
	
	for (Employer *emp in selectedEmployers) {
		if (e.employerId == emp.employerId) {
			found = YES;
		}
	}
	
	if (!found) {
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	
	cell.isAccessibilityElement = YES;
	cell.accessibilityTraits = UIAccessibilityTraitButton;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	BOOL found = NO;
	Employer *matchedEmployer = nil;
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	Employer *e = (Employer *)[employersArray objectAtIndex:indexPath.row];
	
	for (Employer *emp in selectedEmployers) {
		if (e.employerId == emp.employerId) {
			found = YES;
			matchedEmployer = emp;
		}
	}
	
	if (found) {
		[selectedEmployers removeObject:matchedEmployer];
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else {
		[selectedEmployers addObject:[employersArray objectAtIndex:indexPath.row]];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	
	// Deselect the row
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)cancelButtonPressed:(id)sender {
	[self.delegate didCancelJobs:self];
}

-(void)saveButtonPressed:(id)sender {
	[self.delegate jobListViewController:self didSaveJobs:selectedEmployers];
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
	[employersArray release];
	[jobsTableView release];
	[selectedEmployers release];
    [super dealloc];
}


@end
