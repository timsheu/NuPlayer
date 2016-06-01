//
//  DVRInfoPool.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/23.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DVRInfoPool : NSObject
@property (strong, nonatomic) NSMutableDictionary *infoList;
-(id)init;
+(DVRInfoPool *)sharedInstance;
@end
