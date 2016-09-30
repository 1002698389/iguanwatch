//
//  PopupView.h
//  XIAOYI
//
//  Created by 冠一 科技 on 16/1/26.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface PopupView : UIView

@property (strong, nonatomic) IBOutlet UIView *innerView;
@property (nonatomic, weak)UIViewController *parentVC;

+ (instancetype)defaultPopupView;
@end
