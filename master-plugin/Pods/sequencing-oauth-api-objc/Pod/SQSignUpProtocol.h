//
//  SQSignUpProtocol.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>


@protocol SQSignUpProtocol <NSObject>

@required
- (void)emailIsRegisteredSuccessfully;
- (void)emailIsNotRegistered:(NSString *)errorMessage;


@end
