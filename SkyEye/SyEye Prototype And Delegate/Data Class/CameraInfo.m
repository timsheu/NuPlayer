//
//  CameraInfo.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/17.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "CameraInfo.h"

@implementation CameraInfo

-(CameraInfo *)initWithCameraURL:(NSString *)url serial:(NSString *)serial name:(NSString *)name resolution:(NSString *)resolution quality:(NSString *)quality bitRate:(NSString *)bitrate FPS:(NSString *)FPS{
    _cameraURL = [[NSString alloc] initWithString:url];
    _cameraSerial = [[NSString alloc] initWithString:serial];
    if (name == nil) {
        name = @"New Camera";
    }
    _cameraName = [[NSString alloc] initWithString:name];
    if (resolution == nil) {
        resolution = @"1";
    }
    _cameraResolution = [[NSString alloc] initWithString:resolution];
    if (quality == nil) {
        quality = @"1";
    }
    _cameraQuality = [[NSString alloc] initWithString:quality];
    if (bitrate == nil) {
        bitrate = @"6000";
    }
    _cameraBitRate = [[NSString alloc] initWithString:bitrate];
    if (FPS == nil) {
        FPS = @"30";
    }
    _cameraFPS = [[NSString alloc] initWithString:FPS];
    return self;
}

-(CameraInfo *)initWithDictionary:(NSDictionary *)dic{
    _cameraURL = [NSString stringWithString:[dic objectForKey:@"URL"]];
    _cameraName = [NSString stringWithString:[dic objectForKey:@"Name"]];
    _cameraSerial = [NSString stringWithString:[dic objectForKey:@"Serial"]];
    _cameraResolution = [NSString stringWithString:[dic objectForKey:@"Resolution"]];
    _cameraQuality = [NSString stringWithString:[dic objectForKey:@"Encode Quality"]];
    _cameraBitRate = [NSString stringWithString:[dic objectForKey:@"Bit Rate"]];
    _cameraFPS = [NSString stringWithString:[dic objectForKey:@"FPS"]];
    return self;
}

@end
