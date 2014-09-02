//
//  PSRAnnotation.m
//  PSRPochta
//
//  Created by n.shubenkov on 02/09/14.
//  Copyright (c) 2014 n.shubenkov. All rights reserved.
//

#import "PSRAnnotation.h"

@interface PSRAnnotation()

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, readwrite, copy) NSString *title;

@end

@implementation PSRAnnotation

@synthesize coordinate = _coordinate;

+ (instancetype)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title
{
    PSRAnnotation *annotation = [PSRAnnotation new];
    annotation.coordinate = coordinate;
    annotation.title = [title copy];
    
    return annotation;
}

@end
