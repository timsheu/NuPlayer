//
//  DVRWiFiInfo.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/17.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DVRWiFiInfo : NSObject
@property (nonatomic, strong) NSString *SSID;
@property (nonatomic, strong) NSString *password;
- (DVRWiFiInfo *) initWithSSID:(NSString *)ssid password:(NSString *)pass;
@end
