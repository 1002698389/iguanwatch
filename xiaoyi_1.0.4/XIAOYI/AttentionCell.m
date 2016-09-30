//
//  AttentionCell.m
//  XIAOYI
//
//  Created by 王帅 on 16/6/28.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "AttentionCell.h"

@implementation AttentionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.headImage.layer.cornerRadius = self.headImage.frame.size.width/2;
    self.headImage.layer.masksToBounds = YES;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
