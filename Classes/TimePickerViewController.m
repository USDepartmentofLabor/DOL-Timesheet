//
//  TimePickerViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "TimePickerViewController.h"

@implementation TimePickerViewController

@synthesize nowButton;
@synthesize defaultButton;
@synthesize messageLabel;
@synthesize datePicker;
@synthesize defaultTime;
@synthesize selectedDate;
@synthesize delegate;
@synthesize displayText;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

- (IBAction)nowBarButtonPressed:(id)sender {
	datePicker.date = [NSDate date];
	
	[UIView beginAnimations:@"buttonFades" context:nil];
	[UIView setAnimationDuration:0.5];
	[nowButton setAlpha:0.0];
	[UIView commitAnimations];
}

- (IBAction)defaultBarButtonPressed:(id)sender {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	
	NSDate *today = [NSDate date];
	NSDateComponents *todayComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:today];
	NSDateComponents *defaultComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:defaultTime];
	
	NSDateComponents *finalComponents = [[NSDateComponents alloc]init];
	[finalComponents setYear:[todayComponents year]];
	[finalComponents setMonth:[todayComponents month]];
	[finalComponents setDay:[todayComponents day]];
	[finalComponents setHour:[defaultComponents hour]];
	[finalComponents setMinute:[defaultComponents minute]];
	
	[datePicker setDate:[calendar dateFromComponents:finalComponents] animated:YES];
	[finalComponents release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = NSLocalizedString(@"Time",@"Time");
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripe3.png"]];
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveButtonPressed:)];
	[self.navigationItem setRightBarButtonItem:saveButton animated:NO];
	[saveButton release];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
	[self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
	[cancelButton release];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	
	if (defaultTime != nil ) {
		[defaultButton setTitle:[formatter stringFromDate:defaultTime] forState:UIControlStateNormal];
		defaultButton.hidden = NO;
	} else {
		[defaultButton setTitle:@"No default" forState:UIControlStateNormal];
		defaultButton.hidden = YES;
	}
	
	[formatter release];
	
	messageLabel.text = displayText;
	messageLabel.isAccessibilityElement = YES;
	messageLabel.accessibilityTraits = UIAccessibilityTraitStaticText;
	messageLabel.accessibilityLabel = [NSString stringWithFormat:@"%@.%@", messageLabel.text, NSLocalizedString(@"Heading",@"Heading")];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.selectedDate != nil) {
		[datePicker setDate:selectedDate animated:NO];
		
	} else {
		[datePicker setDate:[NSDate date] animated:NO];
	}
	//Bug ID 2594
	//Manual Time Entry – Select Started Work and Stop Worked – Disable Current Time button  if the user is on the current time.
	NSDate *today = [NSDate date];
	NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:today];
	NSDateComponents *defaultComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:[datePicker date]];
	
	if ([todayComponents year] == [defaultComponents year] && [todayComponents month] == [defaultComponents month] && [todayComponents day] == [defaultComponents day] && [todayComponents hour] == [defaultComponents hour] && [todayComponents minute] == [defaultComponents minute]) {
		[nowButton setAlpha:0.0];
	} else {
		[nowButton setAlpha:1.0];
	}
}

- (IBAction)timeChanged:(id)sender { //Bug ID 2594
	
	NSDate *today = [NSDate date];
	NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:today];
	NSDateComponents *defaultComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:[datePicker date]];
	
	if ([todayComponents year] == [defaultComponents year] && [todayComponents month] == [defaultComponents month] && [todayComponents day] == [defaultComponents day] && [todayComponents hour] == [defaultComponents hour] && [todayComponents minute] == [defaultComponents minute]) {
		[UIView beginAnimations:@"buttonFades" context:nil];
		[UIView setAnimationDuration:0.5];
		[nowButton setAlpha:0.0];
		[UIView commitAnimations];
	} else {
		[UIView beginAnimations:@"buttonFades" context:nil];
		[UIView setAnimationDuration:0.5];
		[nowButton setAlpha:1.0];
		[UIView commitAnimations];
	}
}

- (void)cancelButtonPressed:(id)sender {
	[self.delegate didCancelDate:self];
}

- (void)saveButtonPressed:(id)sender {
	[self.delegate timePickerViewController:self didSaveDate:datePicker.date];
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
	[messageLabel release];
	[datePicker release];
	[defaultTime release];
	[defaultButton release];
	[nowButton release];
	[selectedDate release];
	[displayText release];
    [super dealloc];
}


@end
