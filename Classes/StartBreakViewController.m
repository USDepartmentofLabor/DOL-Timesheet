//
//  StartBreakViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "StartBreakViewController.h"
#import "MealDisclaimerViewController.h"
#define TEXTFIELD_TAG 1001

@implementation StartBreakViewController

@synthesize commentsTableView;
@synthesize segment;
@synthesize delegate;
@synthesize timer;

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveButtonPressed:)];
	[self.navigationItem setRightBarButtonItem:saveButton animated:NO];
	[saveButton release];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
	[self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
	[cancelButton release];
	
	commentsTableView.backgroundColor = [UIColor clearColor];
	commentsTableView.allowsSelection = NO;
	commentsTableView.scrollEnabled = NO;
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripe3.png"]];
	self.title = NSLocalizedString(@"Start Break",@"Start Break");
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSInteger hasRun = [prefs integerForKey:@"hasRun"];
	if (hasRun != 100) {
		timer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerUp:) userInfo:nil repeats:NO]retain];		
	}
}

- (void)timerUp:(NSTimer *)timer {
	MealDisclaimerViewController *controller = [[MealDisclaimerViewController alloc]init];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setInteger:100 forKey:@"hasRun"];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text { 
	BOOL shouldChangeText = YES;
	
	if ([text isEqualToString:@"\n"]) {
		shouldChangeText = NO;
	} else {
		if ([textView.text length] >= 100 && range.length == 0) {
			shouldChangeText = NO; // return NO to not change text
		} else {
			shouldChangeText = YES;
		}
	}
	
	return shouldChangeText;
}

#pragma mark -
#pragma mark Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([segment selectedSegmentIndex] == 0) {
		return NSLocalizedString(@"Meal Break Comments",@"Meal Break Comments");
	} else {
		return NSLocalizedString(@"Other Break Comments",@"Other Break Comments");
	}
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	UITextView *textView;
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 280, 90)];
		textView.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
		textView.textAlignment = UITextAlignmentLeft;
		textView.font = [UIFont systemFontOfSize:14];
		textView.backgroundColor = [UIColor clearColor];
		textView.tag = TEXTFIELD_TAG;
		textView.delegate = self;
		[cell.contentView addSubview:textView];			
	}
	else {
		textView = (UITextView *)[cell viewWithTag:TEXTFIELD_TAG];
	}
	
	[textView setEnablesReturnKeyAutomatically:YES];
	
	[textView becomeFirstResponder];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 100.0;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

- (void)saveButtonPressed:(id)sender {
	UITableViewCell *cell = [commentsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	UITextView *tv = (UITextView *)[cell viewWithTag:TEXTFIELD_TAG];
	
	[self.delegate startBreakViewController:self didSaveComments:[tv text] forType:segment.selectedSegmentIndex];
	
	//cell = nil;
	//tv = nil;
}

- (void)cancelButtonPressed:(id)sender {
	[self.delegate didCancelComments:self];
}

-(IBAction)segmentValueChanged:(id)sender {
	[commentsTableView reloadData];
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
	[commentsTableView release];
	[segment release];
	[timer release];
    [super dealloc];
}


@end
