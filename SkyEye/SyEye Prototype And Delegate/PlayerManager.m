//
//  PlayerManager.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/1.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "PlayerManager.h"

@implementation PlayerManager

- (BOOL)setupPlayerWithURL:(NSString *)url withCameraNumber:(NSString *)cameraSerial withCameraName:(NSString *)cameraName{
    CameraInfo *info = [[CameraInfo alloc] initWithCameraURL:url serial:cameraSerial name:cameraName resolution:nil quality:nil bitRate:nil FPS:nil];
    return [self setupPlayerWithCameraInfo:info];
}

- (BOOL)setupPlayerWithCameraInfo:(CameraInfo *)info{
    if ([_cameraAddress objectForKey:info.cameraSerial] == nil) {
        [_cameraAddress setObject:info forKey:info.cameraSerial];
        return YES;
    }
    
    return NO;
}

- (BOOL)setupRouterInfoWithSSID:(NSString *)ssid password:(NSString *)pass{
    WiFiInfo *info = [[WiFiInfo alloc] initWithSSID:ssid password:pass];
    if (info != nil) {
        _wifiInfo = info;
        return YES;
    }
    return NO;
}

- (BOOL)setupRouterInfo:(WiFiInfo *)info{
    if (info != nil) {
        _wifiInfo = info;
        return YES;
    }
    return NO;
}

- (id)init{
    if (self == [super init]) {
        if (_cameraAddress == nil) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
            NSString *docfilePath = [basePath stringByAppendingPathComponent:@"/SettingsPropertyListLocal.plist"];
            NSString *tempPath = [[NSBundle mainBundle] pathForResource:@"SettingsPropertyList" ofType:@"plist"];
            NSDictionary *tempDictionary = [NSDictionary dictionaryWithContentsOfFile:tempPath];
            NSDictionary *checkDictinary = [NSDictionary dictionaryWithContentsOfFile:docfilePath];
            if (checkDictinary == nil) {
                [tempDictionary writeToFile:docfilePath atomically:YES];
            }
            path = [NSString stringWithString:docfilePath];
            _dictionarySetting = [NSMutableDictionary dictionaryWithContentsOfFile:path];
            settingPath = [NSString stringWithString:path];
            
            docfilePath = [basePath stringByAppendingString:@"/InfoPropertyListLocal.plist"];
            tempPath = [[NSBundle mainBundle] pathForResource:@"InfoPropertyList" ofType:@"plist"];
            tempDictionary = [NSDictionary dictionaryWithContentsOfFile:tempPath];
            checkDictinary = [NSDictionary dictionaryWithContentsOfFile:docfilePath];
            if (checkDictinary == nil) {
                [tempDictionary writeToFile:docfilePath atomically:YES];
            }
            path = [NSString stringWithString:docfilePath];
            _dictionaryInfo = [NSMutableDictionary dictionaryWithContentsOfFile:path];
            
            docfilePath = [basePath stringByAppendingString:@"/FileNamePropertyListLocal.plist"];
            tempPath = [[NSBundle mainBundle] pathForResource:@"FileNamePropertyList" ofType:@"plist"];
            NSArray *tempArray = [NSArray arrayWithContentsOfFile:tempPath];
            NSMutableArray *checkArray = [NSMutableArray arrayWithContentsOfFile:docfilePath];
            if (checkArray == nil) {
                [tempArray writeToFile:docfilePath atomically:YES];
            }
            path = [NSString stringWithString:docfilePath];
            if (_arrayFileNameListCollection == nil) {
                _arrayFileNameListCollection = [[NSMutableArray alloc] initWithCapacity:4];
            }
            _arrayFileNameListCollection = [NSMutableArray arrayWithContentsOfFile:path];
            
            docfilePath = [basePath stringByAppendingString:@"/QRCodePropertyListLocal.plist"];
            tempPath = [[NSBundle mainBundle] pathForResource:@"QRCodePropertyList" ofType:@"plist"];
            tempDictionary = [NSDictionary dictionaryWithContentsOfFile:tempPath];
            checkDictinary = [NSDictionary dictionaryWithContentsOfFile:docfilePath];
            if (checkDictinary == nil) {
                [tempDictionary writeToFile:docfilePath atomically:YES];
            }
            path = [NSString stringWithString:docfilePath];
            _dictionaryWiFiSetup = [NSMutableDictionary dictionaryWithContentsOfFile:path];
            
            _isPhoneMicMute = NO;
            _isDeviceMicMute = NO;
            NSDictionary *dic = [_dictionarySetting objectForKey:@"Wi-Fi AP Setup"];
            if ([dic objectForKey:@"SSID"] != nil) {
                [self setupRouterInfoWithSSID:[dic objectForKey:@"SSID"] password:[dic objectForKey:@"password"]];
            }
        }
    }
    return self;
}

