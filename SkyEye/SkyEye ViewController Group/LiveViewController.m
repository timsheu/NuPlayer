//
//  LiveViewController.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/22.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "LiveViewController.h"

@interface LiveViewController ()

@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    hideUIFlag = NO;
    hideSliderFlag = NO;
    isFullScreen = NO;
    isPlaying = NO;
    redDotFlash = NO;
    _outletPlayButton.enabled = NO;
    _outletSnapshotButton.enabled = NO;
    deviceRegionDifference = self.view.bounds.size.width - self.view.bounds.size.height;
    if (deviceRegionDifference <= 0) {
        deviceRegionDifference = 0 - deviceRegionDifference;
    }
    [outletBuffering stopAnimating];
    _outletSeekSlider.minimumValue = 0;
    _outletSeekSlider.maximumValue = 1;
    _outletSeekSlider.value = 0;
    _outletSeekSlider.enabled = NO;
    socketManager = [SocketManager shareInstance];
    socketManager.delegate = self;
    activeCamSerial = -1;
    _outletSnapshotResult.layer.masksToBounds = YES;
    _outletSnapshotResult.layer.cornerRadius = 5.0;
    _outletSnapshotResult.alpha = 0;
    [_outletCamTabBar setHidden:YES];
    // Do any additional setup after loading the view.
    queue = dispatch_queue_create("com.dispatch.video", DISPATCH_QUEUE_SERIAL);
}

-(void)viewDidAppear:(BOOL)animated{
    UIApplication *app = [UIApplication sharedApplication];
    app.idleTimerDisabled = YES;
    if (cameraArray == nil){
        cameraArray = [[NSMutableArray alloc] initWithCapacity:4];
    }
    _outletSeekSlider.value = 0;
    _outletSeekSlider.enabled = NO;
    _outletSnapshotResult.alpha = 0;
    [_outletMicButton setImage:[UIImage imageNamed:@"mic-mute"] forState:UIControlStateNormal];
    [self initCamera:cameraString.intValue];
}

- (void)viewWillDisappear:(BOOL)animated{
    isPlaying = NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    if (hideUIFlag == YES) {
        [self dismissTabBars:NO];
    }
    UIApplication *app = [UIApplication sharedApplication];
    app.idleTimerDisabled = NO;
    [playTimer invalidate];
    playTimer = nil;
    [dotTimer invalidate];
    dotTimer = nil;
    [checkTimer invalidate];
    checkTimer = nil;
    [_video closeAudio];
    _video = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [outletBuffering stopAnimating];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)buttonSnapshot:(id)sender {
    socketManager = [SocketManager shareInstance];
    socketManager.delegate = self;
    NSString *snapshotCommand = [SkyEyeCommandGenerator generateInfoCommandWithName:@"Snapshot"];
    NSString *cameraSerial = [NSString stringWithFormat:@"Setup Camera %@", cameraString];
    [socketManager sendCommand:snapshotCommand toCamera:cameraSerial withTag:SOCKET_READ_TAG_SNAPSHOT];
}

