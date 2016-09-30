//
//  AttentionListViewController.h
//  XIAOYI
//
//  Created by 冠一 科技 on 16/3/29.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@protocol AttentionListDelegate <NSObject>

- (void)refreshWatchListInfo;

@end


@interface AttentionListViewController : UIViewController<MGSwipeTableCellDelegate>

@property (nonatomic, assign) id<AttentionListDelegate>delegate;
@end
