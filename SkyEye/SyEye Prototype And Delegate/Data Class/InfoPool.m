//
//  InfoPool.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/23.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "InfoPool.h"

@implementation InfoPool
-(id)init{
    if (self = [super init]) {
        
    }
    return self;
}

+(InfoPool *)sharedInstance{
    static InfoPool *infoPool = nil;
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
