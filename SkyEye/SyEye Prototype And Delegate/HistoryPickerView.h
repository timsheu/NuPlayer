//
//  HistoryPickerView.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 3/28/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryPickerView : UIPickerView <UIPickerViewDelegate>{
    NSArray *historyArray;
    UIView *parentView;
}

@property (weak, nonatomic) IBOutlet UIPickerView *historyPicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonDone;
- (id) initWithHistoryArray:(NSArray *)array inView:(id)view;
@end
