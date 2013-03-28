//
//  UITableViewCellWithSubtitle.m
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import "UITableViewCellWithSubtitle.h"


@implementation UITableViewCellWithSubtitle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}

- (void) layoutSubviews {
	[super layoutSubviews];
	self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, 
                                      4.0, 
                                      self.textLabel.frame.size.width, 
                                      self.textLabel.frame.size.height);
	self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x, 
											8.0 + self.textLabel.frame.size.height, 
											self.detailTextLabel.frame.size.width, 
											self.detailTextLabel.frame.size.height);
}

@end
