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
                                           @"latitude"         :@(longitude),
                                           @"longitude"        :@(latitude),
                                           @"searchRadius"     :@(radius),
                                           @"type"             :type
                                           }];
    
    [self getPath:@"mobile-api/method/offices.find.nearby"
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
          }];
    
//    [self p_postRequest:[SSIAPIRequest requestWithPath:@"mobile-api/method/offices.find.nearby"
//                                            parameters:parameters]
//            withSuccess:^(NSArray *offices) {
//                NSMutableArray *officesIDs = [NSMutableArray arrayWithCapacity:[offices count]];
//                for (NSDictionary *anOffice in offices){
//                    [officesIDs addObject:anOffice[@"postalCode"]];
//                }
//                [self getOfficesDetailes:officesIDs
//                            forLongitude:longitude
//                                latitude:latitude
//                             withSuccess:success
//                                 failure:failure];
//            }
//            failure:failure];
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

- (void)getOfficesDetailes:(NSArray *)officesIDs forLongitude:(double)longitude latitude:(double)latitude withSuccess:(RPIApiSuccessBlock)success failure:(RPIApiFailureBlock)failure
{
    __block int idsCount = officesIDs.count;
    RPIApiSuccessBlock successCopied = success;
    RPIApiFailureBlock failureCopied = failure;
    NSMutableArray *officeDetailedInfoes = [NSMutableArray arrayWithCapacity:officesIDs.count];
    for (NSString *anOfficeID in officesIDs){
        [self getOfiiceDetailesForOfficeID:anOfficeID withSuccess:^(id recivedData) {
            [officeDetailedInfoes addObject:[self p_officeDetailesByRemovingUnnecessaryInfo:recivedData]];
            NSLog(@"recieved offices count %d, total complition %f.0",officeDetailedInfoes.count, (float) 100 * officeDetailedInfoes.count / idsCount);
            if (officeDetailedInfoes.count == idsCount){
                NSParameterAssert(self.operationQueue.operationCount == 0);
                successCopied(officeDetailedInfoes);
            }
        } failure:^(NSError *apiError, NSError *systemError) {
            [self.operationQueue cancelAllOperations];
            if (self.operationQueue.operationCount == 0){
                failureCopied(apiError, systemError);
            }
        }];
    }
}

- (NSDictionary *)p_officeDetailesByRemovingUnnecessaryInfo:(NSDictionary *)detailes
{
    NSMutableDictionary *preparedDetailes = [detailes[@"office"] mutableCopy];
    NSArray *keysToClear = @[@"isClosed",@"isTemporaryClosed",@"currentDayWorkingHours",@"nextDayWorkingHours"];
    for(NSString *key in keysToClear){
        [preparedDetailes setValue:nil forKey:key];
    }
    return preparedDetailes;
}

- (void)getOfiiceDetailesForOfficeID:(NSString *)officeID withSuccess:(RPIApiSuccessBlock)success failure:(RPIApiFailureBlock)failure
{
    NSMutableDictionary *parameters = [self p_defaultParameters];
    [parameters addEntriesFromDictionary:@{
                                           @"postalCode" : @([officeID intValue])
                                          }];    
//    
//    [self p_postRequest:[SSIAPIRequest requestWithPath:@"mobile-api/method/offices.find.byCode"
//                                            parameters:parameters]
//            withSuccess:success
//                failure:failure];
}

#pragma mark - private

//- (AFHTTPRequestOperation*)p_operationWithRequest:(SSIAPIRequest *)request success:(RPIApiSuccessBlock)success failure:(RPIApiFailureBlock)failure
//{
//    NSMutableURLRequest *networkRequest = [[self requestWithMethod:@"GET"
//                                                              path:request.path
//                                                        parameters:[request dictionaryRepresentation]] mutableCopy];
//    networkRequest.timeoutInterval = 120;
//    NSParameterAssert(success);
//    RPIApiSuccessBlock successCopied = [success copy];
//    RPIApiFailureBlock failureCopied = [failure copy];
//    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:networkRequest
//                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                                                          successCopied(responseObject);
//                                                                      }
//                                                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//
//                                                                          if (failureCopied){
//                                                                              failureCopied(nil, error);
//                                                                          }
//                                                                      }];
//    return operation;
//}
//
//
//- (void)p_postRequest:(SSIAPIRequest *)request withSuccess:(RPIApiSuccessBlock)success failure:(RPIApiFailureBlock)failure
//{
//    AFHTTPRequestOperation *operatopn = [self p_operationWithRequest:request success:success failure:failure];
//    [self enqueueHTTPRequestOperation:operatopn];
//}


#pragma mark - super overload


//- (void) getPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
//{
//    
//}

#pragma mark -  -

@end
