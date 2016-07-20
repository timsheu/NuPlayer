//
//  DVRMultipleSettingTableViewController.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/16.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVRCameraInfo.h"
#import "DVRPlayerManager.h"
#import "DVRWiFiInfo.h"
#import "DVRSocketManager.h"
#import "DVRCommandGenerator.h"
#import "DVRSocketManager.h"
#import "DVRQRCodeViewController.h"
#import "QRCodeGenerator.h"

@import SystemConfiguration.CaptiveNetwork;
@class DVRMultipleSettingTableViewController;
@protocol DVRMultipleSettingTableViewControllerDelegate <NSObject>

- (void)updateDetailLabel:(NSString *)string;

@end
@interface DVRMultipleSettingTableViewController : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate, DVRSocketManagerDelegate>{
    NSString *receivedString;
    NSArray *receivedArray;
    NSString *receivedCategory;
    UILabel *labelQualityValue, *labelBitRateValue, *labelFPSValue;
    UISlider *sliderQuality, *sliderFPS;
    UITextField *textfieldName, *textfieldURL, *textfieldSSID, *textfieldPASS, *textfieldPort;
    UISegmentedControl *controlResolution, *controlDeviceMute, *controlPhoneMute, *controlRecording;
    UIButton *rebootButton, *resetButton, *qrButton;
    UIStepper *stepperBitRate;
    NSString *sliderSavedValue;
    NSString *qrCodeString;
    NSMutableArray *historyArray;
    DVRSocketManager *socketManager;
    int rowOfTable;
    int sectionOfTable;
}
- (IBAction)stepperValueChange:(id)sender;
- (void)setupArray:(NSArray *)array forCategory:(NSString *)category;
- (IBAction)sliderValueChange:(id)sender;
- (IBAction)sliderTouchUpInside:(id)sender;
- (IBAction)segmentsValueChange:(id)sender;
- (IBAction)rebootButtonAction:(id)sender;
- (IBAction)qrButtonAction:(id)sender;
- (void)setString:(NSString *)string;
@property (weak, nonatomic) IBOutlet UIPickerView *historyPicker;
@property (strong, nonatomic) id <DVRMultipleSettingTableViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@end
