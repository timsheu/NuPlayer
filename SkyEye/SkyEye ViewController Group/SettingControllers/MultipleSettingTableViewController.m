//
//  MultipleSettingTableViewController.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/16.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "MultipleSettingTableViewController.h"

@interface MultipleSettingTableViewController ()

@end

@implementation MultipleSettingTableViewController
@synthesize labelTitle = _labelTitle;
- (void)viewDidLoad {
    [super viewDidLoad];
//    UINib *nib = [UINib nibWithNibName:@"HistoryPicker" bundle:nil];
//    [nib instantiateWithOwner:self options:nil];
    [_historyPicker setHidden:YES];
    sectionOfTable = 1;
    if ([receivedString isEqualToString:@"Setup Camera 1"] ||
        [receivedString isEqualToString:@"Setup Camera 2"] ||
        [receivedString isEqualToString:@"Setup Camera 3"] ||
        [receivedString isEqualToString:@"Setup Camera 4"]) {
        rowOfTable = 14;
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
    [self setPicker];
    rebootAnnounce = YES;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidDisappear:(BOOL)animated{
    [self updateAllSettingData];
    BOOL update = [[PlayerManager sharedInstance] updateSettingPropertyList];
    DDLogDebug(@"update result: %@", ((update == YES) ? @"Success!" : @"Failed...") );
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self didConnectToHostWithTag:SOCKET_READ_TAG_STATUS_RESOLUTION];
    PlayerManager *manager = [PlayerManager sharedInstance];
    NSDictionary *cameraDic = [manager.dictionarySetting objectForKey:receivedString];
    historyArray = [NSMutableArray arrayWithObject:@"History Records"];
    [historyArray addObjectsFromArray:[cameraDic objectForKey:@"History"]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChangeSetting:) name:UIDeviceOrientationDidChangeNotification object:nil];
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
    NSString *url = @"rtsp://nuvoton.no-ip.biz/cam1/mpeg4";
    NSString *defaultString = @"Default", *string = @"";
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
    if ( [receivedString isEqualToString:@"Setup Camera 1"] ||
        [receivedString isEqualToString:@"Setup Camera 2"] ||
        [receivedString isEqualToString:@"Setup Camera 3"] ||
        [receivedString isEqualToString:@"Setup Camera 4"] ) {
        PlayerManager *manager = [PlayerManager sharedInstance];
        NSString *key;
        if ([receivedString isEqualToString:@"Setup Camera 1"]) {
            key = @"0";
        } else if ([receivedString isEqualToString:@"Setup Camera 2"]){
            key = @"1";
        } else if ([receivedString isEqualToString:@"Setup Camera 3"]){
            key = @"2";
        } else if ([receivedString isEqualToString:@"Setup Camera 4"]){
            key = @"3";
        }
        NSMutableDictionary *dic = [manager.dictionarySetting objectForKey:receivedString];
        NSString *temp;
        UIButton *buttonHistory;
        label.backgroundColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor whiteColor];
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
                temp = [NSString stringWithString:[dic objectForKey:@"URL"]];
                textfieldURL.text = temp;
                [textfieldURL setRightViewMode:UITextFieldViewModeAlways];
                buttonHistory = [UIButton buttonWithType:UIButtonTypeInfoLight];
                buttonHistory.contentMode = UIViewContentModeCenter;
                [buttonHistory addTarget:self action:@selector(showHistoryPicker) forControlEvents:UIControlEventTouchDown];
                [buttonHistory setImage:[UIImage imageNamed:@"signature"] forState:UIControlStateNormal];
                textfieldURL.rightView = buttonHistory;
                break;
            case 2:
                [label setHidden:NO];
                label.text = @"Port";
                [textfield setHidden:NO];
                textfieldPort = textfield;
                temp = [NSString stringWithString:[dic objectForKey:@"port"]];
                textfieldPort.text = temp;
                break;
            case 3: //resolution
                [label setHidden:NO];
                [control setHidden:NO];
                label.text = @"Resolution";
                controlResolution = control;
                temp = [NSString stringWithString:[dic objectForKey:@"Resolution"]];
                [controlResolution setTitle:@"QVGA" forSegmentAtIndex:0];
                [controlResolution setTitle:@"VGA" forSegmentAtIndex:1];
                [controlResolution setTitle:@"720p" forSegmentAtIndex:2];
                [controlResolution setTitle:@"1080p" forSegmentAtIndex:3];
                [controlResolution setSelectedSegmentIndex:temp.intValue];
                break;
            case 4: // adaptive
                [label setHidden:NO];
                label.text = @"Adaptive";
                label.backgroundColor = UIColorFromRGB(0xCCE3FF);
                cell.backgroundColor = UIColorFromRGB(0xCCE3FF);
                [control setHidden:NO];
                control.selectedSegmentIndex = -1;
                controlAdaptive = control;
                [controlAdaptive setTitle:@"Low" forSegmentAtIndex:0];
                [controlAdaptive setTitle:@"Variable" forSegmentAtIndex:1];
                [controlAdaptive setTitle:@"High" forSegmentAtIndex:2];
                if (controlAdaptive.numberOfSegments > 3) {
                    [controlAdaptive removeSegmentAtIndex:3 animated:NO];
                }
                string = [dic objectForKey:label.text];
                controlAdaptive.selectedSegmentIndex = string.intValue;
                break;
            case 5: // fixed bitrate
                [label setHidden:NO];
                label.text = @"Fixed Bit Rate";
                label.backgroundColor = UIColorFromRGB(0xCCE3FF);
                cell.backgroundColor = UIColorFromRGB(0xCCE3FF);
                [control setHidden:NO];
                control.selectedSegmentIndex = -1;
                controlFixedBitrate = control;
                [controlFixedBitrate setTitle:@"Low" forSegmentAtIndex:0];
                [controlFixedBitrate setTitle:@"Medium" forSegmentAtIndex:1];
                [controlFixedBitrate setTitle:@"High" forSegmentAtIndex:2];
                if (controlFixedBitrate.numberOfSegments > 3) {
                    [controlFixedBitrate removeSegmentAtIndex:3 animated:NO];
                }
                string = [dic objectForKey:label.text];
                controlFixedBitrate.selectedSegmentIndex = string.intValue;
                break;
            case 6: // fixed quality
                [label setHidden:NO];
                label.text = @"Fixed Quality";
                label.backgroundColor = UIColorFromRGB(0xCCE3FF);
                cell.backgroundColor = UIColorFromRGB(0xCCE3FF);
                [control setHidden:NO];
                control.selectedSegmentIndex = -1;
                controlFixedQuality = control;
                [controlFixedQuality setTitle:@"Low" forSegmentAtIndex:0];
                [controlFixedQuality setTitle:@"Medium" forSegmentAtIndex:1];
                [controlFixedQuality setTitle:@"High" forSegmentAtIndex:2];
                if (controlFixedQuality.numberOfSegments > 3) {
                    [controlFixedQuality removeSegmentAtIndex:3 animated:NO];
                }
                string = [dic objectForKey:label.text];
                controlFixedQuality.selectedSegmentIndex = string.intValue;
                break;
            case 7: //fps
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
            case 8:
                [label setHidden:NO];
                [control setHidden:NO];
                if (control.numberOfSegments > 3) {
                    [control removeSegmentAtIndex:3 animated:NO];
                }
                if (control.numberOfSegments > 2) {
                    [control removeSegmentAtIndex:2 animated:NO];
                }
                dic = [manager.dictionarySetting objectForKey:receivedString];
                string = (NSString *)[dic objectForKey:@"Mute"];
                controlDeviceMute = control;
                if ([string isEqualToString:@"ON"]) {
                    [controlDeviceMute setSelectedSegmentIndex:0];
                }else{
                    [controlDeviceMute setSelectedSegmentIndex:1];
                }
                label.text = @"Device Mic";
                break;
            case 9:
                [label setHidden:NO];
                dic = [manager.dictionarySetting objectForKey:receivedString];
                dic = [dic objectForKey:@"Device Info"];
                label.text = @"Available Storage";
                if ([[dic objectForKey:@"Available Storage"] isEqualToString:@"1"]) {
                    labelInfo.text = @"Enough Storage Remains";
                } else {
                    labelInfo.text = @"No Storage Remains";
                }
                [labelInfo setHidden:NO];
                break;
            case 10:
                [label setHidden:NO];
                [control setHidden:NO];
                controlTransmission = control;
                dic = [manager.dictionarySetting objectForKey:receivedString];
                label.text = @"Transmission";
                [controlTransmission removeSegmentAtIndex:3 animated:NO];
                [controlTransmission removeSegmentAtIndex:2 animated:NO];
                [controlTransmission setTitle:@"UDP" forSegmentAtIndex:0];
                [controlTransmission setTitle:@"TCP" forSegmentAtIndex:1];
                if ([[dic objectForKey:@"Transmission"] isEqualToString:@"TCP"]) {
                    controlTransmission.selectedSegmentIndex = 1;
                }else{
                    controlTransmission.selectedSegmentIndex = 0;
                }
                break;
            case 11:
                [label setHidden:NO];
                label.text = @"Recorder Status";
                if ([[dic objectForKey:@"Recorder Status"] isEqualToString:@"1"]) {
                    labelInfo.text = @"Recording";
                } else {
                    labelInfo.text = @"Recorder is stopped";
                }
                [labelInfo setHidden:NO];
                break;
            case 12:
                [label setHidden:NO];
                label.text = @"Reboot System";
                rebootButton = button;
                [rebootButton setTitle:@"Reboot" forState:UIControlStateNormal];
                [rebootButton setHidden:NO];
                break;
            case 13:
                [label setHidden:NO];
                label.text = @"Report";
                [button setHidden:NO];
                sendReportButton = button;
                [sendReportButton setTitle:@"Send Report" forState:UIControlStateNormal];
            default:
                break;
        }
    } else if ( [receivedString isEqualToString:@"Wi-Fi AP Setup"]){
        [label setHidden:NO];
        [textfield setHidden:NO];
        PlayerManager *manager = [PlayerManager sharedInstance];
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
        PlayerManager *manager = [PlayerManager sharedInstance];
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
        PlayerManager *manager = [PlayerManager sharedInstance];
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
        PlayerManager *manager = [PlayerManager sharedInstance];
        [label setHidden:NO];
        NSDictionary *dic = [manager.dictionarySetting objectForKey:receivedString];
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
    DDLogDebug(@"qr String: %@", qrString);
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
    } else if([button isEqual:sendReportButton]){
        [self sendMail:nil];
    }
}

