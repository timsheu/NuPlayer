#import "AudioRecorder.h"

#define AUDIO_DATA_TYPE_FORMAT float

@implementation AudioRecorder

AudioRecorder *refToSelf;

void AQOutputCallback(void *inUserData, AudioQueueRef queue, AudioQueueBufferRef queueBuffer){
    RecordState *recordStateQ = (RecordState *) inUserData;
    AudioStreamPacketDescription *packetDescs;
    UInt32 bytesRead;
    UInt32 numPackets = 8000;
    OSStatus status;
    status = AudioFileReadPackets(recordStateQ->audioFile, false, &bytesRead, packetDescs, recordStateQ->currentPacket, &numPackets, queueBuffer->mAudioData);
    if (numPackets) {
        queueBuffer->mAudioDataByteSize = bytesRead;
        AudioQueueEnqueueBuffer(recordStateQ->queue, queueBuffer, 0, NULL);
        recordStateQ->currentPacket += numPackets;
    }else{
        AudioQueueStop(recordStateQ->queue, false);
        AudioFileClose(recordStateQ->audioFile);
    }
    NSData *data = [NSData dataWithBytes:queueBuffer->mAudioData length:queueBuffer->mAudioDataBytesCapacity];
    DDLogDebug(@"%@", data);
    
}

void AudioInputCallback(void * inUserData,  // Custom audio metadata
                        AudioQueueRef inAQ,
                        AudioQueueBufferRef inBuffer,
                        const AudioTimeStamp * inStartTime,
                        UInt32 inNumberPacketDescriptions,
                        const AudioStreamPacketDescription * inPacketDescs) {
    
    RecordState *recordState = (RecordState*) inUserData;
    OSStatus status = AudioFileWritePackets(recordState->audioFile,
                                            false,
                                            inBuffer->mAudioDataByteSize, 
                                            inPacketDescs, 
                                            recordState->currentPacket, 
                                            &inNumberPacketDescriptions,
                                            inBuffer->mAudioData);
    if (status == 0) {
        recordState->currentPacket += inNumberPacketDescriptions;
    }
    AudioQueueEnqueueBuffer(recordState->queue, inBuffer, 0, NULL);
    
    AudioRecorder *rec = refToSelf;
    [rec feedSamplesToEngine:inBuffer->mAudioDataBytesCapacity audioData:inBuffer->mAudioData];
}

- (id)init
{
    if (self = [super init]) {
        _isRecording = NO;
        refToSelf = self;
        bufferSize = 4000;
    }
    return self;
}

+ (id)sharedInstance{
    static AudioRecorder* audioRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioRecorder = [[self alloc] init];
    });
    return audioRecorder;
}

- (void)setupAudioFormat:(AudioStreamBasicDescription*)format {
    format->mSampleRate = 8000.0;
    format->mFormatID = kAudioFormatLinearPCM;
    format->mFormatFlags =  kLinearPCMFormatFlagIsSignedInteger |
                            kLinearPCMFormatFlagIsPacked;
    format->mFramesPerPacket  = 1;
    format->mChannelsPerFrame = 1;
    format->mBytesPerFrame    = 2;
    format->mBytesPerPacket   = 2;
    format->mBitsPerChannel   = 16;
    format->mReserved = 0;
}

- (void)startRecording {
    // tell n329 that iOS opened a socket for her
    socketManager = [SocketManager shareInstance];
    socketManager.delegate = self;
    [socketManager waitSocketConnection];
    NSData *command = [SkyEyeCommandGenerator generateContinousAudioCommand:8000 channel:1 volume:100];
    [socketManager sendCommandData:command toCamera:_cameraSerial withTag:SOCKET_UPLOAD_AUDIO_STREAM];
}

- (void)stopRecording {
    socketManager = [SocketManager shareInstance];
    [socketManager disconnectMicSocket];
    recordState.recording = false;
    
    AudioQueueStop(recordState.queue, true);
    
    for (int i = 0; i < NUM_BUFFERS; i++) {
        AudioQueueFreeBuffer(recordState.queue, recordState.buffers[i]);
    }
    
    AudioQueueDispose(recordState.queue, true);
    AudioFileClose(recordState.audioFile);
    _isRecording = recordState.recording;
}

