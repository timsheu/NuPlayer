//
//  MicRecorder.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 5/6/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

#import "MicRecorder.h"

@implementation MicRecorder

+ (id)sharedInstance{
    static MicRecorder *micRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        micRecorder = [[self alloc] init];
    });
    return micRecorder;
}

- (id) init{
    if (self = [super init]) {
        NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInteger:kAudioFormatLinearPCM], AVFormatIDKey,
                                       [NSNumber numberWithInt:16], AVEncoderBitRateKey,
                                       [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                       [NSNumber numberWithFloat:8000], AVSampleRateKey, nil];
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/record.caf", [[NSBundle mainBundle] resourcePath]]];
        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&error];
        
        if (error != nil) {
            NSLog(@"init audio recorder error: %@", error);
        }else{
            NSLog(@"init audio recorder success");
        }
    }
    return self;
}

- (BOOL)startRecord{
    BOOL isStart = NO;
    dispatch_queue_t createQueue = dispatch_queue_create("SerialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(createQueue, ^(){
        [_audioRecorder record];
        
    });
    return isStart;
}

- (BOOL)stopRecord{
    BOOL isStop = NO;
    return isStop;
}
@end
