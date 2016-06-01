//
//  AudioRecorder.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 5/9/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>
#import "SkyEyeCommandGenerator.h"
#import "SocketManager.h"
#import "PlayerManager.h"
#define NUM_BUFFERS 3

@class AudioRecorder;
@protocol AudioRecorderDelegate <NSObject>
- (void)audioDataInCommand:(NSData *)data;
@end

typedef struct
{
    AudioStreamBasicDescription dataFormat;
    AudioQueueRef               queue;
    AudioQueueBufferRef         buffers[NUM_BUFFERS];
    AudioFileID                 audioFile;
    UInt32                      bufferByteSize;
    SInt64                      currentPacket;
    bool                        recording;
}RecordState;

void AudioInputCallback(void * inUserData,  // Custom audio metadata
                        AudioQueueRef inAQ,
                        AudioQueueBufferRef inBuffer,
                        const AudioTimeStamp * inStartTime,
                        UInt32 inNumberPacketDescriptions,
                        const AudioStreamPacketDescription * inPacketDescs);

@interface AudioRecorder : NSObject <SocketManagerDelegate> {
    RecordState recordState, m_audioFormat;
    SocketManager *socketManager;
    CFURLRef filePath;
    uint32_t bufferSize;
}

@property (strong, nonatomic) id<AudioRecorderDelegate> delegate;

+ (id) sharedInstance;
- (void)setupAudioFormat:(AudioStreamBasicDescription*)format;
- (void)startRecording;
- (void)stopRecording;
- (void)startPlayback;
- (void)stopPlayback;
- (void)feedSamplesToEngine:(UInt32)audioDataBytesCapacity audioData:(void *)audioData;
@property BOOL isRecording;
@property (strong, nonatomic) NSString *cameraSerial;
@end
