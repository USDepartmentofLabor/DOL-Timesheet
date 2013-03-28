//
//  TextEntryViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "TextEntryViewController.h"
#define TEXTFIELD_TAG 1001

@implementation TextEntryViewController

@synthesize textTableView;
@synthesize textValue;
@synthesize placeHolderText;
@synthesize maxLength;
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
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveButtonPressed:)];
	[self.navigationItem setRightBarButtonItem:saveButton animated:NO];
	[saveButton release];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
	[self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
	[cancelButton release];
	
	textTableView.backgroundColor = [UIColor clearColor];
	textTableView.scrollEnabled = NO;
	textTableView.allowsSelection = NO;
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripe3.png"]];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= self.maxLength && range.length == 0)
    {
        return NO; // return NO to not change text
    }
    else
    {return YES;}
}

- (void)saveButtonPressed:(id)sender {
	UITableViewCell *cell = [textTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	UITextField *tf = (UITextField *)[cell viewWithTag:TEXTFIELD_TAG];
	
	[self.delegate textEntryViewController:self didSaveText:[tf text]];
	
	cell = nil;
	tf = nil;
}

- (void)cancelButtonPressed:(id)sender {
	[self.delegate didCancelText:self];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (nil != self.placeHolderText) {
		return self.placeHolderText;
	}else {
		return @"";
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
	
	UITextField *textField = nil;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 280, 22)];
		textField.tag = TEXTFIELD_TAG;
		textField.autocorrectionType = UITextAutocorrectionTypeNo;
		textField.clearButtonMode = UITextFieldViewModeAlways;
		textField.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
		textField.font = [UIFont systemFontOfSize:16];
		
		[cell.contentView addSubview:textField];
    } else {
		textField = (UITextField *)[cell  viewWithTag:TEXTFIELD_TAG];
	}
	
	textField.delegate = self;
	[textField setText:textValue];
	[textField becomeFirstResponder];
	
    return cell;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	[textTableView release];
	[placeHolderText release];
	[textValue release];
    [super dealloc];
}


@end