+ (PlayerManager *)sharedInstance{
    static PlayerManager *playerManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerManager = [[self alloc] init];
    });
    return playerManager;
}

- (BOOL)updateSettingPropertyList{
    return [_dictionarySetting writeToFile:settingPath atomically:YES];
}

- (void)resetData{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *docfilePath = [basePath stringByAppendingPathComponent:@"/SettingsPropertyListLocal.plist"];
    NSString *tempPath = [[NSBundle mainBundle] pathForResource:@"SettingsPropertyList" ofType:@"plist"];
    NSDictionary *tempDictionary = [NSDictionary dictionaryWithContentsOfFile:tempPath];
    NSDictionary *checkDictinary = [NSDictionary dictionaryWithContentsOfFile:docfilePath];
    [tempDictionary writeToFile:docfilePath atomically:YES];
    path = [NSString stringWithString:docfilePath];
    settingPath = [NSString stringWithString:path];
    _dictionarySetting = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    docfilePath = [basePath stringByAppendingString:@"/InfoPropertyListLocal.plist"];
    tempPath = [[NSBundle mainBundle] pathForResource:@"InfoPropertyList" ofType:@"plist"];
    tempDictionary = [NSDictionary dictionaryWithContentsOfFile:tempPath];
    checkDictinary = [NSDictionary dictionaryWithContentsOfFile:docfilePath];
    [tempDictionary writeToFile:docfilePath atomically:YES];
    path = [NSString stringWithString:docfilePath];
    _dictionaryInfo = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    docfilePath = [basePath stringByAppendingString:@"/FileNamePropertyListLocal.plist"];
    tempPath = [[NSBundle mainBundle] pathForResource:@"FileNamePropertyList" ofType:@"plist"];
    NSArray *tempArray = [NSArray arrayWithContentsOfFile:tempPath];
    [tempArray writeToFile:docfilePath atomically:YES];
    path = [NSString stringWithString:docfilePath];
    _arrayFileNameListCollection = [[NSMutableArray alloc] initWithCapacity:4];
    _arrayFileNameListCollection = [NSMutableArray arrayWithContentsOfFile:path];
    
    NSDictionary *dic = [_dictionarySetting objectForKey:@"Wi-Fi AP Setup"];
    docfilePath = [basePath stringByAppendingString:@"/QRCodePropertyListLocal.plist"];
    tempPath = [[NSBundle mainBundle] pathForResource:@"QRCodePropertyList" ofType:@"plist"];
    tempDictionary = [NSDictionary dictionaryWithContentsOfFile:tempPath];
    checkDictinary = [NSDictionary dictionaryWithContentsOfFile:docfilePath];
    [tempDictionary writeToFile:docfilePath atomically:YES];
    path = [NSString stringWithString:docfilePath];
    _dictionaryWiFiSetup = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    _isPhoneMicMute = NO;
    _isDeviceMicMute = NO;

    [self setupRouterInfoWithSSID:[dic objectForKey:@"SSID"] password:[dic objectForKey:@"password"]];
}

@end
