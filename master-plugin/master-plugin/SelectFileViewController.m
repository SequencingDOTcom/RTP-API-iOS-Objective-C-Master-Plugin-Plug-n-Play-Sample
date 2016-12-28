//
//  SelectFileViewController.m
//  Copyright © 2016 Sequencing.com. All rights reserved
//

#import "SelectFileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppChainsHelper.h"

// ADD THIS IMPORT
#import "SQOAuth.h"
#import "SQToken.h"
#import "SQFilesAPI.h"
#import "SQAuthResult.h"


#define kMainQueue dispatch_get_main_queue()
static NSString *const FILES_CONTROLLER_SEGUE_ID = @"GET_FILES";


@interface SelectFileViewController ()

// activity indicator with label properties
@property (retain, nonatomic) UIView *messageFrame;
@property (retain, nonatomic) UILabel *strLabel;
@property (retain, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIView     *buttonView;
@property (weak, nonatomic) IBOutlet UIButton   *buttonSelectFile;

@property (weak, nonatomic) IBOutlet UISegmentedControl *getFileInfo;
@property (weak, nonatomic) IBOutlet UIView *segmentedControlView;

@property (weak, nonatomic) IBOutlet UIView *batchButtonView;
@property (weak, nonatomic) IBOutlet UIButton *batchButton;

@property (weak, nonatomic) IBOutlet UILabel    *selectedFileTagline;
@property (weak, nonatomic) IBOutlet UILabel    *selectedFileName;
@property (weak, nonatomic) IBOutlet UILabel    *vitaminDInfo;
@property (weak, nonatomic) IBOutlet UILabel    *melanomaInfo;

@property (strong, nonatomic) NSDictionary *selectedFile;

@end


@implementation SelectFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Using genetic file";
    
    // prepare activity indicator items
    self.messageFrame = [UIView new];
    self.activityIndicator = [UIActivityIndicatorView new];
    self.strLabel = [UILabel new];
    
    // subscribe self as delegate to SQTokenRefreshProtocol
    [[SQOAuth sharedInstance] setRefreshTokenDelegate:self];
    
    // subscribe self as delegate to SQFileSelectorProtocol
    [[SQFilesAPI sharedInstance] setFileSelectedHandler:self];
    [SQFilesAPI sharedInstance].closeButton = YES;
    
    // adjust buttons view
    self.buttonView.layer.cornerRadius = 5;
    self.buttonView.layer.masksToBounds = YES;
    self.buttonView.layer.borderColor = [UIColor colorWithRed:35/255.0 green:121/255.0 blue:254/255.0 alpha:1.0].CGColor;
    self.buttonView.layer.borderWidth = 1.f;
    
    self.segmentedControlView.layer.cornerRadius = 5;
    self.segmentedControlView.layer.masksToBounds = YES;
    
    self.batchButtonView.layer.cornerRadius = 5;
    self.batchButtonView.layer.masksToBounds = YES;
    self.batchButtonView.layer.borderColor = [UIColor colorWithRed:35/255.0 green:121/255.0 blue:254/255.0 alpha:1.0].CGColor;
    self.batchButtonView.layer.borderWidth = 1.f;
    
    [self.selectedFileTagline setHidden:YES];
    [self.selectedFileName setHidden:YES];
    [self.getFileInfo setHidden:YES];
    [self.segmentedControlView setHidden:YES];
    [self.batchButtonView setHidden:YES];
    [self.batchButton setHidden:YES];
    [self.vitaminDInfo setHidden:YES];
    [self.melanomaInfo setHidden:YES];
}


- (void)dealloc {
    // unsubscribe self as delegate to SQTokenRefreshProtocol
    [[SQOAuth sharedInstance] setRefreshTokenDelegate:nil];
    
    // unsubscribe self as delegate to SQFileSelectorProtocol
    [[SQFilesAPI sharedInstance] setFileSelectedHandler:nil];
}



#pragma mark -
#pragma mark Actions

