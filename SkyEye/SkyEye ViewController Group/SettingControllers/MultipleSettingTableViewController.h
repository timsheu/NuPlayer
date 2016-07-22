//
//  MultipleSettingTableViewController.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/16.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraInfo.h"
#import "PlayerManager.h"
#import "WiFiInfo.h"
#import "SocketManager.h"
#import "SkyEyeCommandGenerator.h"
#import "SocketManager.h"
#import "QRCodeViewController.h"
#import "QRCodeGenerator.h"
#import "HistoryTableView.h"
#import "HistoryPickerView.h"
#import <MessageUI/MessageUI.h>
@import SystemConfiguration.CaptiveNetwork;
@class MultipleSettingTableViewController;
@protocol MultipleSettingTableViewControllerDelegate <NSObject>

- (void)updateDetailLabel:(NSString *)string;

@end
#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]
@interface MultipleSettingTableViewController : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate, SocketManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MFMailComposeViewControllerDelegate>{
    MFMailComposeViewController *mailComposer;
    NSString *receivedString;
    NSArray *receivedArray;
    NSString *receivedCategory;
    UILabel *labelQualityValue, *labelBitRateValue, *labelFPSValue;
    UISlider *sliderQuality, *sliderFPS;
    UITextField *textfieldName, *textfieldURL, *textfieldSSID, *textfieldPASS, *textfieldPort;
    UISegmentedControl *controlResolution, *controlDeviceMute, *controlPhoneMute, *controlAdaptive, *controlTransmission, *controlFixedBitrate, *controlFixedQuality;
    UIButton *rebootButton, *resetButton, *qrButton, *sendReportButton;
    UIStepper *stepperBitRate;
    NSString *sliderSavedValue;
    NSString *qrCodeString;
    NSMutableArray *historyArray;
    CGRect historyFrame;
    int rowOfTable;
    int sectionOfTable;
    BOOL rebootAnnounce;
}
- (IBAction)stepperValueChange:(id)sender;
- (void)setupArray:(NSArray *)array forCategory:(NSString *)category;
- (IBAction)sliderValueChange:(id)sender;
- (IBAction)sliderTouchUpInside:(id)sender;
- (IBAction)segmentsValueChange:(id)sender;
- (IBAction)rebootButtonAction:(id)sender;
- (IBAction)qrButtonAction:(id)sender;
- (void)setString:(NSString *)string;
@property (strong, nonatomic) IBOutlet UIPickerView *historyPicker;
@property (strong, nonatomic) id <MultipleSettingTableViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@end