- (IBAction)stepperValueChange:(id)sender {
    [self.view endEditing:YES];
    UIStepper *stepper = (UIStepper *)sender;
    NSMutableDictionary *dic = [[PlayerManager sharedInstance] dictionarySetting];
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
    NSMutableDictionary *dic = [[PlayerManager sharedInstance] dictionarySetting];
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
    PlayerManager *manager = [PlayerManager sharedInstance];
    NSMutableDictionary *dic = [manager.dictionarySetting objectForKey:receivedString];
    if ([control isEqual:controlResolution]) {
        string = [NSString stringWithFormat:@"%d", (int)control.selectedSegmentIndex];
        [self sendValueWithCategory:@"Resolution" value:string];
    } else if ([control isEqual:controlDeviceMute]){
        string = [NSString stringWithFormat:@"%d", (int)control.selectedSegmentIndex];
        [self sendValueWithCategory:@"Device Mic" value:string];
    } else if ([control isEqual:controlPhoneMute]){
        string = [NSString stringWithFormat:@"%d", (int)control.selectedSegmentIndex];
        [self sendValueWithCategory:@"Phone Mic" value:string];
    } else if ([control isEqual:controlAdaptive]){
        NSString *category = @"Adaptive";
        controlFixedBitrate.selectedSegmentIndex = -1;
        [dic setObject:@"-1" forKey:@"Fixed Bit Rate"];
        controlFixedQuality.selectedSegmentIndex = -1;
        [dic setObject:@"-1" forKey:@"Fixed Quality"];
        [self updatePluginParameter:category];
    } else if ([control isEqual:controlFixedBitrate]){
        NSString *category = @"Fixed Bit Rate";
        controlAdaptive.selectedSegmentIndex = -1;
        [dic setObject:@"-1" forKey:@"Adaptive"];
        controlFixedQuality.selectedSegmentIndex = -1;
        [dic setObject:@"-1" forKey:@"Fixed Quality"];
        [self updatePluginParameter:category];
    } else if ([control isEqual:controlFixedQuality]){
        NSString *category = @"Fixed Quality";
        controlFixedBitrate.selectedSegmentIndex = -1;
        [dic setObject:@"-1" forKey:@"Fixed Bit Rate"];
        controlAdaptive.selectedSegmentIndex = -1;
        [dic setObject:@"-1" forKey:@"Adaptive"];
        [self updatePluginParameter:category];
    } else if ([control isEqual:controlTransmission]){
        PlayerManager *manager = [PlayerManager sharedInstance];
        NSMutableDictionary *dic = [manager.dictionarySetting objectForKey:receivedString];
        if (control.selectedSegmentIndex == 0) {
            NSString *string = @"UDP";
            [dic setObject:string forKey:@"Transmission"];
        }else{
            NSString *string = @"TCP";
            [dic setObject:string forKey:@"Transmission"];
        }
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    PlayerManager *manager = [PlayerManager sharedInstance];
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
    NSMutableDictionary *dic = [[PlayerManager sharedInstance] dictionarySetting];
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

#pragma misc functions

-(void)setString:(NSString *)string{
    receivedString = [NSString stringWithString:string];
}

-(void)updateAllSettingData{
    PlayerManager *playerManager = [PlayerManager sharedInstance];
    NSMutableDictionary *dic = playerManager.dictionarySetting;
    NSMutableDictionary *settingDic = [dic objectForKey:receivedString];
    if ([receivedString isEqualToString:@"Setup Camera 1"] ||
        [receivedString isEqualToString:@"Setup Camera 2"] ||
        [receivedString isEqualToString:@"Setup Camera 3"] ||
        [receivedString isEqualToString:@"Setup Camera 4"]) {
        NSString *string = textfieldName.text;
        [settingDic setObject:string forKey:@"Name"];
        [_delegate updateDetailLabel:string];
        string = textfieldURL.text;
        [settingDic setObject:string forKey:@"URL"];
        string = [NSString stringWithFormat:@"%d",(int) (controlResolution.selectedSegmentIndex)];
        [settingDic setObject:string forKey:@"Resolution"];
        string = [NSString stringWithFormat:@"%d", (int)sliderQuality.value];
        [settingDic setObject:string forKey:@"Encode Quality"];
        string = [NSString stringWithFormat:@"%d", (int)stepperBitRate.value];
        [settingDic setObject:string forKey:@"Bit Rate"];
        string = [NSString stringWithFormat:@"%d", (int)sliderFPS.value];
        [settingDic setObject:string forKey:@"FPS"];
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
    DDLogDebug(@"Supported interfaces :%@", interfaces);
    
    NSDictionary *info;
    for (NSString *interfaceName in interfaces) {
        info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName);
        DDLogDebug(@"%@ => %@", interfaceName, info);
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
        for (int i=historyArray.count-1; i>1; i--) {
            NSString *from = [historyArray objectAtIndex:i-1];
            [historyArray setObject:from atIndexedSubscript:i];
        }
        [historyArray setObject:historyString atIndexedSubscript:1];
    }
    NSArray *tempArray = [historyArray subarrayWithRange:NSMakeRange(1, 5)];
    PlayerManager *manager = [PlayerManager sharedInstance];
    NSMutableDictionary *dic = [manager.dictionarySetting objectForKey:receivedString];
    [dic setObject:tempArray forKey:@"History"];
    NSString *targetURL = [tempArray objectAtIndex:0];
    [dic setObject:targetURL forKey:@"URL"];
}

#pragma touches began delegate

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [_historyPicker setHidden:YES];
    DDLogDebug(@"touches began");
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
    [_historyPicker setHidden:YES];
    if (![receivedString isEqualToString:@"Wi-Fi AP Setup"]&&
        ![receivedString isEqualToString:@"Device Information"]) {
        [self updateHistoryRecord];
    }
}

-(void)setCameraInCategory:(NSString *)category withAnyValue:(NSString *)value{
    
}

#pragma send value to device

-(void)sendValueWithCategory:(NSString *)category value:(NSString *)value{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:receivedString forKey:@"Camera"];
    [dic setObject:category forKey:@"Category"];
    [dic setObject:value forKey:@"Value"];
    NSString *generatedCommand = [NSString stringWithString:[SkyEyeCommandGenerator generateSettingCommandWithDictionary:dic]];
    SocketManager *socketManager = [SocketManager shareInstance];
    DDLogDebug(@"command: %@", generatedCommand);
    if ([category isEqualToString:@"Device Mic"]) {
        [socketManager sendCommand:generatedCommand toCamera:receivedString withTag:SOCKET_READ_TAG_OTHER];
    }
    [socketManager sendCommand:generatedCommand toCamera:receivedString withTag:SOCKET_READ_TAG_SEND_SETTING];
}

