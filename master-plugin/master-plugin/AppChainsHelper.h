//
//  AppChainsHelper.h
//  master-plugin
//
//  Created by Bogdan Laukhin on 5/27/16.
//  Copyright © 2016 Bogdan Laukhin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AppChainsHelper : NSObject

- (void)requestForChain88BasedOnFileID:(NSString *)fileID
                           accessToken:(NSString *)accessToken
                        withCompletion:(void (^)(NSString *vitaminDValue))completion;


- (void)requestForChain9BasedOnFileID:(NSString *)fileID
                          accessToken:(NSString *)accessToken
                       withCompletion:(void (^)(NSString *melanomaRiskValue))completion;

@end
