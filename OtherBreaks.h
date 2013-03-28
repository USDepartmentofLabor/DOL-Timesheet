//
//  OtherBreaks.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

@interface OtherBreaks : NSObject {
	NSInteger otherBreaksId;
	NSInteger timeEntryId;
	NSTimeInterval breakTime;
	NSInteger breakType;
	NSString *comments;
}

@property (nonatomic, assign) NSInteger otherBreaksId;
@property (nonatomic, assign) NSInteger timeEntryId;
@property (nonatomic, assign) NSTimeInterval breakTime;
@property (nonatomic, assign) NSInteger breakType;
@property (nonatomic, copy) NSString *comments;

- (id)initWithPrimaryKey:(NSInteger)pk;

@end
