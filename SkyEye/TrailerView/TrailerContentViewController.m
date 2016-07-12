//
//  TrailerContentViewController.m
//  NuPlayer
//
//  Created by Chia-Cheng Hsu on 7/7/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

#import "TrailerContentViewController.h"

@implementation TrailerContentViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    _backgroundImageView.image = [UIImage imageNamed:_imageFile];
    _titleLabel.text = _titleText;
    [_dismissButtonOutlet setHidden:YES];
}
- (IBAction)dismissTrailer:(id)sender {
    [_delegate removeTrailer];
}
@end
