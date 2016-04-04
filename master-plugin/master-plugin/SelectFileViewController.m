//
//  SelectFileViewController.m
//  master-plugin
//
//  Created by Bogdan Laukhin on 3/29/16.
//  Copyright © 2016 Bogdan Laukhin. All rights reserved.
//

#import "SelectFileViewController.h"

// ADD THIS IMPORT
#import "SQOAuth.h"
#import "SQToken.h"
#import "SQFilesAPI.h"
#import "SQAuthResult.h"


#define kMainQueue dispatch_get_main_queue()
static NSString *const FILES_CONTROLLER_SEGUE_ID = @"GET_FILES";


@interface SelectFileViewController ()

// activity indicator with label properties
@property (retain, nonatomic) UIView            *messageFrame;
@property (retain, nonatomic) UILabel           *strLabel;
// @property (retain, nonatomic) UIViewController  *mainVC;
@property (retain, nonatomic) UIActivityIndicatorView *activityIndicator;

@end


@implementation SelectFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // prepare activity indicator items
    self.messageFrame = [UIView new];
    self.activityIndicator = [UIActivityIndicatorView new];
    self.strLabel = [UILabel new];
    // self.mainVC = [[[[[UIApplication sharedApplication] windows] firstObject] rootViewController] presentedViewController];
    
    
    // subscribe self as delegate to SQTokenRefreshProtocol
    [[SQOAuth sharedInstance] setRefreshTokenDelegate:self];
    
    // subscribe self as delegate to SQFileSelectorProtocol
    [[SQFilesAPI sharedInstance] setFileSelectedHandler:self];
}



#pragma mark -
#pragma mark Actions

- (IBAction)myFilesSelected:(id)sender {
    [self getFiles:sender];
}


- (IBAction)sampleFilesSelected:(id)sender {
    [self getFiles:sender];
}


- (void)getFiles:(UIButton *)sender {
    self.view.userInteractionEnabled = NO;
    [self startActivityIndicatorWithTitle:@"Loading files"];
    
    [[SQFilesAPI sharedInstance] withToken:self.token.accessToken loadFiles:^(BOOL success) {
        dispatch_async(kMainQueue, ^{
            if (success) {
                [self stopActivityIndicator];
                self.view.userInteractionEnabled = YES;
                // redirect user to view with tab bar with related files displayed (with subcategories)
                
                if ([sender.titleLabel.text containsString:@"Sample"]) {
                    NSLog(@"%@", sender.titleLabel.text);
                    [self performSegueWithIdentifier:FILES_CONTROLLER_SEGUE_ID sender:@1];
                    
                } else {
                    NSLog(@"%@", sender.titleLabel.text);
                    [self performSegueWithIdentifier:FILES_CONTROLLER_SEGUE_ID sender:@0];
                }
                
            } else {
                [self stopActivityIndicator];
                self.view.userInteractionEnabled = YES;
                [self showAlertWithMessage:@"Can't load files"];
            }
        });
    }];
}



#pragma mark -
#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:FILES_CONTROLLER_SEGUE_ID]) {
        NSNumber *indexToShow = sender;
        UITabBarController *tabBar = segue.destinationViewController;
        [tabBar setSelectedIndex:indexToShow.unsignedIntegerValue];
    }
}



#pragma mark -
#pragma mark SQTokenRefreshProtocol

- (void)tokenIsRefreshed:(SQToken *)updatedToken {
    self.token.accessToken = updatedToken.accessToken;
    self.token.expirationDate = updatedToken.expirationDate;
    self.token.tokenType = updatedToken.tokenType;
    self.token.scope = updatedToken.scope;
    // DO NOT OVERRIDE REFRESH_TOKEN PROPERTY (it comes as null after refresh token request)
}


#pragma mark -
#pragma mark SQFileSelectorProtocol

- (void)handleFileSelected:(NSDictionary *)file {
    NSLog(@"handleFileSelected: %@", file);
}



#pragma mark -
#pragma mark Activity Indicator

- (void)startActivityIndicatorWithTitle:(NSString *)title {
    dispatch_async(kMainQueue, ^{
        self.strLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 90, 30)];
        self.strLabel.text = title;
        self.strLabel.font = [UIFont systemFontOfSize:13.f];
        self.strLabel.textColor = [UIColor grayColor];
        
        CGFloat xPos = self.view.frame.size.width / 2 - 60;
        CGFloat yPos = self.view.frame.size.height / 2 + 20;
        self.messageFrame = [[UIView alloc] initWithFrame:CGRectMake(xPos, yPos, 120, 30)];
        self.messageFrame.layer.cornerRadius = 15;
        self.messageFrame.backgroundColor = [UIColor clearColor];
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicator.frame = CGRectMake(0, 0, 30, 30);
        [self.activityIndicator startAnimating];
        
        [self.messageFrame addSubview:self.activityIndicator];
        [self.messageFrame addSubview:self.strLabel];
        [self.view addSubview:self.messageFrame];
        
    });
}


- (void)stopActivityIndicator {
    dispatch_async(kMainQueue, ^{
        [self.activityIndicator stopAnimating];
        [self.messageFrame removeFromSuperview];
    });
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