- (IBAction)loadFilesPressed:(id)sender {
    self.view.userInteractionEnabled = NO;
    [self startActivityIndicatorWithTitle:@"Loading files"];
    [self.selectedFileTagline setHidden:YES];
    [self.selectedFileName setHidden:YES];
    [self.getFileInfo setHidden:YES];
    [self.segmentedControlView setHidden:YES];
    [self.batchButtonView setHidden:YES];
    [self.batchButton setHidden:YES];
    [self.vitaminDInfo setHidden:YES];
    [self.melanomaInfo setHidden:YES];
    
    [[SQFilesAPI sharedInstance] withToken:self.token.accessToken loadFiles:^(BOOL success) {
        dispatch_async(kMainQueue, ^{
            if (success) {
                [self stopActivityIndicator];
                self.view.userInteractionEnabled = YES;
                [self performSegueWithIdentifier:FILES_CONTROLLER_SEGUE_ID sender:nil];
                
            } else {
                [self stopActivityIndicator];
                self.view.userInteractionEnabled = YES;
                [self showAlertWithMessage:@"Sorry, can't load files"];
            }
        });
    }];
}



#pragma mark -
#pragma mark SQFileSelectorProtocol

- (void)handleFileSelected:(NSDictionary *)file {
    NSLog(@"handleFileSelected: %@", file);
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (file && [[file allKeys] count] > 0) {
        dispatch_async(kMainQueue, ^{
            [self stopActivityIndicator];
            
            _selectedFile = file;
            
            NSString *fileCategory = [file objectForKey:@"FileCategory"];
            NSString *fileName;
            
            if ([fileCategory containsString:@"Community"]) {
                fileName = [NSString stringWithFormat:@"%@ - %@", [file objectForKey:@"FriendlyDesc1"], [file objectForKey:@"FriendlyDesc2"]];
            } else {
                fileName = [NSString stringWithFormat:@"%@", [file objectForKey:@"Name"]];
            }
            
            _selectedFileName.text = fileName;
            
            [self.selectedFileTagline setHidden:NO];
            [self.selectedFileName setHidden:NO];
            [self.getFileInfo setHidden:NO];
            [self.segmentedControlView setHidden:NO];
            [self.batchButtonView setHidden:NO];
            [self.batchButton setHidden:NO];
        });
        
    } else {
        dispatch_async(kMainQueue, ^{
            [self stopActivityIndicator];
            self.view.userInteractionEnabled = YES;
            [self showAlertWithMessage:@"Sorry, can't load files"];
            
            [self.selectedFileTagline setHidden:YES];
            [self.selectedFileName setHidden:YES];
            [self.getFileInfo setHidden:YES];
            [self.segmentedControlView setHidden:YES];
            [self.batchButtonView setHidden:YES];
            [self.batchButton setHidden:YES];
        });
    }
}

- (void)closeButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark -
#pragma mark Get genetic information

- (IBAction)getGeneticInfoPressed:(UISegmentedControl *)sender {
    if (_selectedFile && [[_selectedFile allKeys] count] > 0) {
        NSString *selectedSegmentItem = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];
        
        if ([selectedSegmentItem containsString:@"vitamin"]) {
            // load vitamin info
            [self getVitaminDInfo];
            
        } else {
            // load melanoma info
            [self getMelanomaInfo];
        }
    } else {
        [self showAlertWithMessage:@"Please select genetic file"];
    }
}


- (void)getVitaminDInfo {
    if (self.token && self.selectedFile) {
        
        [self.vitaminDInfo setHidden:YES];
        [self startActivityIndicatorWithTitle:@"Loading info..."];
        self.view.userInteractionEnabled = NO;
        
        AppChainsHelper *appChainsHelper = [[AppChainsHelper alloc] init];
        
        [appChainsHelper requestForChain88BasedOnFileID:[_selectedFile objectForKey:@"Id"]
                                            accessToken:self.token.accessToken
                                         withCompletion:^(NSString *vitaminDValue) {
                                             
                                             [self handleVitaminDLabel:vitaminDValue];
                                         }];
    } else {
        dispatch_async(kMainQueue, ^{
            [self.vitaminDInfo setHidden:YES];
            [self showAlertWithMessage:@"Corrupted user info, can't load information."];
        });
    }
}


