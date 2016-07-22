//
//  DVRFileViewController.m
//  
//
//  Created by Chia-Cheng Hsu on 2016/1/26.
//
//

#import "DVRFileViewController.h"

@implementation DVRFileViewController

@synthesize outletTableView = _outletTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    self.refreshControl.backgroundColor = [UIColor grayColor];
    [self.refreshControl addTarget:self action:@selector(refreshFileList) forControlEvents:UIControlEventValueChanged];
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    cellHeight = 20;
    parser = [DVRCommandParser shareInstance];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [self refreshFileList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"File List";
    }else{
        return @"";
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"FileCellPrototype";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *labelName = (UILabel *)[cell viewWithTag:10];
    UILabel *labelDate = (UILabel *)[cell viewWithTag:11];
    UIImageView *image = (UIImageView *)[cell viewWithTag:12];
    labelName.text = [targetDeviceFileList objectAtIndex:indexPath.row];
    NSString *date = [self parseFileDate:labelName.text];
    labelDate.text = [NSString stringWithString:date];
    [image setImage:[UIImage imageNamed:@"video"]];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    targetVideoName = [NSString stringWithString:[targetDeviceFileList objectAtIndex:indexPath.row]];
    [self performSegueWithIdentifier:@"PlayFileIdentifier" sender:self];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

-(void)refreshFileList{
    [self.refreshControl beginRefreshing];
    [self downloadFileListFromCamera:SOCKET_READ_TAG_CAMERA_OFFSET+1];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return targetDeviceFileList.count;
    }else{
        return 0;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

-(void)setupTargetCamera:(NSDictionary *)dic{
    dicTargetCamera = [NSDictionary dictionaryWithDictionary:dic];
    targetDeviceFileList = [NSArray arrayWithArray:[dic objectForKey:@"File List"]];
    [self.tableView reloadData];
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     DVRFilePlayViewController *controller = (DVRFilePlayViewController *)[segue destinationViewController];
     [controller setVideoPath:targetVideoName];
     [controller setDevice:dicTargetCamera];
 }

- (IBAction)actionRefresh:(id)sender {
}

- (void)hostNotResponse{
    DDLogDebug(@"=====host not response=====");
//    [self connectToHost];
}

- (void)connectToHost{
    DVRSocketManager *manager = [DVRSocketManager shareInstance];
    manager.delegate = self;
}
-(void)downloadFileListFromCamera:(int)serial{
    [self.refreshControl beginRefreshing];
    DVRSocketManager *socketManager = [DVRSocketManager shareInstance];
    socketManager.delegate = self;
    DVRPlayerManager *playerManager = [DVRPlayerManager sharedInstance];
    NSString *key = [NSString stringWithFormat:@"Setup DVR"];
    NSDictionary *dic = [playerManager.dictionarySetting objectForKey:key];
    NSString *url = [dic objectForKey:@"URL"];
    NSArray *split = [url componentsSeparatedByString:@"/"];
    DDLogDebug(@"split: %@", split);
    NSDictionary *commmandDic = [NSDictionary dictionaryWithObjectsAndKeys:key, @"Camera", @"Download File List", @"Category", @"N/A", @"Value", nil];
    NSString *command = [DVRCommandGenerator generateSettingCommandWithDictionary:commmandDic];
    [socketManager setTag:serial commandCategory:key];
    [socketManager sendCommand:command toCamera:key withTag:serial];
}
-(NSString *)parseFileDate:(NSString *)filename{
    NSString *returnDate = @"20";
    if (filename.length > 12) {
        NSString *subString = [filename substringWithRange:NSMakeRange(9, 12)];
        NSString *year = [subString substringWithRange:NSMakeRange(0, 2)];
        NSString *month = [subString substringWithRange:NSMakeRange(2, 2)];
        NSString *day = [subString substringWithRange:NSMakeRange(4, 2)];
        NSString *hour = [subString substringWithRange:NSMakeRange(6, 2)];
        NSString *minute = [subString substringWithRange:NSMakeRange(8, 2)];
        NSString *second = [subString substringWithRange:NSMakeRange(10, 2)];
        NSArray *dateArray = [NSArray arrayWithObjects:year, @"/", month, @"/", day, @" ", hour, @":", minute, @":", second, nil];
        for (NSString *s in dateArray) {
            returnDate = [returnDate stringByAppendingString:s];
        }
    }
    if ([returnDate isEqualToString:@"20"] || returnDate == nil) {
        returnDate = @"Unknown Date";
    }
    return returnDate;
}

- (void)setupCameraString:(NSString *)string{
//    cameraString = @"1";
}

- (void)updateFileListUponRefresh:(BOOL)refresh{
    if (refresh) {
        DVRPlayerManager *manager = [DVRPlayerManager sharedInstance];
        NSString *dicKey = [NSString stringWithFormat:@"Setup DVR"];
        NSDictionary *dic = [manager.dictionarySetting objectForKey:dicKey];
        [self setupTargetCamera:dic];
        [self.refreshControl endRefreshing];
    }
}

- (void)hostNotResponse:(int)serial command:(NSString *)command{
    UIAlertView *view = [[UIAlertView alloc]initWithTitle:@"No Response" message:@"It seems that the device is not response, please check the address and internet connection." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [view show];
    [self.refreshControl endRefreshing];
}
- (void)hostResponse:(int)tag{
    
}
@end
