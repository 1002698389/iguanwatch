//
//  WatchUserInfoViewController.h
//  XIAOYI
//
//  Created by 冠一 科技 on 15/11/9.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WatchUserInfoDelegate <NSObject>

- (void)refreshWatchUserInfo;

@end

@interface WatchUserInfoViewController : UIViewController

@property (nonatomic, assign) id<WatchUserInfoDelegate>delegate;

@end
