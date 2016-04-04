//
//  SQOAuth.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>
#import "SQAuthResult.h"
#import "SQToken.h"
#import "SQAuthorizationProtocol.h"
#import "SQTokenRefreshProtocol.h"

@class SQAuthResult;
@class SQToken;

@interface SQOAuth : NSObject

@property (strong, nonatomic) id <SQAuthorizationProtocol> authorizationDelegate;
@property (strong, nonatomic) id <SQTokenRefreshProtocol> refreshTokenDelegate;

// designated initializer
+ (instancetype)sharedInstance;

// method to set up allication registration parameters
- (void)registrateApplicationParametersCliendID:(NSString *)client_id
                                   ClientSecret:(NSString *)client_secret
                                    RedirectUri:(NSString *)redirect_uri
                                          Scope:(NSString *)scope;

// authorization method that uses SQAuthorizationProtocol as result
- (void)authorizeUser;


@end
