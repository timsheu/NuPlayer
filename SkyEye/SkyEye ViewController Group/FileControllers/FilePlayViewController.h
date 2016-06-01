//
//  FilePlayViewController.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/22.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerManager.h"
#import "SocketManager.h"
#import "RTSPPlayer.h"
enum{
    ALERT_TAG_EARLY_STOP = 0,
};
@interface FilePlayViewController : UIViewController <UIAlertViewDelegate>{
    BOOL isNavigationHide;
    BOOL isFullScreen;
    NSString *targetVideoPath;
    NSDictionary *targetDevice;
    BOOL isPlaying;
    float currentDuration;
    NSTimer *sliderTimer;
    NSTimer *playTimer;
    float lastSliderValue, lastFrameTime;
}
@property (strong, nonatomic) RTSPPlayer *video;
@property (weak, nonatomic) IBOutlet UILabel *outletFPSLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *outletWaiting;
@property (weak, nonatomic) IBOutlet UIView *outletPlayView;
@property (weak, nonatomic) IBOutlet UIButton *outletExpandButton;
@property (weak, nonatomic) IBOutlet UIButton *outletPlayButton;
@property (weak, nonatomic) IBOutlet UISlider *outletSeekSlider;
@property (weak, nonatomic) IBOutlet UILabel *outletTimeLabel;
- (IBAction)buttonPlay:(id)sender;
- (IBAction)buttonExpand:(id)sender;
- (IBAction)actionOneTap:(id)sender;
- (IBAction)actionSeekTime:(id)sender;
- (IBAction)actionBackToMain:(id)sender;
- (IBAction)sliderTouchUp:(id)sender;
- (IBAction)sliderTouchDown:(id)sender;
- (void)setVideoPath:(NSString *)string;
- (void)setDevice:(NSDictionary *)dictionary;
@end
