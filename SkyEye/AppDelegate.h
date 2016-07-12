//
//  AppDelegate.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/18.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "EMailReport.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

