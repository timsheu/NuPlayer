//
//  FileSetCameraTableViewController.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/23.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingPool.h"
#import "PlayerManager.h"
#import "FileViewController.h"
#import "SocketManager.h"
#import "SkyEyeCommandGenerator.h"
@interface FileSetCameraTableViewController : UITableViewController <SocketManagerDelegate>{
    NSMutableArray *arrayCameraName;
    NSMutableArray *arrayFileAmount;
    int cameraSerial;
    SocketManager *socketManager;
}

@end
