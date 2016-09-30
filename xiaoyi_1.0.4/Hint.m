//
//  Hint.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/2/3.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "Hint.h"

@implementation Hint

+ (void)showAlertIn:(UIView *)tempView WithMessage:(NSString *)msg {
    UILabel *hintLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, tempView.frame.size.height-90, tempView.frame.size.width- 120, 40)];
    hintLabel.layer.cornerRadius = 5;
    hintLabel.backgroundColor = [UIColor lightGrayColor];
    hintLabel.alpha = 0.0;
    hintLabel.text = msg;
    
    [tempView addSubview:hintLabel];
    [UIView animateWithDuration:1.0 animations:^{
        hintLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        [hintLabel removeFromSuperview];
    }];
}

@end
