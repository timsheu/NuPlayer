//
//  SocketManager.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/27.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "CommandPool.h"
#import "PlayerManager.h"
#import "RecieveDataParser.h"

@protocol SocketManagerDelegate <NSObject>
@optional
- (void) hostNotResponse:(int)serial command:(NSString *)command;
- (void) hostResponse:(int)tag;
- (void) downloadFileListFromCamera:(int)serial;
- (void) getDeviceInformation:(int)tag;
- (void) snapshotResult:(int)result;
- (void) updateFileListUponRefresh:(BOOL)refresh;
- (void) updateCameraSettings;
- (void) didConnectToHostWithTag:(int)tag;
- (void) acceptNewSocket; 
@end

@interface SocketManager : NSObject <GCDAsyncSocketDelegate>{
    GCDAsyncSocket *socket, *socketSwap;
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
    NSData *commandToBeSentInData;
    int indexLocal;
}
@property BOOL isConnected;
@property (nonatomic, weak) id <SocketManagerDelegate> delegate;
@property (nonatomic, strong) NSString *hostURL;
@property (nonatomic, strong) NSString *hostPort;
+ (SocketManager *) shareInstance;
- (id) init;

- (BOOL)connectHost:(NSString *)hostURL withPort:(NSString *)hostPort withTag:(int)tag;
- (BOOL)sendCommand:(NSString *)commandString toCamera:(NSString *)cameraSerial withTag:(int)tag;
- (BOOL)sendCommandData:(NSData *)command toCamera:(NSString *)cameraSerial withTag:(int)tag;
- (BOOL)sendCommandSet:(NSArray *)commandSet toCamera:(NSString *)cameraSerial withTag:(int)tag index:(int)index;
- (void)setTag:(int)value commandCategory:(NSString *)string;
- (void)waitSocketConnection;
- (void)sendMicAudio:(NSData *)data;
- (void)disconnectMicSocket;
@end
