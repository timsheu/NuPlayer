//
//  DVRPlayerManager.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/1.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "DVRPlayerManager.h"

@implementation DVRPlayerManager

- (BOOL)setupPlayerWithURL:(NSString *)url withCameraNumber:(NSString *)cameraSerial withCameraName:(NSString *)cameraName{
    DVRCameraInfo *info = [[DVRCameraInfo alloc] initWithCameraURL:url serial:cameraSerial name:cameraName resolution:nil quality:nil bitRate:nil FPS:nil recording:nil];
    return [self setupPlayerWithCameraInfo:info];
}

- (BOOL)setupPlayerWithCameraInfo:(DVRCameraInfo *)info{
    if ([_cameraAddress objectForKey:info.cameraSerial] == nil) {
        [_cameraAddress setObject:info forKey:info.cameraSerial];
        return YES;
    }
    
    return NO;
}

- (BOOL)setupRouterInfoWithSSID:(NSString *)ssid password:(NSString *)pass{
    DVRWiFiInfo *info = [[DVRWiFiInfo alloc] initWithSSID:ssid password:pass];
    if (info != nil) {
        _wifiInfo = info;
        return YES;
    }
    return NO;
}

- (BOOL)setupRouterInfo:(DVRWiFiInfo *)info{
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
            NSString *docfilePath = [basePath stringByAppendingPathComponent:@"/DVRSettingsPropertyListLocal.plist"];
            NSString *tempPath = [[NSBundle mainBundle] pathForResource:@"DVRSettingsPropertyList" ofType:@"plist"];
            NSDictionary *tempDictionary = [NSDictionary dictionaryWithContentsOfFile:tempPath];
            NSDictionary *checkDictinary = [NSDictionary dictionaryWithContentsOfFile:docfilePath];
            if (checkDictinary == nil) {
                [tempDictionary writeToFile:docfilePath atomically:YES];
            }
            path = [NSString stringWithString:docfilePath];
            settingPath = path;
            _dictionarySetting = [NSMutableDictionary dictionaryWithContentsOfFile:path];
            
            docfilePath = [basePath stringByAppendingString:@"/DVRInfoPropertyListLocal.plist"];
            tempPath = [[NSBundle mainBundle] pathForResource:@"DVRInfoPropertyList" ofType:@"plist"];
            tempDictionary = [NSDictionary dictionaryWithContentsOfFile:tempPath];
            checkDictinary = [NSDictionary dictionaryWithContentsOfFile:docfilePath];
            if (checkDictinary == nil) {
                [tempDictionary writeToFile:docfilePath atomically:YES];
            }
            path = [NSString stringWithString:docfilePath];
            _dictionaryInfo = [NSMutableDictionary dictionaryWithContentsOfFile:path];
            
            docfilePath = [basePath stringByAppendingString:@"/DVRFileNamePropertyListLocal.plist"];
            tempPath = [[NSBundle mainBundle] pathForResource:@"DVRFileNamePropertyList" ofType:@"plist"];
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
            
            docfilePath = [basePath stringByAppendingString:@"/DVRQRCodePropertyListLocal.plist"];
            tempPath = [[NSBundle mainBundle] pathForResource:@"DVRQRCodePropertyList" ofType:@"plist"];
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

+ (DVRPlayerManager *)sharedInstance{
    static DVRPlayerManager *playerManager = nil;
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
    NSString *docfilePath = [basePath stringByAppendingPathComponent:@"/DVRSettingsPropertyListLocal.plist"];
    NSString *tempPath = [[NSBundle mainBundle] pathForResource:@"DVRSettingsPropertyList" ofType:@"plist"];
    NSDictionary *tempDictionary = [NSDictionary dictionaryWithContentsOfFile:tempPath];
    NSDictionary *checkDictinary = [NSDictionary dictionaryWithContentsOfFile:docfilePath];
    [tempDictionary writeToFile:docfilePath atomically:YES];
    path = [NSString stringWithString:docfilePath];
    _dictionarySetting = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    docfilePath = [basePath stringByAppendingString:@"/DVRInfoPropertyListLocal.plist"];
    tempPath = [[NSBundle mainBundle] pathForResource:@"DVRInfoPropertyList" ofType:@"plist"];
    tempDictionary = [NSDictionary dictionaryWithContentsOfFile:tempPath];
    checkDictinary = [NSDictionary dictionaryWithContentsOfFile:docfilePath];
    [tempDictionary writeToFile:docfilePath atomically:YES];
    path = [NSString stringWithString:docfilePath];
    _dictionaryInfo = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    docfilePath = [basePath stringByAppendingString:@"/DVRFileNamePropertyListLocal.plist"];
    tempPath = [[NSBundle mainBundle] pathForResource:@"DVRFileNamePropertyList" ofType:@"plist"];
    NSArray *tempArray = [NSArray arrayWithContentsOfFile:tempPath];
    [tempArray writeToFile:docfilePath atomically:YES];
    path = [NSString stringWithString:docfilePath];
    _arrayFileNameListCollection = [[NSMutableArray alloc] initWithCapacity:4];
    _arrayFileNameListCollection = [NSMutableArray arrayWithContentsOfFile:path];
    
    NSDictionary *dic = [_dictionarySetting objectForKey:@"Wi-Fi AP Setup"];
    docfilePath = [basePath stringByAppendingString:@"/DVRQRCodePropertyListLocal.plist"];
    tempPath = [[NSBundle mainBundle] pathForResource:@"DVRQRCodePropertyList" ofType:@"plist"];
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
