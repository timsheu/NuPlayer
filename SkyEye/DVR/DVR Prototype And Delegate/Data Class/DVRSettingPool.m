//
//  SettingPool.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/18.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "DVRSettingPool.h"

@implementation DVRSettingPool
-(id)init{
    if (self = [super init]) {
        [self parsePropertyList];
    }
    return self;
}

+(DVRSettingPool *)sharedInstance{
    static DVRSettingPool *settingPool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        settingPool = [[self alloc] init];
    });
    return settingPool;
}

- (void)parsePropertyList{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SettingsPropertyList" ofType:@"plist"];
    _settingList = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
}
@end
