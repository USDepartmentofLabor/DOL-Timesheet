//
//  ReviewHoursViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "ReviewHoursViewController.h"
#import "ClearLabelsCellView.h"
#import "GradientView.h"
#import "WeekSummaryViewController.h"
#import "TimeSummaryController.h"
#import "TimeEntryController.h"
#import "TimeSummary.h"
#import "ReviewDaysViewController.h"
#import "PayDisclaimerViewController.h"
#import <sqlite3.h>
#include <stdlib.h>

#define kCustomButtonHeight     30.0

@implementation ReviewHoursViewController
@synthesize reviewTableView;
@synthesize timeData;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Summary", @"Summary tab bar title");
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	//self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripebg.png"]];
	
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
											[NSArray arrayWithObjects:										 
											 NSLocalizedString(@"Day",@"Day"), NSLocalizedString(@"Week",@"Week"), NSLocalizedString(@"Month",@"Month"), nil]];
	segmentedControl.selectedSegmentIndex = 0;
	//segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	segmentedControl.autoresizingMask = UIViewAutoresizingNone;
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.frame = CGRectMake(0, 0, 230, kCustomButtonHeight);
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	
	self.navigationItem.titleView = segmentedControl;
	[segmentedControl release];
	
	defaultTintColor = [segmentedControl.tintColor retain];    // keep track of this for later
	
	segmentedControl.selectedSegmentIndex = 1;
	
	//Add info icon to display disclaimer
	UIButton *info = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[info addTarget:self action:@selector(infoPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithCustomView:info];
	
	//Accesibility
	infoItem.isAccessibilityElement = YES;
	infoItem.accessibilityTraits = UIAccessibilityTraitButton;
	infoItem.accessibilityLabel = NSLocalizedString(@"Reminder", "@Reminder");
	//
	
	[info setFrame:CGRectMake(0, 0, 40, 40)];
	
	self.navigationItem.rightBarButtonItem = infoItem;
	[infoItem release];
	
	reviewTableView.backgroundColor = [UIColor clearColor];
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripe3.png"]];
	
	UIView *containerView =
	[[[UIView alloc]
	  initWithFrame:CGRectMake(0, 0, 300, 40)]
	 autorelease];
    UILabel *headerLabel =
	[[[UILabel alloc]
	  initWithFrame:CGRectMake(40, 10, 250, 30)]
	 autorelease];
	
	containerView.backgroundColor = [UIColor clearColor];
	//Overtime Icon
	UIImage *image = [UIImage imageNamed:@"overtime.png"];
	UIImageView *iview = [[[UIImageView alloc] initWithImage:image]autorelease];
	iview.frame = CGRectMake(10, 10, 24, 24);
	
	//Accesibility
	iview.isAccessibilityElement = YES;
	iview.accessibilityTraits = UIAccessibilityTraitImage;
	iview.accessibilityLabel = NSLocalizedString(@"Overtime",@"Overtime");
	
	[containerView addSubview:iview];
	
    headerLabel.text = NSLocalizedString(@"Week includes overtime", @"Week includes overtime");
    headerLabel.textColor = [UIColor blackColor];
    headerLabel.shadowColor = [UIColor whiteColor];
    headerLabel.shadowOffset = CGSizeMake(0, 1);
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    headerLabel.backgroundColor = [UIColor clearColor];
    [containerView addSubview:headerLabel];
    reviewTableView.tableHeaderView = containerView;
}

- (void) infoPressed:(id)sender {
	
	PayDisclaimerViewController *controller = [[PayDisclaimerViewController alloc]initWithNibName:@"PayDisclaimerViewController" bundle:nil];
	
	//Add the navigation controller to the Job View
	//UINavigationController *navController = [[[UINavigationController alloc]
	//											 initWithRootViewController:controller] autorelease];
	
	//navController.navigationBar.tintColor = [UIColor colorWithRed:0.8f green:0.0 blue:0.0 alpha:1];
	
	//[navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	
	//[self.navigationController presentModalViewController:navController animated:YES];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
	//[navController release];
}


