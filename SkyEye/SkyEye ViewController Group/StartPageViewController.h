//
//  StartPageViewController.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/25.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrailerContentViewController.h"

@interface StartPageViewController : UIViewController <UIPageViewControllerDataSource, TrailerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *skyEyeButton;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;
- (IBAction)showTutorial:(id)sender;

@end