-(void)sendRebootSystemCommand{
    NSString *generatedCommand = [NSString stringWithString:[SkyEyeCommandGenerator generateInfoCommandWithName:@"Reboot System"]];
    SocketManager *socketManager = [SocketManager shareInstance];
    DDLogDebug(@"command: %@", generatedCommand);
    [socketManager sendCommand:generatedCommand toCamera:@"Setup Camera 1" withTag:SOCKET_READ_TAG_INFO_REBOOT];
}

- (void)updatePluginParameter:(NSString *)parameter{
    NSString *generatedCommand;
    NSString *pluginName = @"h264_encoder", *pluginParam, *value;
    SocketManager *socketManager = [SocketManager shareInstance];
    NSMutableArray *commandSet = [NSMutableArray arrayWithCapacity:0];
    if ([parameter isEqualToString:@"Adaptive"]) {
        pluginParam = @"Pipe0_Quality";
        value = @"0";
        generatedCommand = [SkyEyeCommandGenerator generateUpdatePluginCommand:pluginName withParameter:pluginParam withValue:value];
        [commandSet addObject:generatedCommand];
        pluginParam = @"Pipe0_Min_Quality";
        value = @"20";
        generatedCommand = [SkyEyeCommandGenerator generateUpdatePluginCommand:pluginName withParameter:pluginParam withValue:value];
        [commandSet addObject:generatedCommand];
        pluginParam = @"Pipe0_Max_Quality";
        value = @"52";
        generatedCommand = [SkyEyeCommandGenerator generateUpdatePluginCommand:pluginName withParameter:pluginParam withValue:value];
        [commandSet addObject:generatedCommand];
        switch (controlAdaptive.selectedSegmentIndex) {
            case 0:
                pluginParam = @"Pipe0_Min_Bitrate";
                value = @"512";
                generatedCommand = [SkyEyeCommandGenerator generateUpdatePluginCommand:pluginName withParameter:pluginParam withValue:value];
                [commandSet addObject:generatedCommand];
                pluginParam = @"Pipe0_Max_Bitrate";
                value = @"2000";
                generatedCommand = [SkyEyeCommandGenerator generateUpdatePluginCommand:pluginName withParameter:pluginParam withValue:value];
                [commandSet addObject:generatedCommand];
                break;
            case 1:
                pluginParam = @"Pipe0_Min_Bitrate";
                value = @"512";
                generatedCommand = [SkyEyeCommandGenerator generateUpdatePluginCommand:pluginName withParameter:pluginParam withValue:value];
                [commandSet addObject:generatedCommand];
                pluginParam = @"Pipe0_Max_Bitrate";
                value = @"5000";
                generatedCommand = [SkyEyeCommandGenerator generateUpdatePluginCommand:pluginName withParameter:pluginParam withValue:value];
                [commandSet addObject:generatedCommand];
                break;
            case 2:
                pluginParam = @"Pipe0_Min_Bitrate";
                value = @"2000";
                generatedCommand = [SkyEyeCommandGenerator generateUpdatePluginCommand:pluginName withParameter:pluginParam withValue:value];
                [commandSet addObject:generatedCommand];
                pluginParam = @"Pipe0_Max_Bitrate";
                value = @"5000";
                generatedCommand = [SkyEyeCommandGenerator generateUpdatePluginCommand:pluginName withParameter:pluginParam withValue:value];
                [commandSet addObject:generatedCommand];
                break;
            default:
                break;
        }
        [socketManager sendCommandSet:commandSet toCamera:receivedString withTag:SOCKET_READ_TAG_SET_PLUGIN index:0];
    }else if ([parameter isEqualToString:@"Fixed Bit Rate"]){
        pluginParam = @"Pipe0_Quality";
        value = @"0";
        generatedCommand = [SkyEyeCommandGenerator generateUpdatePluginCommand:pluginName withParameter:pluginParam withValue:value];
        [commandSet addObject:generatedCommand];
        pluginParam = @"Pipe0_Min_Quality";
        value = @"1";
        generatedCommand = [SkyEyeCommandGenerator generateUpdatePluginCommand:pluginName withParameter:pluginParam withValue:value];
        [commandSet addObject:generatedCommand];
        pluginParam = @"Pipe0_Max_Quality";
        value = @"52";
        generatedCommand = [SkyEyeCommandGenerator generateUpdatePluginCommand:pluginName withParameter:pluginParam withValue:value];
        [commandSet addObject:generatedCommand];
        pluginParam = @"Pipe0_Max_Bitrate";
        value = @"0";
        generatedCommand = [SkyEyeCommandGenerator generateUpdatePluginCommand:pluginName withParameter:pluginParam withValue:value];
        [commandSet addObject:generatedCommand];
        
        pluginParam = @"Pipe0_Bitrate";
        
        switch (controlFixedBitrate.selectedSegmentIndex) {
            case 0:
                value = @"2000";
                generatedCommand = [SkyEyeCommandGenerator generateUpdatePluginCommand:pluginName withParameter:pluginParam withValue:value];
                break;
            case 1:
                value = @"3000";
                generatedCommand = [SkyEyeCommandGenerator generateUpdatePluginCommand:pluginName withParameter:pluginParam withValue:value];
                break;
            case 2:
                value = @"5000";
                generatedCommand = [SkyEyeCommandGenerator generateUpdatePluginCommand:pluginName withParameter:pluginParam withValue:value];
                break;
            default:
                break;
        }
        [commandSet addObject:generatedCommand];
        [socketManager sendCommandSet:commandSet toCamera:receivedString withTag:SOCKET_READ_TAG_SET_PLUGIN index:0];
    }else if ([parameter isEqualToString:@"Fixed Quality"]){
        pluginParam = @"Pipe0_Min_Bitrate";
        value = @"512";
        generatedCommand = [SkyEyeCommandGenerator generateUpdatePluginCommand:pluginName withParameter:pluginParam withValue:value];
        NSMutableArray *commandSet = [NSMutableArray arrayWithObject:generatedCommand];
        pluginParam = @"Pipe0_Max_Bitrate";
        value = @"4096";
        
        switch (controlFixedQuality.selectedSegmentIndex) {
            case 0:
                pluginParam = @"Pipe0_Quality";
                value = @"50";
                generatedCommand = [SkyEyeCommandGenerator generateUpdatePluginCommand:pluginName withParameter:pluginParam withValue:value];
                break;
            case 1:
                pluginParam = @"Pipe0_Quality";
                value = @"40";
                generatedCommand = [SkyEyeCommandGenerator generateUpdatePluginCommand:pluginName withParameter:pluginParam withValue:value];
                break;
            case 2:
                pluginParam = @"Pipe0_Quality";
                value = @"25";
                generatedCommand = [SkyEyeCommandGenerator generateUpdatePluginCommand:pluginName withParameter:pluginParam withValue:value];
                break;
            default:
                break;
        }
        [commandSet addObject:generatedCommand];
        [socketManager sendCommandSet:commandSet toCamera:receivedString withTag:SOCKET_READ_TAG_SET_PLUGIN index:0];
    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Reminder" message:@"This setting requires rebooting the device, please click the \"Reboot\" button at the bottom of the page !" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:@"Okay and don't mention again.", nil];
    alert.tag = 3;
    if (rebootAnnounce) {
        [alert show];
    }
}

