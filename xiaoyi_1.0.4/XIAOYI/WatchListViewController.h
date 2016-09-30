//
//  WatchListViewController.h
//  XIAOYI
//
//  Created by 冠一 科技 on 16/3/31.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WatchListVCDelegate <NSObject>

- (void)selectOneWatchWithIndex:(NSInteger)index;
- (void)deleteWatchWithIndex:(NSInteger)index;
@end

@interface WatchListViewController : UIViewController


@property (nonatomic, assign) id<WatchListVCDelegate>delegate;
@end
