//
//  JobViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "JobViewController.h"
#import "EmployerController.h"
#import "TimeEntryController.h"
#import "OtherBreaks.h"
#import "StartBreakViewController.h"
#import "MealDisclaimerViewController.h"
#import "Clock.h"
#import <sqlite3.h>

@implementation JobViewController

@synthesize employersArray;
@synthesize jobsTableView;
@synthesize backgroundView;
@synthesize clockArray;

@synthesize clockIsRunning;
@synthesize isOnMealBreak;
@synthesize isOnOtherBreak;
@synthesize clockStart;
@synthesize clockMealBreak;
@synthesize clockOtherBreak;
@synthesize clockEmployerId;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
    
    // View name for Google Analytics
    self.screenName = @"Timesheet Screen";
	
	self.navigationItem.leftBarButtonItem = nil;
	
	self.title = NSLocalizedString(@"Timesheet",@"Timesheet");
	
	/*
	UILabel *titleLabel = [[[UILabel alloc]init]autorelease];
	titleLabel.text = NSLocalizedString(@"Timesheet Calculator",@"Timesheet Calculator");
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
	 */
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
	
	addButton.isAccessibilityElement = YES;
	addButton.accessibilityTraits = UIAccessibilityTraitButton;
	addButton.accessibilityLabel = NSLocalizedString(@"Add Employer", "@Add Employer");
	
	[self.navigationItem setRightBarButtonItem:addButton animated:NO];
	
	[addButton release];
	
	jobsTableView.backgroundColor = [UIColor clearColor];
	jobsTableView.allowsSelectionDuringEditing = YES;
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripe3.png"]];
	backgroundView.image = [UIImage imageNamed:@"whd-background-dol.png"];
	backgroundView.alpha = 0.25f;
	
	// Data load
	employersArray = [[NSMutableArray alloc] init];
	
	[employersArray addObjectsFromArray:[EmployerController getEmployers]];
	
	if ([employersArray count] > 0) {
		self.navigationItem.leftBarButtonItem = self.editButtonItem;
	}
	
	[clockArray addObjectsFromArray:[TimeEntryController getClock]];
	
	//Clock Load
	[self reloadClock];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	// Unselect the selected row if any
	NSIndexPath* selection = [self.jobsTableView indexPathForSelectedRow];
	if (selection)
		[self.jobsTableView deselectRowAtIndexPath:selection animated:YES];
}

- (void)reloadClock {
	[clockArray release];
	clockArray = [[TimeEntryController getClock]retain];
	
	clockIsRunning = NO;
	isOnMealBreak = NO;
	isOnOtherBreak = NO;
	clockStart = nil;
	clockMealBreak = nil;
	clockOtherBreak = nil;
	clockEmployerId = 0;
	
	for (Clock *c in clockArray) {
		switch (c.clockType) {
			case Work:
				clockIsRunning = YES;
				clockEmployerId = c.employerId;
				clockStart = c.startTime;
				break;
			case MealBreak:
				if (c.endTime == nil) {
					isOnMealBreak = YES;
					clockMealBreak = c.startTime;
				}
				break;
			case OtherBreak:
				if (c.endTime == nil) {
					isOnOtherBreak = YES;
					clockOtherBreak = c.startTime;
				}
				break;
			default:
				break;
		}
	}
}

- (id)init {
	if (self = [super initWithNibName:@"JobViewController" bundle:nil]) {
		self.title = NSLocalizedString(@"Employers",@"Employers");
		
		//Tab Bar item
		UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Timesheet",@"Timesheet") image:[UIImage imageNamed:@"timesheet-icon.png"] tag:0];
		self.tabBarItem = item;
		[item release];
	}
	return self;
}

- (void)add:(id)sender
{
	EditJobViewController *editJob = [[EditJobViewController alloc] initWithNibName:@"EditJobViewController" bundle:nil];
	editJob.title = NSLocalizedString(@"Add Employer", @"Edit employer view title when in add mode.");
	
	// Create the navigation controller and present it modally.
	
	UINavigationController *navController = [[UINavigationController alloc]
											 
											 initWithRootViewController:editJob];
	
	editJob.delegate = self;
	
	navController.navigationBar.tintColor = [UIColor colorWithRed:0.8f green:0.0 blue:0.0 alpha:1];
	
	[self presentModalViewController:navController animated:YES];
	
	[editJob release];
	[navController release];
}

