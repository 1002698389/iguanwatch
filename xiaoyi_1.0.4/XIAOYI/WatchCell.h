//
//  WatchCell.h
//  XIAOYI
//
//  Created by 冠一 科技 on 15/10/26.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WatchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *badgeCount;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *batteryImage;
@end
