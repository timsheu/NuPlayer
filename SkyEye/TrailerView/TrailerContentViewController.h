//
//  TrailerContentViewController.h
//  NuPlayer
//
//  Created by Chia-Cheng Hsu on 7/7/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TrailerContentViewController;
@protocol TrailerDelegate <NSObject>

- (void) removeTrailer;

@end
@interface TrailerContentViewController : UIViewController
@property (weak, nonatomic) id <TrailerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)dismissTrailer:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *dismissButtonOutlet;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;
@end
