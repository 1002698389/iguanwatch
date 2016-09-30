//
//  PerfectInfoViewController.h
//  XIAOYI
//
//  Created by 王帅 on 15/11/1.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PerfectInfoViewController : UIViewController

@property (nonatomic, strong) NSString *qrcodeWatchId;



///从登陆界面或者主界面进入绑定界面  1：登陆界面跳转到绑定界面  2：主界面跳转到绑定界面
@property (nonatomic, assign) int bindingInWhere;

/**
 *通过二维码扫描或是手动输入手表序列号 1：二维码   2：输入手表序列号
 */
///
@property (nonatomic, assign) int selectedQRcode;

@end
