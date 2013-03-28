//
//  WeekSummaryViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "WeekSummaryViewController.h"
#import "DateConversion.h"

@implementation WeekSummaryViewController

@synthesize detailsTable;
@synthesize timeSummary;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0) {
		return 4;
	} else {
		return 3;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *DefaultCellIdentifier = @"DefaultCell";
	static NSString *ValueCellIdentifier1 = @"ValueCell1";
    
    UITableViewCell *cell;
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			
			cell = [tableView dequeueReusableCellWithIdentifier:DefaultCellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DefaultCellIdentifier] autorelease];
				cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
			}
			cell.textLabel.text = timeSummary.employerName;
			
		} else if (indexPath.row == 1) {
			
			cell = [tableView dequeueReusableCellWithIdentifier:DefaultCellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DefaultCellIdentifier] autorelease];
				cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
			}
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:@"yyyy-MM-dd"];
			NSDate *d1 = [formatter dateFromString:timeSummary.startDate];
			NSDate *d2 = [formatter dateFromString:timeSummary.endDate];
			
			[formatter setDateFormat:@"E MMM d, yyyy"];
			
			cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:d1], [formatter stringFromDate:d2]];
			
			[formatter release];
		} else if (indexPath.row == 2) {
			cell = [tableView dequeueReusableCellWithIdentifier:ValueCellIdentifier1];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ValueCellIdentifier1] autorelease];
				cell.detailTextLabel.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
				cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
				cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
			}
			cell.textLabel.text = NSLocalizedString(@"Regular Hours", @"Regular Hours");
			
			unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
			
			NSDate *d1 = [[NSDate alloc] init];
			NSDate *d2 = [[NSDate alloc] initWithTimeInterval:(timeSummary.regularTime) sinceDate:d1];
			
			NSDateComponents *conversionInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:d1 toDate:d2 options:0];
			[d1 release];
			[d2 release];
			
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%02dh %02dm", [conversionInfo hour], [conversionInfo minute]];
			//Accesibility
			cell.detailTextLabel.isAccessibilityElement = YES;
			cell.detailTextLabel.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"%d hours and %d minutes", @"Accesibility for Time Entry"), [conversionInfo hour], [conversionInfo minute]];
			//
			
		} else if (indexPath.row == 3) {
			cell = [tableView dequeueReusableCellWithIdentifier:ValueCellIdentifier1];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ValueCellIdentifier1] autorelease];
				cell.detailTextLabel.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
				cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
				cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
			}
			cell.textLabel.text = NSLocalizedString(@"Overtime Hours",@"Overtime Hours");
			unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
			
			NSDate *d1 = [[NSDate alloc] init];
			NSDate *d2 = [[NSDate alloc] initWithTimeInterval:(timeSummary.overTime) sinceDate:d1];
			
			NSDateComponents *conversionInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:d1 toDate:d2 options:0];
			[d1 release];
			[d2 release];
			
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%02dh %02dm", [conversionInfo hour], [conversionInfo minute]];
			//Accesibility
			cell.detailTextLabel.isAccessibilityElement = YES;
			cell.detailTextLabel.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"%d hours and %d minutes", @"Accesibility for Time Entry"), [conversionInfo hour], [conversionInfo minute]];
			//
		}
	} else if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			cell = [tableView dequeueReusableCellWithIdentifier:ValueCellIdentifier1];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ValueCellIdentifier1] autorelease];
				cell.detailTextLabel.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
				cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
				cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
			}
			cell.textLabel.text = NSLocalizedString(@"Regular Pay",@"Regular Pay");
			NSString *pay = [NSString stringWithFormat:@"$%0.2f", timeSummary.pay - ((timeSummary.overTime * 1.5) / 3600 * timeSummary.hourlyRate)];
			cell.detailTextLabel.text = pay;
		} else if (indexPath.row == 1) {
			cell = [tableView dequeueReusableCellWithIdentifier:ValueCellIdentifier1];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ValueCellIdentifier1] autorelease];
				cell.detailTextLabel.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
				cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
				cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
			}
			cell.textLabel.text = NSLocalizedString(@"Overtime Pay",@"Overtime Pay");
			NSString *pay = [NSString stringWithFormat:@"$%0.2f", ((timeSummary.overTime * 1.5) / 3600 * timeSummary.hourlyRate)];
			cell.detailTextLabel.text = pay;
		} else if (indexPath.row == 2) {
			cell = [tableView dequeueReusableCellWithIdentifier:ValueCellIdentifier1];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ValueCellIdentifier1] autorelease];
				cell.detailTextLabel.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
				cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
				cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
			}
			cell.textLabel.text = NSLocalizedString(@"Gross Pay",@"Gross Pay");
			//Calculate Gross Pay
			NSString *pay = [NSString stringWithFormat:@"$%0.2f", timeSummary.pay];
			cell.detailTextLabel.text = pay;
		}
	}
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 1) {
		return NSLocalizedString(@"Pay Summary",@"Pay Summary");
	} else {
		return @"";
	}
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripe3.png"]];
	detailsTable.backgroundColor = [UIColor clearColor];
	detailsTable.allowsSelection = NO;
	
	self.title = NSLocalizedString(@"Week Summary", @"Week summary view title");
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
	[detailsTable release];
	[timeSummary release];
    [super dealloc];
}


@end
