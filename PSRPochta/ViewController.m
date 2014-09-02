//
//  ViewController.m
//  PSRPochta
//
//  Created by n.shubenkov on 02/09/14.
//  Copyright (c) 2014 n.shubenkov. All rights reserved.
//

#import "ViewController.h"

#import "RPIAPIClient.h"
#import "PSRAnnotation.h"
#import "PSRAnnotationsParser.h"


static const double kRPMoscowCenterLatitude = 55.451332;
static const double kRPMoscowCenterLongitude = 37.6155600;

@interface ViewController () <MKMapViewDelegate>
@property (nonatomic, strong) NSArray *offices;
@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)get_offices:(id)sender
{
    [[RPIAPIClient shared] getAllOfficesNearLongitude:kRPMoscowCenterLongitude
                                             latitude:kRPMoscowCenterLatitude
                                          withSuccess:^(id recivedData) {
                                              [self.mapView removeAnnotations:self.mapView.annotations];
                                              self.offices = [self annotationsFromInfoes:recivedData];
                                              [self.mapView addAnnotations:self.offices];
                                              [self.mapView showAnnotations:self.offices animated:YES];
//                                              self.mapView
    } failure:^(NSError *apiError) {
        NSLog(@"OOps: %@",apiError);
    }];
}

- (NSArray *)annotationsFromInfoes:(NSArray *)infoes
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:infoes.count];
    PSRAnnotationsParser *parser = [PSRAnnotationsParser new];
    for (NSDictionary *anInfo in infoes){
        [annotations addObject:[parser annotationFromInfo:anInfo]];
    }
    return annotations;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (![annotation isKindOfClass:[PSRAnnotation class]]){
        return nil;
    }
    
    NSString *reusableIdentifier = @"PSRIdentifier";
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:reusableIdentifier];
    if (!aView){
        aView = [[MKAnnotationView alloc]initWithAnnotation:annotation
                                            reuseIdentifier:reusableIdentifier];
        aView.canShowCallout = YES;
    }
    else {
        aView.annotation = annotation;
    }
    aView.image = [UIImage imageNamed:@"map"];
    
    return aView;
}


@end
