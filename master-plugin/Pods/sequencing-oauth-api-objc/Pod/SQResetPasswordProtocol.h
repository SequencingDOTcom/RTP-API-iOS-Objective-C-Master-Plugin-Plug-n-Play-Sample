//
//  SQResetPasswordProtocol.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//


#import <Foundation/Foundation.h>


@protocol SQResetPasswordProtocol <NSObject>

@required
- (void)applicationForPasswordResetIsAccepted;
- (void)applicationForPasswordResetIsNotAccepted:(NSString *)errorMessage;

@end
