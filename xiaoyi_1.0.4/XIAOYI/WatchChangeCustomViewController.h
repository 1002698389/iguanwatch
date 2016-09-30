//
//  WatchChangeCustomViewController.h
//  XIAOYI
//
//  Created by 冠一 科技 on 16/4/22.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChangeCustomInfoDelegate <NSObject>

- (void)changeContentWith:(NSString *)content;

@end

@interface WatchChangeCustomViewController : UIViewController


@property (nonatomic, strong) NSString *content;
@property (nonatomic, assign) NSInteger selectIndex;

@property (nonatomic, assign) id<ChangeCustomInfoDelegate>delegate;
@end
