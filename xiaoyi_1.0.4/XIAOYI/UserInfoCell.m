//
//  UserInfoCell.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/4/5.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "UserInfoCell.h"

@implementation UserInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.headImage.layer.cornerRadius = 20;
    self.headImage.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
