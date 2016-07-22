//
//  QRCodeViewController.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/3/8.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHChainableAnimations.h"
#import "QRCodeGenerator.h"
#import "PlayerManager.h"
@interface QRCodeViewController : UIViewController{
    NSString *localString;
    UIImage *localImage;
}
@property (strong, nonatomic) IBOutlet UIImageView *imageQRCode;
- (void)setImage:(UIImage *)image;
- (void)setString:(NSString *)string;
@end