#pragma did connect/disconnect


-(void)didConnectToHostWithTag:(int)tag{
    SocketManager *socketManager = [SocketManager shareInstance];
    socketManager.delegate = self;
    NSString *generatedCommand;
    switch (tag) {
        case SOCKET_READ_TAG_STATUS_RESOLUTION:
            generatedCommand = [NSString stringWithString:[SkyEyeCommandGenerator generateInfoCommandWithName:@"Get Resolution"]];
            break;
        case SOCKET_READ_TAG_STATUS_ENCODE_QUALITY:
            generatedCommand = [NSString stringWithString:[SkyEyeCommandGenerator generateInfoCommandWithName:@"Get Encode Quality"]];
            break;
        case SOCKET_READ_TAG_STATUS_ENCODE_BITRATE:
            generatedCommand = [NSString stringWithString:[SkyEyeCommandGenerator generateInfoCommandWithName:@"Get Encode BitRate"]];
            break;
        case SOCKET_READ_TAG_STATUS_MAX_FPS:
            generatedCommand = [NSString stringWithString:[SkyEyeCommandGenerator generateInfoCommandWithName:@"Get MAX FPS"]];
            break;
            
        default:
            break;
    }
    [socketManager sendCommand:generatedCommand toCamera:receivedString withTag:tag];
}

