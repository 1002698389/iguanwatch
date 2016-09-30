//
//  SelectBindingWayViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 15/11/3.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import "SelectBindingWayViewController.h"
#import "QRcodeViewController.h"
#import "PerfectInfoViewController.h"
#import "QRViewController.h"

@interface SelectBindingWayViewController ()
{
    int _chooseQRcode;// 1：二维码    2：输入手表序列号
}
@property (weak, nonatomic) IBOutlet UIButton *qrcodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *watchIdBtn;

@end

@implementation SelectBindingWayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = YES;
    
    self.qrcodeBtn.layer.cornerRadius = 15;
    self.qrcodeBtn.layer.borderWidth = 2;
    self.qrcodeBtn.layer.borderColor = [[UIColor colorWithRed:239.0/255.0 green:106.0/255.0 blue:107.0/255.0 alpha:1.0] CGColor];
    self.watchIdBtn.layer.cornerRadius = 15;
    self.watchIdBtn.layer.borderWidth = 2;
    self.watchIdBtn.layer.borderColor = [[UIColor colorWithRed:239.0/255.0 green:106.0/255.0 blue:107.0/255.0 alpha:1.0] CGColor];
    
    
    self.navigationItem.leftBarButtonItem = nil;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (IBAction)bindingByQRcode:(id)sender {
     
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
    PerfectInfoViewController *one = [storyboard instantiateViewControllerWithIdentifier:@"perfectInfoLogin"];
    one.bindingInWhere = 1;
    one.selectedQRcode = 1;
    [self.navigationController pushViewController:one animated:YES];
}

- (IBAction)bindingByWatchId:(id)sender {
//    _chooseQRcode = 2;
//    [self performSegueWithIdentifier:@"bindingByIdInLogin" sender:self];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
    PerfectInfoViewController *one = [storyboard instantiateViewControllerWithIdentifier:@"perfectInfoLogin"];
    one.bindingInWhere = 1;
    one.selectedQRcode = 2;
    [self.navigationController pushViewController:one animated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqual:@"bindingByQRcodeInLogin"]) {
//        QRcodeViewController *qrVC = [segue destinationViewController];
//        qrVC.bindingInWhere = 1;
        QRViewController *qrVC = [segue destinationViewController];
        qrVC.bindingFrom = 1;
        
    } else if ([[segue identifier] isEqual:@"bindingByIdInLogin"]) {
        PerfectInfoViewController *perfectVC = [segue destinationViewController];
        perfectVC.bindingInWhere = 1;
        perfectVC.selectedQRcode = _chooseQRcode;
    }
}


@end
