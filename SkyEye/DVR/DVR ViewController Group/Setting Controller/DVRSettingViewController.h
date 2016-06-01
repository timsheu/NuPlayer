//
//  DVRSettingViewController.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/22.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVRSettingCatagoryCellPrototype.h"
#import "DVRSettingItemCellPrototype.h"
#import "DVRSocketManager.h"
#import "DVRCommandParser.h"
#import "DVRCommandPool.h"
#import "DVRMultipleSettingTableViewController.h"
#import "DVRWiFiInfo.h"
#import "DVRSettingPool.h"
#import "DVRMultipleSettingTableViewController.h"
enum{
    VIDEO_SECTION = 0,
    AUDIO_SECTION,
    WIRELESS_SECTION,
    INFO_SECTION, 
    SETTING_SECTION_IMAGE_TAG = 100,
    SETTING_SECTION_LABEL_TAG,
    SETTING_ITEM_LABEL_TAG,
    SETTING_CURRENT_SETTING_TAG,
};


@interface DVRSettingViewController : UITableViewController <UITextInputDelegate, DVRMultipleSettingTableViewControllerDelegate>{
    DVRCommandParser *parser;
    DVRCommandPool *pool;
    NSMutableArray *passedArray;
    NSArray *cameraAddress;
    NSString *passedString, *indexOfDetail;
    UILabel *detailLabel;
}

@property (nonatomic, strong) NSArray *settingCatagoryArray;
@property (nonatomic, strong) NSArray *settingItemVideoArray;
@property (nonatomic, strong) NSArray *settingItemAudioArray;
@property (nonatomic, strong) NSArray *settingItemWirelessArray;
@property (nonatomic, strong) NSArray *settingItemInfoArray;
@property (nonatomic, strong) NSArray *settingDefaultArray;


@end
