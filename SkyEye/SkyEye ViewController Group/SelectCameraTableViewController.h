//
//  SelectCameraTableViewController.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/3/21.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerManager.h"
#import "LiveViewController.h"
#import "FileViewController.h"
#import "SettingViewController.h"
enum{
    LAYOUT_TAG_TITLE = 10,
    LAYOUT_TAG_CAMERANAME = 11
};

@interface SelectCameraTableViewController : UITableViewController{
    PlayerManager *playerManager;
    NSMutableArray *cameraCollection;
    NSString *targetCameraString;
}

@end
