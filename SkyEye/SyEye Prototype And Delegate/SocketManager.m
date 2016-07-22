//
//  SocketManager.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/27.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "SocketManager.h"

@implementation SocketManager
@synthesize hostURL = _hostURL;
@synthesize hostPort = _hostPort;

+ (id)shareInstance {
    static SocketManager* socketManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socketManager = [[self alloc] init];
    });
    return socketManager;
}

- (id) init{
    if (self = [super init]) {
        _isConnected = NO;
        serial = 0;
        connectTry = 0;
        tagLocal = 0;
        indexLocal = 0;
        connectedSocket = [[NSMutableArray alloc] initWithCapacity:1];
        socketQueue = dispatch_queue_create("socketQueue", NULL);
        socket = [[GCDAsyncSocket alloc]init];
        socketSwap = [[GCDAsyncSocket alloc]init];
        [socket setDelegate:self delegateQueue:dispatch_get_main_queue()];
        [socketSwap setDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)sendAudioData{
//    DDLogDebug(@"socket manager, send audio data, %@", commandToBeSentInData);
    [socket writeData:commandToBeSentInData withTimeout:-1 tag:tagLocal];
}

- (void)sendData{
    NSData *data = [commandToBeSent dataUsingEncoding:NSUTF8StringEncoding];
    [socket readDataWithTimeout:-1 tag:tagLocal];
    if (tagLocal >= SOCKET_READ_TAG_CAMERA_OFFSET && tagLocal <= SOCKET_READ_TAG_CAMERA_4) {
        [socket writeData:data withTimeout:-1 tag:tagLocal+SOCKET_READ_TAG_CAMERA_OFFSET];
    }else if ((tagLocal >= SOCKET_READ_TAG_STATUS_RESOLUTION && tagLocal <= SOCKET_READ_TAG_STATUS_MAX_FPS) || tagLocal == SOCKET_READ_TAG_SEND_SETTING
              || tagLocal == SOCKET_READ_TAG_INFO_REBOOT){
        [socket writeData:data withTimeout:-1 tag:tagLocal];
    }else if (tagLocal == SOCKET_READ_TAG_SNAPSHOT){
        [socket writeData:data withTimeout:-1 tag:tagLocal];
    }else if (tagLocal == SOCKET_READ_TAG_SET_PLUGIN){
        [socket writeData:data withTimeout:-1 tag:tagLocal];
    }else if (tagLocal == SOCKET_UPLOAD_AUDIO_STREAM){
        data = [NSData dataWithData:commandToBeSentInData];
		[socket writeData:data withTimeout:-1 tag:tagLocal];
    }else{
        [socket writeData:data withTimeout:-1 tag:tagLocal];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    _isConnected = YES;
    _hostURL = [[NSString alloc] initWithString:host];
    _hostPort = [[NSString alloc] initWithFormat:@"%d", port];
    DDLogDebug(@"Did connected to Host: %@ at port: %@", _hostURL, _hostPort);
    [self sendData];
}

- (BOOL)connectHost:(NSString *)hostURL withPort:(NSString *)hostPort withTag:(int)tag{
    BOOL ret = NO;
    if (socket == nil) {
        socket = [[GCDAsyncSocket alloc]init];
        [socket setDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    if (_isConnected == YES && ![socket.connectedHost isEqualToString:hostURL]) {
        [socket disconnect];
    }
    _hostURL = hostURL;
    _hostPort = hostPort;
    DDLogDebug(@"address: %@, port: %@", _hostURL, _hostPort);
    ret = [socket connectToHost:_hostURL onPort:_hostPort.intValue withTimeout:3 error:nil];
    return ret;
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    DDLogDebug(@"error code: %ld", (long)err.code);
    _isConnected = NO;
    if (err.code >=4 && err.code < 7) {
        [_delegate hostNotResponse:tagLocal command:commandToBeSent];
    }else if (err.code == 61){
//        [self connectHost:localURL withPort:@"8000" withTag:tagLocal];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
//    DDLogDebug(@"did write data: %@", commandToBeSent);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    DDLogDebug(@"===tag: %ld", (long)tag);
    DDLogDebug(@"%@", string);
    PlayerManager *manager = [PlayerManager sharedInstance];
    if (tag == SOCKET_READ_TAG_CAMERA_1 || tag == SOCKET_READ_TAG_CAMERA_2 || tag == SOCKET_READ_TAG_CAMERA_3 || tag == SOCKET_READ_TAG_CAMERA_4) {
        NSMutableDictionary *dic = [manager.dictionarySetting objectForKey:cameraSerialLocal];
        NSArray *arrayData = [string componentsSeparatedByString:@"\r\n"];
        NSMutableArray *dataContentArray = [[NSMutableArray alloc]init];
        NSMutableArray *fileList = [[NSMutableArray alloc]init];
        NSString *searchPatternAVI = @".avi";
        NSString *searchPatternMP4 = @".mp4";
        NSRange range;
        NSString *httpHearder = [arrayData objectAtIndex:0];
        if (arrayData.count > 8 && [httpHearder isEqualToString:@"HTTP/1.1 200 OK"]) {
            for (int i=8; i<arrayData.count; i++) {
                [dataContentArray addObject:[arrayData objectAtIndex:i]];
            }
        } else {
            for (NSString *s in arrayData) {
                [dataContentArray addObject:s];
            }
        }
        BOOL isDataFlag = NO;
        for (NSString *s in dataContentArray) {
            NSArray *split = [s componentsSeparatedByString:@"\n"];
            if (split.count == 0) {
                break;
            }else{
                for (NSString *ss in split) {
                    range = [ss rangeOfString:searchPatternAVI];
                    if (![ss isEqualToString:@""]) {
                        isDataFlag = YES;
                    }
                    if (range.location != NSNotFound) {
                        NSArray *deleteNextLine = [ss componentsSeparatedByString:@"\n"];
                        [fileList addObject:[deleteNextLine objectAtIndex:0]];
                    }
                    range = [ss rangeOfString:searchPatternMP4];
                    if (![ss isEqualToString:@""]) {
                        isDataFlag = YES;
                    }
                    if (range.location != NSNotFound) {
                        NSArray *deleteNextLine = [ss componentsSeparatedByString:@"\n"];
                        [fileList addObject:[deleteNextLine objectAtIndex:0]];
                    }
                }
            }
        }
        if (!isDataFlag) {
            [socket readDataWithTimeout:-1 tag:tag];
            return;
        }
//        NSString *serialOfCamera = [dic objectForKey:@"Serial"];
//        int serialInt = serialOfCamera.intValue - 1;
//        [manager.arrayFileNameListCollection setObject:fileList atIndexedSubscript:serialInt];
        [dic setObject:fileList forKey:@"File List"];
        [_delegate updateFileListUponRefresh:YES];
//        if (tag == SOCKET_READ_TAG_CAMERA_4) {
//            [socket readDataWithTimeout:-1 tag:SOCKET_READ_TAG_INFO_STORAGE];
//            [_delegate getDeviceInformation:SOCKET_READ_TAG_INFO_STORAGE];
//            [_delegate updateFileListUponRefresh:YES];
//        } else {
//            [socket readDataWithTimeout:-1 tag:(int)tag+1];
//            [_delegate downloadFileListFromCamera:(int)tag+1];
//            
//        }
    }else if(tag == SOCKET_READ_TAG_INFO_STORAGE){
        NSArray *array = [string componentsSeparatedByString:@"\n"];
        NSString *targetString;
        for (NSString *s in array) {
            NSData *data = [s dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            targetString = [json objectForKey:@"value"];
        }
        if (targetString == nil) {
            [socket readDataWithTimeout:-1 tag:SOCKET_READ_TAG_INFO_STORAGE];
            return;
        } else {
            DDLogDebug(@"storage result: %@", targetString);
            NSMutableDictionary *dic = [manager.dictionarySetting objectForKey:cameraSerialLocal];
            NSMutableDictionary *deviceInfo = [dic objectForKey:@"Device Info"];
            [deviceInfo setObject:targetString forKey:@"Available Storage"];
            [socket readDataWithTimeout:-1 tag:SOCKET_READ_TAG_INFO_STATUS];
            [_delegate getDeviceInformation:SOCKET_READ_TAG_INFO_STATUS];
        }
    }else if(tag == SOCKET_READ_TAG_INFO_STATUS){
        NSArray *array = [string componentsSeparatedByString:@"\n"];
        NSString *targetString;
        for (NSString *s in array) {
            NSData *data = [s dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            targetString = [json objectForKey:@"value"];
        }
        if (targetString == nil) {
            [socket readDataWithTimeout:-1 tag:SOCKET_READ_TAG_INFO_STATUS];
            return;
        } else {
            DDLogDebug(@"status result: %@", targetString);
            NSMutableDictionary *dic = [manager.dictionarySetting objectForKey:cameraSerialLocal];
            NSMutableDictionary *deviceInfo = [dic objectForKey:@"Device Info"];
            [dic setObject:targetString forKey:@"Recording"];
            [deviceInfo setObject:targetString forKey:@"Recorder Status"];
            [_delegate updateCameraSettings];
//            [_delegate getDeviceInformation:0];//for resolution
        }
    }else if(tag == SOCKET_READ_TAG_SNAPSHOT){
        NSArray *array = [string componentsSeparatedByString:@"\n"];
        NSString *targetString;
        for (NSString *s in array){
            NSData *data = [s dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            targetString = [json objectForKey:@"value"];
            if (targetString == nil) {
                [socket readDataWithTimeout:-1 tag:SOCKET_READ_TAG_SNAPSHOT];
                return;
            } else {
                [_delegate snapshotResult:targetString.intValue];
            }
        }
    }else if(tag == SOCKET_READ_TAG_OTHER){
        [socket readDataWithTimeout:-1 tag:SOCKET_READ_TAG_OTHER];
    }else if(tag == SOCKET_READ_TAG_STATUS_ENCODE_QUALITY){
        NSDictionary *parsedDic = [NSDictionary dictionaryWithDictionary:[RecieveDataParser parseSocketReadData:data withTag:(int)tag]];
        PlayerManager *manager = [PlayerManager sharedInstance];
        NSDictionary *cameraDic = [manager.dictionarySetting objectForKey:cameraSerialLocal];
        NSString *dataType = [parsedDic objectForKey:@"type"];
        if ([dataType isEqualToString:@"JSON DATA"]) {
            NSDictionary *json = [parsedDic objectForKey:@"json"];
            NSString *value = [NSString stringWithString:[json objectForKey:@"value"]];
            [cameraDic setValue:value forKey:@"Encode Quality"];
            [socket readDataWithTimeout:-1 tag:(int)tag+1];
            [_delegate didConnectToHostWithTag:(int)tag+1];
        } else if ([dataType isEqualToString:@"no data"]){
            [socket readDataWithTimeout:-1 tag:(int)tag];
            return;
        }
    }else if(tag == SOCKET_READ_TAG_STATUS_ENCODE_BITRATE){
        NSDictionary *parsedDic = [NSDictionary dictionaryWithDictionary:[RecieveDataParser parseSocketReadData:data withTag:(int)tag]];
        PlayerManager *manager = [PlayerManager sharedInstance];
        NSDictionary *cameraDic = [manager.dictionarySetting objectForKey:cameraSerialLocal];
        NSString *dataType = [parsedDic objectForKey:@"type"];
        if ([dataType isEqualToString:@"JSON DATA"]) {
            NSDictionary *json = [parsedDic objectForKey:@"json"];
            NSString *value = [NSString stringWithString:[json objectForKey:@"value"]];
            [cameraDic setValue:value forKey:@"Bit Rate"];
            [socket readDataWithTimeout:-1 tag:(int)tag+1];
            [_delegate didConnectToHostWithTag:(int)tag+1];
        } else if ([dataType isEqualToString:@"no data"]){
            [socket readDataWithTimeout:-1 tag:(int)tag];
            return;
        }
    }else if(tag == SOCKET_READ_TAG_STATUS_MAX_FPS){
        NSDictionary *parsedDic = [NSDictionary dictionaryWithDictionary:[RecieveDataParser parseSocketReadData:data withTag:(int)tag]];
        PlayerManager *manager = [PlayerManager sharedInstance];
        NSDictionary *cameraDic = [manager.dictionarySetting objectForKey:cameraSerialLocal];
        NSString *dataType = [parsedDic objectForKey:@"type"];
        if ([dataType isEqualToString:@"JSON DATA"]) {
            NSDictionary *json = [parsedDic objectForKey:@"json"];
            NSString *value = [NSString stringWithString:[json objectForKey:@"value"]];
            [cameraDic setValue:value forKey:@"FPS"];
            [socket readDataWithTimeout:-1 tag:SOCKET_READ_TAG_INFO_STORAGE];
            [_delegate getDeviceInformation:SOCKET_READ_TAG_INFO_STORAGE];
        } else if ([dataType isEqualToString:@"no data"]){
            [socket readDataWithTimeout:-1 tag:(int)tag];
            return;
        }
    }else if(tag == SOCKET_READ_TAG_STATUS_RESOLUTION){
        NSDictionary *parsedDic = [NSDictionary dictionaryWithDictionary:[RecieveDataParser parseSocketReadData:data withTag:(int)tag]];
        PlayerManager *manager = [PlayerManager sharedInstance];
        NSDictionary *cameraDic = [manager.dictionarySetting objectForKey:cameraSerialLocal];
        NSString *dataType = [parsedDic objectForKey:@"type"];
        if ([dataType isEqualToString:@"JSON DATA"]) {
            NSDictionary *json = [parsedDic objectForKey:@"json"];
            NSString *value = [NSString stringWithString:[json objectForKey:@"value"]];
            [cameraDic setValue:value forKey:@"Resolution"];
            [socket readDataWithTimeout:-1 tag:SOCKET_READ_TAG_STATUS_MAX_FPS];
            [_delegate didConnectToHostWithTag:SOCKET_READ_TAG_STATUS_MAX_FPS];
        } else if ([dataType isEqualToString:@"no data"]){
            [socket readDataWithTimeout:-1 tag:(int)tag];
            return;
        }
    }else if(tag == SOCKET_READ_TAG_SEND_SETTING){
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        DDLogDebug(@"%@", string);
    }else if(tag == SOCKET_READ_TAG_SET_PLUGIN){
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        DDLogDebug(@"%@", string);
        if (indexLocal+1 < commandSetLocal.count) {
            [self sendCommandSet:commandSetLocal toCamera:cameraSerialLocal withTag:tagLocal index:indexLocal+1];
        }
    }
}

- (BOOL)sendCommandData:(NSData *)command toCamera:(NSString *)cameraSerial withTag:(int)tag{
    NSString *string = [[NSString alloc] initWithData:command encoding:NSUTF8StringEncoding];
    DDLogDebug(@"send command data: %@", string);
    commandToBeSent = string;
    commandToBeSentInData = [NSData dataWithData:command];
    cameraSerialLocal = [NSString stringWithString:cameraSerial];
    tagLocal = tag;
    
    PlayerManager *playerManager = [PlayerManager sharedInstance];
    NSDictionary *dic = [playerManager.dictionarySetting objectForKey:cameraSerial];
    NSString *fullURL = [dic objectForKey:@"URL"];
    NSArray *split = [fullURL componentsSeparatedByString:@"/"];
    NSString *splitURL;
    if (split.count == 1) {
        splitURL = [split objectAtIndex:0];
    }else{
        splitURL = [split objectAtIndex:2];
    }
    localURL = splitURL;
    NSString *port = [dic objectForKey:@"port"];
    if (_isConnected == NO || ![socket.connectedHost isEqualToString:_hostURL]){
        return [self connectHost:splitURL withPort:port withTag:tag];
    }else{
        [self sendAudioData];
        return NO;
    }
}

-(BOOL)sendCommand:(NSString *)commandString toCamera:(NSString *)cameraSerial withTag:(int)tag {
    commandToBeSent = [NSString stringWithString:commandString];
    cameraSerialLocal = [NSString stringWithString:cameraSerial];
    tagLocal = tag;
    
    PlayerManager *playerManager = [PlayerManager sharedInstance];
    NSDictionary *dic = [playerManager.dictionarySetting objectForKey:cameraSerial];
    NSString *fullURL = [dic objectForKey:@"URL"];
    NSArray *split = [fullURL componentsSeparatedByString:@"/"];
    NSString *splitURL;
    if (split.count == 1) {
        splitURL = [split objectAtIndex:0];
    }else{
        splitURL = [split objectAtIndex:2];
    }
    localURL = splitURL;
    NSString *port = [dic objectForKey:@"port"];
    if (_isConnected == NO || ![socket.connectedHost isEqualToString:_hostURL]){
        DDLogDebug(@"connect to host; send command set");
        return [self connectHost:splitURL withPort:port withTag:tag];
    }else{
//        [self sendData];
        return NO;
    }
}

-(void)setTag:(int)value commandCategory:(NSString *)string{
    commandName = string;
    tagLocal = value;
}

-(BOOL)sendCommandSet:(NSArray *)commandSet toCamera:(NSString *)cameraSerial withTag:(int)tag index:(int)index{
    commandSetLocal = [NSArray arrayWithArray: commandSet];
    cameraSerialLocal = cameraSerial;
    tagLocal = tag;
    commandToBeSent = [commandSetLocal objectAtIndex:index];
    PlayerManager *playerManager = [PlayerManager sharedInstance];
    NSDictionary *dic = [playerManager.dictionarySetting objectForKey:cameraSerial];
    NSString *fullURL = [dic objectForKey:@"URL"];
    NSArray *split = [fullURL componentsSeparatedByString:@"/"];
    NSString *splitURL;
    if (split.count == 1) {
        splitURL = [split objectAtIndex:0];
    }else{
        splitURL = [split objectAtIndex:2];
    }
    localURL = splitURL;
    indexLocal = index;
    NSString *port = [dic objectForKey:@"port"];
    if (_isConnected == NO || ![socket.connectedHost isEqualToString:_hostURL]){
        DDLogDebug(@"connect to host; send command set");
        return [self connectHost:splitURL withPort:port withTag:tag];
    }else{
        DDLogDebug(@"direct send command set");
//        [self sendData];
        return NO;
    }
    
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    socketSwap = newSocket;
    [_delegate acceptNewSocket];
//    DDLogDebug(@"did accept socket");
}

- (void)waitSocketConnection{
    BOOL ret = [socketSwap acceptOnPort:8080 error:nil];
//    DDLogDebug(@"wait socket connection");
}

- (void)sendMicAudio:(NSData *)data{
    [socketSwap writeData:data withTimeout:-1 tag:SOCKET_UPLOAD_AUDIO_STREAM];
//    DDLogDebug(@"send mic audio");
}

- (void)disconnectMicSocket{
    [socketSwap disconnect];
    [socket disconnect];
}

@end
