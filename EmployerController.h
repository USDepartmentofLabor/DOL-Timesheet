//
//  EmployerController.h
//  WHD
//
//  Created by the US Department of Labor.
//  Code available in the public domain
//

#import <Foundation/Foundation.h>
#import "Employer.h"

@interface EmployerController : NSObject {

}

+ (NSMutableArray *) getEmployers;
+ (NSInteger)addEmployer:(Employer *)e;
+ (NSInteger)updateEmployer:(Employer *)e;
+ (NSInteger)deleteEmployer:(Employer *)e;
@end
