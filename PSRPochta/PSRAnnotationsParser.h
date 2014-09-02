//
//  PSRAnnotationsParser.h
//  PSRPochta
//
//  Created by n.shubenkov on 02/09/14.
//  Copyright (c) 2014 n.shubenkov. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PSRAnnotation;
@interface PSRAnnotationsParser : NSObject

- (PSRAnnotation *)annotationFromInfo:(NSDictionary *)info;

@end
