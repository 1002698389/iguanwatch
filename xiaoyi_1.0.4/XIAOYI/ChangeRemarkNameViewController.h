//
//  ChangeRemarkNameViewController.h
//  XIAOYI
//
//  Created by 冠一 科技 on 16/4/22.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChangeRemarkDelegate <NSObject>

@optional
- (void)changeRemarkNameWith:(NSString *)content;

@end

@interface ChangeRemarkNameViewController : UIViewController

@property (nonatomic, strong) NSString *remarkNameString;
@property (nonatomic, strong) id<ChangeRemarkDelegate>delegate;
@end
