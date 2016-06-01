//
//  SkyEyeCommandGenerator.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/22.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandPool.h"
#import "SettingPool.h"
#import "PlayerManager.h"
@interface SkyEyeCommandGenerator : NSObject
+ (NSString *)generateInfoCommandWithName:(NSString *)string;
+ (NSString *)generateSettingCommandWithDictionary:(NSDictionary *)dictionary;
+ (NSString *)generateUpdatePluginCommand:(NSString *)string withParameter:(NSString *)param withValue:(NSString *)value;
+ (NSData *)generateUploadAudioCommand:(NSData *)audioData sampleRate:(int)sampleRate channel:(int)channel volume:(int)volume;
+ (NSData *)generateContinousAudioCommand:(int)sampleRate channel:(int)channel volume:(int)volume;
@end
