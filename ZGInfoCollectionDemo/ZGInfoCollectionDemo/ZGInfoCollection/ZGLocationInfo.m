//
//  ZGLocationInfo.m
//  ZGInfoCollectionDemo
//
//  Created by zhanggui on 16/8/18.
//  Copyright © 2016年 zhanggui. All rights reserved.
//

#import "ZGLocationInfo.h"
#import <UIkit/UIDevice.h>
#define isIOS(version) ([[UIDevice currentDevice].systemVersion floatValue] >= version)
@interface ZGLocationInfo ()<CLLocationManagerDelegate>

@property (nonatomic,strong)CLLocationManager *locationManager;
@end


@implementation ZGLocationInfo

+ (instancetype)currentLocation {
    static ZGLocationInfo *locationInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationInfo = [[self alloc] init];
    });
    return locationInfo;
}

- (void)getCurrentLocation:(ChangeLocationBlock)block {
    self.blockLocation = block;
    if (![CLLocationManager locationServicesEnabled]) {
        if (self.blockLocation) {
            self.blockLocation(nil,@"请先开启定位功能");
        }
        return;
    }
    if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
        self.locationManager.delegate = self;
        CLLocationDistance distance  = 1.0;
        self.locationManager.distanceFilter = distance;  //最小的告诉位置更新的距离,单位是m
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [self.locationManager startUpdatingLocation];

    }else{
        self.locationManager.delegate = self;
        CLLocationDistance distance  = 500.0;
        self.locationManager.distanceFilter = distance;  //最小的告诉位置更新的距离,单位是m
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [self.locationManager startUpdatingLocation];
    }
    
}
#pragma mark - lazy load
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];  //创建一个位置管理器
    }
    return _locationManager;
}
#pragma mark - CLLocationManageDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *currentLocation = [locations lastObject];
    CLGeocoder *geoCoder = [CLGeocoder new];
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count>0) {
            CLPlacemark *placeMark = placemarks[0];
            if (self.blockLocation) {
                self.blockLocation(placeMark,@"定位成功");
            }
        }
    }];
   
}
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (self.blockLocation) {
        self.blockLocation(nil,@"方向改变");
    }
}




















@end
