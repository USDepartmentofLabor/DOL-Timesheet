//
//  WHDAppDelegate.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@class Employer;

@interface WHDAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	UITabBarController *tabBarController;
	
	sqlite3 *database;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

- (void) copyDatabaseIfNeeded;
- (NSString *) getDBPath;
@end

