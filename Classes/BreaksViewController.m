//
//  BreaksViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "BreaksViewController.h"
#import "EditBreakViewController.h"
#import "UITableViewCellWithSubtitle.h"

@implementation BreaksViewController

#pragma mark -
#pragma mark View lifecycle

@synthesize breaksTableView;
@synthesize timeEntryId;
@synthesize dataList;
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back") style:UIBarButtonItemStyleBordered target:self action:@selector(saveButtonPressed:)];
	[self.navigationItem setLeftBarButtonItem:saveButton animated:NO];
	[saveButton release];
	
	//New Item
	if (dataList == nil) {
		dataList = [[NSMutableArray array]retain];
		NSMutableArray *mealArray = [NSMutableArray array];
		NSMutableArray *otherArray = [NSMutableArray array];
		[dataList addObject:mealArray];
		[dataList addObject:otherArray];
	}
	
	breaksTableView.backgroundColor = [UIColor clearColor];
	breaksTableView.allowsSelectionDuringEditing = YES;
	breaksTableView.allowsSelection = NO;
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripe3.png"]];
	self.title = NSLocalizedString(@"Breaks",@"Breaks title");
	
	//Edit button
	//self.navigationItem.rightBarButtonItem =  self.editButtonItem;
	[super setEditing:YES animated:NO];
	[self.breaksTableView setEditing:YES];
}

