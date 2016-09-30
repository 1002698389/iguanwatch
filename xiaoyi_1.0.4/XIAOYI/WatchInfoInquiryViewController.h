//
//  WatchInfoInquiryViewController.h
//  XIAOYI
//
//  Created by 冠一 科技 on 16/4/21.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol WatchInfoInquiryDelegate <NSObject>

- (void)removeBindingWatch;

@end

@interface WatchInfoInquiryViewController : UIViewController


@property (nonatomic, strong) NSString *locationDetail;
@property (nonatomic, strong) NSString *remarkString;
@property (nonatomic, strong) NSString *deviceRefId;
@property (nonatomic, strong) id<WatchInfoInquiryDelegate>delegate;

@property (nonatomic, assign) NSInteger managedIndex;  //1：非管理员  2：管理员


@property (weak, nonatomic) IBOutlet UIImageView *headImage;


@end