- (void)editJobViewController:(EditJobViewController *)controller didSave:(NSString *)text
{
	[employersArray release];
	
	[super setEditing:NO animated:NO];
	[self.jobsTableView setEditing:NO animated:NO];
	
	// Data load
	employersArray = [[NSMutableArray alloc] init];
	[employersArray addObjectsFromArray:[EmployerController getEmployers]];
	
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
	[jobsTableView reloadData];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)didCancel:(EditJobViewController *)controller
{
	[super setEditing:NO animated:NO];
	[self.jobsTableView setEditing:NO animated:NO];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark TimeEntryViewController Delegate

- (void)timeEntryViewController:(TimeEntryViewController *)controller didSaveTimeEntry:(NSInteger)result {
	
}

- (void)didCancelTimeEntry:(TimeEntryViewController *)controller {
	
}

-(void)didCancelToContactWHD:(EditJobViewController *)controller {
	[super setEditing:NO animated:NO];
	[self.jobsTableView setEditing:NO animated:NO];
	//[self.navigationController popViewControllerAnimated:YES];
	
	[self.navigationController dismissModalViewControllerAnimated:YES];
	[self.tabBarController setSelectedIndex:4];
}
-(void)didCancelEntryToContactWHD:(TimeEntryViewController *)controller {
	[super setEditing:NO animated:NO];
	[self.jobsTableView setEditing:NO animated:NO];
	[self.navigationController popViewControllerAnimated:YES];
	
	//[self.navigationController dismissModalViewControllerAnimated:YES];
	[self.tabBarController setSelectedIndex:4];
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
    static NSString *InCellIdentifier = @"InCell";
	UITableViewCell *cell;
	
	Employer *emp = (Employer *)[employersArray objectAtIndex:indexPath.row];
	
	if (clockIsRunning && clockEmployerId == emp.employerId) {
		
		
		cell = [tableView dequeueReusableCellWithIdentifier:InCellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:InCellIdentifier] autorelease];
			
		} 
		
		[cell.textLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
		[cell.textLabel setText:emp.employerName];
		
		
		NSString *startTime;
		NSString *breakTime;
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"M/d/yy h:mm a"];
		
		startTime = [formatter stringFromDate:clockStart];
		
		[formatter setDateFormat:@"h:mm a"];
		if (isOnMealBreak) {
			breakTime = [formatter stringFromDate:clockMealBreak];
		}
		if (isOnOtherBreak) {
			breakTime = [formatter stringFromDate:clockOtherBreak];
		}
		[formatter release];
		
		NSMutableString *infoText = [NSMutableString stringWithString:NSLocalizedString(@"Started work on ",@"Started work on ")];
		[infoText appendString:startTime];
		
		if (isOnMealBreak || isOnOtherBreak) {
			[infoText appendFormat:@"\n%@ %@",NSLocalizedString(@"Break started at",@"Break started at"), breakTime];
		}

		cell.detailTextLabel.numberOfLines = 2;
		cell.detailTextLabel.text = infoText;
		
		
		
		cell.detailTextLabel.textColor = [UIColor redColor];
		[cell setEditingAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

	} else {
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			
		} 
		
		[cell.textLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
		[cell.textLabel setText:emp.employerName];
		[cell setEditingAccessoryType:UITableViewCellAccessoryDisclosureIndicator];		 
	}
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	Employer *emp = (Employer *)[employersArray objectAtIndex:indexPath.row];
	
	if (clockIsRunning && clockEmployerId == emp.employerId) {
		if (isOnMealBreak || isOnOtherBreak) {
			return 70;
		} else {
			return 60;
		}
	} else {
		return 50;
	}
}

 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
	 if (editingStyle == UITableViewCellEditingStyleDelete) {
		 
		 //Stop clock if deleting employer with active clock
		 if (clockIsRunning) {
			 Employer * e = [employersArray objectAtIndex:indexPath.row];
			 if (clockEmployerId == e.employerId) {
				 [TimeEntryController resetClock];
				 [self reloadClock];
			 }
		 }
		 
		 NSInteger result = [EmployerController deleteEmployer:[employersArray objectAtIndex:indexPath.row]];
		 
		 UIAlertView *alert = nil;
		 
		 switch (result) {
			 case SQLITE_DONE:
				 [employersArray removeObjectAtIndex:indexPath.row];
				 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
				 if ([employersArray count] == 0) {
					 [jobsTableView reloadData];
				 }
				 if ([employersArray count] == 0) {
					 self.navigationItem.leftBarButtonItem = nil;
				 }
				 break;
			 default:
				 alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error deleting employer", @"Alert view title when there is an error deleting an employer") message: NSLocalizedString(@"Employer could not be deleted from the database.",@"Alert view text when there is an error deleting an employer") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				 [alert show];
				 [alert release];
				 break;
		 }
	 }   
 }

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([employersArray count] == 0) {
		return NSLocalizedString(@"Tap + to add an employer(s)", @"Instructions for adding employers");
	} else {
		return @"";
	}

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	NSIndexPath *selectedRow = [jobsTableView indexPathForSelectedRow];
	Employer *e = [employersArray objectAtIndex:selectedRow.row]; 
	
	if (!clockIsRunning) {
		//userActionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") destructiveButtonTitle:NSLocalizedString(@"Start Work",@"Start Work") otherButtonTitles:@"Manual Time Entry",nil];
		if (buttonIndex == 0) {
			Clock *clock = [[[Clock alloc]init]autorelease];
			
			clock.employerId = e.employerId;
			clock.startTime = [NSDate date];
			clock.clockType = Work;
			[TimeEntryController insertClock:clock];
			[self reloadClock];
		}
		if (buttonIndex == 1) {
			TimeEntryViewController *controller = [[TimeEntryViewController alloc]init];
			controller.employer = e;
			controller.delegate = self;
			[self.navigationController pushViewController:controller animated:YES];
			[controller release];
		}
	} else {
		if (e.employerId == clockEmployerId) {
			if (buttonIndex == 2) {
				[TimeEntryController resetClock];
				[self reloadClock];
			} else {
				if (buttonIndex == 1 && !isOnMealBreak && !isOnOtherBreak) {
					
					StartBreakViewController *controller = [[StartBreakViewController alloc] init];
					controller.delegate = self;
					
					UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:controller];
					nav.navigationBar.tintColor = [UIColor colorWithRed:0.8f green:0.0 blue:0.0 alpha:1];
					
					[self.navigationController presentModalViewController:nav animated:YES];
					
					[nav release];
					[controller release];
										
				} else if (buttonIndex != 3 && (isOnMealBreak || isOnOtherBreak)){
					if (isOnMealBreak) {
						[TimeEntryController stopClock:MealBreak];
					}
					if (isOnOtherBreak){
						[TimeEntryController stopClock:OtherBreak];
					}
					[self reloadClock];
				}
					//userActionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") destructiveButtonTitle:NSLocalizedString(@"Stop Work",@"Stop Work") otherButtonTitles:@"Start Break", @"DiscardEntry",nil];
				if (buttonIndex == 0) {
					
					if (isOnMealBreak) {
						[TimeEntryController stopClock:MealBreak];
					} 
					
					if (isOnOtherBreak){
						[TimeEntryController stopClock:OtherBreak];
					}
					
					[TimeEntryController stopClock:Work];
					[self reloadClock];
					
					//Do the time entry
					TimeEntry *entry = [[[TimeEntry alloc] init] autorelease];
					NSMutableArray *breaks = [NSMutableArray array];
					OtherBreaks *oBreak;
					
					NSDateComponents *conversionInfo; // = [[NSCalendar currentCalendar] components: NSSecondCalendarUnit fromDate:date1 toDate:date2 options:0];
					
					for (Clock *c in clockArray) {
						if (c.clockType == Work) {
							entry.employerId = c.employerId;
							entry.startTime = c.startTime;
							entry.endTime = c.endTime;
							entry.hourlyRate = e.hourlyRate;
						} else if (c.clockType == MealBreak) {
							oBreak = [[OtherBreaks alloc]init];
							oBreak.comments = c.comments;
							oBreak.breakType = 0;
							
							conversionInfo = [[NSCalendar currentCalendar] components: NSSecondCalendarUnit fromDate:c.startTime toDate:c.endTime options:0];
							oBreak.breakTime = [[NSNumber numberWithUnsignedInt:[conversionInfo second]] doubleValue];
							
							[breaks addObject:oBreak];
							[oBreak release];
						} else if (c.clockType == OtherBreak) {
							OtherBreaks *oBreak = [[OtherBreaks alloc]init];
							oBreak.comments = c.comments;
							oBreak.breakType = 1;
							
							conversionInfo = [[NSCalendar currentCalendar] components: NSSecondCalendarUnit fromDate:c.startTime toDate:c.endTime options:0];
							oBreak.breakTime = [[NSNumber numberWithUnsignedInt:[conversionInfo second]] doubleValue];
							[breaks addObject:oBreak];
							[oBreak release];
						}
					}
					
					NSInteger insertId = [TimeEntryController addTimeEntry:entry withBreaks:breaks];
					
					
					// 168 hour per week validation
					if (insertId == -100) {
						UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Hours per week exceeded",@"Hours per week exceeded") message:NSLocalizedString(@"The total amount of hours in a 7 day period cannot exceed 168 hours.",@"The total amount of hours in a 7 day period cannot exceed 168 hours.") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"OK") otherButtonTitles:nil]autorelease];
						[alert show];
						
						NSIndexPath* selection = [self.jobsTableView indexPathForSelectedRow];
						if (selection)
							[self.jobsTableView deselectRowAtIndexPath:selection animated:YES];
						
					} else {
						[TimeEntryController resetClock];
						[self reloadClock];
						
						TimeEntryViewController *controller = [[TimeEntryViewController alloc] initWithNibName:@"TimeEntryViewController" bundle:nil];
						
						controller.timeEntryId = insertId;
						controller.editMode = NO;
						controller.delegate = self;
						
						[self.navigationController pushViewController:controller animated:YES];
						
						[controller release];
					}
				}
			}
		} else {
			//userActionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") destructiveButtonTitle:nil otherButtonTitles:@"Manual Time Entry",nil];
			if (buttonIndex == 0) {
				TimeEntryViewController *controller = [[TimeEntryViewController alloc]init];
				controller.employer = e;
				controller.delegate = self;
				[self.navigationController pushViewController:controller animated:YES];
				[controller release];
			}
		}
	}

	[jobsTableView deselectRowAtIndexPath:[jobsTableView indexPathForSelectedRow] animated:YES];
	[jobsTableView reloadData];
}
 