- (void) segmentAction:(id)sender {
	UISegmentedControl *segmented = (UISegmentedControl *)self.navigationItem.titleView;
	
	groupBy = [segmented selectedSegmentIndex];
	
	if (groupBy == kWeek) {
		UIView *containerView =
		[[[UIView alloc]
		  initWithFrame:CGRectMake(0, 0, 300, 40)]
		 autorelease];
		UILabel *headerLabel =
		[[[UILabel alloc]
		  initWithFrame:CGRectMake(40, 10, 250, 30)]
		 autorelease];
		
		containerView.backgroundColor = [UIColor clearColor];
		//Overtime Icon
		UIImage *image = [UIImage imageNamed:@"overtime.png"];
		UIImageView *iview = [[[UIImageView alloc] initWithImage:image]autorelease];
		iview.frame = CGRectMake(10, 10, 24, 24);
		
		//Accesibility
		iview.isAccessibilityElement = YES;
		iview.accessibilityTraits = UIAccessibilityTraitImage;
		iview.accessibilityLabel = NSLocalizedString(@"Overtime",@"Overtime");
		
		[containerView addSubview:iview];
		
		headerLabel.text = NSLocalizedString(@"Week includes overtime", @"Week includes overtime");
		headerLabel.textColor = [UIColor blackColor];
		headerLabel.shadowColor = [UIColor whiteColor];
		headerLabel.shadowOffset = CGSizeMake(0, 1);
		headerLabel.font = [UIFont boldSystemFontOfSize:14];
		headerLabel.backgroundColor = [UIColor clearColor];
		[containerView addSubview:headerLabel];
		reviewTableView.tableHeaderView = containerView;
	} else {
		reviewTableView.tableHeaderView = nil;
	}

	
	[self fetchData];
	[reviewTableView reloadData];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	UISegmentedControl *segmentedControl = (UISegmentedControl *)self.navigationItem.titleView;
	
	// before we show this view make sure the segmentedControl matches the nav bar style
	if (self.navigationController.navigationBar.barStyle == UIBarStyleBlackTranslucent ||
		self.navigationController.navigationBar.barStyle == UIBarStyleBlackOpaque) 
	{
		segmentedControl.tintColor = [UIColor darkGrayColor];
	}
	else
	{
		segmentedControl.tintColor = defaultTintColor;
	}
	
	[self fetchData];
	[reviewTableView reloadData];
}

- (void)fetchData {
	
	switch (groupBy) {
		case kDay:
			self.timeData = [NSMutableArray arrayWithArray:[TimeSummaryController getTimeSummaryByDay]];
			break;
		case kWeek:
			self.timeData = [NSMutableArray arrayWithArray:[TimeSummaryController getTimeSummaryByWeek]];
			break;
		case kMonth:
			self.timeData = [NSMutableArray arrayWithArray:[TimeSummaryController getTimeSummaryByMonth]];
			break;
		default:
			break;
	}
}	


 - (void)viewDidAppear:(BOOL)animated {
	 [super viewDidAppear:animated];
 }
 
