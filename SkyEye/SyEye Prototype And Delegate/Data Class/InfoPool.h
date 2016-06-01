//
//  InfoPool.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/23.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfoPool : NSObject
@property (strong, nonatomic) NSMutableDictionary *infoList;
-(id)init;
+(InfoPool *)sharedInstance;
@end
