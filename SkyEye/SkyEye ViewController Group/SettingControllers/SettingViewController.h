//
//  SettingViewController.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/22.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingCatagoryCellPrototype.h"
#import "SettingItemCellPrototype.h"
#import "SocketManager.h"
#import "SkyEyeCommandParser.h"
#import "CommandPool.h"
#import "MultipleSettingTableViewController.h"
#import "SettingDetailViewController.h"
#import "WiFiInfo.h"
#import "SettingPool.h"
#import "MultipleSettingTableViewController.h"
enum{
    VIDEO_SECTION = 0,
//    AUDIO_SECTION,
    WIRELESS_SECTION,
//    INFO_SECTION, 
    SETTING_SECTION_IMAGE_TAG = 100,
    SETTING_SECTION_LABEL_TAG,
    SETTING_ITEM_LABEL_TAG,
    SETTING_CURRENT_SETTING_TAG,
};


@interface SettingViewController : UITableViewController <UITextInputDelegate, MultipleSettingTableViewControllerDelegate>{
    SkyEyeCommandParser *parser;
    CommandPool *pool;
    NSMutableArray *passedArray;
    NSArray *cameraAddress;
    NSString *passedString, *indexOfDetail;
    UILabel *detailLabel;
    NSString *cameraString;
}

@property (nonatomic, strong) NSArray *settingCatagoryArray;
@property (nonatomic, strong) NSArray *settingItemVideoArray;
@property (nonatomic, strong) NSArray *settingItemAudioArray;
@property (nonatomic, strong) NSArray *settingItemWirelessArray;
@property (nonatomic, strong) NSArray *settingItemInfoArray;
@property (nonatomic, strong) NSArray *settingDefaultArray;

- (void)setupCameraString:(NSString *)string;
@end
