//
//  DVRMultipleSettingTableViewController.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/16.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "DVRMultipleSettingTableViewController.h"

@interface DVRMultipleSettingTableViewController ()

@end

@implementation DVRMultipleSettingTableViewController
@synthesize labelTitle = _labelTitle;
- (void)viewDidLoad {
    [super viewDidLoad];
    [_historyPicker setHidden:YES];
    sectionOfTable = 1;
    if ([receivedString isEqualToString:@"Setup DVR"]) {
        rowOfTable = 6;
    } else if ([receivedString isEqualToString:@"Wi-Fi AP Setup"]){
        rowOfTable = 3;
    } else if ([receivedString isEqualToString:@"Device Mic"] ||
               [receivedString isEqualToString:@"Phone Mic"]){
    	rowOfTable = 1;
    } else if ([receivedString isEqualToString:@"Device Information"]){
        rowOfTable = (int)receivedArray.count - 1;
    }
    _labelTitle.text = receivedString;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidDisappear:(BOOL)animated{
    [self updateAllSettingData];
    BOOL update = [[DVRPlayerManager sharedInstance] updateSettingPropertyList];
    NSLog(@"update result: %@", ((update == YES) ? @"Success!" : @"Failed...") );
}

-(void)viewDidAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    socketManager = [DVRSocketManager shareInstance];
    socketManager.delegate = self;
    [self getDeviceInformation:SOCKET_READ_TAG_INFO_STORAGE];
    DVRPlayerManager *manager = [DVRPlayerManager sharedInstance];
    NSDictionary *cameraDic = [manager.dictionarySetting objectForKey:receivedString];
    historyArray = [NSMutableArray arrayWithObject:@"History Records"];
    [historyArray addObjectsFromArray:[cameraDic objectForKey:@"History"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sectionOfTable;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return rowOfTable;
}

- (void)setupString:(NSString *)string forType:(NSString *)type{
    [_labelTitle setText:string];
}

-(void)setupArray:(NSArray *)array forCategory:(NSString *)category{
    receivedArray = [NSArray arrayWithArray:array];
    receivedString = [NSString stringWithString:category];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    NSString *defaultString = @"Default";
    UILabel *label = (UILabel *) [cell viewWithTag:10];
    UITextField *textfield = (UITextField *) [cell viewWithTag:11];
    UISegmentedControl *control = (UISegmentedControl *)[cell viewWithTag:12];
    UISlider *slider = (UISlider *)[cell viewWithTag:13];
    UILabel *labelValue = (UILabel *) [cell viewWithTag:14];
    UIStepper *stepper = (UIStepper *)[cell viewWithTag:15];
    UIButton *button = (UIButton *)[cell viewWithTag:16];
    UILabel *labelInfo = (UILabel *)[cell viewWithTag:17];
    UIButton *buttonQR = (UIButton *)[cell viewWithTag:18];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    for (int i=10; i<19; i++){
        UIControl *ui = [cell viewWithTag:i];
        [ui setHidden:YES];
    }
    NSString *temp;
    if ( [receivedString isEqualToString:@"Setup DVR"]) {
        DVRPlayerManager *manager = [DVRPlayerManager sharedInstance];
        NSString *url = [manager.dictionarySetting objectForKey:@"URL"];
        NSString *key;
        key = @"0";
        NSMutableDictionary *dic = [manager.dictionarySetting objectForKey:receivedString];
        UIButton *buttonHistory;
        switch (indexPath.row) {
            case 0: //name
                [label setHidden:NO];
                [textfield setHidden:NO];
                label.text = @"Name";
                textfieldName = textfield;
                temp = [NSString stringWithString:[dic objectForKey:@"Name"]];
                textfieldName.text = temp;
                break;
            case 1: //url
                [label setHidden:NO];
                [textfield setHidden:NO];
                label.text = @"URL Address";
                textfieldURL = textfield;
                textfieldURL.text = [dic objectForKey:@"URL"];
                [textfieldURL setRightViewMode:UITextFieldViewModeAlways];
                buttonHistory = [UIButton buttonWithType:UIButtonTypeInfoLight];
                buttonHistory.contentMode = UIViewContentModeCenter;
                [buttonHistory addTarget:self action:@selector(showHistoryPicker) forControlEvents:UIControlEventTouchDown];
                [buttonHistory setImage:[UIImage imageNamed:@"signature"] forState:UIControlStateNormal];
//                textfieldURL.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qr-code"]];
                textfieldURL.rightView = buttonHistory;
                break;
            case 2: //port
                [label setHidden:NO];
                [textfield setHidden:NO];
                label.text = @"Port";
                textfieldPort = textfield;
                temp = [NSString stringWithString:[dic objectForKey:@"port"]];
                textfieldPort.text = temp;
                break;
            case 3: //resolution
                [label setHidden:NO];
                [control setHidden:NO];
                label.text = @"Resolution";
                controlResolution = control;
                [controlResolution setTitle:@"QVGA" forSegmentAtIndex:0];
                [controlResolution setTitle:@"VGA" forSegmentAtIndex:1];
                [controlResolution setTitle:@"720p" forSegmentAtIndex:2];
                [controlResolution setTitle:@"1080p" forSegmentAtIndex:3];
                temp = [NSString stringWithString:[dic objectForKey:@"Resolution"]];
                [controlResolution setSelectedSegmentIndex:temp.intValue];
                break;
            case 4: //fps
                [label setHidden:NO];
                [labelValue setHidden:NO];
                [slider setHidden:NO];
                labelFPSValue = labelValue;
                label.text = @"FPS";
                sliderFPS = slider;
                sliderFPS.minimumValue = 1;
                sliderFPS.maximumValue = 30;
                temp = [NSString stringWithString:[dic objectForKey:@"FPS"]];
                sliderFPS.value = (float)temp.intValue;
                labelFPSValue.text = [NSString stringWithFormat:@"%d", (int)sliderFPS.value];
                break;
            case 5: // is recording
                [label setHidden:NO];
                [control setHidden:NO];
                label.text = @"Record Status";
                controlRecording = control;
                [controlRecording removeSegmentAtIndex:3 animated:NO];
                [controlRecording removeSegmentAtIndex:2 animated:NO];
                [controlRecording setTitle:@"Stop" forSegmentAtIndex:0];
                [controlRecording setTitle:@"Start" forSegmentAtIndex:1];
                temp = [NSString stringWithString:[dic objectForKey:@"Recording"]];
                controlRecording.selectedSegmentIndex = temp.intValue;
                break;
            default:
                break;
        }
    } else if ( [receivedString isEqualToString:@"Wi-Fi AP Setup"]){
        [label setHidden:NO];
        [textfield setHidden:NO];
        DVRPlayerManager *manager = [DVRPlayerManager sharedInstance];
        NSMutableDictionary *dic = manager.dictionaryWiFiSetup;
        if (dic == nil) {
            NSString *SSID = @"Sky Eye";
            NSString *PASS = @"12345678";
            [dic setObject:SSID forKey:@"AP_SSID"];
            [dic setObject:PASS forKey:@"AP_AUTH_KEY"];
        }
        if (indexPath.row == 0) {
            label.text = @"SSID";
            textfieldSSID = textfield;
            [textfieldSSID setEnabled:NO];
            NSDictionary *ssidDic = [self getSSID];
            textfieldSSID.text = [ssidDic objectForKey:@"SSID"];
        } else if(indexPath.row == 1){
            label.text = @"Password";
            textfieldPASS = textfield;
            textfieldPASS.text = @"12345678";
        } else if(indexPath.row == 2){
            [textfield setHidden:YES];
            [label setHidden:YES];
            [buttonQR setHidden:NO];
            qrButton = buttonQR;
        }
    } else if ( [receivedString isEqualToString:@"Device Mic"]){
        DVRPlayerManager *manager = [DVRPlayerManager sharedInstance];
        [label setHidden:NO];
        [control setHidden:NO];
        [control removeSegmentAtIndex:3 animated:NO];
        [control removeSegmentAtIndex:2 animated:NO];
        NSDictionary *dic = [manager.dictionarySetting objectForKey:receivedString];
        NSString *mute = (NSString *)[dic objectForKey:@"Mute"];
        if (indexPath.row == 0) {
            int index = 0;
            ([mute isEqualToString:@"ON"]) ? (index = 0) : (index = 1);
            controlDeviceMute = control;
            [controlDeviceMute setSelectedSegmentIndex:index];
            label.text = @"Device Mic";
        }
    } else if ([receivedString isEqualToString:@"Phone Mic"]){
        DVRPlayerManager *manager = [DVRPlayerManager sharedInstance];
        [label setHidden:NO];
        [control setHidden:NO];
        [control removeSegmentAtIndex:3 animated:NO];
        [control removeSegmentAtIndex:2 animated:NO];
        NSDictionary *dic = [manager.dictionarySetting objectForKey:receivedString];
        NSString *mute = (NSString *)[dic objectForKey:@"Mute"];
        if (indexPath.row == 0) {
            int index = 0;
            ([mute isEqualToString:@"ON"]) ? (index = 0) : (index = 1);
            controlPhoneMute = control;
            [controlPhoneMute setSelectedSegmentIndex:index];
            label.text = @"Phone Mic";
        }
    } else if ([receivedString isEqualToString:@"Device Information"]){
        DVRPlayerManager *manager = [DVRPlayerManager sharedInstance];
        [label setHidden:NO];
        NSDictionary *dic = [manager.dictionarySetting objectForKey:@"Setup DVR"];
        NSDictionary *deviceDic = [dic objectForKey:@"Device Info"];
        if (indexPath.row == 0) {
            NSString *labelString = @"Available Storage";
            label.text = labelString;
            if ([[deviceDic objectForKey:labelString] isEqualToString:@"1"]) {
                labelInfo.text = @"Enough Storage Remains";
            } else if ([[deviceDic objectForKey:labelString] isEqualToString:@"0"]) {
                labelInfo.text = @"No Storage Remains";
            }
            [labelInfo setHidden:NO];
        }else if (indexPath.row == 1) {
            NSString *labelString = @"Recorder Status";
            label.text = labelString;
            if ([[deviceDic objectForKey:labelString] isEqualToString:@"1"]) {
                labelInfo.text = @"Recording";
            } else if ([[deviceDic objectForKey:labelString] isEqualToString:@"0"]) {
                labelInfo.text = @"Recorder is stopped";
            }
            [labelInfo setHidden:NO];
        }else if (indexPath.row == 2) {
            label.text = @"Reboot System";
            rebootButton = button;
            [rebootButton setTitle:@"Reboot" forState:UIControlStateNormal];
            [rebootButton setHidden:NO];
        }else if (indexPath.row == 3){
            label.text = @"Reset Data";
            resetButton = button;
            [resetButton setTitle:@"Reset" forState:UIControlStateNormal];            
            [resetButton setHidden:NO];
        }


    }
    return cell;
}
#pragma value change sending
- (void)qrButtonAction:(id)sender{
    NSString *ssid = [NSString stringWithString:textfieldSSID.text];
    NSString *pass = [NSString stringWithString:textfieldPASS.text];
    if (pass.length < 8) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Too Short" message:@"Invalid Password Length, requires at least 8 words" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        alert.tag = 3;
        [alert show];
    }
    NSString *contentFore =
    @"BOOTPROTO DHCP\nIPADDR 192.168.3.1\nGATEWAY 192.168.3.1\nSSID \"NT_ZY\"\nAUTH_MODE WPA2PSK\nENCRYPT_TYPE AES\nAUTH_KEY 12345678\nWPS_TRIG_KEY HOME\n\nAP_IPADDR 192.168.100.1\nAP_SSID \"";
    NSString *contentMic = @"\"\nAP_AUTH_MODE WPA2PSK\nAP_ENCRYPT_TYPE AES\nAP_AUTH_KEY ";
    NSString *contentPost = @"\nAP_CHANNEL AUTO\n\nBRIF";
    NSString *qrString = @"";
    NSArray *array = [NSArray arrayWithObjects:contentFore, ssid, contentMic, pass, contentPost, nil];
    for (NSString *s in array) {
        qrString = [qrString stringByAppendingString:s];
    }
    NSLog(@"qr String: %@", qrString);
    qrCodeString = [NSString stringWithString:qrString];
    NSString *identifier = @"QRCodeSegue";
    [self performSegueWithIdentifier:identifier sender:self];
}


- (void)rebootButtonAction:(id)sender{
    UIButton *button = (UIButton *)sender;
    if ([button isEqual:rebootButton]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Device will reboot, are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
        alert.tag = 0;
        [alert show];
    } else if ([button isEqual:resetButton]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Data will reset, are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
        alert.tag = 1;
        [alert show];
    }
}

- (IBAction)stepperValueChange:(id)sender {
    [self.view endEditing:YES];
    UIStepper *stepper = (UIStepper *)sender;
    NSMutableDictionary *dic = [[DVRPlayerManager sharedInstance] dictionarySetting];
    NSMutableDictionary *cameraDic = [dic objectForKey:receivedString];
    NSString *value;
    if (labelBitRateValue != nil) {
        if (stepper.value == 6144) {
            value = [NSString stringWithFormat:@"%d", 6000];
            [cameraDic setObject:value forKey:@"Bit Rate"];
            labelBitRateValue.text = @"6000 Kbps";
        } else {
            value = [NSString stringWithFormat:@"%d", (int)stepper.value];
            [cameraDic setObject:value forKey:@"Bit Rate"];
            labelBitRateValue.text = [NSString stringWithFormat:@"%d Kbps", (int) stepper.value];
        }
    }
    [self sendValueWithCategory:@"Bit Rate" value:value];
}

- (IBAction)sliderValueChange:(id)sender {
    [self.view endEditing:YES];
    UISlider *slider = (UISlider *)sender;
    NSMutableDictionary *dic = [[DVRPlayerManager sharedInstance] dictionarySetting];
    NSMutableDictionary *cameraDic = [dic objectForKey:receivedString];
    NSString *value = [NSString stringWithFormat:@"%d", (int)slider.value];
    if ([slider isEqual:sliderQuality]) {
        if (sliderQuality.value == 1) {
            labelQualityValue.text = [NSString stringWithFormat:@"%d (best)", (int)sliderQuality.value];
        }else{
            labelQualityValue.text = [NSString stringWithFormat:@"%d", (int)sliderQuality.value];
        }
        [cameraDic setObject:value forKey:@"Encode Quality"];
    }else {
        if (sliderFPS.value == 30) {
            labelFPSValue.text = [NSString stringWithFormat:@"%d (best)", (int)sliderFPS.value];
        }else{
            labelFPSValue.text = [NSString stringWithFormat:@"%d", (int)sliderFPS.value];
        }
        [cameraDic setObject:value forKey:@"FPS"];
    }
}

-(void)segmentsValueChange:(id)sender{
    UISegmentedControl *control = (UISegmentedControl *)sender;
    NSString *string;
    if ([control isEqual:controlResolution]) {
        string = [NSString stringWithFormat:@"%d", (int)control.selectedSegmentIndex];
        [self sendValueWithCategory:@"Resolution" value:string];
    } else if ([control isEqual:controlDeviceMute]){
        string = [NSString stringWithFormat:@"%d", (int)control.selectedSegmentIndex];
        [self sendValueWithCategory:@"Device Mic" value:string];
    } else if ([control isEqual:controlPhoneMute]){
        string = [NSString stringWithFormat:@"%d", (int)control.selectedSegmentIndex];
        [self sendValueWithCategory:@"Phone Mic" value:string];
    } else if ([control isEqual:controlRecording]){
        string = [NSString stringWithFormat:@"%d", (int)control.selectedSegmentIndex];
        [self sendRecordCommand:(int)control.selectedSegmentIndex];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    DVRPlayerManager *manager = [DVRPlayerManager sharedInstance];
    NSMutableDictionary *dic = manager.dictionarySetting;
    NSMutableDictionary *cameraDic = [dic objectForKey:receivedString];
    if ([textField isEqual:textfieldName]) {
        NSString *string = [NSString stringWithString:textfieldName.text];
        [cameraDic setObject:string forKey:@"Name"];
    }else if([textField isEqual:textfieldURL]){
        NSString *string = [NSString stringWithString:textfieldURL.text];
        [cameraDic setObject:string forKey:@"URL"];
    }else if([textField isEqual:textfieldPort]){
        NSString *string = [NSString stringWithString:textfieldPort.text];
        [cameraDic setObject:string forKey:@"port"];
    }
    [self.view endEditing:YES];
    [self updateHistoryRecord];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [_historyPicker setHidden:YES];
}

-(void)sliderTouchUpInside:(id)sender{
    [self.view endEditing:YES];
    UISlider *slider = (UISlider *)sender;
    NSMutableDictionary *dic = [[DVRPlayerManager sharedInstance] dictionarySetting];
    NSMutableDictionary *cameraDic = [dic objectForKey:receivedString];
    NSString *value = [NSString stringWithFormat:@"%d", (int)slider.value];
    if ([slider isEqual:sliderQuality]) {
        if (sliderQuality.value == 1) {
            labelQualityValue.text = [NSString stringWithFormat:@"%d (best)", (int)sliderQuality.value];
        }else{
            labelQualityValue.text = [NSString stringWithFormat:@"%d", (int)sliderQuality.value];
        }
        [cameraDic setObject:value forKey:@"Encode Quality"];
        [self sendValueWithCategory:@"Encode Quality" value:value];
    }else {
        if (sliderFPS.value == 30) {
            labelFPSValue.text = [NSString stringWithFormat:@"%d (best)", (int)sliderFPS.value];
        }else{
            labelFPSValue.text = [NSString stringWithFormat:@"%d", (int)sliderFPS.value];
        }
        [cameraDic setObject:value forKey:@"FPS"];
        [self sendValueWithCategory:@"FPS" value:value];
    }
}



#pragma custom

-(void)setString:(NSString *)string{
    receivedString = [NSString stringWithString:string];
}

-(void)updateAllSettingData{
    DVRPlayerManager *playerManager = [DVRPlayerManager sharedInstance];
    NSMutableDictionary *dic = playerManager.dictionarySetting;
    NSMutableDictionary *settingDic = [dic objectForKey:receivedString];
    if ([receivedString isEqualToString:@"Setup DVR"]) {
        NSString *string = textfieldName.text;
        [settingDic setObject:string forKey:@"Name"];
        [_delegate updateDetailLabel:string];
        string = textfieldURL.text;
        [settingDic setObject:string forKey:@"URL"];
        string = [NSString stringWithFormat:@"%d",(int) (controlResolution.selectedSegmentIndex + 1)];
        [settingDic setObject:string forKey:@"Resolution"];
        string = [NSString stringWithFormat:@"%d", (int)sliderQuality.value];
        [settingDic setObject:string forKey:@"Encode Quality"];
        string = [NSString stringWithFormat:@"%d", (int)stepperBitRate.value];
        [settingDic setObject:string forKey:@"Bit Rate"];
        string = [NSString stringWithFormat:@"%d", (int)sliderFPS.value];
        [settingDic setObject:string forKey:@"FPS"];
        string = [NSString stringWithFormat:@"%d", (int)controlRecording];
        [settingDic setObject:string forKey:@"Recording"];
        string = [NSString stringWithString:textfieldPort.text];
        [settingDic setObject:string forKey:@"Port"];
    }else if ([receivedString isEqualToString:@"Wi-Fi AP Setup"]){
        NSString *ssid = [NSString stringWithString:textfieldSSID.text];
        [settingDic setObject:ssid forKey:@"SSID"];
        NSString *string = [NSString stringWithString:ssid];
        [_delegate updateDetailLabel:string];
        NSString *pass = [NSString stringWithString:textfieldPASS.text];
        [settingDic setObject:pass forKey:@"password"];
    }else if ( [receivedString isEqualToString:@"Device Mic"] ){
        NSString *mute = [NSString stringWithFormat:@"%@", ((controlDeviceMute.selectedSegmentIndex == 0) ? @"ON" : @"OFF")];
        [settingDic setObject:mute forKey:@"Mute"];
        NSString *string = [NSString stringWithString:mute];
        [_delegate updateDetailLabel:string];
    }else if ( [receivedString isEqualToString:@"Phone Mic"]){
        NSString *mute = [NSString stringWithFormat:@"%@", ((controlPhoneMute.selectedSegmentIndex == 0) ? @"ON" : @"OFF")];
        [settingDic setObject:mute forKey:@"Mute"];
        NSString *string = [NSString stringWithString:mute];
        [_delegate updateDetailLabel:string];
        
    }
}

-(NSDictionary *)getSSID{
    NSArray *interfaces = (__bridge_transfer NSArray *) CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces :%@", interfaces);
    
    NSDictionary *info;
    for (NSString *interfaceName in interfaces) {
        info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName);
        NSLog(@"%@ => %@", interfaceName, info);
        if (info && [info count] ) {
            break;
        }
    }
    return info;
}

-(void)updateHistoryRecord{
    NSString *historyString = [NSString stringWithString:textfieldURL.text];
    if ([historyString isEqualToString:@""]) {
        historyString = @"-";
    }
    
    NSString *firstHistory = [historyArray objectAtIndex:1];
    if (![firstHistory isEqualToString:historyString]) {
        for (int i=(int)historyArray.count-1; i>1; i--) {
            NSString *from = [historyArray objectAtIndex:i-1];
            [historyArray setObject:from atIndexedSubscript:i];
        }
        [historyArray setObject:historyString atIndexedSubscript:1];
    }
    
    NSArray *tempArray = [historyArray subarrayWithRange:NSMakeRange(1, 5)];
    DVRPlayerManager *manager = [DVRPlayerManager sharedInstance];
    NSMutableDictionary *dic = [manager.dictionarySetting objectForKey:receivedString];
    [dic setObject:tempArray forKey:@"History"];
    NSString *targetURL = [tempArray objectAtIndex:0];
    [dic setObject:targetURL forKey:@"URL"];
}

#pragma touches began delegate

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [_historyPicker setHidden:YES];
    NSLog(@"touches began");
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
    [_historyPicker setHidden:YES];
    [self updateHistoryRecord];
}

