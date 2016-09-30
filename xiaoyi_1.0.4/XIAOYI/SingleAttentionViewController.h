//
//  SingleAttentionViewController.h
//  XIAOYI
//
//  Created by 王帅 on 16/6/28.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FollowerDelegate <NSObject>

- (void)refreshDataAfterDeleteFollower;

@end


@interface SingleAttentionViewController : UIViewController


@property (nonatomic, assign) id<FollowerDelegate>delegate;
@property (nonatomic, strong) NSDictionary *resultDic;

@end
