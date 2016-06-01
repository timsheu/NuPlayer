//
//  DVRFilePlayViewController.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/22.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVRCommandParser.h"
#import "DVRPlayerManager.h"
#import "DVRSocketManager.h"
#import "RTSPPlayer.h"
enum{
    ALERT_TAG_EARLY_STOP = 0,
};
@interface DVRFilePlayViewController : UIViewController <UIAlertViewDelegate, DVRSocketManagerDelegate>{
    BOOL isNavigationHide;
    BOOL isFullScreen;
    DVRCommandParser *parser;
    NSString *targetVideoPath;
    NSDictionary *targetDevice;
    BOOL isPlaying;
    float currentDuration;
    NSTimer *sliderTimer, *playTimer;
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
