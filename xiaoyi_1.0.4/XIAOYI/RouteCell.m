//
//  RouteCell.m
//  TravelConcomitant
//
//  Created by 冠一 科技 on 15/7/15.
//  Copyright (c) 2015年 冠一 科技. All rights reserved.
//

#import "RouteCell.h"

@implementation RouteCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    for (UIView *subView in self.subviews)
    {
        if([subView isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")])
        {
            UIView *confirmView=(UIView *)[subView.subviews firstObject];
            //改背景颜色
//            confirmView.backgroundColor=[UIColor colorWithWhite:0.898 alpha:1.000];
//            confirmView.backgroundColor = [UIColor whiteColor];

            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, confirmView.frame.size.height - 10, confirmView.frame.size.width, 10)];
            view.backgroundColor = [UIColor whiteColor];
            [confirmView addSubview:view];
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, confirmView.frame.size.width, confirmView.frame.size.height - 10)];
            label.text = @"删除";
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            [confirmView addSubview:label];
//            NSLog(@"%lf\n%lf\n%lf\n%lf", confirmView.frame.origin.x, confirmView.frame.origin.y, confirmView.frame.size.width, confirmView.frame.size.height);
            for(UIView *sub in confirmView.subviews)
            {
                //修改字的大小、颜色，这个方法可以修改文字样式
                
//                if ([sub isKindOfClass:NSClassFromString(@"UIButtonLabel")]) {
//                    UILabel *deleteLabel=(UILabel *)sub;
////                    deleteLabel.backgroundColor = [UIColor redColor];
//                    //改删除按钮的字体大小
//                    deleteLabel.font=[UIFont boldSystemFontOfSize:20];
//                    //改删除按钮的文字
//                    deleteLabel.text = @"嘿 嘿";
//                    [deleteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                        make.top.mas_equalTo(confirmView.mas_top).with.offset(0);
//                        make.bottom.mas_equalTo(confirmView.mas_bottom).with.offset(-10);
//                        make.left.mas_equalTo(confirmView.mas_left).with.offset(0);
//                        make.right.mas_equalTo(confirmView.mas_right).with.offset(0);
//                    }];
//                }
                
                NSLog(@"%lf\n%lf\n%lf\n%lf", sub.frame.origin.x, sub.frame.origin.y, sub.frame.size.width, sub.frame.size.height);
                //添加图片
                /*
                if ([sub  isKindOfClass:NSClassFromString(@"UIView")]) {
                    UIView *deleteView = sub;
                    UIImageView *imageView = [[UIImageView alloc] init];
                    imageView.image = [UIImage imageNamed:@"iconfont-zhuchang"];
                    imageView.frame = CGRectMake(CGRectGetMaxX(sub.frame) - 58, -5, 30, 30);
                    [deleteView addSubview:imageView];
                }
                 */
            }
            break;
        }
    }
}

@end
