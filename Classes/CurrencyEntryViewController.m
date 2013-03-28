//
//  CurrencyEntryViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "CurrencyEntryViewController.h"
#define TEXTFIELD_TAG 1001

@implementation CurrencyEntryViewController

@synthesize textTableView;
@synthesize placeHolderText;
@synthesize delegate;
@synthesize currencyAmount;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

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

- (void)saveButtonPressed:(id)sender {
	[self.delegate currencyEntryViewController:self didSaveCurrency:currencyAmount];
}

- (void)cancelButtonPressed:(id)sender {
	[self.delegate didCancelCurrency:self];
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
		textField.clearButtonMode = UITextFieldViewModeNever;
		textField.delegate = self;
		textField.keyboardType = UIKeyboardTypeNumberPad;
		textField.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
		textField.font = [UIFont systemFontOfSize:16];
		
		[cell.contentView addSubview:textField];
    } else {
		textField = (UITextField *)[cell viewWithTag:TEXTFIELD_TAG];
	}
	
	if (self.currencyAmount == nil) {
		self.currencyAmount = [[[NSNumber alloc] initWithFloat:0.0]autorelease];
	}
	
	NSNumberFormatter *_currencyFormatter = [[NSNumberFormatter alloc] init];
	[_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[_currencyFormatter setCurrencyCode:@"USD"];
	[_currencyFormatter setNegativeFormat:@"-¤#,##0.00"];
	textField.text = [_currencyFormatter stringFromNumber:currencyAmount];
	[_currencyFormatter release];
	
	textField.delegate = self;
	[textField becomeFirstResponder];
	
	
	//Release the object because cell.contentview is holding on to it.
	[textField release];
	
    return cell;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range 
replacementString:(NSString *)string
{
	// Clear all characters that are not numbers
	// (like currency symbols or dividers)
	NSString *cleanCentString = [[textField.text
								  componentsSeparatedByCharactersInSet:
								  [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
								 componentsJoinedByString:@""];
	// Parse final integer value
	NSInteger centAmount = cleanCentString.integerValue;
	// Check the user input
	if (string.length > 0)
	{
		// Digit added
		centAmount = centAmount * 10 + string.integerValue;
	}
	else
	{
		// Digit deleted
		centAmount = centAmount / 10;
	}
	
	if (centAmount < 100000) {
		// Update call amount value
		self.currencyAmount = [[[NSNumber alloc] initWithFloat:(float)centAmount / 100.0f] autorelease];
		// Write amount with currency symbols to the textfield
		NSNumberFormatter *_currencyFormatter = [[NSNumberFormatter alloc] init];
		[_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[_currencyFormatter setCurrencyCode:@"USD"];
		[_currencyFormatter setNegativeFormat:@"-¤#,##0.00"];
		textField.text = [_currencyFormatter stringFromNumber:self.currencyAmount];
		[_currencyFormatter release];
	}
	// Since we already wrote our changes to the textfield
	// we don't want to change the textfield again
	return NO;
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
	[currencyAmount release];
    [super dealloc];
}


@end
