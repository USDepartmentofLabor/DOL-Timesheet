//
//  ContactViewController.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "ContactViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>
#include <netdb.h> 
#include "Reachability.h"

@implementation ContactViewController
@synthesize webView;
@synthesize backButton;
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
	
	activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[self.view addSubview:activityIndicator];
	activityIndicator.center = CGPointMake(160,173);
	
	webView.delegate = self;
	webView.opaque = YES;
	
	NSString *path = [[NSBundle mainBundle] pathForResource:NSLocalizedString(@"contact-en",@"Help file name without extension") ofType:@"html"];
	NSURL *url = [NSURL fileURLWithPath:path];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[webView loadRequest:request];
	
}

- (id)init {
	if (self = [super initWithNibName:@"ContactViewController" bundle:nil]) {
		self.title = NSLocalizedString(@"Contact-Us",@"Contact-Us");
		
		//Tab Bar item
		UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Contact-Us",@"Contact-Us") image:[UIImage imageNamed:@"whd-icon-2.png"] tag:3];
		self.tabBarItem = item;
		[item release];
	}
	return self;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[activityIndicator startAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	NSLog(@"Error: %@", [error localizedDescription]);
	[activityIndicator stopAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[backButton setEnabled:[self.webView canGoBack]];
	[activityIndicator stopAnimating];
}

- (void)backButtonPressed:(id)sender {
	[self.webView goBack];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *url = [request URL];
	
	NSString *scheme = [url scheme];
	
	if (![scheme isEqualToString:@"file"]) {
		 Reachability *r = [Reachability reachabilityWithHostName:@"www.dol.gov"];
		 
		 NetworkStatus internetStatus = [r currentReachabilityStatus];
		 
		 if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
		 {
		 UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Internet Connection", @"No Internet Connection") message:NSLocalizedString(@"An internet connection is required to open external links.",@"No internet error") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		 [myAlert show];
		 [myAlert release];
		 return NO;
		 }
		return ![ [ UIApplication sharedApplication ] openURL:url ];
	}
	
	return YES;
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
	[webView setDelegate:nil];
	[webView release];
	[backButton release];
	[activityIndicator release];
    [super dealloc];
}


@end