-(void)sendValueWithCategory:(NSString *)category value:(NSString *)value{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:receivedString forKey:@"Camera"];
    [dic setObject:category forKey:@"Category"];
    [dic setObject:value forKey:@"Value"];
    NSString *generatedCommand = [NSString stringWithString:[DVRCommandGenerator generateSettingCommandWithDictionary:dic]];
    NSLog(@"command: %@", generatedCommand);
    [socketManager sendCommand:generatedCommand toCamera:receivedString withTag:SOCKET_READ_TAG_SEND_SETTING];
}

-(void)sendRecordCommand:(int)value{
    NSString *generatedCommand = @"";
    int tag;
    if (value == 0) {
         generatedCommand = [NSString stringWithString:[DVRCommandGenerator generateInfoCommandWithName:@"Stop Record"]];
    } else if (value == 1) {
        generatedCommand = [NSString stringWithString:[DVRCommandGenerator generateInfoCommandWithName:@"Start Record"]];
    } else if (value == 2) {
        generatedCommand = [NSString stringWithString:[DVRCommandGenerator generateInfoCommandWithName:@"Record Status"]];
    }
    tag = SOCKET_READ_TAG_INFO_STATUS;
    NSLog(@"command: %@", generatedCommand);
    socketManager = [DVRSocketManager shareInstance];
    [socketManager sendCommand:generatedCommand toCamera:@"Setup DVR" withTag:tag];
}

