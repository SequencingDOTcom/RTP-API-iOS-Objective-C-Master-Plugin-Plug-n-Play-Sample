//
//  SQOAuth.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQOAuth.h"
#import "SQServerManager.h"
#import "SQToken.h"
#import "SQAuthResult.h"



@implementation SQOAuth

#pragma mark - Initializer

+ (instancetype)sharedInstance {
    static SQOAuth *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SQOAuth alloc] init];
    });
    return instance;
}


- (void)registrateApplicationParametersCliendID:(NSString *)client_id ClientSecret:(NSString *)client_secret RedirectUri:(NSString *)redirect_uri Scope:(NSString *)scope {
    [[SQServerManager sharedInstance] registrateParametersCliendID:client_id ClientSecret:client_secret RedirectUri:redirect_uri Scope:scope];
}




#pragma mark - for Guest user

- (void)authorizeUser {
    [[SQServerManager sharedInstance] authorizeUser:^(SQToken *token, BOOL didCancel, BOOL error) {
        
        if (token.accessToken != nil) {
            [self.authorizationDelegate userIsSuccessfullyAuthorized:token];
            
        } else if (didCancel) {
            if ([self.authorizationDelegate respondsToSelector:@selector(userDidCancelAuthorization)]) {
                [self.authorizationDelegate userDidCancelAuthorization];
            }
            
        } else if (error) {
            [self.authorizationDelegate userIsNotAuthorized];
            
        }
    }];
}




#pragma mark - Token methods for Authorized user

- (void)token:(void(^)(SQToken *token))tokenResult {
    if ([self isTokenUpToDay]) { // token is valid > let's return current token
        SQToken *currentToken = [[SQAuthResult sharedInstance] token];
        tokenResult(currentToken);
        
    } else { // token is expired > let's update it
        [self updateUserTokenWithCompletion:^(BOOL success) {
            
            if (success) {
                SQToken *updatedToken = [[SQAuthResult sharedInstance] token];
                tokenResult(updatedToken);
                
            } else // smth is wrong, we can't update token
                tokenResult(nil);
        }];
    }
}


- (BOOL)isTokenUpToDay {
    NSLog(@">>>>> [SQOAuth]: verifying if Token is UpToDay");
    
    BOOL tokenIsValid = NO;
    SQToken *currentToken = [[SQAuthResult sharedInstance] token];
    
    if (currentToken) {
        NSDate *nowDate = [NSDate date];
        NSDate *expDate = currentToken.expirationDate;
        
        if ([nowDate compare:expDate] == NSOrderedDescending) { // token is expired
            NSLog(@">>>>> [SQOAuth]: token is expired");
            
        } else { // token is valid
            NSLog(@">>>>> [SQOAuth]: token is valid");
            tokenIsValid = YES;
        }
    }
    
    return tokenIsValid;
}


- (void)updateUserTokenWithCompletion:(void (^)(BOOL success))completion {
    NSLog(@">>>>> [SQOAuth]: execute refresh token request (token update)");
    SQToken *currentToken = [[SQAuthResult sharedInstance] token];
    
    if (currentToken.refreshToken == nil) { // we can't updated token without "refresh token" value
        completion(NO);
        return;
    }
    
    // current token is valid > let's execute refresh token request
    [self withRefreshToken:currentToken updateAccessToken:^(SQToken *updatedToken) {
        
        if (updatedToken == nil) { // invalid token
            completion(NO);
            return;
        }
        
        if (updatedToken.accessToken == nil) { // invalid token
            completion(NO);
            return;
        }
        
        if (updatedToken.refreshToken == nil) { // invalid token
            completion(NO);
            return;
        }
        
        // let's return valid token
        completion(YES);
    }];
}


- (void)withRefreshToken:(SQToken *)refreshToken updateAccessToken:(void (^)(SQToken *))tokenResult {
    [[SQServerManager sharedInstance] withRefreshToken:refreshToken
                                     updateAccessToken:^(SQToken *token) {
                                         
                                         tokenResult(token);
                                     }];
}


- (void)userDidSignOut {
    [[SQServerManager sharedInstance] userDidSignOut];
}




#pragma mark -
#pragma mark Registrate new account

- (void)registrateNewAccountForEmailAddress:(NSString *)emailAddress {
    [[SQServerManager sharedInstance] registrateAccountForEmailAddress:emailAddress withResult:^(NSString *error) {
        
        if (error == nil) {
            [self.signUpDelegate emailIsRegisteredSuccessfully];
            
        } else {
            [self.signUpDelegate emailIsNotRegistered:error];
        }
    }];
}



#pragma mark -
#pragma mark Reset password

- (void)resetPasswordForEmailAddress:(NSString *)emailAddress {
    [[SQServerManager sharedInstance] resetPasswordForEmailAddress:emailAddress withResult:^(NSString *error) {
        
        if (error == nil) {
            [self.resetPasswordDelegate applicationForPasswordResetIsAccepted];
            
        } else {
            [self.resetPasswordDelegate applicationForPasswordResetIsNotAccepted:error];
        }
    }];
}



@end
