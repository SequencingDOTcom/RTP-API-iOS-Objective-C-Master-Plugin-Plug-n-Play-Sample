//
//  LoginViewController.m
//  Copyright © 2016 Sequencing.com. All rights reserved
//

#import "LoginViewController.h"
#import "SelectFileViewController.h"


// ADD THIS IMPORT
#import "SQOAuth.h"
#import "SQToken.h"

// THESE ARE APPLICATION PARAMETERS (from App Registration - https://sequencing.com/developer-documentation/app-registration)
// SPECIFY THEM HERE
static NSString *const CLIENT_ID        = @"oAuth2 Demo ObjectiveC";
static NSString *const CLIENT_SECRET    = @"RZw8FcGerU9e1hvS5E-iuMb8j8Qa9cxI-0vfXnVRGaMvMT3TcvJme-Pnmr635IoE434KXAjelp47BcWsCrhk0g";
static NSString *const REDIRECT_URI     = @"authapp://Default/Authcallback";
static NSString *const SCOPE            = @"demo,external";

#define kMainQueue dispatch_get_main_queue()
static NSString *const SELECT_FILES_SEGUE_ID = @"SELECT_FILES";



@interface LoginViewController () <UserSignOutProtocol>

@end



@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // REGISTER APPLICATION PARAMETERS
    [[SQOAuth sharedInstance] registerApplicationParametersCliendID:CLIENT_ID
                                                       clientSecret:CLIENT_SECRET
                                                        redirectUri:REDIRECT_URI
                                                              scope:SCOPE
                                                           delegate:self
                                             viewControllerDelegate:self];
}



#pragma mark - Actions

- (IBAction)authorizeButtonPressed:(id)sender {
    [[SQOAuth sharedInstance] authorizeUser];
}


- (IBAction)registerResetButtonPressed:(id)sender {
    [[SQOAuth sharedInstance] callRegisterResetAccountFlow];
}




#pragma mark - SQAuthorizationProtocol

- (void)userIsSuccessfullyAuthorized:(SQToken *)token {
    dispatch_async(kMainQueue, ^{
        self.view.userInteractionEnabled = YES;
        [self performSegueWithIdentifier:SELECT_FILES_SEGUE_ID sender:token];
    });
}

- (void)userIsNotAuthorized {
    dispatch_async(kMainQueue, ^{
        self.view.userInteractionEnabled = YES;
        [self showAlertWithMessage:@"Server error\nCan't authorize user"];
    });
}

- (void)userDidCancelAuthorization {
    dispatch_async(kMainQueue, ^{
        self.view.userInteractionEnabled = YES;
    });
}



#pragma mark - UserSignOutProtocol

- (void)userDidSignOut {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Delete any cached URLrequests!
    NSURLCache *sharedCache = [NSURLCache sharedURLCache];
    [sharedCache removeAllCachedResponses];
    
    // Also delete all stored cookies!
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookies];
    id cookie;
    for (cookie in cookies) {
        [cookieStorage deleteCookie:cookie];
    }
    
    NSDictionary *credentialsDict = [[NSURLCredentialStorage sharedCredentialStorage] allCredentials];
    if ([credentialsDict count] > 0) {
        // the credentialsDict has NSURLProtectionSpace objs as keys and dicts of userName => NSURLCredential
        NSEnumerator *protectionSpaceEnumerator = [credentialsDict keyEnumerator];
        id urlProtectionSpace;
        // iterate over all NSURLProtectionSpaces
        while (urlProtectionSpace = [protectionSpaceEnumerator nextObject]) {
            NSEnumerator *userNameEnumerator = [[credentialsDict objectForKey:urlProtectionSpace] keyEnumerator];
            id userName;
            // iterate over all usernames for this protectionspace, which are the keys for the actual NSURLCredentials
            while (userName = [userNameEnumerator nextObject]) {
                NSURLCredential *cred = [[credentialsDict objectForKey:urlProtectionSpace] objectForKey:userName];
                //NSLog(@"credentials to be removed: %@", cred);
                [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:cred forProtectionSpace:urlProtectionSpace];
            }
        }
    }
}




#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:SELECT_FILES_SEGUE_ID]) {
        UINavigationController *selectFileNav = segue.destinationViewController;
        SelectFileViewController *selectFileVC = [[selectFileNav viewControllers] firstObject];
        [selectFileVC setDelegate:self];
    }
}




#pragma mark - Alert message

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:close];
    [self presentViewController:alert animated:YES completion:nil];
}





@end
