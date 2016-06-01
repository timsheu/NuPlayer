//
//  SettingPool.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/18.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DVRSettingPool : NSObject
@property (strong, nonatomic) NSMutableDictionary *settingList;
- (id)init;
+ (DVRSettingPool *) sharedInstance;
@end
