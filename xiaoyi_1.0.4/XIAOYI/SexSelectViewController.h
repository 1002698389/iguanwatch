//
//  SexSelectViewController.h
//  XIAOYI
//
//  Created by 冠一 科技 on 16/4/22.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChangeSexDelegate <NSObject>

- (void)changeSexWith:(NSString *)content;

@end

@interface SexSelectViewController : UIViewController

@property (nonatomic, strong) NSString *sexIndex;
@property (nonatomic, strong) id<ChangeSexDelegate>delegate;
@end
