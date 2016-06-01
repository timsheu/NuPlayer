//
//  DVRFileSetCameraTableViewController.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/23.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "DVRFileSetCameraTableViewController.h"

@interface DVRFileSetCameraTableViewController ()

@end

@implementation DVRFileSetCameraTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(refreshFileList) forControlEvents:UIControlEventValueChanged];
    [self updateFileListUponRefresh:NO];
    [self downloadFileList];
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
    socketManager = [DVRSocketManager shareInstance];
    socketManager.delegate = self;
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"FileNameCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    UILabel *labelCameraName = (UILabel *)[cell viewWithTag:10];
    UILabel *labelCameraAmount = (UILabel *)[cell viewWithTag:11];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    // Configure the cell...
    NSDictionary *dic = [arrayCameraName objectAtIndex:indexPath.row];
    labelCameraName.text = [NSString stringWithFormat:@"Camera: %@", [dic objectForKey:@"Name"]];
    NSString *fileAmount = [arrayFileAmount objectAtIndex:indexPath.row];
    if ([fileAmount isEqualToString:@"0"] || [fileAmount isEqualToString:@"1"]) {
        labelCameraAmount.text = [NSString stringWithFormat:@"%@ File", fileAmount];
    }else{
        labelCameraAmount.text = [NSString stringWithFormat:@"%@ Files", fileAmount];
    }
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *fileAmount = [arrayFileAmount objectAtIndex:indexPath.row];
    if ([fileAmount isEqualToString:@"0"]) {
        return nil;
    }
    return indexPath;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *fileAmount = [arrayFileAmount objectAtIndex:indexPath.row];
    if ([fileAmount isEqualToString:@"0"]) {
        return NO;
    }
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    cameraSerial = (int)indexPath.row;
    [self performSegueWithIdentifier:@"EnterTargetCameraSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"EnterTargetCameraSegue"]) {
        DVRFileViewController *controller = (DVRFileViewController *)[segue destinationViewController];
        NSDictionary *cameraDic = [arrayCameraName objectAtIndex:cameraSerial];
        [controller setupTargetCamera:cameraDic];
    }
}


-(void)setFileAmount:(int)amount forCameraSerial:(int)serial{
    
}

-(void)refreshFileList{
    NSLog(@"--refresing--");
    [self downloadFileList];
//    [self.refreshControl endRefreshing];
}

-(void)downloadFileList{
    socketManager = [DVRSocketManager shareInstance];
    DVRPlayerManager *playerManager = [DVRPlayerManager sharedInstance];
    int i=0;
    NSString *key = [NSString stringWithFormat:@"Setup DVR"];
    NSDictionary *dic = [playerManager.dictionarySetting objectForKey:key];
    NSString *url = [dic objectForKey:@"URL"];
    NSArray *split = [url componentsSeparatedByString:@"/"];
    NSLog(@"split: %@", split);
    NSDictionary *commmandDic = [NSDictionary dictionaryWithObjectsAndKeys:key, @"Camera", @"Download File List", @"Category", @"N/A", @"Value", nil];
    NSString *command = [DVRCommandGenerator generateSettingCommandWithDictionary:commmandDic];
    [socketManager setTag:SOCKET_READ_TAG_CAMERA_1 commandCategory:key];
    [socketManager sendCommand:command toCamera:key withTag:i+SOCKET_READ_TAG_CAMERA_OFFSET+1];
}

-(void)downloadFileListFromCamera:(int)serial{
    socketManager = [DVRSocketManager shareInstance];
    DVRPlayerManager *playerManager = [DVRPlayerManager sharedInstance];
    NSString *key = [NSString stringWithFormat:@"Setup Camera %d", serial-SOCKET_READ_TAG_CAMERA_OFFSET];
    NSDictionary *dic = [playerManager.dictionarySetting objectForKey:key];
    NSString *url = [dic objectForKey:@"URL"];
    NSArray *split = [url componentsSeparatedByString:@"/"];
    NSLog(@"split: %@", split);
    NSDictionary *commmandDic = [NSDictionary dictionaryWithObjectsAndKeys:key, @"Camera", @"Download File List", @"Category", @"N/A", @"Value", nil];
    NSString *command = [DVRCommandGenerator generateSettingCommandWithDictionary:commmandDic];
    [socketManager setTag:serial commandCategory:key];
    [socketManager sendCommand:command toCamera:key withTag:serial];
}

-(void)updateFileListUponRefresh:(BOOL)refresh{
    DVRPlayerManager *playerManager = [DVRPlayerManager sharedInstance];
    NSDictionary *dic = playerManager.dictionarySetting;
    arrayCameraName = [[NSMutableArray alloc]initWithCapacity:1];
    arrayFileAmount = [[NSMutableArray alloc]initWithCapacity:1];
    NSString *key = [NSString stringWithFormat:@"Setup DVR"];
    NSDictionary *cameraDic = [dic objectForKey:key];
    NSArray *targetFileList = [cameraDic objectForKey:@"File List"];//[playerManager.arrayFileNameListCollection objectAtIndex:0];
    NSString *amount = [NSString stringWithFormat:@"%d", (int)targetFileList.count];
    [arrayCameraName setObject:cameraDic atIndexedSubscript:0];
    [arrayFileAmount setObject:amount atIndexedSubscript:0];
    [self.tableView reloadData];
    if (refresh) {
        [self.refreshControl endRefreshing];
    }
}

-(void)getDeviceInformation:(int)tag{
    
}

-(void)hostNotResponse:(int)serial command:(NSString *)command{
    if (serial <= SOCKET_READ_TAG_CAMERA_4 && serial >= SOCKET_READ_TAG_CAMERA_1) {
        if (serial == SOCKET_READ_TAG_CAMERA_4) {
            [self.refreshControl endRefreshing];
        }
        NSString *commandCameraName = [NSString stringWithFormat:@"Setup DVR"];
        [socketManager sendCommand:command toCamera:commandCameraName withTag:serial+1];
        [self.tableView reloadData];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
