//
//  SQOAuth.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQOAuth.h"
#import "SQServerManager.h"

@interface SQOAuth()

@property (strong, nonatomic) SQAuthResult *auth;

@end


@implementation SQOAuth

+ (instancetype)sharedInstance {
    static SQOAuth *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SQOAuth alloc] init];
    });
    return instance;
}

- (void)registrateApplicationParametersCliendID:(NSString *)client_id
                                   ClientSecret:(NSString *)client_secret
                                    RedirectUri:(NSString *)redirect_uri
                                          Scope:(NSString *)scope {
    [[SQServerManager sharedInstance] registrateParametersCliendID:client_id
                                                    ClientSecret:client_secret
                                                     RedirectUri:redirect_uri
                                                           Scope:scope];
}

- (void)authorizeUser {
    [[SQServerManager sharedInstance] authorizeUser:^(SQToken *token) {
        if (token) {
            [self.authorizationDelegate userIsSuccessfullyAuthorized:token];
            
        } else {
            [self.authorizationDelegate userIsNotAuthorized];
        }
    }];
}


@end
