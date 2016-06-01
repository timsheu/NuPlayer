//
//  SelectCameraTableViewController.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/3/21.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "SelectCameraTableViewController.h"

@interface SelectCameraTableViewController ()

@end

@implementation SelectCameraTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    playerManager = [PlayerManager sharedInstance];
    cameraCollection = [NSMutableArray arrayWithCapacity:4];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    for (int i=1; i<=4; i++) {
        NSString *cameraString = [NSString stringWithFormat:@"Setup Camera %d", i];
        NSDictionary *dic = [playerManager.dictionarySetting objectForKey:cameraString];
        [cameraCollection addObject:dic];
    }    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectCameraIdentifier" forIndexPath:indexPath];
    UILabel *cameraTitle = (UILabel *)[cell viewWithTag:LAYOUT_TAG_TITLE];
    UILabel *cameraName = (UILabel *)[cell viewWithTag:LAYOUT_TAG_CAMERANAME];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SelectCameraIdentifier"];
    }
    NSDictionary *dic = [cameraCollection objectAtIndex:indexPath.row];
    NSString *string = [NSString stringWithFormat:@"Camera %d", indexPath.row + 1];
    cameraTitle.text = string;
    string = [dic objectForKey:@"Name"];
    cameraName.text = string;
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    targetCameraString = [NSString stringWithFormat:@"%d", indexPath.row + 1];
    [self performSegueWithIdentifier:@"LiveViewSegue" sender:self];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITabBarController *dest = (UITabBarController *)[segue destinationViewController];
    LiveViewController *controller = (LiveViewController *)[dest.viewControllers objectAtIndex:0];
    FileViewController *fileController = (FileViewController *)[dest.viewControllers objectAtIndex:1];
    SettingViewController *settingController = (SettingViewController *)[dest.viewControllers objectAtIndex:2];
    [fileController setupCameraString:targetCameraString];
    [settingController setupCameraString:targetCameraString];
    [controller setupCameraString:targetCameraString];
}


@end
