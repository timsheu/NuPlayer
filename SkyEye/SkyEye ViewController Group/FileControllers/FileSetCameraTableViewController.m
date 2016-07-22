//
//  FileSetCameraTableViewController.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/23.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "FileSetCameraTableViewController.h"

@interface FileSetCameraTableViewController ()

@end

@implementation FileSetCameraTableViewController

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
    socketManager = [SocketManager shareInstance];
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

    return 4;
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
        FileViewController *controller = (FileViewController *)[segue destinationViewController];
        NSDictionary *cameraDic = [arrayCameraName objectAtIndex:cameraSerial];
        [controller setupTargetCamera:cameraDic];
    }
}

//-(void)downloadFileList{
//    SocketManager *socketManager = [SocketManager shareInstance];
//    for (int i=0; i<4; i++) {
//        NSDictionary *dic = [arrayCameraName objectAtIndex:i];
//        NSString *url = [dic objectForKey:@"URL"];
//        NSArray *split = [url componentsSeparatedByString:@"/"];
//        DDLogDebug(@"split: %@", split);
//        NSString *string = [NSString stringWithFormat:@"Setup Camera %d", i+1];
//        NSDictionary *commmandDic = [NSDictionary dictionaryWithObjectsAndKeys:string, @"Camera", @"Download File List", @"Category", @"N/A", @"Value", nil];
//        NSString *command = [SkyEyeCommandGenerator generateSettingCommandWithDictionary:commmandDic];
//        [socketManager setTag:SOCKET_READ_TAG_CAMERA_1];
//        [socketManager sendCommand:command toCamera:string withTag:i+10];
//        PlayerManager *playerManager = [PlayerManager sharedInstance];
//        NSArray *filenameList = [playerManager.arrayFileNameListCollection objectAtIndex:i];
//        NSString *fileAmount = [NSString stringWithFormat:@"%d", (int)filenameList.count];
//        [arrayFileAmount setObject:fileAmount atIndexedSubscript:i];
//    }
//}

-(void)setFileAmount:(int)amount forCameraSerial:(int)serial{
    
}

-(void)refreshFileList{
    DDLogDebug(@"--refresing--");
    [self downloadFileList];
//    [self.refreshControl endRefreshing];
}

-(void)downloadFileList{
    socketManager = [SocketManager shareInstance];
    PlayerManager *playerManager = [PlayerManager sharedInstance];
    int i=0;
    NSString *key = [NSString stringWithFormat:@"Setup Camera %d", i+1];
    NSDictionary *dic = [playerManager.dictionarySetting objectForKey:key];
    NSString *url = [dic objectForKey:@"URL"];
    NSArray *split = [url componentsSeparatedByString:@"/"];
    DDLogDebug(@"split: %@", split);
    NSDictionary *commmandDic = [NSDictionary dictionaryWithObjectsAndKeys:key, @"Camera", @"Download File List", @"Category", @"N/A", @"Value", nil];
    NSString *command = [SkyEyeCommandGenerator generateSettingCommandWithDictionary:commmandDic];
    [socketManager setTag:SOCKET_READ_TAG_CAMERA_1 commandCategory:key];
    [socketManager sendCommand:command toCamera:key withTag:i+SOCKET_READ_TAG_CAMERA_OFFSET+1];
}

-(void)downloadFileListFromCamera:(int)serial{
    socketManager = [SocketManager shareInstance];
    PlayerManager *playerManager = [PlayerManager sharedInstance];
    NSString *key = [NSString stringWithFormat:@"Setup Camera %d", serial-SOCKET_READ_TAG_CAMERA_OFFSET];
    NSDictionary *dic = [playerManager.dictionarySetting objectForKey:key];
    NSString *url = [dic objectForKey:@"URL"];
    NSArray *split = [url componentsSeparatedByString:@"/"];
    DDLogDebug(@"split: %@", split);
    NSDictionary *commmandDic = [NSDictionary dictionaryWithObjectsAndKeys:key, @"Camera", @"Download File List", @"Category", @"N/A", @"Value", nil];
    NSString *command = [SkyEyeCommandGenerator generateSettingCommandWithDictionary:commmandDic];
    [socketManager setTag:serial commandCategory:key];
    [socketManager sendCommand:command toCamera:key withTag:serial];
}

-(void)updateFileListUponRefresh:(BOOL)refresh{
    PlayerManager *playerManager = [PlayerManager sharedInstance];
    NSDictionary *dic = playerManager.dictionarySetting;
    arrayCameraName = [[NSMutableArray alloc]initWithCapacity:4];
    arrayFileAmount = [[NSMutableArray alloc]initWithCapacity:4];
    for (int i=1; i<=4; i++) {
        NSString *key = [NSString stringWithFormat:@"Setup Camera %d", i];
        NSDictionary *cameraDic = [dic objectForKey:key];
        NSArray *targetFileList = [playerManager.arrayFileNameListCollection objectAtIndex:i-1];
        NSString *amount = [NSString stringWithFormat:@"%d", (int)targetFileList.count];
        [arrayCameraName setObject:cameraDic atIndexedSubscript:i-1];
        [arrayFileAmount setObject:amount atIndexedSubscript:i-1];
    }
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
        NSString *commandCameraName = [NSString stringWithFormat:@"Setup Camera %d", serial-SOCKET_READ_TAG_CAMERA_OFFSET+1];
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
