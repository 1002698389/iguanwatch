//
//  UIViewController+LewPopupViewController.h
//  LewPopupViewController
//
//  Created by pljhonglu on 15/3/4.
//  Copyright (c) 2015年 pljhonglu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LewPopupAnimation <NSObject>
@required
- (void)showView:(UIView*)popupView overlayView:(UIView*)overlayView;
- (void)dismissView:(UIView*)popupView overlayView:(UIView*)overlayView completion:(void (^)(void))completion;

@end




@interface UIViewController (LewPopupViewController)
@property (nonatomic, retain, readonly) UIView *lewPopupView;
@property (nonatomic, retain, readonly) UIView *lewOverlayView;
@property (nonatomic, retain, readonly) id<LewPopupAnimation> lewPopupAnimation;

- (void)lew_presentPopupView:(UIView *)popupView animation:(id<LewPopupAnimation>)animation;
- (void)lew_presentPopupView:(UIView *)popupView animation:(id<LewPopupAnimation>)animation dismissed:(void(^)(void))dismissed;

- (void)lew_dismissPopupView;
- (void)lew_dismissPopupViewWithanimation:(id<LewPopupAnimation>)animation;

//手表设置列表
- (void)showSettingListZero:(id<LewPopupAnimation>)animation; //关于手表
- (void)showSettingListOne:(id<LewPopupAnimation>)animation; //设置手表参数
- (void)showSettingListTwo:(id<LewPopupAnimation>)animation; //设置通讯录
- (void)showSettingListThree:(id<LewPopupAnimation>)animation; //修改手表用户信息
- (void)showSettingListFour:(id<LewPopupAnimation>)animation; //修改头像
- (void)showSettingListFive:(id<LewPopupAnimation>)animation; //设置紧急联系人
- (void)showSettingListSix:(id<LewPopupAnimation>)animation; //关注者列表

@end
