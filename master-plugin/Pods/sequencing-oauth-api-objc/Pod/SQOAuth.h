//
//  SQOAuth.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>
#import "SQAuthorizationProtocol.h"
#import "SQResetPasswordProtocol.h"
#import "SQSignUpProtocol.h"

@class SQToken;


@interface SQOAuth : NSObject

@property (weak, nonatomic) id<SQAuthorizationProtocol> authorizationDelegate;
@property (weak, nonatomic) id<SQResetPasswordProtocol> resetPasswordDelegate;
@property (weak, nonatomic) id<SQSignUpProtocol>        signUpDelegate;


// designated initializer
+ (instancetype)sharedInstance;

// method to set up apllication registration parameters
- (void)registrateApplicationParametersCliendID:(NSString *)client_id ClientSecret:(NSString *)client_secret RedirectUri:(NSString *)redirect_uri Scope:(NSString *)scope;

// method to registrate new account
- (void)registrateNewAccountForEmailAddress:(NSString *)emailAddress;

// method to reset password
- (void)resetPasswordForEmailAddress:(NSString *)emailAddress;

// authorization method that uses SQAuthorizationProtocol as result
- (void)authorizeUser;


// receive updated token
- (void)token:(void(^)(SQToken *token))tokenResult;

// shoud be used when user is authorized but token is expired
- (void)withRefreshToken:(SQToken *)refreshToken updateAccessToken:(void(^)(SQToken *token))tokenResult;


// should be called when sign out, this method will stop refreshToken autoupdater
- (void)userDidSignOut;

@end