-(void)connectHostWithTag:(int)tag{
    SocketManager *socketManager = [SocketManager shareInstance];
    socketManager.delegate = self;
    PlayerManager *playerManager = [PlayerManager sharedInstance];
    NSDictionary *dic = [playerManager.dictionarySetting objectForKey:receivedString];
    NSString *fullURL = [dic objectForKey:@"URL"];
    NSArray *split = [fullURL componentsSeparatedByString:@"/"];
    NSString *splitURL;
    if (split.count == 1) {
        splitURL = [split objectAtIndex:0];
    }else{
        splitURL = [split objectAtIndex:2];
    }
    NSString *port = [dic objectForKey:@"port"];
    [socketManager connectHost:splitURL withPort:port withTag:tag];
}

#pragma socket manager delegate

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
        PlayerManager *manager = [PlayerManager sharedInstance];
        switch (buttonIndex) {
            case 1:
                [manager resetData];
                break;
            default:
                break;
        }
    } else if (alertView.tag == 2){
        PlayerManager *manager = [PlayerManager sharedInstance];
        NSDictionary *dic = manager.dictionaryWiFiSetup;
        NSString *SSID = [dic objectForKey:@"AP_SSID"];
        NSString *PASS = [dic objectForKey:@"AP_AUTH_KEY"];
        textfieldSSID.text = SSID;
        textfieldPASS.text = PASS;
    } else if (alertView.tag == 3){
        switch (buttonIndex) {
            case 0:
                //ok, not doing anything
                break;
            case 1:
                //ok and will not metiong again
                rebootAnnounce = NO;
                break;
            default:
                break;
        }
    }
}

