//
//  ViewController.m
//  PSRPochta
//
//  Created by n.shubenkov on 02/09/14.
//  Copyright (c) 2014 n.shubenkov. All rights reserved.
//

#import "ViewController.h"

#import "RPIAPIClient.h"

static const double kRPMoscowCenterLatitude = 55.451332;
static const double kRPMoscowCenterLongitude = 37.6155600;

@interface ViewController ()

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
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
        
    } failure:^(NSError *apiError, NSError *systemError) {
        
    }];
}

@end
