//
//  BreaksReviewController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "OtherBreaks.h"

@interface BreaksReviewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *breaksTableView;
	NSMutableArray *dataList;
}

@property (nonatomic, retain) UITableView *breaksTableView;
@property (nonatomic, retain) NSMutableArray *dataList;

@end