- (void)saveButtonPressed:(id)sender {
	[self.delegate breaksViewController:self didSaveBreaks:dataList];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
	
	UIBarButtonItem *backButton = (UIBarButtonItem *)self.navigationItem.leftBarButtonItem;
	
	NSArray *paths = [NSArray arrayWithObject:
					  [NSIndexPath indexPathForRow:[dataList count] inSection:0]];
    [breaksTableView beginUpdates];
	if (editing)
    {
        [[self breaksTableView] insertRowsAtIndexPaths:paths
                                withRowAnimation:UITableViewRowAnimationFade];
		[backButton setEnabled:NO];
    }
    else {
        [[self breaksTableView] deleteRowsAtIndexPaths:paths
                                withRowAnimation:UITableViewRowAnimationFade];
		[backButton setEnabled:YES];
    }
	[breaksTableView setEditing:editing];
	[breaksTableView endUpdates];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	// Unselect the selected row if any
	NSIndexPath* selection = [self.breaksTableView indexPathForSelectedRow];
	if (selection)
		[self.breaksTableView deselectRowAtIndexPath:selection animated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSMutableArray *thisArray = [dataList objectAtIndex:section];
	
	int count = [thisArray count];
	if(self.editing) count++;
	return count;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath  *)indexPath {
	NSMutableArray *thisArray = [dataList objectAtIndex:indexPath.section];
	
	if (self.editing == NO || !indexPath) return   UITableViewCellEditingStyleNone;
	if (self.editing && indexPath.row == ([thisArray count])) {
		return UITableViewCellEditingStyleInsert;
	} else {
		return UITableViewCellEditingStyleDelete;
	}
	return UITableViewCellEditingStyleNone;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	
    UITableViewCellWithSubtitle *cell = (UITableViewCellWithSubtitle *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCellWithSubtitle alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
	//Set font sizes
	cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
	cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
	
	//Remove backcolor so that when cells are removed and faded away it looks better
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	
	NSMutableArray *mealArray = [dataList objectAtIndex:0];
	NSMutableArray *otherArray = [dataList objectAtIndex:1];
	
	if (indexPath.section == 0) {
		if(indexPath.row == ([mealArray count]) && self.editing){
			cell.textLabel.text = NSLocalizedString(@"Add Meal Break",@"Add Meal Break");
			cell.detailTextLabel.text = NSLocalizedString(@"Tap to add a meal break",@"Tap to add a meal break");
			return cell;
		}
	} else {
		if(indexPath.row == ([otherArray count]) && self.editing){
			cell.textLabel.text = NSLocalizedString(@"Add Other Break",@"Add Other Break");
			cell.detailTextLabel.text = NSLocalizedString(@"Tap to add a break",@"Tap to add a break");
			return cell;
		}
	}

	
	NSMutableArray *thisArray = [dataList objectAtIndex:indexPath.section];
	
	OtherBreaks *otherBreak = (OtherBreaks *)[thisArray objectAtIndex:indexPath.row];
	
	
	// Get the system calendar
	NSCalendar *sysCalendar = [NSCalendar currentCalendar];
	
	NSDate *d1 = [[NSDate alloc] init];
	NSDate *d2 = [[NSDate alloc] initWithTimeInterval:otherBreak.breakTime sinceDate:d1];
	
	// Get conversion to months, days, hours, minutes
	unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
	
	NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:d1 toDate:d2 options:0];
	
	cell.textLabel.text = [NSString stringWithFormat:@"%dh %dm", [conversionInfo hour], [conversionInfo minute]];
	//Accesibility
	cell.textLabel.isAccessibilityElement = YES;
	cell.textLabel.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"%d hours and %d minutes", @"Accesibility for Time Entry"), [conversionInfo hour], [conversionInfo minute]];
	//
	[d1 release];
	[d2 release];
	
	if ([otherBreak.comments length] > 0) {
		cell.detailTextLabel.text = otherBreak.comments;
	} else {
		cell.detailTextLabel.text = @"No comment";
	}
	
	cell.detailTextLabel.numberOfLines = 0;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *titleText;
	NSString *subtitleText;
	
	CGSize titleSize;
	CGSize subtitleSize;
	
	NSMutableArray *thisArray = [dataList objectAtIndex:indexPath.section];
	
	if(indexPath.row == ([thisArray count]) && self.editing){
		titleText = NSLocalizedString(@"Add Break",@"Add Break");
		subtitleText = [NSString stringWithString:NSLocalizedString(@"Tap to add break", @"Tap to add break")];
	} else {
		OtherBreaks *otherBreak = (OtherBreaks *)[thisArray objectAtIndex:indexPath.row];
		titleText = @"23h 59m";
		if ([otherBreak.comments length] > 0) {
			subtitleText = otherBreak.comments;
		} else {
			subtitleText = NSLocalizedString(@"No comment",@"No comment");
		}
	}
	CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
	
	subtitleSize = [subtitleText sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	titleSize = [titleText sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	
	return titleSize.height + subtitleSize.height + 20;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSMutableArray *thisArray = [dataList objectAtIndex:indexPath.section];
		
		[thisArray removeObjectAtIndex:indexPath.row];
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if (section == 0) {
		return NSLocalizedString(@"Meal Breaks",@"Meal Breaks");
	} else {
		return NSLocalizedString(@"Other Breaks",@"Other Breaks");
	}

}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSMutableArray *thisArray = [dataList objectAtIndex:indexPath.section];
	
	if (self.editing && indexPath.row == ([thisArray count])) {
		EditBreakViewController *editBreak = [[EditBreakViewController alloc] initWithNibName:@"EditBreakViewController" bundle:nil];
		editBreak.title = NSLocalizedString(@"Add Break",@"Add Break");
		editBreak.delegate = self;
		
		editBreak.breakType = indexPath.section;
		
		UINavigationController *navController = [[UINavigationController alloc]
													 initWithRootViewController:editBreak];
		//jobNavController.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.2 blue:0.6 alpha:1];
		navController.navigationBar.tintColor = [UIColor colorWithRed:0.8f green:0.0 blue:0.0 alpha:1];
		
		[self.navigationController presentModalViewController:navController animated:YES];
		
		[editBreak release];
		[navController release];
	}
}

- (void)didCancelBreak:(EditBreakViewController *)controller {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)editBreakViewController:(EditBreakViewController *)controller didSaveBreak:(OtherBreaks *)aBreak {
	if (aBreak.breakTime > 0) {
		
		NSMutableArray *thisArray = [dataList objectAtIndex:aBreak.breakType];
		[thisArray addObject:aBreak];
		[breaksTableView reloadData];
		[self.navigationController dismissModalViewControllerAnimated:YES];
	} else {
		UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Duration not valid",@"Duration not valid") message:NSLocalizedString(@"The duration must be greater than zero.",@"The duration must be greater than zero.") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
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
	[breaksTableView release];
	[dataList release];
    [super dealloc];
}


@end

