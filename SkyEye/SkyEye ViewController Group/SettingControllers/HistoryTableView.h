//
//  HistoryTableView.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/3/10.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerManager.h"
#import "HistoryTableViewCell.h"
@interface HistoryTableView : UITableView <UITableViewDelegate>{
    NSString *cameraString;
    NSMutableArray *historyArray;
}
-(HistoryTableView *)initWithFrame:(CGRect)frame withCamera:(NSString *)string;
-(void)setCameraString:(NSString *)string;
@end
