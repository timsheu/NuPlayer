//
//  LiveViewController.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/22.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHChainableAnimations.h"
#import "PlayerManager.h"
#import "CameraInfo.h"
#import "SocketManager.h"
#import "MultipleSettingTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AudioRecorder.h"
#import "UIView+Toast.h"

#ifdef USE_DFU_RTSP_PLAYER
#import "RTSPPlayer.h"
#endif


#define TAG_OF_GESTURE 100;

@interface LiveViewController : UIViewController <UITabBarDelegate, SocketManagerDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, AudioRecorderDelegate>{
    UIColor *backgroundImage;
    NSString *resolution;
    BOOL hideUIFlag;
    BOOL hideSliderFlag;
    BOOL isFullScreen;
    BOOL hideNavigationFlag;
    BOOL isPlaying;
    BOOL redDotFlash;
    int deviceRegionDifference;
    int tagOfGesture;
    float scaleWidth, scaleHeight;
    int playerX, playerY;
    NSTimer *idleTimer;
    NSMutableArray *cameraArray;
    int activeCamSerial;
    __weak IBOutlet UIActivityIndicatorView *outletBuffering;
    NSTimer *dotTimer, *checkTimer, *playTimer;
    SocketManager *socketManager;
    NSURL *tempURL;
    UITabBar *cameraTabBar;
    NSString *passedString, *targetURL;
    float lastFrameTime;
    NSString *cameraString;
    NSThread *playerThread;
    NSString *localPath;
    float localTime;
    AudioRecorder *audioRecorder;
    dispatch_queue_t queue;
}

enum {
    TAB_CAM_1_TAG = 300,
    TAB_CAM_2_TAG,
    TAB_CAM_3_TAG,
    TAB_CAM_4_TAG
};

- (void)setupCameraString:(NSString *)string;
@property (weak, nonatomic) IBOutlet UILabel *outletOffline;

//outlet variables
@property (weak, nonatomic) IBOutlet UIButton *outletMicButton;
@property (strong, nonatomic) RTSPPlayer *video;
@property (weak, nonatomic) IBOutlet UILabel *outletFPSLabel;
@property (weak, nonatomic) IBOutlet UILabel *outletSnapshotResult;
@property (weak, nonatomic) IBOutlet UIImageView *outletRedDot;
@property (weak, nonatomic) IBOutlet UIView *outletLiveView;
@property (weak, nonatomic) IBOutlet UIView *outletPlayerControlView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *outletTapGesture;
@property (weak, nonatomic) IBOutlet UIButton *outletSnapshotButton;
@property (weak, nonatomic) IBOutlet UIButton *outletExpandButton;
@property (weak, nonatomic) IBOutlet UIButton *outletPlayButton;
@property (weak, nonatomic) IBOutlet UISlider *outletSeekSlider;
//action access point
- (IBAction)buttonSnapshot:(id)sender;
- (IBAction)buttonPlay:(id)sender;
- (IBAction)buttonExpand:(id)sender;
- (IBAction)actionOneTap:(id)sender;
- (IBAction)actionSeekTime:(id)sender;
- (IBAction)actionBackToMain:(id)sender;
- (IBAction)startRecordVoice:(id)sender;
- (IBAction)startRecordVoiceHalfDuplex:(id)sender;
@end
