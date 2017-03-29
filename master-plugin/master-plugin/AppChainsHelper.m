//
//  AppChainsHelper.m
//  Copyright © 2016 Sequencing.com. All rights reserved
//

#import "AppChainsHelper.h"
#import "AppChains.h"
#import "SQOAuth.h"


@implementation AppChainsHelper


- (void)requestForChain88BasedOnFileID:(NSString *)fileID
                           accessToken:(id)tokenProvider
                        withCompletion:(void (^)(NSString *vitaminDValue))completion {
    
    NSLog(@"starting request for chains88: vitaminDValue");
    [tokenProvider token:^(SQToken *token, NSString *accessToken) {
        if (!accessToken || [accessToken length] == 0) {
            completion(nil);
            return;
        }
        
        AppChains *appChains = [[AppChains alloc] initWithToken:accessToken withHostName:@"api.sequencing.com"];
        
        // v2 protocol
        [appChains getReportWithApplicationMethodName:@"Chain88"
                                     withDatasourceId:fileID
                                     withSuccessBlock:^(Report *result) {
                                         
                                         completion([self parseReportForChain88:result]);
                                     }
                                     withFailureBlock:^(NSError *error) {
                                         if (error) {
                                             NSLog(@"[appChain88 Error] %@", error);
                                             completion(nil);
                                         } else {
                                             completion(nil);
                                         }
                                     }];
    }];
}



- (void)requestForChain9BasedOnFileID:(NSString *)fileID
                          accessToken:(id)tokenProvider
                       withCompletion:(void (^)(NSString *melanomaRiskValue))completion {
    NSLog(@"starting request for chains9: melanomaRiskValue");
    [tokenProvider token:^(SQToken *token, NSString *accessToken) {
        if (!accessToken || [accessToken length] == 0) {
            completion(nil);
            return;
        }
        
        AppChains *appChains = [[AppChains alloc] initWithToken:accessToken withHostName:@"api.sequencing.com"];
        
        [appChains getReportWithApplicationMethodName:@"Chain9"
                                     withDatasourceId:fileID
                                     withSuccessBlock:^(Report *result) {
                                         
                                         completion([self parseReportForChain9:result]);
                                         
                                     }
                                     withFailureBlock:^(NSError *error) {
                                         if (error) {
                                             NSLog(@"appChains error: %@", error);
                                             completion(nil);
                                         }
                                     }];
    }];
}


- (void)batchRequestForChain88AndChain9BasedOnFileID:(NSString *)fileID
                                         accessToken:(id)tokenProvider
                                      withCompletion:(void (^)(NSArray *appchainsResults))completion {
    NSLog(@"starting batch request for chains88 (vitaminDValue) and chains9 (melanomaRiskValue)");
    [tokenProvider token:^(SQToken *token, NSString *accessToken) {
        if (!accessToken || [accessToken length] == 0) {
            completion(nil);
            return;
        }
        
        AppChains *appChains = [[AppChains alloc] initWithToken:accessToken withHostName:@"api.sequencing.com"];
        
        NSArray *appChainsForRequest = @[@[@"Chain88", fileID],
                                         @[@"Chain9",  fileID]];
        
        [appChains getBatchReportWithApplicationMethodName:appChainsForRequest
                                          withSuccessBlock:^(NSArray *reportResultsArray) {
                                              // @reportResultsArray - result of reports for batch request, it's an array of dictionaries
                                              // each dictionary has following keys: "appChainID": keyAppChainID string, "report": *Report object
                                              
                                              NSMutableArray *appChainsResultsArray = [[NSMutableArray alloc] init];
                                              
                                              for (NSDictionary *appChainReportDict in reportResultsArray) {
                                                  
                                                  Report *result = [appChainReportDict objectForKey:@"report"];
                                                  NSString *appChainID = [appChainReportDict objectForKey:@"appChainID"];
                                                  NSString *appChainValue = [NSString stringWithFormat:@""];
                                                  
                                                  if ([appChainID isEqualToString:@"Chain88"])
                                                      appChainValue = [self parseReportForChain88:result];
                                                  
                                                  else if ([appChainID isEqualToString:@"Chain9"])
                                                      appChainValue = [self parseReportForChain9:result];
                                                  
                                                  NSDictionary *reportItem = @{@"appChainID":   appChainID,
                                                                               @"appChainValue":appChainValue};
                                                  [appChainsResultsArray addObject:reportItem];
                                              }
                                              
                                              completion(appChainsResultsArray);
                                              
                                          }
                                          withFailureBlock:^(NSError *error) {
                                              if (error) {
                                                  NSLog(@"batch request error: %@", error);
                                                  completion(nil);
                                              }
                                          }];
    }];
}



- (NSString *)parseReportForChain88:(Report *)result {
    NSString *vitaminDValue;
    
    if ([result isSucceeded]) {
        NSString *vitaminDKey = @"result";
        
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
    }
    return vitaminDValue;
}


- (NSString *)parseReportForChain9:(Report *)result {
    NSString *riskValue;
    
    if ([result isSucceeded]) {
        NSString *riskKey = @"RiskDescription";
        
        for (Result *obj in [result getResults]) {
            ResultValue *frv = [obj getValue];
            
            if ([frv getType] == kResultTypeText) {
                NSLog(@"\nfrv %@=%@\n", [obj getName], [(TextResultValue *)frv getData]);
                
                if ([[obj getName] isEqualToString:riskKey]) {
                    riskValue = [(TextResultValue *)frv getData];
                }
            }
        }
    }
    return riskValue;;
}


@end
