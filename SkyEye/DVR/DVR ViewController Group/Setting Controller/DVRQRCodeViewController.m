//
//  DVRQRCodeViewController.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/3/8.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "DVRQRCodeViewController.h"

@interface DVRQRCodeViewController ()

@end

@implementation DVRQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *image = [QRCodeGenerator qrImageForString:localString imageSize:self.view.bounds.size.width];
    [_imageQRCode setImage:image];
    DDLogDebug(@"viewdidload: image view width: %f", _imageQRCode.bounds.size.width);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
    
    // Save image.
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setImage:(UIImage *)image{
    localImage = image;
    DDLogDebug(@"image view width: %f", _imageQRCode.bounds.size.width);
}
- (void)setString:(NSString *)string{
    localString = [NSString stringWithString:string];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
