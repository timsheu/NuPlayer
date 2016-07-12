//
//  AppDelegate.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/18.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

static void uncaughtExceptionHandler(NSException *exception){
    static const DDLogLevel ddLogLevel = DDLogLevelWarning;
    [[EMailReport sharedInstance] crashed:YES];
    DDLogError(@"CRASH: %@", exception);
    DDLogError(@"Stack Trace: %@", [exception callStackSymbols]);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([[EMailReport sharedInstance] isCrashed]) {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setSubject:@"NuPlayer Crash Log"];
        // Set up recipients
        NSArray *toRecipients = [NSArray arrayWithObject:@"CCHSU20@nuvoton.com"];
        [mailComposer setToRecipients:toRecipients];
        // Attach the Crash Log..
        
        //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
        //                                                         NSUserDomainMask, YES);NSString *documentsDirectory = [paths objectAtIndex:0];
        //    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
        
        NSString *logPath = [[EMailReport sharedInstance] getCurrentLogFile];
        NSData *myData = [NSData dataWithContentsOfFile:logPath];
        [mailComposer addAttachmentData:myData mimeType:@"Text/XML" fileName:@"Report.log"];
        // Fill out the email body text
        NSString *emailBody = @"Crash Log";
        [mailComposer setMessageBody:emailBody isHTML:NO];
        [self.window.rootViewController presentViewController:mailComposer animated:YES completion:nil];
        [[EMailReport sharedInstance] crashed:NO];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
