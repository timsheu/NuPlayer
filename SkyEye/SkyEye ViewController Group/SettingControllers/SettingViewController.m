//
//  SettingViewController.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/22.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

#pragma UIView Delegate

- (void)viewDidLoad {
    [super viewDidLoad];
    
    pool = [CommandPool sharedInstance];
    [self initSettingArray];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (passedArray == nil) {
        passedArray = [[NSMutableArray alloc]init];
    }
    if (passedString == nil) {
        passedString = [[NSString alloc]init];
    }
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
        string = @"Camera Setup";
        [sectionImage setImage:[UIImage imageNamed:@"camera"]];
    } else if (section == WIRELESS_SECTION){
        string = @"Wireless Setup";
        [sectionImage setImage:[UIImage imageNamed:@"wifi"]];
    } else {
        
    }
    UILabel *sectionLabel = (UILabel *) [cell viewWithTag:SETTING_SECTION_LABEL_TAG];
    [sectionLabel setText:string];
    return cell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *settingItemCellIndentifier = @"SettingItemCellIdentifier";
    SettingItemCellPrototype *cell = [tableView dequeueReusableCellWithIdentifier:settingItemCellIndentifier];
    if (cell == nil) {
        cell = [[SettingItemCellPrototype alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:settingItemCellIndentifier];
    }
    NSString *string = @"";
    NSString *detailString = @"";
    UILabel *settingLabel = (UILabel *) [cell viewWithTag:SETTING_CURRENT_SETTING_TAG];
    if (indexPath.section == VIDEO_SECTION) {
        string = [_settingItemVideoArray objectAtIndex:indexPath.row];
        detailString = [NSString stringWithString:[self determineDetailString:string]];
    } else if (indexPath.section == WIRELESS_SECTION){
        string = [_settingItemWirelessArray objectAtIndex:indexPath.row];
       detailString = [NSString stringWithString:[self determineDetailString:string]];
    } else{
        string = @"";
        detailString = @"";
    }
    UILabel *sectionLabel = (UILabel *) [cell viewWithTag:SETTING_ITEM_LABEL_TAG];
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
    PlayerManager *manager = [PlayerManager sharedInstance];
    NSDictionary *dic = [manager.dictionarySetting objectForKey:string];
    if ([string isEqualToString:@"Setup Camera 1"]){
        indexOfDetail = @"0";
        NSString *name = [NSString stringWithString:[dic objectForKey:@"Name"]];
        if (name != nil) {
            detailString = name;
        } else {
            detailString = @"Required Setup";
        }
    }else if ([string isEqualToString:@"Setup Camera 2"]){
        indexOfDetail = @"1";
        NSString *name = [NSString stringWithString:[dic objectForKey:@"Name"]];
        if (name != nil) {
            detailString = name;
        } else {
            detailString = @"Required Setup";
        }
        
    }else if ([string isEqualToString:@"Setup Camera 3"]){
        indexOfDetail = @"2";
        NSString *name = [NSString stringWithString:[dic objectForKey:@"Name"]];
        if (name != nil) {
            detailString = name;
        } else {
            detailString = @"Required Setup";
        }
        
    }else if ([string isEqualToString:@"Setup Camera 4"]){
        indexOfDetail = @"3";
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
        _settingItemVideoArray = [[NSArray alloc] initWithObjects:@"Setup Camera 1", @"Setup Camera 2", @"Setup Camera 3", @"Setup Camera 4", nil];
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
        _settingCatagoryArray = [[NSArray alloc]initWithObjects:_settingItemVideoArray, _settingItemWirelessArray, tempArray, nil];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    detailLabel = [cell viewWithTag:SETTING_CURRENT_SETTING_TAG];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                title = @"Setup Camera 1";
                break;
            case 1:
                title = @"Setup Camera 2";
                break;
            case 2:
                title = @"Setup Camera 3";
                break;
            case 3:
                title = @"Setup Camera 4";
                break;
            default:
                break;
        }
        passedArray = [[NSMutableArray alloc]initWithObjects:title, nil];
        [self performSegueWithIdentifier:@"TableSettingDetailSegue" sender:self];
    }else if(indexPath.section == 1){
        switch (indexPath.row) {
            case 0: //Wi-Fi AP Setup
                title = @"Wi-Fi AP Setup";
                passedArray = [[NSMutableArray alloc]initWithObjects:title, nil];
                [self performSegueWithIdentifier:@"TableSettingDetailSegue" sender:self];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"TableSettingDetailSegue"]) {
        MultipleSettingTableViewController *dest = (MultipleSettingTableViewController *)segue.destinationViewController;
        NSString *category = [NSString stringWithString:[passedArray objectAtIndex:0]];
        dest.delegate = self;
        [dest setupArray:passedArray forCategory:category];
    }else{
        SettingDetailViewController* dest = (SettingDetailViewController *)segue.destinationViewController;
        NSString *category = [NSString stringWithString:[passedArray objectAtIndex:0]];
        [dest setupArray:passedArray forType:category];
    }
}

-(void)updateDetailLabel:(NSString *)string{
    detailLabel.text = [NSString stringWithString:string];
}

- (void)setupCameraString:(NSString *)string{
    cameraString = [NSString stringWithString:string];
}
@end
