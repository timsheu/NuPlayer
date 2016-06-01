//
//  FileCellPrototype.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/26.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FileCellPrototype : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *outletThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *outletLabelFileName;
@property (weak, nonatomic) IBOutlet UILabel *outletLabelFileDate;
@property (weak, nonatomic) IBOutlet UILabel *outletLabelFileSize;
//@property int position;
//@property float cellHeight;
//- (FileCellPrototype *)initWithFileData: (NSArray *)dataArray;
@end
