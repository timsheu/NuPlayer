//
//  FileNamePool.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/24.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "FileNamePool.h"

@implementation FileNamePool
- (id)init{
    if (self = [super init]) {
        [self initArrayContent];
    }
    return self;
}

+ (FileNamePool *)sharedInstance{
    static FileNamePool *fileNamePool = nil;
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
