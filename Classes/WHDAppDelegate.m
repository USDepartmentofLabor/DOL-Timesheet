//
//  WHDAppDelegate.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "WHDAppDelegate.h"
#import "JobViewController.h"
#import "JobViewController.h"
#import "ReviewHoursViewController.h"
#import "ExportViewController.h"
#import "HelpViewController.h"
#import "ContactViewController.h"

@implementation WHDAppDelegate

@synthesize window;
@synthesize tabBarController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
    // Override point for customization after application launch
	
	//Copy database to the user's phone if needed.
	[self copyDatabaseIfNeeded];
	
	//create a new Tab Bar
	tabBarController = [[UITabBarController alloc] init];
	
	//Create an instance of each one of the tab views
	JobViewController *jobViewController = [[[JobViewController alloc] init] autorelease];
	ReviewHoursViewController *reviewHoursViewController = [[[ReviewHoursViewController alloc] init] autorelease];
	ExportViewController *exportViewController = [[[ExportViewController alloc] init] autorelease];
	HelpViewController *helpViewController = [[[HelpViewController alloc] init] autorelease];
	ContactViewController *contactViewController = [[[ContactViewController alloc]init] autorelease];
	

	//Add the navigation controller to the Job View
	UINavigationController *jobNavController = [[[UINavigationController alloc]
												 initWithRootViewController:jobViewController] autorelease];
	//jobNavController.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.2 blue:0.6 alpha:1];
	jobNavController.navigationBar.tintColor = [UIColor colorWithRed:0.8f green:0.0 blue:0.0 alpha:1];
	
	//Add the navigation controller to the review hours view controller
	UINavigationController *reviewNavController = [[[UINavigationController alloc]
													initWithRootViewController:reviewHoursViewController] autorelease];
	//reviewNavController.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.2 blue:0.6 alpha:1];
	reviewNavController.navigationBar.tintColor = [UIColor colorWithRed:0.8f green:0.0 blue:0.0 alpha:1];
	
	//Add the navigation controller to the export view controller
	UINavigationController *exportNavController = [[[UINavigationController alloc]
													initWithRootViewController:exportViewController] autorelease];
	exportNavController.navigationBar.tintColor = [UIColor colorWithRed:0.8f green:0.0f blue:0.0f alpha:1];
	
	NSArray *controllers = [NSArray arrayWithObjects:jobNavController, reviewNavController, exportNavController, helpViewController, contactViewController, nil];
	tabBarController.viewControllers = controllers;
	
	[window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
	
	return YES;
}

- (void)openDatabase{
	if (sqlite3_open([[self getDBPath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
	}	
}

- (void)copyDatabaseIfNeeded {
	
	//Using NSFileManager we can perform many file system operations.
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSString *dbPath = [self getDBPath];
	BOOL success = [fileManager fileExistsAtPath:dbPath];
	
	if(!success) {
		
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"whd.sqlite"];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
		
		if (!success)
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
	}
}

- (NSString *) getDBPath {
	//Search for standard documents using NSSearchPathForDirectoriesInDomains
	//First Param = Searching the documents directory
	//Second Param = Searching the Users directory and not the System
	//Expand any tildes and identify home directories.
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	return [documentsDir stringByAppendingPathComponent:@"whd.sqlite"];
}


- (void)dealloc {
	[tabBarController release];
    [window release];
    [super dealloc];
}


@end