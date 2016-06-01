//
//  DVRCommandGenerator.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/22.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVRCommandPool.h"
#import "DVRSettingPool.h"
#import "DVRPlayerManager.h"
@interface DVRCommandGenerator : NSObject
+ (NSString *)generateInfoCommandWithName:(NSString *)string;
+ (NSString *)generateSettingCommandWithDictionary:(NSDictionary *)dictionary;
@end