#pragma socket manager delegate

-(void)hostNotResponse:(int)serial command:(NSString *)command{
    
}

#pragma button delegate

-(void)showHistoryPicker{
    [self.view endEditing:YES];
    PlayerManager *manager = [PlayerManager sharedInstance];
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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.bounds.size.width, 50)];
    label.text = [historyArray objectAtIndex:(int)row];
    if (row == 0) {
        [label setFont:[UIFont fontWithName:@"Courier" size:25]];
    }else{
        [label setFont:[UIFont fontWithName:@"System" size:17]];
    }
//    CGFloat x = pickerView.bounds.origin.x;
//    CGFloat y = pickerView.bounds.origin.y;
//    CGFloat w = pickerView.bounds.size.width;
//    CGFloat h = pickerView.bounds.size.height;
//    DDLogDebug(@"cell frame size: %f, %f, %f, %f", x, y, w, h);
    [label setTextAlignment:NSTextAlignmentCenter];
//    label.backgroundColor = [UIColor whiteColor];// UIColorFromRGB(0x007DFF);
    label.textColor = UIColorFromRGB(0x007DFF);
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

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 50;
}

-(void)setPicker{
    UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
    CGFloat x, y, w, h;
    if (interfaceOrientation == UIInterfaceOrientationPortrait ||
        interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        x = 0;
        y = 1*self.view.bounds.size.height/2;
        w = self.view.bounds.size.width;
        h = 1.3*self.view.bounds.size.height/3;
    } else {
        x = 0;
        y = self.view.bounds.size.height/2;
        w = self.view.bounds.size.width;
        h = 1.3*self.view.bounds.size.height/3;
    }
    CGRect frame = CGRectMake(x, y, w, h);
    historyFrame = frame;
    if (_historyPicker == nil) {
        _historyPicker = [[UIPickerView alloc]initWithFrame:historyFrame];
    }
    _historyPicker = [[UIPickerView alloc] initWithFrame:historyFrame];
    _historyPicker.backgroundColor = UIColorFromRGB(0xCCE3FF);//UIColorFromRGB(0x006DF0);
    _historyPicker.alpha = 0.95f;
    _historyPicker.dataSource = self;
    _historyPicker.delegate = self;
    [self.view addSubview:_historyPicker];
    [_historyPicker setHidden:YES];
}

