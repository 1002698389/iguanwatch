//
//  QRcodeViewController.h
//  XIAOYI
//
//  Created by 冠一 科技 on 15/10/28.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZXingObjC/ZXingObjC.h>

@interface QRcodeViewController : UIViewController<ZXCaptureDelegate>
{
    UIView *scannerView;
}
@property (nonatomic, strong) ZXCapture *capture;

/**
 *  1:LoginSB   2: MainSB
 */
@property (nonatomic, assign) int bindingInWhere;

@end
