//
//  SelectFileViewController.h
//  master-plugin
//
//  Created by Bogdan Laukhin on 3/29/16.
//  Copyright © 2016 Bogdan Laukhin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQTokenRefreshProtocol.h"
#import "SQFileSelectorProtocol.h"

@class SQToken;


@interface SelectFileViewController : UIViewController <SQFileSelectorProtocol, SQTokenRefreshProtocol>

@property (strong, nonatomic) SQToken *token;

@end
