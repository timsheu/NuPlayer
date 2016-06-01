//
//  DVRFilePlayViewController.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/22.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "DVRFilePlayViewController.h"

@interface DVRFilePlayViewController ()

@end

@implementation DVRFilePlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    isNavigationHide = NO;
    isFullScreen = NO;
    isPlaying = NO;
    _outletSeekSlider.value = 0;
    _outletSeekSlider.enabled = NO;
    _outletPlayButton.enabled = NO;
    [_outletWaiting setHidden:NO];
    [_outletWaiting startAnimating];
    [self setupVideoContent];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    UIApplication *app = [UIApplication sharedApplication];
    app.idleTimerDisabled = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    _outletSeekSlider.value = 0;
    _outletSeekSlider.enabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    UIApplication *app = [UIApplication sharedApplication];
    app.idleTimerDisabled = NO;
    isPlaying = NO;
    [_video closeAudio];
    _video = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)setupVideoContent{
    NSString *videoPathAttach = @"file/";
    NSString *videoPath = [targetDevice objectForKey:@"URL"];
    NSArray *videoPathSplit = [videoPath componentsSeparatedByString:@"/"];
    NSString *videoPathTemp = @"";
    if (videoPathSplit.count != 1) {
        for (int i=0; i<videoPathSplit.count-2; i++) {
            videoPathTemp = [videoPathTemp stringByAppendingString:[videoPathSplit objectAtIndex:i]];
            videoPathTemp = [videoPathTemp stringByAppendingString:@"/"];
        }
    }else{
        videoPathTemp = @"rtsp://";
        videoPathTemp = [videoPathTemp stringByAppendingString:[videoPathSplit objectAtIndex:0]];
    }
    videoPath = [[videoPathTemp stringByAppendingString:videoPathAttach] stringByAppendingString:targetVideoPath];
    targetVideoPath = videoPath;
//    float seekTime = 0;
//    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:targetVideoPath, @"path", seekTime, @"time", nil];
//    [NSThread detachNewThreadSelector:@selector(playVideoViewWithPath:seekTime:) toTarget:self withObject:params];
    [self playVideoViewWithPath:targetVideoPath seekTime:0];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)actionOneTap:(id)sender{
    (isNavigationHide == YES) ? (isNavigationHide = NO) : (isNavigationHide = YES);
    [[self navigationController] setNavigationBarHidden:isNavigationHide animated:YES];
}

