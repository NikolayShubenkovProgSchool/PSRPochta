//
//  SSIAPIClient.m
//  SecondScreen
//
//  Created by n.shubenkov on 16/04/14.
//  Copyright (c) 2014 Be-Interactive. All rights reserved.
//

#import "RPIAPIClient.h"
#import "AFNetworking.h"

NSString *const kRPIAddress = @"http://95.128.178.180:5432";

@implementation RPIAPIClient

#pragma mark - public -

+ (instancetype) shared
{
    static dispatch_once_t onceToken = 0;
    static __strong RPIAPIClient *_sharedObject;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] initWithBaseURL:[NSURL URLWithString:kRPIAddress]];
        _sharedObject.operationQueue.maxConcurrentOperationCount = 4;
        [_sharedObject registerHTTPOperationClass:[AFJSONRequestOperation class]];
        _sharedObject.parameterEncoding = AFFormURLParameterEncoding;
        [_sharedObject setDefaultHeader:@"Accept"
                                  value:@"application/json; charset=utf-8"];
        
        [_sharedObject setDefaultHeader:@"Accept-Charset" value:@"utf-8"];
        
        [_sharedObject setDefaultHeader:@"User-Agent"
                                  value:@"RussianPost/2.1"];
        
        [_sharedObject setDefaultHeader:@"MobileApiAccessToken"
                                  value:@"Yi5GaWMTY8x27uEPte0/l9vfrZw="];
        
    });
    return _sharedObject;
}

- (NSMutableDictionary *)p_defaultParameters
{
    NSDateFormatter *formatter1 = [NSDateFormatter new];
    formatter1.dateFormat = @"YYYY-MM-dd";
    NSDateFormatter *formatter2 = [NSDateFormatter new];
    formatter2.dateFormat = @"HH:mm:ss";
    NSString *time = [NSString stringWithFormat:@"%@T%@",[formatter1 stringFromDate:[NSDate date]], [formatter2 stringFromDate:[NSDate date]]];
    return [@{
             @"currentDateTime"  :time,
             } mutableCopy];

}

- (void)getAllOfficesNearLongitude:(double)longitude latitude:(double)latitude withSuccess:(RPIApiSuccessBlock)success failure:(RPIApiFailureBlock)failure
{
    int maxOfficcesesCount = 15;
    int radius             = 5000;
    NSString *type = @"ALL";
    NSMutableDictionary *parameters = [self p_defaultParameters];
    [parameters addEntriesFromDictionary:@{
                                           @"top"              :@(maxOfficcesesCount),
                                           @"latitude"         :@(latitude),
                                           @"longitude"        :@(longitude),
                                           @"searchRadius"     :@(radius),
                                           @"type"             :type
                                           }];
    
    [self getPath:@"mobile-api/method/offices.find.nearby"
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              if (success){
                  success(responseObject);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure){
                  failure(error);
              }
          }];
}

- (NSDictionary *)officesFromBundle
{
    NSURL *fileUrl = [[NSBundle mainBundle]  URLForResource:@"pochta_json" withExtension:@"txt"];
    NSParameterAssert(fileUrl);
    NSError *error = nil;
    NSString *string = [[NSString alloc]initWithContentsOfURL:fileUrl encoding:NSUTF8StringEncoding error:&error];
    NSParameterAssert(string && !error);
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:0
                                                           error:&error];
    return data;
}

@end
