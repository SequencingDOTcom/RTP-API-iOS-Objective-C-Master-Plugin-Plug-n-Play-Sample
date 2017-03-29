//
//  AppChainsHelper.h
//  Copyright © 2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>


@interface AppChainsHelper : NSObject

- (void)requestForChain88BasedOnFileID:(NSString *)fileID
                           accessToken:(id)tokenProvider
                        withCompletion:(void (^)(NSString *vitaminDValue))completion;


- (void)requestForChain9BasedOnFileID:(NSString *)fileID
                          accessToken:(id)tokenProvider
                       withCompletion:(void (^)(NSString *melanomaRiskValue))completion;


// @appchainsResults - result of string values for chains for batch request, it's an array of dictionaries
// each dictionary has following keys: "appChainID": appChainID string, "appChainValue": *String value
- (void)batchRequestForChain88AndChain9BasedOnFileID:(NSString *)fileID
                                         accessToken:(id)tokenProvider
                                      withCompletion:(void (^)(NSArray *appchainsResults))completion;


@end
