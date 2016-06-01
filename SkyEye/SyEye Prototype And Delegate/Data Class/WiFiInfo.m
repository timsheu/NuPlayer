//
//  WiFiInfo.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/17.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "WiFiInfo.h"

@implementation WiFiInfo
@synthesize SSID = _SSID;
@synthesize password = _password;

-(WiFiInfo *)initWithSSID:(NSString *)ssid password:(NSString *)pass{
    if (ssid != nil) {
        _SSID = [NSString stringWithString:ssid];
    }
    if (pass != nil) {
        _password = [NSString stringWithString:pass];
    }
    return self;
}

@end