-(void)didCancelComments:(StartBreakViewController *)controller {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)startBreakViewController:(StartBreakViewController *)controller didSaveComments:(NSString *)comments forType:(NSInteger)breakType {
	
	Clock *clock = [[[Clock alloc]init]autorelease];
	
	clock.employerId = clockEmployerId;
	clock.startTime = [NSDate date];
	if (breakType == 0) {
		clock.clockType = MealBreak;
	} else {
		clock.clockType = OtherBreak;
	}
	clock.comments = comments;
	
	[TimeEntryController insertClock:clock];
	[self reloadClock];
	[jobsTableView reloadData];
	[self.navigationController dismissModalViewControllerAnimated:YES];
	
	
}
#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editing) {
		EditJobViewController *editJob = [[EditJobViewController alloc] initWithNibName:@"EditJobViewController" bundle:nil];
		editJob.title = NSLocalizedString(@"Edit Employer", @"Edit employer view title when in edit mode.");
		
		// Create the navigation controller and present it modally.
		
		UINavigationController *navController = [[UINavigationController alloc]
												 
												 initWithRootViewController:editJob];
		
		editJob.delegate = self;
		editJob.employer = [[employersArray objectAtIndex:indexPath.row]copy];
		
		navController.navigationBar.tintColor = [UIColor colorWithRed:0.8f green:0.0 blue:0.0 alpha:1];
		
		[self presentModalViewController:navController animated:YES];
		
		[editJob release];
		[navController release];
	} else {
		
		UIActionSheet *userActionSheet;
		
		if (!clockIsRunning) {
			userActionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") destructiveButtonTitle:NSLocalizedString(@"Start Work",@"Start Work") otherButtonTitles:NSLocalizedString(@"Manual Time Entry",@"Manual Time Entry"),nil];
		} else {
			Employer *e = [employersArray objectAtIndex:indexPath.row];
			
			if (e.employerId == clockEmployerId) {
				if (isOnMealBreak || isOnOtherBreak) {
					userActionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") destructiveButtonTitle:NSLocalizedString(@"Stop Work",@"Stop Work") otherButtonTitles:NSLocalizedString(@"Stop Break",@"Stop Break"), NSLocalizedString(@"Discard Entry",@"Discard Entry"),nil];
				} else {
					userActionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") destructiveButtonTitle:NSLocalizedString(@"Stop Work",@"Stop Work") otherButtonTitles:NSLocalizedString(@"Start Break",@"Stop Break"), NSLocalizedString(@"Discard Entry",@"Discard Entry"),nil];
				}
			} else {
				userActionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Manual Time Entry",@"Manual Time Entry"),nil];
			}
		}

		
		userActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		
		[userActionSheet showInView:self.tabBarController.view];
		[userActionSheet release];
	}
}

-(void)didDelete:(TimeEntryViewController *)controller {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	[self.jobsTableView setEditing:editing animated:animated];
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
	[jobsTableView release];
	[backgroundView release];
	[employersArray release];
	[clockMealBreak release];
	[clockOtherBreak release];
	[clockStart release];
	[clockArray release];
    [super dealloc];
}


@end
