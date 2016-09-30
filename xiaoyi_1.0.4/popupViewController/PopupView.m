//
//  PopupView.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/1/26.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "PopupView.h"
#import "UIViewController+LewPopupViewController.h"
#import "LewPopupViewAnimationFade.h"
#import "LewPopupViewAnimationSlide.h"
#import "LewPopupViewAnimationSpring.h"
#import "LewPopupViewAnimationDrop.h"

@implementation PopupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil];
        _innerView.frame = frame;
        [self addSubview:_innerView];
    }
    return self;
}

+ (instancetype)defaultPopupView{
    return [[PopupView alloc]initWithFrame:CGRectMake(0, 0, 140, 220)];
}

- (IBAction)showAboutWatchInfo:(id)sender {
    LewPopupViewAnimationSlide *animation = [[LewPopupViewAnimationSlide alloc]init];
    animation.type = LewPopupViewAnimationSlideTypeTopTop;
    [_parentVC showSettingListZero:animation];
}

- (IBAction)showWatchParameters:(id)sender {
    LewPopupViewAnimationSlide *animation = [[LewPopupViewAnimationSlide alloc]init];
    animation.type = LewPopupViewAnimationSlideTypeTopTop;
    [_parentVC showSettingListOne:animation];
//    [_parentVC lew_dismissPopupViewWithanimation:animation];
    
}

- (IBAction)setContacts:(id)sender {
    LewPopupViewAnimationSlide *animation = [[LewPopupViewAnimationSlide alloc]init];
    animation.type = LewPopupViewAnimationSlideTypeTopTop;
    [_parentVC showSettingListTwo:animation];
//    [_parentVC lew_dismissPopupViewWithanimation:animation];
}

- (IBAction)setUserInfo:(id)sender {
    LewPopupViewAnimationSlide *animation = [[LewPopupViewAnimationSlide alloc]init];
    animation.type = LewPopupViewAnimationSlideTypeTopTop;
    [_parentVC showSettingListThree:animation];
//    [_parentVC lew_dismissPopupViewWithanimation:animation];
}

- (IBAction)changeUserHeadImage:(id)sender {
    LewPopupViewAnimationSlide *animation = [[LewPopupViewAnimationSlide alloc]init];
    animation.type = LewPopupViewAnimationSlideTypeTopTop;
    [_parentVC showSettingListFour:animation];
//    [_parentVC lew_dismissPopupViewWithanimation:animation];
}

- (IBAction)setUrgentContacts:(id)sender {
    LewPopupViewAnimationSlide *animation = [[LewPopupViewAnimationSlide alloc]init];
    animation.type = LewPopupViewAnimationSlideTypeTopBottom;
    [_parentVC showSettingListFive:animation];
//    [_parentVC lew_dismissPopupViewWithanimation:animation];
}

- (IBAction)showAttentionList:(id)sender {
    LewPopupViewAnimationSlide *animation = [[LewPopupViewAnimationSlide alloc]init];
    animation.type = LewPopupViewAnimationSlideTypeTopTop;
    [_parentVC showSettingListSix:animation];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
