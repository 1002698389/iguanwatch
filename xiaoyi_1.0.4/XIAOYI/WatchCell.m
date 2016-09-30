//
//  WatchCell.m
//  XIAOYI
//
//  Created by 冠一 科技 on 15/10/26.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import "WatchCell.h"

@implementation WatchCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.headImage.layer.cornerRadius = 15;
    self.headImage.layer.masksToBounds = YES;
    self.badgeCount.layer.cornerRadius = 7;
    self.badgeCount.clipsToBounds = YES;
    self.badgeCount.textAlignment = NSTextAlignmentCenter;
    self.badgeCount.adjustsFontSizeToFitWidth = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
