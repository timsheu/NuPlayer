//
//  EMailReport.h
//  NuPlayer
//
//  Created by Chia-Cheng Hsu on 7/12/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaLumberjack.h"
@interface EMailReport : NSObject{
    DDFileLogger *fileLogger;
}

+ (id)sharedInstance;
- (BOOL)isCrashed;
- (void)crashed: (BOOL)isCrashed;
- (NSString *)getCurrentLogFile;
@end
