//
//  DVRInfoPool.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/23.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "DVRInfoPool.h"

@implementation DVRInfoPool
-(id)init{
    if (self = [super init]) {
        
    }
    return self;
}

+(DVRInfoPool *)sharedInstance{
    static DVRInfoPool *infoPool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        infoPool = [[self alloc] init];
    });
    return infoPool;
}

-(void)parseInfoList{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"InfoSettingList" ofType:@"plist"];
    _infoList = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
}

@end
