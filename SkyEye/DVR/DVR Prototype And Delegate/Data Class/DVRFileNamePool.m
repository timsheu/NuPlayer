//
//  DVRFileNamePool.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/24.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "DVRFileNamePool.h"

@implementation DVRFileNamePool
- (id)init{
    if (self = [super init]) {
        [self initArrayContent];
    }
    return self;
}

+ (DVRFileNamePool *)sharedInstance{
    static DVRFileNamePool *fileNamePool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileNamePool = [[self alloc] init];
    });
    return fileNamePool;
}

- (void)initArrayContent{
    if (arrayCameraFileListCollection == nil) {
        arrayCameraFileListCollection = [[NSMutableArray alloc] initWithCapacity:4];
    }
}
@end
