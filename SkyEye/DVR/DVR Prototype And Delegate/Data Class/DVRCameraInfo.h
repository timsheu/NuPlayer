//
//  DVRCameraInfo.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/17.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DVRCameraInfo : NSObject
@property (nonatomic, strong) NSString *cameraURL;
@property (nonatomic, strong) NSString *cameraSerial;
@property (nonatomic, strong) NSString *cameraName;
@property (nonatomic, strong) NSString *cameraResolution;
@property (nonatomic, strong) NSString *cameraQuality;
@property (nonatomic, strong) NSString *cameraBitRate;
@property (nonatomic, strong) NSString *cameraFPS;
@property (nonatomic, strong) NSString *cameraRecording;

- (DVRCameraInfo *)initWithCameraURL:(NSString *)url
                              serial:(NSString *)serial
                                name:(NSString *)name
                          resolution:(NSString *)resolution
                             quality:(NSString *)quality
                             bitRate:(NSString *)bitrate
                                 FPS:(NSString *)FPS
                           recording:(NSString *)recording;

- (DVRCameraInfo *)initWithDictionary:(NSDictionary *)dic;
@end
