//
//  DVRFileViewController.h
//  
//
//  Created by Chia-Cheng Hsu on 2016/1/26.
//
//

#import <UIKit/UIKit.h>
#import "DVRFileCellPrototype.h"
#import "DVRSocketManager.h"
#import "DVRCommandParser.h"
#import "DVRCommandGenerator.h"
#import "DVRFilePlayViewController.h"
@interface DVRFileViewController : UITableViewController <DVRSocketManagerDelegate>{
    NSArray *targetDeviceFileList;
    float cellHeight;
    BOOL isFullScreen;
    DVRCommandParser *parser;
    NSDictionary *dicTargetCamera;
    NSString *targetVideoName;
}
@property (weak, nonatomic) IBOutlet UITableView *outletTableView;

- (void)setupTargetCamera:(NSDictionary *)dic;
@end
