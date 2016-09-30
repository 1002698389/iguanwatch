//
//  MapLoctionViewController.h
//  XIAOYI
//
//  Created by 冠一 科技 on 15/10/23.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapLoctionViewController : UIViewController

@property (nonatomic, assign) float lat;
@property (nonatomic, assign) float lon;

@property (nonatomic, assign) CLLocationCoordinate2D *locationCoordinate;

@end
