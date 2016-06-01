	//
//  SocketManager.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/27.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "DVRCommandPool.h"
#import "DVRPlayerManager.h"
#import "DVRRecieveDataParser.h"

@protocol DVRSocketManagerDelegate <NSObject>
@optional
- (void) hostNotResponse:(int)serial command:(NSString *)command;
- (void) hostResponse:(int)tag;
- (void) downloadFileListFromCamera:(int)serial;
- (void) getDeviceInformation:(int)tag;
- (void) snapshotResult:(int)result;
- (void) updateFileListUponRefresh:(BOOL)refresh;
- (void) updateResolution:(int)reslution;
- (void) updateCameraSettings;
- (void) didConnectToHostWithTag:(int)tag;

@end

@interface DVRSocketManager : NSObject <GCDAsyncSocketDelegate>{
    BOOL isConnected;
    GCDAsyncSocket *socket;
    int serial;
    NSMutableArray *connectedSocket;
    dispatch_queue_t socketQueue;
    int connectTry;
    NSString *commandToBeSent;
    int tagLocal;
    NSString *cameraSerialLocal;
    NSString *commandName;
    NSString *localURL;
    NSArray *commandSetLocal;
    int indexLocal;
}

@property (nonatomic, weak) id <DVRSocketManagerDelegate> delegate;
@property (nonatomic, strong) NSString *hostURL;
@property (nonatomic, strong) NSString *hostPort;
+ (DVRSocketManager *) shareInstance;
- (id) init;

- (BOOL)connectHost:(NSString *)hostURL withPort:(NSString *)hostPort withTag:(int)tag;
- (BOOL)sendCommand:(NSString *)commandString toCamera:(NSString *)cameraSerial withTag:(int)tag;
- (BOOL)sendCommandSet:(NSArray *)commandSet toCamera:(NSString *)cameraSerial withTag:(int)tag index:(int)index;
- (void)setTag:(int)value commandCategory:(NSString *)string;
@end