- (IBAction)buttonPlay:(id)sender {
//    VMediaPlayer *player = [VMediaPlayer sharedInstance];
    if (isPlaying == YES) {
        isPlaying = NO;
        [_outletPlayButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [dotTimer invalidate];
        [playTimer invalidate];
        dotTimer = nil;
        playTimer = nil;
    } else {
        isPlaying = YES;
        [_outletPlayButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [self playVideoViewWithPath:targetURL seekTime:0];
    }
}

- (IBAction)buttonExpand:(id)sender {
    NSNumber *orientationNumber = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
    if (interfaceOrientation == UIInterfaceOrientationPortrait ||
        interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        isFullScreen = YES;
        [[UIDevice currentDevice] setValue:orientationNumber forKey:@"orientation"];
        [_outletExpandButton setImage:[UIImage imageNamed:@"shrink"] forState:UIControlStateNormal];
    } else {
        orientationNumber = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:orientationNumber forKey:@"orientation"];
        [_outletExpandButton setImage:[UIImage imageNamed:@"expand"] forState:UIControlStateNormal];
    }
}

- (IBAction)actionSeekTime:(id)sender {
}

- (IBAction)actionBackToMain:(id)sender {
    [[self navigationController]popToRootViewControllerAnimated:YES];
}


- (IBAction)actionOneTap:(id)sender {
    //just invert the flag
    UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
    if (interfaceOrientation != UIDeviceOrientationPortrait && interfaceOrientation != UIDeviceOrientationPortraitUpsideDown) {
        _outletTapGesture.enabled = NO;
        (hideUIFlag == YES) ? (hideUIFlag = NO) : (hideUIFlag = YES);
        [self dismissTabBars:hideUIFlag];
    }

}

- (void)idleHandleFunction{
    [self dismissSeekSlider:YES delay:(0.1) animate:(0.3)];
}

- (void)dismissSeekSlider:(BOOL)localHideSliderFlag delay:(float)delayTime animate:(float)animateTime{
    hideSliderFlag = localHideSliderFlag;
    int side = 1;
    (localHideSliderFlag == NO) ? (side = -1) : (side = 1);
}

- (void)dismissTabBars:(BOOL)localHideUIFlag{
    hideUIFlag = localHideUIFlag;
    int side = 1;//1 is up, 0 is down
    (localHideUIFlag == YES) ? (side = -1) : (side = 1);
    int uiHeightToBound = _outletCamTabBar.bounds.origin.y + _outletCamTabBar.bounds.size.height + 20;
    _outletCamTabBar.transformY(side*uiHeightToBound).easeIn.delay(0.1).animate(0.3).animationCompletion =
    JHAnimationCompletion(){
        _outletTapGesture.enabled = YES;
    };
    uiHeightToBound = self.tabBarController.tabBar.bounds.origin.y + self.tabBarController.tabBar.bounds.size.height;
    self.tabBarController.tabBar.transformY(-1*side*uiHeightToBound).easeIn.delay(0.1).animate(0.3);
    [self.navigationController setNavigationBarHidden:localHideUIFlag animated:YES];
}

- (void)orientationChange:(UIInterfaceOrientation) orientation{
    [self adjustViewForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)adjustViewForOrientation:(UIInterfaceOrientation) orientation{
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            if (hideUIFlag == NO) {
                if (isPlaying == YES) {
                    [self dismissTabBars:YES];
                }
                [_outletExpandButton setImage:[UIImage imageNamed:@"shrink"] forState:UIControlStateNormal];
                self.view.backgroundColor = [UIColor blackColor];
                isFullScreen = YES;
            }
            break;
        case UIInterfaceOrientationLandscapeRight:
            if (hideUIFlag == NO) {
                if (isPlaying == YES) {
                    [self dismissTabBars:YES];
                }
                [_outletExpandButton setImage:[UIImage imageNamed:@"shrink"] forState:UIControlStateNormal];
                self.view.backgroundColor = [UIColor blackColor];
                isFullScreen = YES;
            }
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationPortrait:
            if (hideUIFlag == YES) {
                [self dismissTabBars:NO];
            }
            if (hideSliderFlag == YES) {
                [self dismissSeekSlider:NO delay:(0.1) animate:(0.5)];
            }
            [_outletExpandButton setImage:[UIImage imageNamed:@"expand"] forState:UIControlStateNormal];
            self.view.backgroundColor = [UIColor whiteColor];
            isFullScreen = NO;
            break;
        default:
            break;
    }
}



-(void)displayLiveNextFrame:(NSTimer *)timer {
    _outletSeekSlider.value = 1;
    if (![_video stepFrame]) {
        [timer invalidate];
        [dotTimer invalidate];
        [_outletPlayButton setEnabled:YES];
        [_video closeAudio];
        return;
    }
    if (checkTimer != nil) {
        [checkTimer invalidate];
        checkTimer = nil;
    }
    _video.outputWidth = _outletLiveView.bounds.size.width;
    _video.outputHeight = _outletLiveView.bounds.size.height;
    dispatch_async(dispatch_get_main_queue(), ^{
        _outletLiveView.backgroundColor = [UIColor colorWithPatternImage:_video.currentImage];
        [_outletPlayButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        isPlaying = YES;
        [outletBuffering stopAnimating];
        _outletSeekSlider.value = _outletSeekSlider.maximumValue;
        _outletPlayButton.enabled = YES;
        _outletSnapshotButton.enabled = YES;
        [outletBuffering stopAnimating];
    });
}

- (void)initCamera:(int)cameraSerial{
    PlayerManager* manager = [PlayerManager sharedInstance];
    NSString *string = [NSString stringWithFormat:@"Setup Camera %d", cameraSerial];
    NSMutableDictionary *dic = manager.dictionarySetting;
    NSMutableDictionary *cameraDic = [dic objectForKey:string];
    NSString *url = [cameraDic objectForKey:@"URL"];
    [outletBuffering startAnimating];
    targetURL = url;
    @try {
        [checkTimer invalidate];
        checkTimer = nil;
        [self playVideoViewWithPath:targetURL seekTime:0];
    }
    @catch (NSException *exception) {
        NSLog(@"set data source failed");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Not Stable" message:@"Please Check Internet Connection and try again." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    _outletSeekSlider.enabled = NO;
    _outletSeekSlider.value = 0;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    NSString *string = @"EditCameraSegue";
    passedString = [NSString stringWithFormat:@"Setup Camera %d", (int)cameraTabBar.selectedItem.tag + 1 - 300];
    [self performSegueWithIdentifier:string sender:self];
    return YES;
}

-(void)flashRedDot{
    NSString *string = [[NSString alloc] init];
    (redDotFlash == YES) ? (string = @"flashOn", redDotFlash = NO) : (string = @"flashOff", redDotFlash = YES);
    [_outletRedDot setImage:[UIImage imageNamed:string]];
}

-(void)downloadFileList{
    socketManager = [SocketManager shareInstance];
    PlayerManager *playerManager = [PlayerManager sharedInstance];
    int i=0;
    NSString *key = [NSString stringWithFormat:@"Setup Camera %d", i+1];
    NSDictionary *dic = [playerManager.dictionarySetting objectForKey:key];
    NSString *url = [dic objectForKey:@"URL"];
    NSArray *split = [url componentsSeparatedByString:@"/"];
    NSString *category = @"File List";
    NSLog(@"split: %@", split);
    NSDictionary *commmandDic = [NSDictionary dictionaryWithObjectsAndKeys:key, @"Camera", @"Download File List", @"Category", @"N/A", @"Value", nil];
    NSString *command = [SkyEyeCommandGenerator generateSettingCommandWithDictionary:commmandDic];
    [socketManager setTag:SOCKET_READ_TAG_CAMERA_1 commandCategory:category];
    [socketManager sendCommand:command toCamera:key withTag:i+SOCKET_READ_TAG_CAMERA_OFFSET+1];
    socketManager.delegate = self;
}

-(void)downloadFileListFromCamera:(int)serial{
    NSString *category = @"File List";    
    socketManager = [SocketManager shareInstance];
    PlayerManager *playerManager = [PlayerManager sharedInstance];
    NSString *key = [NSString stringWithFormat:@"Setup Camera %d", serial-SOCKET_READ_TAG_CAMERA_OFFSET];
    NSDictionary *dic = [playerManager.dictionarySetting objectForKey:key];
    NSString *url = [dic objectForKey:@"URL"];
    NSArray *split = [url componentsSeparatedByString:@"/"];
    NSLog(@"split: %@", split);
    NSDictionary *commmandDic = [NSDictionary dictionaryWithObjectsAndKeys:key, @"Camera", @"Download File List", @"Category", @"N/A", @"Value", nil];
    NSString *command = [SkyEyeCommandGenerator generateSettingCommandWithDictionary:commmandDic];
    [socketManager setTag:serial commandCategory:category];
    [socketManager sendCommand:command toCamera:key withTag:serial];
}

-(void)getDeviceInformation:(int)tag{
    socketManager = [SocketManager shareInstance];
    NSString *key = @"Setup Camera 1";
    NSString *category;
    NSString *command;
    if (tag == SOCKET_READ_TAG_INFO_STATUS) {
        category = @"Recorder Status";
        command = [SkyEyeCommandGenerator generateInfoCommandWithName:category];
        [socketManager setTag:SOCKET_READ_TAG_INFO_STATUS commandCategory:category];
        [socketManager sendCommand:command toCamera:key withTag:SOCKET_READ_TAG_INFO_STATUS];
    }else {
        category = @"Available Storage";
        command = [SkyEyeCommandGenerator generateInfoCommandWithName:category];
        [socketManager setTag:SOCKET_READ_TAG_INFO_STORAGE commandCategory:category];
        [socketManager sendCommand:command toCamera:key withTag:SOCKET_READ_TAG_INFO_STORAGE];
    }
}


#pragma delegate

- (void)hostNotResponse:(int)serial command:(NSString *)command{
    if (serial <= SOCKET_READ_TAG_CAMERA_4 && serial >= SOCKET_READ_TAG_CAMERA_1) {
        NSString *commandCameraName = [NSString stringWithFormat:@"Setup Camera %d", serial-SOCKET_READ_TAG_CAMERA_OFFSET+1];
        [socketManager sendCommand:command toCamera:commandCameraName withTag:serial+1];
    }
}

- (void)hostResponse{
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    MultipleSettingTableViewController *dest = (MultipleSettingTableViewController *)[segue destinationViewController];
    [dest setString:passedString];
}

- (void)snapshotResult:(int)result{
    _outletSnapshotResult.alpha = 1;
    if (result == 0) { // 0 for success
        _outletSnapshotResult.text = @"Snapshot Success!!";
//        _outletSnapshotResult.makeOpacity(0).easeIn.animate(1.5);
    } else if (result == 1){
        _outletSnapshotResult.text = @"Snapshot Failed.";
//        _outletSnapshotResult.makeOpacity(0).easeIn.animate(1.5);
    }
    [UIView animateWithDuration:4.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{_outletSnapshotResult.alpha = 0;} completion:nil];
}


-(void)playVideoViewWithPath:(NSString *)path seekTime:(float)time{
    [outletBuffering startAnimating];
    [_outletPlayButton setEnabled:NO];
    [_outletSeekSlider setEnabled:NO];
    [playTimer invalidate];
    _video = nil;
    
    localPath = path;
    localTime = time;
    [self isDeviceAlive];
}

- (void)setupCameraString:(NSString *)string{
    cameraString = [NSString stringWithString:string];
}

- (void)streamNotResponse{
    [self stopVideo];
    [self initCamera:cameraString.intValue];
}

- (void)stopVideo{
    [_video closeAudio];
    _video = nil;
    [playTimer invalidate];
    playTimer = nil;
    [dotTimer invalidate];
    dotTimer = nil;
    [checkTimer invalidate];
    checkTimer = nil;
    [outletBuffering stopAnimating];
}

- (void)isDeviceAlive{
    socketManager = [SocketManager shareInstance];
    socketManager.delegate = self;
    NSString *command;
    NSString *category;
    category = @"Recorder Status";
    command = [SkyEyeCommandGenerator generateInfoCommandWithName:category];
    [socketManager sendCommand:command toCamera:[NSString stringWithFormat:@"Setup Camera %d", cameraString.intValue] withTag:SOCKET_READ_TAG_INFO_STATUS];
    checkTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(streamNotResponse) userInfo:nil repeats:NO];
}

- (void)updateCameraSettings{
    _outletOffline.text = @"ONLINE";
    [checkTimer invalidate];
    checkTimer = nil;
    BOOL useTCPFlag = NO;
    PlayerManager *manager = [PlayerManager sharedInstance];
    NSDictionary *dic = [manager.dictionarySetting objectForKey:[NSString stringWithFormat:@"Setup Camera %d", cameraString.intValue]];
    NSString *transmissionString = [dic objectForKey:@"Transmission"];
    if ([transmissionString isEqualToString:@"TCP"]) {
        useTCPFlag = YES;
    }
    _video = [[RTSPPlayer alloc] initWithVideo:localPath usesTcp:useTCPFlag];
    if (_video == nil) {
        [self stopVideo];
        return;
    }
    _video.outputWidth = _outletLiveView.bounds.size.width;
    _video.outputHeight = _outletLiveView.bounds.size.height;
    
    lastFrameTime = -1;
    
    // seek to 0.0 seconds
    [_video seekTime:localTime];
    _outletSeekSlider.value = 0;
    _outletSeekSlider.maximumValue = _video.duration;
    _outletSeekSlider.minimumValue = 0;
    
    isPlaying = YES;
    //	float nFrame = 1.0/10;
    // fps
    // nFrame for China: 25 frame per second
    // palFrame: 30 frame per second
    float palFrame = 1.0/30; // PAL Mode
    dotTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(flashRedDot) userInfo:nil repeats:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            while (isPlaying) {
            [self displayLiveNextFrame:nil];
            [NSThread sleepForTimeInterval:palFrame];
        }
    });
//    playTimer = [NSTimer scheduledTimerWithTimeInterval:palFrame
//                                                 target:self
//                                               selector:@selector(displayLiveNextFrame:)
//                                               userInfo:nil
//                                                repeats:YES];
//    
//    isPlaying = NO;
}

- (void)startRecordVoice:(id)sender{
    audioRecorder = [AudioRecorder sharedInstance];
    audioRecorder.delegate = self;
    audioRecorder.cameraSerial = [NSString stringWithFormat:@"Setup Camera %@", cameraString];
    if ([audioRecorder isRecording]) {
        [audioRecorder stopRecording];
//        [audioRecorder stopPlayback];
        [_outletMicButton setImage:[UIImage imageNamed:@"mic-mute"] forState:UIControlStateNormal];
    }else{
        [audioRecorder startRecording];
//        [audioRecorder startPlayback];
        [_outletMicButton setImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
    }
}

- (void)audioDataInCommand:(NSData *)data{
//    NSLog(@"Live view, audio data in command: %@", data);
    NSString *cameraSerial = [NSString stringWithFormat:@"Setup Camera %@", cameraString];
    socketManager = [SocketManager shareInstance];
    [socketManager sendCommandData:data toCamera:cameraSerial withTag:SOCKET_UPLOAD_AUDIO_STREAM];
}

@end
