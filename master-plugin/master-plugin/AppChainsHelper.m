//
//  AppChainsHelper.m
//  master-plugin
//
//  Created by Bogdan Laukhin on 5/27/16.
//  Copyright © 2016 Bogdan Laukhin. All rights reserved.
//

#import "AppChainsHelper.h"
#import "AppChains.h"

@implementation AppChainsHelper

- (void)requestForChain88BasedOnFileID:(NSString *)fileID
                           accessToken:(NSString *)accessToken
                        withCompletion:(void (^)(NSString *vitaminDValue))completion {
    NSLog(@"starting request for chains88: vitaminDValue");
    
    AppChains *appChains = [[AppChains alloc] initWithToken:accessToken withHostName:@"api.sequencing.com"];
    
    [appChains getReportWithRemoteMethodName:@"StartApp"
                   withApplicationMethodName:@"Chain88"
                            withDatasourceId:fileID
                            withSuccessBlock:^(Report *result) {
                                if ([result isSucceeded]) {
                                    
                                    NSString *vitaminDKey = @"result";
                                    NSString *vitaminDValue;
                                    
                                    for (Result *obj in [result getResults]) {
                                        ResultValue *frv = [obj getValue];
                                        
                                        if ([frv getType] == kResultTypeText) {
                                            
                                            NSLog(@"\nfrv %@=%@\n", [obj getName], [(TextResultValue *)frv getData]);
                                            
                                            if ([[obj getName] isEqualToString:vitaminDKey]) {
                                                NSString *vitaminDRawValue = [(TextResultValue *)frv getData];
                                                
                                                if ([vitaminDRawValue length] != 0) {
                                                    if ([vitaminDRawValue isEqualToString:@"no"]) {
                                                        vitaminDValue = @"False";
                                                    } else {
                                                        vitaminDValue = @"True";
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    if (vitaminDValue && [vitaminDValue length] != 0) {
                                        completion(vitaminDValue);
                                        
                                    } else {
                                        completion(nil);
                                    }
                                } else {
                                    completion(nil);
                                }
                            }
                            withFailureBlock:^(NSError *error) {
                                if (error) {
                                    NSLog(@"[appChain88 Error] %@", error);
                                    completion(nil);
                                } else {
                                    completion(nil);
                                }
                            }];
}



- (void)requestForChain9BasedOnFileID:(NSString *)fileID
                          accessToken:(NSString *)accessToken
                       withCompletion:(void (^)(NSString *melanomaRiskValue))completion {
    NSLog(@"starting request for chains9: melanomaRiskValue");
    
    AppChains *appChains = [[AppChains alloc] initWithToken:accessToken withHostName:@"api.sequencing.com"];
    
    [appChains getReportWithRemoteMethodName:@"StartApp"
                   withApplicationMethodName:@"Chain9"
                            withDatasourceId:fileID
                            withSuccessBlock:^(Report *result) {
                                if ([result isSucceeded]) {
                                    
                                    NSString *riskKey = @"RiskDescription";
                                    NSString *riskValue;
                                    
                                    for (Result *obj in [result getResults]) {
                                        ResultValue *frv = [obj getValue];
                                        
                                        if ([frv getType] == kResultTypeText) {
                                            
                                            NSLog(@"\nfrv %@=%@\n", [obj getName], [(TextResultValue *)frv getData]);
                                            
                                            if ([[obj getName] isEqualToString:riskKey]) {
                                                riskValue = [(TextResultValue *)frv getData];
                                            }
                                        }
                                    }
                                    
                                    if (riskValue && [riskValue length] != 0) {
                                        completion(riskValue);
                                        
                                    } else {
                                        NSLog(@"appChains error: Result is empty");
                                        completion(nil);
                                    }
                                } else {
                                    NSLog(@"appChains error: Result is empty");
                                    completion(nil);
                                }
                            }
                            withFailureBlock:^(NSError *error) {
                                if (error) {
                                    NSLog(@"appChains error: %@", error);
                                    completion(nil);
                                }
                            }];
}


@end