-(void)sendGetResolutionCommand{
    NSString *generatedCommand = @"";
    generatedCommand = [NSString stringWithString:[DVRCommandGenerator generateInfoCommandWithName:@"Get Resolution"]];
    int tag;
    tag = SOCKET_READ_TAG_STATUS_RESOLUTION;
    NSLog(@"command: %@", generatedCommand);
    socketManager = [DVRSocketManager shareInstance];
    [socketManager sendCommand:generatedCommand toCamera:@"Setup DVR" withTag:tag];
}


-(void)sendRebootSystemCommand{
    NSString *generatedCommand = [NSString stringWithString:[DVRCommandGenerator generateInfoCommandWithName:@"Reboot System"]];
    NSLog(@"command: %@", generatedCommand);
    [socketManager sendCommand:generatedCommand toCamera:@"Setup DVR" withTag:SOCKET_READ_TAG_INFO_REBOOT];
}

-(void)updateCameraSettings{
    [self.tableView reloadData];
}


#pragma alert view delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 0) {
        switch (buttonIndex) {
            case 1:
                [self sendRebootSystemCommand];
                break;
            default:
                break;
        }
    } else if (alertView.tag == 1){
        DVRPlayerManager *manager = [DVRPlayerManager sharedInstance];
        switch (buttonIndex) {
            case 1:
                [manager resetData];
                break;
            default:
                break;
        }
    } else if (alertView.tag == 2){
        DVRPlayerManager *manager = [DVRPlayerManager sharedInstance];
        NSDictionary *dic = manager.dictionaryWiFiSetup;
        NSString *SSID = [dic objectForKey:@"AP_SSID"];
        NSString *PASS = [dic objectForKey:@"AP_AUTH_KEY"];
        textfieldSSID.text = SSID;
        textfieldPASS.text = PASS;
    }
}

