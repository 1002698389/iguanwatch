
//
//  ChangePwdViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/3/10.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "ChangePwdViewController.h"

@interface ChangePwdViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *oldPwd;
@property (weak, nonatomic) IBOutlet UITextField *changedPwd;
@property (weak, nonatomic) IBOutlet UITextField *pwdAgain;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet UIView *pwdBgView;
@end

@implementation ChangePwdViewController


- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.submitBtn.layer.cornerRadius = 15;
    self.pwdBgView.layer.borderWidth = 1;
    self.pwdBgView.layer.borderColor = RGBACOLOR(185, 185, 185, 1.0).CGColor;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doCHangePwd:(id)sender {
    if (![self.changedPwd.text isEqual:self.pwdAgain.text]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"registerVC.pwdNotMatch", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
//    NSString *oldPwd = [self.oldPwd.text stringByAppendingString:@""];
//    NSString *newPwd = [self.changedPwd.text stringByAppendingString:@""];
//    MBProgressHUD *HUD = [MBProgressHUD bwm_showHUDAddedTo:self.view title:kBWMMBProgressHUDMsgLoading];
    NSString *urlStr = [NSString stringWithFormat:@"http://%@/user/updatePassword.do?t=%@&oldPwd=%@&newPwd=%@",DNS, [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], [MD5Helper md5:self.oldPwd.text], [MD5Helper md5:self.changedPwd.text]];
    NSLog(@"%@",urlStr);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        int a = [[responseObject objectForKey:@"code"] intValue];
        dispatch_async(dispatch_get_main_queue(), ^{
//            [HUD hide:YES];
            if (a == 1000) {
                [self.navigationController popViewControllerAnimated:YES];
            } else if (a == 1005) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"Alert.oldpwdError", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
                [alertView show];
            }  else if ([[responseObject objectForKey:@"code"] intValue] == -1006) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"Alert.expired", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
                alertView.tag = 999;
                [alertView show];
            } else if ([[responseObject objectForKey:@"code"] intValue] == -1007) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"Alert.invalid", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
                alertView.tag = 999;
                [alertView show];
            }  else {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:[responseObject objectForKey:@"showToUI"] delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
                alertView.tag = 999;
                [alertView show];
            }
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];

    }];

}

#pragma mark - UITextFeild Delegate 
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 取消键盘响应
- (IBAction)dismissKeyboard:(id)sender {
    [self.oldPwd resignFirstResponder];
    [self.changedPwd resignFirstResponder];
    [self.pwdAgain resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
