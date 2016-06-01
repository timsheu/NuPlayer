//
//  DVRFileSetCameraTableViewController.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/23.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVRSettingPool.h"
#import "DVRPlayerManager.h"
#import "DVRFileViewController.h"
#import "DVRSocketManager.h"
#import "DVRCommandGenerator.h"
@interface DVRFileSetCameraTableViewController : UITableViewController <DVRSocketManagerDelegate>{
    NSMutableArray *arrayCameraName;
    NSMutableArray *arrayFileAmount;
    int cameraSerial;
    DVRSocketManager *socketManager;
}

@end
