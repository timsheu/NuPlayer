//
//  DVRSettingViewController.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/22.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "DVRSettingViewController.h"

@interface DVRSettingViewController ()

@end

@implementation DVRSettingViewController

#pragma UIView Delegate

- (void)viewDidLoad {
    [super viewDidLoad];
    
    pool = [DVRCommandPool sharedInstance];
    [self initSettingArray];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.tabBarController.tabBar setHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (passedArray == nil) {
        passedArray = [[NSMutableArray alloc]init];
    }
    if (passedString == nil) {
        passedString = [[NSString alloc]init];
    }
    [self.tabBarController.tabBar setUserInteractionEnabled:NO];
    [NSTimer timerWithTimeInterval:1 target:self selector:@selector(enableTabBar) userInfo:nil repeats:NO];
    [self.tabBarController.tabBar setHidden:NO];
}

#pragma TableView Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = [_settingCatagoryArray objectAtIndex:section];
    return array.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _settingCatagoryArray.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    static NSString *settingCatagoryCellIdentifier = @"SettingCatagoryCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:settingCatagoryCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:settingCatagoryCellIdentifier];
    }
    UIImageView *sectionImage = (UIImageView *) [cell viewWithTag:SETTING_SECTION_IMAGE_TAG];
    NSString *string = [[NSString alloc]init];
    if (section == VIDEO_SECTION) {
        string = @"Video Stream";
        [sectionImage setImage:[UIImage imageNamed:@"camera"]];
    } else if (section == AUDIO_SECTION){
        string = @"Audio Stream";
        [sectionImage setImage:[UIImage imageNamed:@"mic"]];
    } else if (section == WIRELESS_SECTION){
        string = @"Wireless Setup";
        [sectionImage setImage:[UIImage imageNamed:@"wifi"]];
    } else if (section == INFO_SECTION){
        string = @"Device Information";
        [sectionImage setImage:[UIImage imageNamed:@"info"]];
    } else {
        
    }
    UILabel *sectionLabel = (UILabel *) [cell viewWithTag:SETTING_SECTION_LABEL_TAG];
    [sectionLabel setText:string];
    return cell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *settingItemCellIndentifier = @"SettingItemCellIdentifier";
    DVRSettingItemCellPrototype *cell = [tableView dequeueReusableCellWithIdentifier:settingItemCellIndentifier];
    if (cell == nil) {
        cell = [[DVRSettingItemCellPrototype alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:settingItemCellIndentifier];
    }
    NSString *string = [[NSString alloc]init];
    UILabel *settingLabel = (UILabel *) [cell viewWithTag:SETTING_CURRENT_SETTING_TAG];
    if (indexPath.section == VIDEO_SECTION) {
        string = [_settingItemVideoArray objectAtIndex:indexPath.row];
    } else if (indexPath.section == AUDIO_SECTION){
        string = [_settingItemAudioArray objectAtIndex:indexPath.row];
    } else if (indexPath.section == WIRELESS_SECTION){
        string = [_settingItemWirelessArray objectAtIndex:indexPath.row];
    } else if (indexPath.section == INFO_SECTION){
        string = [_settingItemInfoArray objectAtIndex:indexPath.row];
    }
    UILabel *sectionLabel = (UILabel *) [cell viewWithTag:SETTING_ITEM_LABEL_TAG];
    NSString *detailString;
    detailString = [NSString stringWithString:[self determineDetailString:string]];
    sectionLabel.text = string;
    settingLabel.text = detailString;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section < _settingCatagoryArray.count - 1) {
        return 100;
    }
    return 20;
}

#pragma custom function