- (id)init {
	if (self = [super initWithNibName:@"ReviewHoursViewController" bundle:nil]) {
		
		//Tab Bar item
		UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Summary", @"Summary tab bar title") image:[UIImage imageNamed:@"summary-icon.png"] tag:0];
		self.tabBarItem = item;
		[item release];
	}
	return self;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return [timeData count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSDictionary *dictionary = [timeData objectAtIndex:section];
	NSArray *array = [dictionary objectForKey:@"Times"];
	return [array count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	const NSInteger EMPLOYER_LABEL_TAG = 1001;
	const NSInteger HOURS_LABEL_TAG = 1002;
	const NSInteger PAY_LABEL_TAG = 1003;
	const NSInteger BREAKS_LABEL_TAG = 1004;
	const NSInteger OVERTIME_ICON_TAG = 1005;
	const NSInteger GROSS_LABEL_TAG = 1005;
	
	
	UILabel *hoursLabel;
	UILabel *breaksLabel;
	UILabel *payLabel;
	UILabel *grossLabel;
	UILabel *employerLabel;
	UIImage *image;
	UIImageView *iview;
	
    static NSString *WeekCellIdentifier = @"WeekCell";
	
	ClearLabelsCellView *cell;
	
    //if (groupBy == kWeek) {
	NSDictionary *dictionary = [timeData objectAtIndex:indexPath.section];
	NSArray *array = [dictionary objectForKey:@"Times"];
	
	TimeSummary *ts = [array objectAtIndex:indexPath.row];
	
	cell = (ClearLabelsCellView *)[tableView dequeueReusableCellWithIdentifier:WeekCellIdentifier];
	if (cell == nil) {
		cell = [[[ClearLabelsCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WeekCellIdentifier] autorelease];
		cell.backgroundView = [[[GradientView alloc] init] autorelease];
		
		hoursLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 32.0, 210.0, 22.0)]autorelease];
		hoursLabel.adjustsFontSizeToFitWidth = YES;
		hoursLabel.font = [UIFont fontWithName:@"Helvetica" size:14.000];
		hoursLabel.minimumFontSize = 10.000;
		hoursLabel.textAlignment = UITextAlignmentLeft;
		hoursLabel.textColor = [UIColor colorWithRed:0.291 green:0.291 blue:0.291 alpha:1.000];
		hoursLabel.opaque = NO;
		hoursLabel.backgroundColor = [UIColor clearColor];
		hoursLabel.highlightedTextColor = [UIColor whiteColor];
		hoursLabel.tag = HOURS_LABEL_TAG;
		
		breaksLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 52.0, 210.0, 22.0)]autorelease];
		breaksLabel.adjustsFontSizeToFitWidth = YES;
		breaksLabel.font = [UIFont fontWithName:@"Helvetica" size:14.000];
		breaksLabel.minimumFontSize = 10.000;
		breaksLabel.textAlignment = UITextAlignmentLeft;
		breaksLabel.textColor = [UIColor colorWithRed:0.291 green:0.291 blue:0.291 alpha:1.000];
		breaksLabel.opaque = NO;
		breaksLabel.backgroundColor = [UIColor clearColor];
		breaksLabel.highlightedTextColor = [UIColor whiteColor];
		breaksLabel.tag = BREAKS_LABEL_TAG;
		
		payLabel = [[[UILabel alloc] initWithFrame:CGRectMake(220.0, 50.0, 76.0, 21.0)]autorelease];
		payLabel.adjustsFontSizeToFitWidth = YES;
		payLabel.font = [UIFont fontWithName:@"Helvetica" size:16.000];
		payLabel.minimumFontSize = 10.000;
		payLabel.textAlignment = UITextAlignmentRight;
		payLabel.textColor = [UIColor colorWithRed:0.000 green:0.502 blue:0.251 alpha:1.000];
		payLabel.opaque = NO;
		payLabel.backgroundColor = [UIColor clearColor];
		payLabel.highlightedTextColor = [UIColor whiteColor];
		payLabel.tag = PAY_LABEL_TAG;
		
		grossLabel = [[[UILabel alloc] initWithFrame:CGRectMake(220.0, 34.0, 76.0, 21.0)]autorelease];
		grossLabel.adjustsFontSizeToFitWidth = YES;
		grossLabel.font = [UIFont fontWithName:@"Helvetica" size:12.000];
		grossLabel.minimumFontSize = 10.000;
		grossLabel.text = NSLocalizedString(@"Gross Pay",@"Gross Pay");
		grossLabel.textAlignment = UITextAlignmentRight;
		grossLabel.textColor = [UIColor colorWithRed:0.000 green:0.502 blue:0.251 alpha:1.000];
		grossLabel.opaque = NO;
		grossLabel.backgroundColor = [UIColor clearColor];
		grossLabel.highlightedTextColor = [UIColor whiteColor];
		grossLabel.tag = GROSS_LABEL_TAG;
		
		employerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 9.0, 300, 24.0)]autorelease];
		employerLabel.adjustsFontSizeToFitWidth = YES;
		employerLabel.contentMode = UIViewContentModeLeft;
		employerLabel.enabled = YES;
		employerLabel.minimumFontSize = 10.000;
		employerLabel.textAlignment = UITextAlignmentLeft;
		employerLabel.textColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:1.000];
		employerLabel.opaque = NO;
		employerLabel.backgroundColor = [UIColor clearColor];
		employerLabel.highlightedTextColor = [UIColor whiteColor];
		employerLabel.font = [UIFont boldSystemFontOfSize:16];
		employerLabel.tag = EMPLOYER_LABEL_TAG;
		
		image = [UIImage imageNamed:@"overtime.png"];
		
		iview = [[UIImageView alloc] initWithImage:image];
		iview.frame = CGRectMake(275, 10, 24, 24);
		iview.tag = OVERTIME_ICON_TAG;
		
		[cell addSubview:employerLabel];
		[cell addSubview:hoursLabel];
		[cell addSubview:breaksLabel];
		[cell addSubview:iview];
		[cell addSubview:grossLabel];
		[cell addSubview:payLabel];
	}
	else {
		hoursLabel = (UILabel *)[cell viewWithTag:HOURS_LABEL_TAG];
		payLabel = (UILabel *)[cell viewWithTag:PAY_LABEL_TAG];
		employerLabel = (UILabel *)[cell viewWithTag:EMPLOYER_LABEL_TAG];
		breaksLabel = (UILabel *)[cell viewWithTag:BREAKS_LABEL_TAG];
		iview = (UIImageView *)[cell viewWithTag:OVERTIME_ICON_TAG];
		grossLabel = (UILabel *)[cell viewWithTag:GROSS_LABEL_TAG];
	}
	
	if (groupBy == kMonth) {
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.isAccessibilityElement = YES;
		cell.accessibilityTraits = UIAccessibilityTraitButton;
	}
	
	//Overtime Icon
	if (groupBy == kWeek) {
		if (ts.sumOfTimeWorked > 144000) {
			[iview setHidden:NO];
		} else {
			[iview setHidden:YES];
		}
	} else {
		[iview setHidden:YES];
	}

	NSDate *d1 = [[NSDate alloc] init];
	NSDate *d2 = [[NSDate alloc] initWithTimeInterval:(ts.sumOfTimeWorked) sinceDate:d1];
	
	// Get conversion to months, days, hours, minutes
	unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
	
	NSDateComponents *conversionInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:d1 toDate:d2 options:0];
	
	NSMutableString *hoursString = [NSMutableString stringWithFormat:@"%02dh %02dm ", [conversionInfo hour], [conversionInfo minute]];
	
	[hoursString appendString:NSLocalizedString(@"Total Work Hours", @"Total Work Hours")];
	
	hoursLabel.text = hoursString;
	
	//Accesibility
	hoursLabel.isAccessibilityElement = YES;
	hoursLabel.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"%d hours and %d minutes total work hours", @"Accesibility for review work hours"), [conversionInfo hour], [conversionInfo minute]];
	//
	
	[d1 release];
	[d2 release];
	
	d1 = [[NSDate alloc] init];
	d2 = [[NSDate alloc] initWithTimeInterval:(ts.sumOfMealBreaks + ts.sumOfOtherBreaks) sinceDate:d1];
	conversionInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:d1 toDate:d2 options:0];
	
	NSMutableString *breaksString = [NSMutableString stringWithFormat:@"%02dh %02dm ", [conversionInfo hour], [conversionInfo minute]];
	
	[breaksString appendString:NSLocalizedString(@"Total Break Hours", @"Total Break Hours")];
	
	breaksLabel.text = breaksString;
	
	//Accesibility
	breaksLabel.isAccessibilityElement = YES;
	breaksLabel.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"%d hours and %d minutes total break hours", @"Accesibility for review work hours"), [conversionInfo hour], [conversionInfo minute]];
	//
	
	//Overtime Accesibility
	iview.isAccessibilityElement = NO;
	//Overtime Icon
	if (groupBy == kWeek) {
		if (ts.sumOfTimeWorked > 144000) {
			grossLabel.accessibilityLabel = [NSString stringWithFormat:@"%@. %@",NSLocalizedString(@"Week includes overtime", @"Week includes overtime"), NSLocalizedString(@"Gross Pay",@"Gross Pay")];
		} else {
			grossLabel.accessibilityLabel = NSLocalizedString(@"Gross Pay",@"Gross Pay");
		}
	} else {
		grossLabel.accessibilityLabel = NSLocalizedString(@"Gross Pay",@"Gross Pay");
	}
	
	[d1 release];
	[d2 release];
	
	employerLabel.text = ts.employerName;
	
	//Calculate Gross Pay
	NSString *pay = [NSString stringWithFormat:@"$%0.2f", ts.pay];
	
	payLabel.text = pay;
	
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView* customView = [[[UIView alloc] 
						   initWithFrame:CGRectMake(10.0, 0.0, 300.0, 24.0)]
						  autorelease];
  	//customView.backgroundColor = 
	//[UIColor colorWithRed:0.0 green:0.2 blue:0.6 alpha:0.7];
	
	customView.backgroundColor = 
	[UIColor lightGrayColor];
	
	UILabel * headerLabel = [[[UILabel alloc]
							  initWithFrame:CGRectZero] autorelease];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor whiteColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:16];
	headerLabel.frame = CGRectMake( 7.0, 1.0, 300.0, 24.0);
	headerLabel.textAlignment = UITextAlignmentLeft;
	
	NSString *headerTitle = nil;
	
	if (groupBy == kDay) {
		NSDictionary *dictionary = [timeData objectAtIndex:section];
		NSArray *array = [dictionary objectForKey:@"Times"];
		
		TimeSummary *ts = (TimeSummary *)[array objectAtIndex:0];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd"];
		NSDate *d = [formatter dateFromString:ts.startDate];
		
		[formatter setDateFormat:@"E MMM d, yyyy"];
				 
		headerTitle = [formatter stringFromDate:d];
		
		[formatter release];
	} else if (groupBy == kWeek) {
		NSDictionary *dictionary = [timeData objectAtIndex:section];
		NSArray *array = [dictionary objectForKey:@"Times"];
		
		TimeSummary *ts = (TimeSummary *)[array objectAtIndex:0];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd"];
		NSDate *d = [formatter dateFromString:ts.weekStart];
		
		[formatter setDateFormat:@"MMM d, yyyy"];
		
		headerTitle = [NSString stringWithFormat:NSLocalizedString(@"Week of %@", @"Week for review view"), [formatter stringFromDate:d]];
		
		[formatter release];		
	} else if (groupBy == kMonth) {
		
		NSDictionary *dictionary = [timeData objectAtIndex:section];
		NSArray *array = [dictionary objectForKey:@"Times"];
		
		TimeSummary *ts = (TimeSummary *)[array objectAtIndex:0];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM"];
		NSDate *d = [formatter dateFromString:ts.startDate];
		
		[formatter setDateFormat:@"MMMM yyyy"];
		
		headerTitle = [formatter stringFromDate:d];
		
		[formatter release];
		
	}
	
	headerLabel.text = headerTitle;
	
  	[customView addSubview:headerLabel];
	
	return customView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 24.0f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 80.0;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (groupBy == kWeek) {
		WeekSummaryViewController *weekSummary = [[WeekSummaryViewController alloc] initWithNibName:@"WeekSummaryViewController" bundle:nil];
		
		NSDictionary *dictionary = [timeData objectAtIndex:indexPath.section];
		NSArray *array = [dictionary objectForKey:@"Times"];
		
		weekSummary.timeSummary = (TimeSummary *)[array objectAtIndex:indexPath.row];
		
		[self.navigationController pushViewController:weekSummary animated:YES];
		[weekSummary release];
	} else if (groupBy == kDay) {
		NSDictionary *dictionary = [timeData objectAtIndex:indexPath.section];
		NSArray *array = [dictionary objectForKey:@"Times"];
		TimeSummary *ts = [array objectAtIndex:indexPath.row];
		
		ReviewDaysViewController *controller = [[ReviewDaysViewController alloc] init];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd"];
		NSDate *d = [formatter dateFromString:ts.startDate];
		
		[formatter setDateFormat:@"E MMM d, yyyy"];
		
		controller.title = [formatter stringFromDate:d];
		[formatter release];
		
		controller.employerId = ts.employerId;
		controller.employerName = ts.employerName;
		
		controller.date = ts.startDate;
		
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
		
	}
	else {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		NSDictionary *dictionary = [timeData objectAtIndex:indexPath.section];
		NSMutableArray *array = [dictionary objectForKey:@"Times"];
		TimeSummary *summary = (TimeSummary *)[array objectAtIndex:indexPath.row];
		
		NSInteger employerId = summary.employerId;
		NSString *startDate = summary.startDate;
		
		NSString *endDate;
		if (groupBy == kDay) {
			endDate = startDate;
		} else if (groupBy == kWeek) {
			endDate = summary.endDate;
		}
		
		if (groupBy == kDay || groupBy == kWeek) {
			
			NSInteger result = [TimeEntryController deleteTimeEntriesForEmployer:employerId fromDay:startDate toDay:endDate];
			
			switch (result) {
				case SQLITE_DONE:
					[array removeObjectAtIndex:indexPath.row];
					if ([array count] == 0) {
						[timeData removeObjectAtIndex:indexPath.section];
						[reviewTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:YES];
					} else {
						[reviewTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
					}

					break;
				default:
					break;
			}
		} else {
			NSInteger result = [TimeEntryController deleteTimeEntriesForMonth:startDate employer:employerId];
			
			switch (result) {
				case SQLITE_DONE:
					[array removeObjectAtIndex:indexPath.row];
					if ([array count] == 0) {
						[timeData removeObjectAtIndex:indexPath.section];
						[reviewTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:YES];
					} else {
						[reviewTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
					}
					
					break;
				default:
					break;
			}
		}

		
		/*
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
		}*/
	}   
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	[self.reviewTableView setEditing:editing animated:animated];
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
	[defaultTintColor release];
	[reviewTableView release];
    [super dealloc];
}


@end

