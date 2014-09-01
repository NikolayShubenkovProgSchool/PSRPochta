//
//  SSIAPIClient.h
//  SecondScreen
//
//  Created by n.shubenkov on 16/04/14.
//  Copyright (c) 2014 Be-Interactive. All rights reserved.
//

#import "AFHTTPClient.h"

typedef void(^RPIApiSuccessBlock)(id recivedData);
typedef void(^RPIApiFailureBlock)(NSError *apiError, NSError *systemError);

@interface RPIAPIClient : AFHTTPClient

+ (instancetype) shared;

- (void)getAllOfficesNearLongitude:(double)longitude latitude:(double)latitude withSuccess:(RPIApiSuccessBlock)success failure:(RPIApiFailureBlock)failure;



@end