- (NSString *)determineDetailString:(NSString *)string{
    NSString *detailString;
    DVRPlayerManager *manager = [DVRPlayerManager sharedInstance];
    NSDictionary *dic = [manager.dictionarySetting objectForKey:string];
    if ([string isEqualToString:@"Setup DVR"]){
        indexOfDetail = @"0";
        NSString *name = [NSString stringWithString:[dic objectForKey:@"Name"]];
        if (name != nil) {
            detailString = name;
        } else {
            detailString = @"Required Setup";
        }
    } else if([string isEqualToString:@"Device Mic"]){
        detailString = [[NSString alloc] initWithString:[dic objectForKey:@"Mute"]];
    } else if([string isEqualToString:@"Phone Mic"]){
        detailString = [[NSString alloc] initWithString:[dic objectForKey:@"Mute"]];
    } else if([string isEqualToString:@"Wi-Fi AP Setup"]){
        detailString = [[NSString alloc] initWithString:[dic objectForKey:@"SSID"]];
    } else if([string isEqualToString:@"Device Information"]){
        detailString = @"more";
    }
    return detailString;
}

- (void)initSettingArray{
    if (_settingItemVideoArray == nil) {
        _settingItemVideoArray = [[NSArray alloc] initWithObjects:@"Setup DVR", nil];
    }
    if (_settingItemAudioArray == nil) {
        _settingItemAudioArray = [[NSArray alloc] initWithObjects:@"Device Mic", nil];
    }
    if (_settingItemWirelessArray == nil){
        _settingItemWirelessArray = [[NSArray alloc] initWithObjects:@"Wi-Fi AP Setup", nil];
    }
    if (_settingItemInfoArray == nil) {
        _settingItemInfoArray = [[NSArray alloc] initWithObjects:@"Device Information", nil];
    }
    NSArray *tempArray = @[];
    if ( _settingCatagoryArray == nil) {
        _settingCatagoryArray = [[NSArray alloc]initWithObjects:_settingItemVideoArray, _settingItemAudioArray, _settingItemWirelessArray, _settingItemInfoArray, tempArray, nil];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    detailLabel = [cell viewWithTag:SETTING_CURRENT_SETTING_TAG];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                title = @"Setup DVR";
                break;
        }
        passedArray = [[NSMutableArray alloc]initWithObjects:title, nil];
        [self performSegueWithIdentifier:@"TableSettingDetailSegue" sender:self];
    }else if(indexPath.section == 1){
        switch (indexPath.row) {
            case 0: //Device Mic Mute
                title = @"Device Mic";
                passedArray = [[NSMutableArray alloc]initWithObjects:title, nil];
                [self performSegueWithIdentifier:@"TableSettingDetailSegue" sender:self];
                break;
            default:
                break;
        }
    }else if(indexPath.section == 2){
        switch (indexPath.row) {
            case 0: //Wi-Fi AP Setup
                title = @"Wi-Fi AP Setup";
                passedArray = [[NSMutableArray alloc]initWithObjects:title, nil];
                [self performSegueWithIdentifier:@"TableSettingDetailSegue" sender:self];
                break;
            default:
                break;
        }
    }else if(indexPath.section == 3){
        title = @"Device Information";
        passedArray = [[NSMutableArray alloc] initWithObjects:title, nil];
        [passedArray addObject:@"Available Storage"];
        [passedArray addObject:@"Recorder Status"];
        [passedArray addObject:@"Reboot System"];
        [passedArray addObject:@"Reset Data"];
        [self performSegueWithIdentifier:@"TableSettingDetailSegue" sender:self];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"TableSettingDetailSegue"]) {
        DVRMultipleSettingTableViewController *dest = (DVRMultipleSettingTableViewController *)segue.destinationViewController;
        NSString *category = [NSString stringWithString:[passedArray objectAtIndex:0]];
        dest.delegate = self;
        [dest setupArray:passedArray forCategory:category];
    }else{
//        SettingDetailViewController* dest = (DVRSettingDetailViewController *)segue.destinationViewController;
//        NSString *category = [NSString stringWithString:[passedArray objectAtIndex:0]];
//        [dest setupArray:passedArray forType:category];
    }
}

-(void)updateDetailLabel:(NSString *)string{
    detailLabel.text = [NSString stringWithString:string];
}


@end
