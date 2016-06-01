//
//  FileViewController.h
//  
//
//  Created by Chia-Cheng Hsu on 2016/1/26.
//
//

#import <UIKit/UIKit.h>
#import "FileCellPrototype.h"
#import "SocketManager.h"
#import "FilePlayViewController.h"
#import "SkyEyeCommandGenerator.h"
@interface FileViewController : UITableViewController <SocketManagerDelegate>{
    NSArray *targetDeviceFileList;
    float cellHeight;
    BOOL isFullScreen;
    NSDictionary *dicTargetCamera;
    NSString *targetVideoName;
    NSString *cameraString;
}
@property (weak, nonatomic) IBOutlet UITableView *outletTableView;

- (void)setupTargetCamera:(NSDictionary *)dic;
- (void)setupCameraString:(NSString *)string;
@end
