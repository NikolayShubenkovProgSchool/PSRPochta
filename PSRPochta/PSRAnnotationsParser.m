//
//  PSRAnnotationsParser.m
//  PSRPochta
//
//  Created by n.shubenkov on 02/09/14.
//  Copyright (c) 2014 n.shubenkov. All rights reserved.
//

#import "PSRAnnotationsParser.h"

#import "PSRAnnotation.h"

@implementation PSRAnnotationsParser

- (PSRAnnotation *)annotationFromInfo:(NSDictionary *)info
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([info[@"latitude"] doubleValue], [info[@"longitude"] doubleValue]);
    
    NSString *title = info[@"addressSource"];
    PSRAnnotation *annotation = [PSRAnnotation annotationWithCoordinate:coordinate title:title];
    return annotation;
}

@end
