//
//  TimerViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "TimerViewController.h"


@implementation TimerViewController

@synthesize timerPicker;
@synthesize defaultButton;
@synthesize noneButton;
@synthesize defaultValue;
@synthesize selectedValue;
@synthesize delegate;


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
	
	if (defaultValue > 0) {
		// Get the system calendar
		NSCalendar *sysCalendar = [NSCalendar currentCalendar];

		NSDate *d1 = [[NSDate alloc] init];
		NSDate *d2 = [[NSDate alloc] initWithTimeInterval:defaultValue sinceDate:d1];
		
		// Get conversion to months, days, hours, minutes
		unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;

		NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:d1 toDate:d2 options:0];
		
		[defaultButton setTitle:[NSString stringWithFormat:@"%02dh %02dm", [conversionInfo hour], [conversionInfo minute]] forState:UIControlStateNormal];
		[d1 release];
		[d2 release];
		
		//Accesibility
		defaultButton.isAccessibilityElement = YES;
		defaultButton.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"%d hours and %d minutes", @"Accesibility for Time Entry"), [conversionInfo hour], [conversionInfo minute]];
		//
		
		defaultButton.hidden = NO;
	} else {
		[defaultButton setTitle:@"No default" forState:UIControlStateNormal];
		defaultButton.hidden = YES;
	}
	
	self.timerPicker.countDownDuration = self.selectedValue;
}

- (void)defaultButtonPressed:(id)sender {
	self.timerPicker.countDownDuration = defaultValue;
}

- (IBAction)noneButtonPressed:(id)sender {
	self.timerPicker.countDownDuration = 0;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)saveButtonPressed:(id)sender {
	[self.delegate timerViewController:self didSaveTimer:self.timerPicker.countDownDuration];
}

- (void)cancelButtonPressed:(id)sender {
	[self.delegate didCancelTimer:self];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[timerPicker release];
	[defaultButton release];
	[noneButton release];
    [super dealloc];
}


@end