#pragma DVRSocketManager delegate

-(void)updateResolution:(int)reslution{
    [controlResolution setSelectedSegmentIndex:reslution];
    [self.tableView reloadData];
}
#pragma button delegate

-(void)showHistoryPicker{
    int rows = [self.tableView numberOfRowsInSection:0] - 1;
    NSIndexPath *index = [NSIndexPath indexPathForRow:rows inSection:0];
    [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self.view endEditing:YES];
    DVRPlayerManager *manager = [DVRPlayerManager sharedInstance];
    NSDictionary *dic = [manager.dictionarySetting objectForKey:receivedString];
    NSArray *history = [dic objectForKey:@"History"];
    NSArray *historyHead = [NSArray arrayWithObject:@"History Records"];
    NSArray *temp = [historyHead arrayByAddingObjectsFromArray:history];
    historyArray = [NSMutableArray arrayWithArray:temp];
    [_historyPicker setHidden:!_historyPicker.hidden];
    [self updateHistoryRecord];
    [_historyPicker reloadComponent:0];
    [_historyPicker selectRow:0 inComponent:0 animated:YES];
}

#pragma picker delegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return historyArray.count;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    label.text = [historyArray objectAtIndex:(int)row];
    [label setTextColor:[UIColor whiteColor]];
    if (row == 0) {
        [label setFont:[UIFont fontWithName:@"Courier" size:25]];
    }else{
        [label setFont:[UIFont fontWithName:@"System" size:17]];
    }
    [label setTextAlignment:NSTextAlignmentCenter];
    label.adjustsFontSizeToFitWidth = YES;
    return label;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSString *dash = @"-";
    NSString *labelString = [historyArray objectAtIndex:row];
    if (row > 0 && ![labelString isEqualToString:dash]) {
        textfieldURL.text = [NSString stringWithString:labelString];
    }
}

-(void)getDeviceInformation:(int)tag{
    socketManager = [DVRSocketManager shareInstance];
    NSString *key = @"Setup DVR";
    NSString *command;
    NSString *category;
    if (tag == SOCKET_READ_TAG_INFO_STATUS) {
        category = @"Recorder Status";
        command = [DVRCommandGenerator generateInfoCommandWithName:category];
        [socketManager sendCommand:command toCamera:key withTag:SOCKET_READ_TAG_INFO_STATUS];
    }else if (tag == SOCKET_READ_TAG_INFO_STORAGE){
        category = @"Available Storage";
        command = [DVRCommandGenerator generateInfoCommandWithName:category];
        [socketManager sendCommand:command toCamera:key withTag:SOCKET_READ_TAG_INFO_STORAGE];
    }else {
        [self sendGetResolutionCommand];
    }
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = @"QRCodeSegue";
    if ([segue.identifier isEqualToString:identifier]) {
        DVRQRCodeViewController *controller = segue.destinationViewController;
        [controller setString:qrCodeString];
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
