//
//  EMailReport.m
//  NuPlayer
//
//  Created by Chia-Cheng Hsu on 7/12/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

#import "EMailReport.h"

@implementation EMailReport
+ (id)sharedInstance{
    static EMailReport *report;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        report = [[self alloc] init];
    });
    return report;
}

- (id)init{
    if (self = [super init]) {
        fileLogger = [[DDFileLogger alloc] init];
        fileLogger.rollingFrequency = 60 * 60 * 24;
        fileLogger.logFileManager.maximumNumberOfLogFiles = 5;
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:fileLogger];
    }
    return self;
}

- (BOOL)isCrashed{
    NSString *crashed = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Crashed"];
    BOOL isCrashed = ([crashed isEqualToString:@"YES"]) ? YES : NO;
    return isCrashed;
}

- (void)crashed: (BOOL) isCrashed{
    NSString *crashed = @"NO";
    if (isCrashed) {
        crashed = @"YES";
    }
    [[NSBundle mainBundle] setValue:@"Crashed" forKey:@"YES"];
}

- (NSString *)getCurrentLogFile{
    NSString *filePath = @"";
    filePath = [NSString stringWithString: fileLogger.currentLogFileInfo.filePath];
    return filePath;
}

@end
