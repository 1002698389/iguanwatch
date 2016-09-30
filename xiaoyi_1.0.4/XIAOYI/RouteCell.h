//
//  RouteCell.h
//  TravelConcomitant
//
//  Created by 冠一 科技 on 15/7/15.
//  Copyright (c) 2015年 冠一 科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *typeImage;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *stayTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@end
