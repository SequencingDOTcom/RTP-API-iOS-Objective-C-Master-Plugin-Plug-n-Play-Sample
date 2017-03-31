//
//  SelectFileViewController.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//

#import <UIKit/UIKit.h>
#import "SQFileSelectorProtocol.h"


@protocol UserSignOutProtocol <NSObject>

- (void)userDidSignOut;

@end



@interface SelectFileViewController : UIViewController <SQFileSelectorProtocol>

@property (weak, nonatomic) id<UserSignOutProtocol> delegate;

@end
