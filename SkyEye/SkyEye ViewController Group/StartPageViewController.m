//
//  StartPageViewController.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/25.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "StartPageViewController.h"

@implementation StartPageViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    [[self navigationController]setNavigationBarHidden:YES animated:NO];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [[self navigationController]setNavigationBarHidden:YES animated:YES];
//    [_skyEyeButton setEnabled:NO];
}
@end
