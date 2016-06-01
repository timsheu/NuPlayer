//
//  DVRCommandPool.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/15.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "DVRCommandPool.h"

@implementation DVRCommandPool
@synthesize arrayVideoCommandList = _arrayVideoCommandList;
@synthesize arrayAudioCommandList = _arrayAudioCommandList;
@synthesize arrayInfoCommandList = _arrayInfoCommandList;
@synthesize arrayRecordCommandList = _arrayRecordCommandList;
@synthesize arraySystemCommandList = _arraySystemCommandList;
@synthesize arrayMulticastCommandList = _arrayMulticastCommandList;
@synthesize arrayConfigCommandList = _arrayConfigCommandList;
@synthesize arrayFileCommandList = _arrayFileCommandList;
- (id) init{
    if (self = [super init]) {
        [self parsePropertyList];
    }
    return self;
}

+(DVRCommandPool *)sharedInstance{
    static DVRCommandPool *commandPool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        commandPool = [[self alloc] init];
    });
    return commandPool;
}

- (void)parsePropertyList{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"DVRVideoCommandPropertyList" ofType:@"plist"];
    _arrayVideoCommandList = [NSArray arrayWithContentsOfFile:path];
    
    path = [[NSBundle mainBundle] pathForResource:@"DVRAudioCommandPropertyList" ofType:@"plist"];
    _arrayAudioCommandList = [NSArray arrayWithContentsOfFile:path];
    
    path = [[NSBundle mainBundle] pathForResource:@"DVRInformationCommandPropertyList" ofType:@"plist"];
    _arrayInfoCommandList = [NSArray arrayWithContentsOfFile:path];
    
    path = [[NSBundle mainBundle] pathForResource:@"DVRRecordCommandPropertyList" ofType:@"plist"];
    _arrayRecordCommandList = [NSArray arrayWithContentsOfFile:path];
    
    path = [[NSBundle mainBundle] pathForResource:@"DVRFileCommandPropertyList" ofType:@"plist"];
    _arrayFileCommandList = [NSArray arrayWithContentsOfFile:path];
    
    path = [[NSBundle mainBundle] pathForResource:@"DVRConfigCommandPropertyList" ofType:@"plist"];
    _arrayConfigCommandList = [NSArray arrayWithContentsOfFile:path];
    
    path = [[NSBundle mainBundle] pathForResource:@"DVRSystemCommandPropertyList" ofType:@"plist"];
    _arraySystemCommandList = [NSArray arrayWithContentsOfFile:path];
    
    path = [[NSBundle mainBundle] pathForResource:@"DVRMulticastCommandPropertyList" ofType:@"plist"];
    _arrayMulticastCommandList = [NSArray arrayWithContentsOfFile:path];
}

@end
