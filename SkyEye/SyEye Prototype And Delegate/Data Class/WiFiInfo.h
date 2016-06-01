//
//  WiFiInfo.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/17.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WiFiInfo : NSObject
@property (nonatomic, strong) NSString *SSID;
@property (nonatomic, strong) NSString *password;
- (WiFiInfo *) initWithSSID:(NSString *)ssid password:(NSString *)pass;
@end
