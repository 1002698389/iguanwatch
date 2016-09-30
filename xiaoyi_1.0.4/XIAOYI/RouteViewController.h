//
//  RouteViewController.h
//  TravelConcomitant
//
//  Created by 冠一 科技 on 15/7/15.
//  Copyright (c) 2015年 冠一 科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THDatePickerViewController.h"

//@protocol changeConstraintDelegate <NSObject>
//
//- (void)changeTopConstraint;
//
//@end

@interface RouteViewController : UIViewController


//@property (nonatomic, assign)id<changeConstraintDelegate>constraintDelegate;
@property (nonatomic, strong) NSString *watchSN;

@property (nonatomic, assign) NSInteger showTripOrLocus;// 1：轨迹图   2：旅程图

@property (nonatomic, strong) NSString *watchUserName;

@property (nonatomic, strong) THDatePickerViewController * datePicker;

@end
