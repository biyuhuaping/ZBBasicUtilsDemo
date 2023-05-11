//
//  LocationViewController.m
//  BasicUtils_Example
//
//  Created by FW on 2020/3/19.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

#import "LocationViewController.h"
#import "ZBBasicUtilsDemo_Example-Swift.h"
#import "ZBBasicUtilsDemo_Example-Bridging-Header.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationViewController ()

@property (nonatomic, strong) XYYLocationReverseGeo * searchGeo;

@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.searchGeo = [[XYYLocationReverseGeo alloc] init];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[XYYLocationManager share] requestSingleLocation:YES with:^(XYYLocationModel * _Nonnull locationModel) {
        
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.searchGeo reverseGeocode:CLLocationCoordinate2DMake(40.00179, 116.487017) with:^(XYYLocationModel * _Nonnull locationModel) {
        NSLog(@"经纬度: %@, %@", locationModel.latitude, locationModel.longitude);
        NSLog(@"详细地址: %@", locationModel.address);
        NSLog(@"省市县：%@",locationModel.addressComponet.province);
    }] ;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