-(void)getDeviceInformation:(int)tag{
    SocketManager *socketManager = [SocketManager shareInstance];
    NSString *command;
    NSString *category;
    if (tag == SOCKET_READ_TAG_INFO_STATUS) {
        category = @"Recorder Status";
        command = [SkyEyeCommandGenerator generateInfoCommandWithName:category];
        [socketManager sendCommand:command toCamera:receivedString withTag:SOCKET_READ_TAG_INFO_STATUS];
    }else if (tag == SOCKET_READ_TAG_INFO_STORAGE){
        category = @"Available Storage";
        command = [SkyEyeCommandGenerator generateInfoCommandWithName:category];
        [socketManager sendCommand:command toCamera:receivedString withTag:SOCKET_READ_TAG_INFO_STORAGE];
    }else {

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


- (void)orientationChangeSetting:(UIInterfaceOrientation) orientation{
    [_historyPicker removeFromSuperview];
    _historyPicker = nil;
    [self setPicker];
    [_historyPicker setHidden:YES];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = @"QRCodeSegue";
    if ([segue.identifier isEqualToString:identifier]) {
        QRCodeViewController *controller = segue.destinationViewController;
        [controller setString:qrCodeString];
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)sendMail:(id)sender{
    if ([MFMailComposeViewController canSendMail]) {
        mailComposer = [[MFMailComposeViewController alloc]init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setSubject:@"Send Report"];
        [mailComposer setToRecipients:@[@"CCHSU20@nuvoton.com"]];
        [mailComposer setMessageBody:@"" isHTML:NO];
        PlayerManager *manager = [PlayerManager sharedInstance];
        NSString *file = manager.getCurrentLogFilePath;
        NSArray *filePart = [file componentsSeparatedByString:@"."];
        NSString *filename = [filePart objectAtIndex:0];
        NSData *fileData = [NSData dataWithContentsOfFile:file];
        
        NSString *mimeType = @"text/plain";
        [mailComposer addAttachmentData:fileData mimeType:mimeType fileName:filename];
        [self presentViewController:mailComposer animated:YES completion:NULL];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"E-mail not Enable" message:@"Configure your E-mail account first!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (result) {
        DDLogDebug(@"Result : %d",result);
    }
    if (error) {
        DDLogDebug(@"Error : %@",error);
    }
    [self dismissModalViewControllerAnimated:YES];
    
}



@end
