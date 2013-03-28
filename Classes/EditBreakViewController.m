//
//  EditBreakViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "EditBreakViewController.h"
#import "MealDisclaimerViewController.h"

#define COMMENTS_TAG 1001

@implementation EditBreakViewController

@synthesize breakTableView;
@synthesize timerPicker;
@synthesize footerView;
@synthesize otherBreak;
@synthesize delegate;
@synthesize selectedValue;
@synthesize commentsValue;
@synthesize breakType;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

- (IBAction)disclaimerTap:(id)sender {
	
	//Dismiss the keyboard
	UITableViewCell *cell = [breakTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	UITextView *tv = (UITextView *)[cell viewWithTag:COMMENTS_TAG];
	
	if ([tv isFirstResponder]) {
		[tv resignFirstResponder];
	}
	
	MealDisclaimerViewController *disclaimer = [[MealDisclaimerViewController alloc] initWithNibName:@"MealDisclaimerViewController" bundle:nil];
	[self.navigationController pushViewController:disclaimer animated:YES];
	[disclaimer release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveButtonPressed:)];
	[self.navigationItem setRightBarButtonItem:saveButton animated:NO];
	[saveButton release];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
	[self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
	[cancelButton release];	
	
	breakTableView.backgroundColor = [UIColor clearColor];
	breakTableView.scrollEnabled = NO;
	breakTableView.allowsSelection = YES;
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripe3.png"]];
	
	//self.timerPicker.countDownDuration = self.selectedValue;
}

- (void)cancelButtonPressed:(id)sender {
	[self.delegate didCancelBreak:self];
}

- (void)saveButtonPressed:(id)sender {
	UITableViewCell *cell = [breakTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	UITextView *tv = (UITextView *)[cell viewWithTag:COMMENTS_TAG];
	
	if (self.otherBreak == nil) {
		self.otherBreak = [[[OtherBreaks alloc]init]autorelease];
	}
	
	self.otherBreak.comments = tv.text;
	self.otherBreak.breakTime = timerPicker.countDownDuration;
	self.otherBreak.breakType = self.breakType;
	
	[self.delegate editBreakViewController:self didSaveBreak:self.otherBreak];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
		case 0:
			return 1;
			break;
		default:
			return 0;
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) 
	{
		case 0:
			return NSLocalizedString(@"Comments",@"Comments");
			break;
		default:
			return @"";
			break;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	UITextView *txtComments;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		txtComments = [[[UITextView alloc] initWithFrame:CGRectMake(10, 3, 280, 70)] autorelease];
		txtComments.tag = COMMENTS_TAG;
		txtComments.textColor = [UIColor colorWithRed:0.219 green:0.329 blue:0.529 alpha:1.0];
		txtComments.keyboardType = UIKeyboardTypeDefault;
		txtComments.returnKeyType = UIReturnKeyDone;
		txtComments.autocorrectionType = UITextAutocorrectionTypeNo;
		txtComments.font = [UIFont systemFontOfSize:14];
		txtComments.delegate = self;
		
		txtComments.backgroundColor = [UIColor clearColor];
		
		// Always add subview at end. If you add Subview first then label text, the subview will be
		// covered by the label
		[cell.contentView addSubview:txtComments];
    }
	else {
		txtComments = (UITextView *)[cell.contentView viewWithTag:COMMENTS_TAG];
	}
	
	if (self.commentsValue != nil) {
		txtComments.text = self.commentsValue;
		self.commentsValue = nil;
	}
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 80.0;
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 50;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {   // custom view for footer. will be adjusted to default or specified footer height
	
	if (footerView == nil) {
		footerView = [[UIView alloc] init];
		
		//we would like to show a gloosy red button, so get the image first
		UIImage *image = [[UIImage imageNamed:@"redButton.png"]
						  stretchableImageWithLeftCapWidth:12 topCapHeight:0];
		
		//create the button
		//ColorfulButton *disclaimerButton = [[ColorfulButton alloc] initWithFrame:CGRectMake(10, 10, 300, 44)];
		UIButton *disclaimerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[disclaimerButton setBackgroundImage:image forState:UIControlStateNormal];
		
		
		//the button should be as big as a table view cell
		[disclaimerButton setFrame:CGRectMake(10, 10, 300, 44)];

		//set title, font size and font color
		[disclaimerButton setTitle:NSLocalizedString(@"Meal and Other Breaks Disclaimer",@"Meal and Other Breaks Disclaimer") forState:UIControlStateNormal];
		[disclaimerButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
		[disclaimerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		
		//set action of the button
		[disclaimerButton addTarget:self action:@selector(disclaimerTap:)
		 forControlEvents:UIControlEventTouchUpInside];
		
		[footerView addSubview:disclaimerButton];
		
	}
		
	return footerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//Dismiss the keyboard
	UITableViewCell *cell = [breakTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	UITextView *tv = (UITextView *)[cell viewWithTag:COMMENTS_TAG];
	
	if (![tv isFirstResponder]) {
		[tv becomeFirstResponder];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	
	BOOL shouldChangeText = YES;
	
	if ([text isEqualToString:@"\n"]) {
		[textView resignFirstResponder];
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

-(void)textViewDidEndEditing:(UITextView *)textView {
	CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];	
}


- (void)textViewDidBeginEditing:(UITextView *)textView{
	CGRect textFieldRect = [self.view.window convertRect:textView.bounds fromView:textView];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
	
	CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =	midline - viewRect.origin.y	- MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    
	CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
	
	if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
	
	UIInterfaceOrientation orientation =
	[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
	
	CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
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
	[breakTableView release];
	[footerView release];
	[otherBreak release];
	[timerPicker release];
	[commentsValue release];
    [super dealloc];
}


@end
