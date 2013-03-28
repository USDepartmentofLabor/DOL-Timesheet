//
//  PayDisclaimerViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "PayDisclaimerViewController.h"


@implementation PayDisclaimerViewController
@synthesize webView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Reminder",@"Reminder");
	
	webView.delegate = self;
	webView.opaque = YES;
	
	NSString *path = [[NSBundle mainBundle] pathForResource:NSLocalizedString(@"pay-en",@"Pay Disclaimer file name without extension") ofType:@"html"];
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
