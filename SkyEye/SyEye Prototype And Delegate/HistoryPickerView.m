//
//  HistoryPickerView.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 3/28/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

#import "HistoryPickerView.h"

@implementation HistoryPickerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithHistoryArray:(NSArray *)array inView:(id)view{
    UINib *nib = [UINib nibWithNibName:@"HistoryPickerView" bundle:nil];
    parentView = (UIView *)view;
    [nib instantiateWithOwner:parentView options:nil];
    historyArray = [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
    return self;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, parentView.bounds.size.width, 50)];
    label.text = [historyArray objectAtIndex:(int)row];
    [label setTextColor:[UIColor whiteColor]];
    if (row == 0) {
        [label setFont:[UIFont fontWithName:@"Courier" size:25]];
    }else{
        [label setFont:[UIFont fontWithName:@"System" size:17]];
    }
    [label setTextAlignment:NSTextAlignmentCenter];
    label.adjustsFontSizeToFitWidth = YES;
    return label;
}

@end