- (void)feedSamplesToEngine:(UInt32)audioDataBytesCapacity audioData:(void *)audioData {
    
    NSMutableData *tempData = [NSMutableData dataWithBytes:audioData length:(NSUInteger)audioDataBytesCapacity];
    [socketManager sendMicAudio:tempData];
//    [_delegate audioDataInCommand:command];
}

- (void)acceptNewSocket{
    [self setupAudioFormat:&recordState.dataFormat];
    //make file
    char path[256];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString* docDir = [paths objectAtIndex:0];
    NSString* file = [docDir stringByAppendingString:@"/recording.aif"];
    char *buffer = path;
    int bufferLength = sizeof path;
    [file getCString:buffer maxLength:bufferLength encoding:NSUTF8StringEncoding];
    filePath = CFURLCreateFromFileSystemRepresentation(NULL, (UInt8 *)path, strlen(path), false);
    //
    
    
    recordState.currentPacket = 0;
    
    OSStatus status;
    
    status = AudioQueueNewInput(&recordState.dataFormat,
                                AudioInputCallback,
                                &recordState,
                                CFRunLoopGetCurrent(),
                                kCFRunLoopCommonModes,
                                0,
                                &recordState.queue);
    
    if (status == 0) {
        
        for (int i = 0; i < NUM_BUFFERS; i++) {
            AudioQueueAllocateBuffer(recordState.queue, bufferSize, &recordState.buffers[i]);
            AudioQueueEnqueueBuffer(recordState.queue, recordState.buffers[i], 0, nil);
        }
        
        status = AudioFileCreateWithURL(filePath, kAudioFileAIFFType, &recordState.dataFormat, kAudioFileFlags_EraseFile, &recordState.audioFile);
        
        recordState.recording = true;
        _isRecording = recordState.recording;
        status = AudioQueueStart(recordState.queue, NULL);
    }
}

- (void)startPlayback{
    m_audioFormat.dataFormat.mFormatID = kAudioFormatLinearPCM;
    m_audioFormat.dataFormat.mSampleRate = 8000;
    m_audioFormat.dataFormat.mFormatFlags = kLinearPCMFormatFlagIsBigEndian |
                                            kLinearPCMFormatFlagIsFloat |
                                            kLinearPCMFormatFlagIsPacked;
    m_audioFormat.dataFormat.mFramesPerPacket = 1;
    m_audioFormat.dataFormat.mBytesPerFrame = 2;
    m_audioFormat.dataFormat.mBitsPerChannel = 16;
    m_audioFormat.dataFormat.mBytesPerPacket= 2;
    m_audioFormat.dataFormat.mChannelsPerFrame = 1;
    m_audioFormat.dataFormat.mReserved = 0;
    char path[256];
    NSString *sine = [[NSBundle mainBundle] pathForResource:@"sine_wave_70s" ofType:@"aiff"];
    char *buffer = path;
    int bufferLength = sizeof path;
    [sine getCString:buffer maxLength:bufferLength encoding:NSUTF8StringEncoding];
    filePath = CFURLCreateFromFileSystemRepresentation(NULL, (UInt8 *)path, strlen(path), false);
    OSStatus status = AudioFileOpenURL(filePath, kAudioFileReadPermission, kAudioFileAIFFType, &m_audioFormat.audioFile);
    if (status == 0) {
        AudioQueueNewOutput(&m_audioFormat.dataFormat, AQOutputCallback, &m_audioFormat, NULL, kCFRunLoopCommonModes, 0, &m_audioFormat.queue);
        for (int i=0; i< NUM_BUFFERS; i++) {
            AudioQueueAllocateBuffer(m_audioFormat.queue, bufferSize, &m_audioFormat.buffers[i]);
//            m_audioFormat.buffers[i]->mAudioDataByteSize = bufferSize;
            AQOutputCallback(&m_audioFormat, m_audioFormat.queue, m_audioFormat.buffers[i]);
        }
        AudioQueueStart(m_audioFormat.queue, NULL);
    }
}

- (void)stopPlayback{
    m_audioFormat.recording = false;
    
    AudioQueueStop(m_audioFormat.queue, true);
    
    for (int i = 0; i < NUM_BUFFERS; i++) {
        AudioQueueFreeBuffer(m_audioFormat.queue, m_audioFormat.buffers[i]);
    }
    
    AudioQueueDispose(m_audioFormat.queue, true);
    AudioFileClose(m_audioFormat.audioFile);
    _isRecording = m_audioFormat.recording;
}

@end