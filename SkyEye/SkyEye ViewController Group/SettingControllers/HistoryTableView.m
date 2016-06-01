//
//  HistoryTableView.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/3/10.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "HistoryTableView.h"

@implementation HistoryTableView

-(HistoryTableView *)initWithFrame:(CGRect)frame withCamera:(NSString *)string{
    if (self = [super init]) {
        self = [[HistoryTableView alloc]initWithFrame:frame];
        cameraString = string;
        historyArray = [NSMutableArray arrayWithObjects:@"a", @"b", @"c", nil];
    }
    return self;
}

#pragma table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"history cell clicked: %d", indexPath.row);
}

-(NSInteger)numberOfSections{
    return 1;
}

-(NSInteger)numberOfRowsInSection:(NSInteger)section{
    return historyArray.count;
}

-(HistoryTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"HistoryCellIdentifier";
    HistoryTableViewCell *cell = [[HistoryTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//    cell.historyLabel.text = @"A";
    if (cell == nil) {
        cell = [[HistoryTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

#pragma general

-(void)setCameraString:(NSString *)string{
    cameraString = [NSString stringWithString:string];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
