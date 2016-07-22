//
//  MicRecorder.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 5/6/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "PlayerManager.h"
@interface MicRecorder : NSObject

@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
+ (id) sharedInstance;
- (BOOL) startRecord;
- (BOOL) stopRecord;
@end
