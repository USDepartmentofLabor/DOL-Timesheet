//
//  CommentsEntryViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "CommentsEntryViewController.h"
#define TEXTFIELD_TAG 1002

@implementation CommentsEntryViewController

@synthesize commentsTableView;
@synthesize delegate;
@synthesize commentsValue;

#pragma mark -
#pragma mark View lifecycle


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
	self.title = NSLocalizedString(@"Comments",@"Comments");
}

- (void)saveButtonPressed:(id)sender {
	UITableViewCell *cell = [commentsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	UITextView *tv = (UITextView *)[cell viewWithTag:TEXTFIELD_TAG];
	
	[self.delegate commentsEntryViewController:self didSaveComments:[tv text]];
	
	cell = nil;
	tv = nil;
}

- (void)cancelButtonPressed:(id)sender {
	[self.delegate didCancelComments:self];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
		
		textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 280, 110)];
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
	
	if (self.commentsValue != nil) {
		textView.text = self.commentsValue;
	}
	
	[textView becomeFirstResponder];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 120.0;
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
	[commentsTableView release];
	[commentsValue release];
    [super dealloc];
}


@end

