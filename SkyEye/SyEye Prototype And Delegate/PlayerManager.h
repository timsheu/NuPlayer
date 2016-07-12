//
//  PlayerManager.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/1.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraInfo.h"
#import "WiFiInfo.h"
#import "SettingPool.h"
#import "FileNamePool.h"

#ifndef USE_DFU_RTSP_PLAYER
#define USE_DFU_RTSP_PLAYER
#endif

enum{
    SOCKET_READ_TAG_SEND_SETTING            = 5,
    SOCKET_READ_TAG_SET_PLUGIN              = 6,
    
    SOCKET_READ_TAG_CAMERA_OFFSET           = 10,
    SOCKET_READ_TAG_CAMERA_1                = 11,
    SOCKET_READ_TAG_CAMERA_2                = 12,
    SOCKET_READ_TAG_CAMERA_3                = 13,
    SOCKET_READ_TAG_CAMERA_4                = 14,
    SOCKET_READ_TAG_OTHER                   = 15,
    
    SOCKET_READ_TAG_INFO_STORAGE            = 20,
    SOCKET_READ_TAG_INFO_STATUS             = 21,
    SOCKET_READ_TAG_INFO_REBOOT             = 22,
    
    SOCKET_READ_TAG_SNAPSHOT                = 30,
    SOCKET_DID_READ_LAST_FILE_LIST          = 40,
    
    SOCKET_READ_TAG_STATUS_RESOLUTION       = 50,
    SOCKET_READ_TAG_STATUS_ENCODE_QUALITY   = 51,
    SOCKET_READ_TAG_STATUS_ENCODE_BITRATE   = 52,
    SOCKET_READ_TAG_STATUS_MAX_FPS          = 53,
    
    SOCKET_UPLOAD_AUDIO_STREAM              = 60
};

@interface PlayerManager : NSObject{
    NSString *path, *settingPath;
}

@property (strong, nonatomic) NSMutableDictionary *cameraAddress;
@property (strong, nonatomic) NSMutableDictionary *dictionarySetting;
@property (strong, nonatomic) NSMutableDictionary *dictionaryInfo;
@property (strong, nonatomic) NSMutableDictionary *dictionaryWiFiSetup;
@property (strong, nonatomic) NSMutableArray *arrayFileNameListCollection;
@property (strong, nonatomic) WiFiInfo *wifiInfo;
@property (nonatomic) BOOL isPhoneMicMute;
@property (nonatomic) BOOL isDeviceMicMute;

- (id)init;
- (BOOL)setupPlayerWithURL:(NSString *)url
                            withCameraNumber:(NSString *)cameraSerial
                            withCameraName:(NSString *)cameraName;
- (BOOL)setupPlayerWithCameraInfo:(CameraInfo *)info;
- (BOOL)setupRouterInfoWithSSID:(NSString *)ssid password:(NSString *)pass;
- (BOOL)setupRouterInfo:(WiFiInfo *)info;

+ (PlayerManager *)sharedInstance;

- (BOOL)updateSettingPropertyList;
- (void)resetData;
@end
