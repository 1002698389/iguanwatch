//
//  ForgetPwdViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/3/18.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "ForgetPwdViewController.h"

@interface ForgetPwdViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *pwd1TF;
@property (weak, nonatomic) IBOutlet UITextField *pwd2TF;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@end

@implementation ForgetPwdViewController


- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = NO;
    
    self.submitBtn.layer.cornerRadius = 15;
    self.submitBtn.layer.borderWidth = 2;
    self.submitBtn.layer.borderColor = RGBACOLOR(105, 206, 251, 1.0).CGColor;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)doChange:(id)sender {
    if (![self.pwd1TF.text isEqual:self.pwd2TF.text]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"register.confirmPassword", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    MBProgressHUD *HUD = [MBProgressHUD bwm_showHUDAddedTo:self.view title:kBWMMBProgressHUDMsgLoading];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //        NSError *error;
        NSString *pwdStr = [MD5Helper md5:self.pwd1TF.text];
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/user/resetPassword.do?telNum=%@&password=%@",DNS,self.telNum, pwdStr];
        NSLog(@"%@",urlStr);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            int a = [[responseObject objectForKey:@"code"] intValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                if (a == 1000) {
                    [[NSUserDefaults standardUserDefaults] setValue:self.pwd1TF.text forKey:@"loginPwd"];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:[responseObject objectForKey:@"devMessage"] delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
                    [alertView show];
                }
            });
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [HUD hide:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"Alert.resetPwd", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
                [alertView show];
            });
        }];
        
    });
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
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