-(IBAction)actionBackToMain:(id)sender{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)buttonPlay:(id)sender{
    if (isPlaying == YES) {
        [_outletPlayButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        if (isPlaying) {
            isPlaying = NO;
        }
        [_video closeAudio];
        [playTimer invalidate];
        [sliderTimer invalidate];
        currentDuration = _outletSeekSlider.value;
    } else {
        [_outletPlayButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        if (currentDuration == _outletSeekSlider.maximumValue) {
            currentDuration = 0;
        }
        [self playVideoViewWithPath:targetVideoPath seekTime:currentDuration];
    }
}
- (IBAction)buttonExpand:(id)sender{
    NSNumber *orientationNumber = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
    if (interfaceOrientation == UIInterfaceOrientationPortrait ||
        interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        isFullScreen = YES;
        [[UIDevice currentDevice] setValue:orientationNumber forKey:@"orientation"];
        [_outletExpandButton setImage:[UIImage imageNamed:@"shrink"] forState:UIControlStateNormal];
        [self.view setBackgroundColor:[UIColor blackColor]];
    } else {
        orientationNumber = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:orientationNumber forKey:@"orientation"];
        [_outletExpandButton setImage:[UIImage imageNamed:@"expand"] forState:UIControlStateNormal];
        [self.view setBackgroundColor:[UIColor whiteColor]];
    }
}

-(void)setDevice:(NSDictionary *)dictionary{
    targetDevice = [NSDictionary dictionaryWithDictionary:dictionary];
}

-(void)setVideoPath:(NSString *)string{
    targetVideoPath = [NSString stringWithString:string];
}

- (void)sliderTouchUp:(id)sender{
    UISlider *slider = (UISlider *)sender;
    currentDuration = slider.value;
    [self performSelector:@selector(jumpToPosition) withObject:nil afterDelay:.3];
}

- (void)jumpToPosition{
    [self playVideoViewWithPath:targetVideoPath seekTime:currentDuration];
}

- (IBAction)actionSeekTime:(id)sender{
    if (isPlaying) {
        isPlaying = NO;
    }
    [_video closeAudio];
    [playTimer invalidate];
    [sliderTimer invalidate];
    UISlider *slider = (UISlider *)sender;
    currentDuration = slider.value;
}

#pragma ffmpeg action
-(void)displayNextFrame:(NSTimer *)timer {
//    NSLog(@"%f, %f", currentDuration, _outletSeekSlider.maximumValue);
    [_outletSeekSlider setEnabled:YES];
    [_outletPlayButton setEnabled:YES];
    if (![_video stepFrame] || currentDuration == _outletSeekSlider.maximumValue) {
        [self stopVideo];
        [self changeTime:_outletSeekSlider.maximumValue];
        [_outletPlayButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_outletPlayButton setEnabled:YES];
        _outletSeekSlider.value = _outletSeekSlider.maximumValue;
        return;
    }
    currentDuration = _outletSeekSlider.value;
    _video.outputWidth = _outletPlayView.bounds.size.width;
    _video.outputHeight = _outletPlayView.bounds.size.height;
    
    _outletPlayView.backgroundColor = [UIColor colorWithPatternImage:_video.currentImage];
    [_outletPlayButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    isPlaying = YES;
    [_outletWaiting stopAnimating];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case ALERT_TAG_EARLY_STOP:
            if (buttonIndex == 1) {
                [self setupVideoContent];
            }
            break;
        default:
            break;
    }
}

-(void)playVideoViewWithPath:(NSString *)path seekTime:(float)time{
    [_outletWaiting startAnimating];
    [_outletPlayButton setEnabled:NO];
    [_outletSeekSlider setEnabled:NO];
    [playTimer invalidate];
    _video = nil;
    _video = [[RTSPPlayer alloc] initWithVideo:path usesTcp:NO];
    _video.outputWidth = _outletPlayView.bounds.size.width;
    _video.outputHeight = _outletPlayView.bounds.size.height;

    lastFrameTime = -1;
    
    // seek to 0.0 seconds
    [_video seekTime:time];
    
    _outletSeekSlider.maximumValue = _video.duration - 1;
    _outletSeekSlider.value = time;
    _outletSeekSlider.minimumValue = 0;

    
    //	float nFrame = 1.0/10;
    // fps
    // nFrame for China: 25 frame per second
    // palFrame: 30 frame per second
    float palFrame = 1.0/30; // PAL Mode
//    @autoreleasepool {
        playTimer = [NSTimer scheduledTimerWithTimeInterval:palFrame
                                                     target:self
                                                   selector:@selector(displayNextFrame:)
                                                   userInfo:nil
                                                    repeats:YES];
//        [[NSRunLoop currentRunLoop] addTimer:playTimer forMode:NSDefaultRunLoopMode];
        sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                       target:self
                                                     selector:@selector(sliderTimerAction)
                                                     userInfo:nil
                                                      repeats:YES];
//        [[NSRunLoop currentRunLoop] addTimer:sliderTimer forMode:NSDefaultRunLoopMode];
//        [NSRunLoop currentRunLoop];
//    }
    isPlaying = NO;
}

- (void)sliderTimerAction{
    _outletSeekSlider.value += 1;
    [self changeTime:_outletSeekSlider.value];
    NSLog(@"%f, %f", _outletSeekSlider.maximumValue, _outletSeekSlider.value);
}

- (void)changeTime:(float)value{
    if (_outletSeekSlider != nil) {
        int min = (int)value/60;
        int sec = (int)value%60;
        _outletTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", min, sec];
    }
}

- (void)stopVideo{
    [_video closeAudio];
    _video = nil;
    [playTimer invalidate];
    playTimer = nil;
    [sliderTimer invalidate];
    sliderTimer = nil;
}

- (void)orientationChange:(UIInterfaceOrientation) orientation{
    [self adjustViewForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)adjustViewForOrientation:(UIInterfaceOrientation) orientation{
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            [_outletExpandButton setImage:[UIImage imageNamed:@"shrink"] forState:UIControlStateNormal];
            self.view.backgroundColor = [UIColor blackColor];
            isFullScreen = YES;
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            break;
        case UIInterfaceOrientationLandscapeRight:
            [_outletExpandButton setImage:[UIImage imageNamed:@"shrink"] forState:UIControlStateNormal];
            self.view.backgroundColor = [UIColor blackColor];
            isFullScreen = YES;
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationPortrait:
            [_outletExpandButton setImage:[UIImage imageNamed:@"expand"] forState:UIControlStateNormal];
            self.view.backgroundColor = [UIColor whiteColor];
            isFullScreen = NO;
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            break;
        default:
            break;
    }
}


@end
