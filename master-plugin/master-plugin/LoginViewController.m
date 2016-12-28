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


@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set up login button
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setImage:[UIImage imageNamed:@"button_signin_black"] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [loginButton sizeToFit];
    [loginButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:loginButton];
    
    // adding constraints for login button
    NSLayoutConstraint *xCenter = [NSLayoutConstraint constraintWithItem:loginButton
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1
                                                                constant:0];
    NSLayoutConstraint *yCenter = [NSLayoutConstraint constraintWithItem:loginButton
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1
                                                                constant:0];
    [self.view addConstraint:xCenter];
    [self.view addConstraint:yCenter];
    
    
    // REGISTER APPLICATION PARAMETERS
    [[SQOAuth sharedInstance] registrateApplicationParametersCliendID:CLIENT_ID
                                                         ClientSecret:CLIENT_SECRET
                                                          RedirectUri:REDIRECT_URI
                                                                Scope:SCOPE];
    
    // subscribe self as delegate to SQAuthorizationProtocol
    [[SQOAuth sharedInstance] setAuthorizationDelegate:self];
}



#pragma mark -
#pragma mark Actions

- (void)loginButtonPressed {
    self.view.userInteractionEnabled = NO;
    [[SQOAuth sharedInstance] authorizeUser];
}



#pragma mark -
#pragma mark SQAuthorizationProtocol

- (void)userIsSuccessfullyAuthorized:(SQToken *)token {
    dispatch_async(kMainQueue, ^{
        // self.token = token;
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


#pragma mark -
#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:SELECT_FILES_SEGUE_ID]) {
        SelectFileViewController *selectFileVC = segue.destinationViewController;
        [selectFileVC setToken:sender];
    }
}



#pragma mark -
#pragma mark Alert message

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:close];
    [self presentViewController:alert animated:YES completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
