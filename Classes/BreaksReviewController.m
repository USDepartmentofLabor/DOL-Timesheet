//
//  BreaksReviewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "BreaksReviewController.h"
#import "UITableViewCellWithSubtitle.h"

@implementation BreaksReviewController
@synthesize breaksTableView;
@synthesize dataList;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	breaksTableView.backgroundColor = [UIColor clearColor];
	breaksTableView.allowsSelection = NO;
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripe3.png"]];
	self.title = NSLocalizedString(@"Other Breaks",@"Other Breaks title");
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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	int count = [dataList count];
	if(self.editing) count++;
	return count;
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
	
	OtherBreaks *otherBreak = (OtherBreaks *)[dataList objectAtIndex:indexPath.row];
	
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
	
	if(indexPath.row == ([dataList count]) && self.editing){
		titleText = NSLocalizedString(@"Add Break",@"Add Break");
		subtitleText = [NSString stringWithString:NSLocalizedString(@"Tap to add break", @"Tap to add break")];
	} else {
		OtherBreaks *otherBreak = (OtherBreaks *)[dataList objectAtIndex:indexPath.row];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([dataList count] == 0) {
		return NSLocalizedString(@"There are no breaks", @"There are no breaks");
	} else {
		return @"";
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

