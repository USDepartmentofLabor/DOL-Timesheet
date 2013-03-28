//
//  MealDisclaimerViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "MealDisclaimerViewController.h"


@implementation MealDisclaimerViewController

@synthesize webView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = NSLocalizedString(@"Meal and Other Breaks Disclaimer",@"Meal and Other Breaks Disclaimer");
	
	UILabel *titleLabel = [[[UILabel alloc]init]autorelease];
	titleLabel.text = NSLocalizedString(@"Meal and Other Breaks Disclaimer",@"Meal and Other Breaks Disclaimer");
	titleLabel.frame = CGRectMake(0, 0, 200, 40);
	
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.font = [UIFont boldSystemFontOfSize:20];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.adjustsFontSizeToFitWidth = YES;
	
	titleLabel.isAccessibilityElement = YES;
	titleLabel.accessibilityTraits = UIAccessibilityTraitStaticText;
	titleLabel.accessibilityLabel = [NSString stringWithFormat:@"%@.%@", titleLabel.text, NSLocalizedString(@"Heading",@"Heading")];
	
	self.navigationItem.titleView = titleLabel;
	
	webView.delegate = self;
	webView.opaque = YES;
	
	NSString *path = [[NSBundle mainBundle] pathForResource:NSLocalizedString(@"meal-en",@"Pay Disclaimer file name without extension") ofType:@"html"];
	NSURL *url = [NSURL fileURLWithPath:path];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[webView loadRequest:request];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *url = [request URL];
	
	NSString *scheme = [url scheme];
	
	if (![scheme isEqualToString:@"file"]) {
		return ![ [ UIApplication sharedApplication ] openURL:url ];
	}
	
	return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
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
	webView.delegate = nil;
    [webView stopLoading];
	[webView release];
    [super dealloc];
}


@end