- (void)getMelanomaInfo {
    if (self.token && self.selectedFile) {
        
        [self.melanomaInfo setHidden:YES];
        [self startActivityIndicatorWithTitle:@"Loading info..."];
        self.view.userInteractionEnabled = NO;
        
        AppChainsHelper *appChainsHelper = [[AppChainsHelper alloc] init];
        
        [appChainsHelper requestForChain9BasedOnFileID:[_selectedFile objectForKey:@"Id"]
                                           accessToken:self.token.accessToken
                                        withCompletion:^(NSString *melanomaRiskValue) {
                                            
                                            [self handleMelanomaLabel:melanomaRiskValue];
                                        }];
    } else {
        dispatch_async(kMainQueue, ^{
            [self.melanomaInfo setHidden:YES];
            [self showAlertWithMessage:@"Corrupted user info, can't load information."];
        });
    }
    
}


- (IBAction)getVitaminDMelanomaInBatchRequest:(id)sender {
    if (self.token && self.selectedFile) {
        
        [self.vitaminDInfo setHidden:YES];
        [self.melanomaInfo setHidden:YES];
        [self startActivityIndicatorWithTitle:@"Loading info..."];
        self.view.userInteractionEnabled = NO;
        
        AppChainsHelper *appChainsHelper = [[AppChainsHelper alloc] init];
        [appChainsHelper batchRequestForChain88AndChain9BasedOnFileID:[_selectedFile objectForKey:@"Id"]
                                                          accessToken:self.token.accessToken
                                                       withCompletion:^(NSArray *appchainsResults) {
                                                           
                                                           // @appchainsResults - result of string values for chains for batch request, it's an array of dictionaries
                                                           // each dictionary has following keys: "appChainID": appChainID string, "appChainValue": *String value
                                                           for (NSDictionary *appChainResult in appchainsResults) {
                                                               
                                                               if ([[appChainResult objectForKey:@"appChainID"] isEqualToString:@"Chain88"])
                                                                   [self handleVitaminDLabel:[appChainResult objectForKey:@"appChainValue"]];
                                                               
                                                               else if ([[appChainResult objectForKey:@"appChainID"] isEqualToString:@"Chain9"])
                                                                   [self handleMelanomaLabel:[appChainResult objectForKey:@"appChainValue"]];
                                                           }
                                                       }];
    } else {
        dispatch_async(kMainQueue, ^{
            [self.vitaminDInfo setHidden:YES];
            [self.melanomaInfo setHidden:YES];
            [self showAlertWithMessage:@"Corrupted user info, can't load information."];
        });
    }
}


- (void)handleVitaminDLabel:(NSString *)vitaminDValue {
    dispatch_async(kMainQueue, ^{
        [self stopActivityIndicator];
        self.view.userInteractionEnabled = YES;
        [self.vitaminDInfo setHidden:NO];
        
        if (vitaminDValue && [vitaminDValue length] > 0) {
            
            if ([vitaminDValue containsString:@"False"])
                self.vitaminDInfo.text = @"Chain88: There is no issue with vitamin D";
            
            else if ([vitaminDValue containsString:@"True"])
                self.vitaminDInfo.text = @"Chain88: There is an issue with vitamin D";
            
            else
                self.vitaminDInfo.text = @"Chain88: Sorry, there is an error from server.";
            
        } else
            self.vitaminDInfo.text = @"Chain88: Sorry, there is an error from server.";
    });
}


- (void)handleMelanomaLabel:(NSString *)melanomaRiskValue {
    dispatch_async(kMainQueue, ^{
        [self stopActivityIndicator];
        self.view.userInteractionEnabled = YES;
        [self.melanomaInfo setHidden:NO];
        
        if (melanomaRiskValue && [melanomaRiskValue length] > 0) {
            
            self.melanomaInfo.text = [NSString stringWithFormat:@"Chain9: Melanoma issue level is: %@", [melanomaRiskValue capitalizedString]];
            
        } else
            self.melanomaInfo.text = @"Chain9: Sorry, there is an error from server.";
    });
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
#pragma mark Activity Indicator

- (void)startActivityIndicatorWithTitle:(NSString *)title {
    dispatch_async(kMainQueue, ^{
        self.strLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 90, 30)];
        self.strLabel.text = title;
        self.strLabel.font = [UIFont systemFontOfSize:13.f];
        self.strLabel.textColor = [UIColor grayColor];
        
        CGFloat xPos = self.view.frame.size.width / 2 - 60;
        //CGFloat yPos = self.view.frame.size.height / 2 + 20;
        self.messageFrame = [[UIView alloc] initWithFrame:CGRectMake(xPos, 60, 120, 30)];
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
