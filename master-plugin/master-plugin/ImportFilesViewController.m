//
//  ImportFilesViewController.m
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import "ImportFilesViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SQOAuth.h"
#import "SQConnectTo.h"
#import "SQ3rdPartyImportAPI.h"



@interface ImportFilesViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailAddressField;
@property (weak, nonatomic) IBOutlet UIButton *andMeButton;
@property (weak, nonatomic) IBOutlet UIView   *andMeButtonView;
@property (weak, nonatomic) IBOutlet UIButton *ancestryButton;
@property (weak, nonatomic) IBOutlet UIView   *ancestryButtonView;

@end




@implementation ImportFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Import genetic files";
    
    // adjust buttons view
    self.andMeButtonView.layer.cornerRadius = 5;
    self.andMeButtonView.layer.masksToBounds = YES;
    self.andMeButtonView.layer.borderColor = [UIColor colorWithRed:35/255.0 green:121/255.0 blue:254/255.0 alpha:1.0].CGColor;
    self.andMeButtonView.layer.borderWidth = 1.f;
    
    self.ancestryButtonView.layer.cornerRadius = 5;
    self.ancestryButtonView.layer.masksToBounds = YES;
    self.ancestryButtonView.layer.borderColor = [UIColor colorWithRed:35/255.0 green:121/255.0 blue:254/255.0 alpha:1.0].CGColor;
    self.ancestryButtonView.layer.borderWidth = 1.f;
}



- (IBAction)connectToButtonPressed:(id)sender {
    NSDictionary *file1 = @{@"name"     : @"NA12877.vcf.gz",
                            @"type"     : @"0",
                            @"url"      : @"ftp://platgene_ro@ussd-ftp.illumina.com/2016-1.0/hg38/small_variants/NA12877/NA12877.vcf.gz",
                            @"hashType" : @"0",
                            @"hashValue": @"0",
                            @"size"     : @"0"};
    NSArray *filesArray = @[file1];
    
    if (!_emailAddressField.text || [_emailAddressField.text length] == 0) {
        [self viewController:self showAlertWithTitle:@"ConnectTo Error" withMessage:@"Please provide your email address"];
        return;
    }
    
    SQConnectTo *connectTo = [[SQConnectTo alloc] init];
    [connectTo connectToSequencingWithCliendSecret:[SQOAuth sharedInstance]
                                         userEmail:_emailAddressField.text
                                        filesArray:filesArray
                            viewControllerDelegate:self];
}



- (IBAction)andMeButtonPressed:(id)sender {
    SQ3rdPartyImportAPI *importAPI = [[SQ3rdPartyImportAPI alloc] init];
    [importAPI importFrom23AndMeWithToken:[SQOAuth sharedInstance]
                   viewControllerDelegate:self];
}


- (IBAction)ancestryButtonPressed:(id)sender {
    SQ3rdPartyImportAPI *importAPI = [[SQ3rdPartyImportAPI alloc] init];
    [importAPI importFromAncestryWithToken:[SQOAuth sharedInstance]
                    viewControllerDelegate:self];
}




#pragma mark - Alert popup

- (void)viewController:(UIViewController *)controller showAlertWithTitle:(NSString *)title withMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:close];
    [controller presentViewController:alert animated:YES completion:nil];
}




@end
