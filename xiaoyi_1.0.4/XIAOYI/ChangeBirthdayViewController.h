//
//  ChangeBirthdayViewController.h
//  XIAOYI
//
//  Created by 冠一 科技 on 16/4/22.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChangeBirthdayDelegate <NSObject>

- (void)changeBirthdayWith:(NSString *)content;

@end


@interface ChangeBirthdayViewController : UIViewController

@property (nonatomic, strong) NSString *birthString;
@property (nonatomic, assign) id<ChangeBirthdayDelegate>delegate;
//@property (weak, nonatomic) IBOutlet UIDatePicker *birthdayPicker;
@end
