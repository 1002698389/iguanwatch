//
//  LoginWithNamePwdViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/3/9.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "LoginWithNamePwdViewController.h"
#import "PerfectInfoViewController.h"

@interface LoginWithNamePwdViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userPwd;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *forgetPwdBtn;

@end

@implementation LoginWithNamePwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.loginBtn.layer.cornerRadius = 20;
    self.loginBtn.layer.borderWidth = 2;
    self.loginBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.registerBtn.layer.cornerRadius = 15;
//    self.registerBtn.layer.borderColor = RGBACOLOR(239.0, 106.0, 107.0, 1.0).CGColor;
    self.registerBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.registerBtn.layer.borderWidth = 1;
    self.forgetPwdBtn.layer.cornerRadius = 15;
//    self.forgetPwdBtn.layer.borderColor = RGBACOLOR(239.0, 106.0, 107.0, 1.0).CGColor;
    self.forgetPwdBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.forgetPwdBtn.layer.borderWidth = 1;
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"loginName"]);
    NSLog(@"%@",nil);
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"loginName"] == nil) {
        self.userName.text = NSLocalizedString(@"loginVC.userName", @"");
    } else {
        self.userName.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"loginName"];
    }
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"loginPwd"] == nil) {
        self.userPwd.text = NSLocalizedString(@"loginVC.password", @"");
        self.userPwd.secureTextEntry = NO;
    } else {
        self.userPwd.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"loginPwd"];
        self.userPwd.secureTextEntry = YES;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.userName resignFirstResponder];
    [self.userPwd resignFirstResponder];
}
#pragma mark - UItextFeild Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextFeild Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField becomeFirstResponder];
    
     if (textField == self.userName) {
         if ([textField.text isEqual:NSLocalizedString(@"loginVC.userName", @"")]) {
                textField.text = @"";
         }
     } else if (textField == self.userPwd) {
         if ([textField.text isEqual:NSLocalizedString(@"loginVC.password", @"")]) {
             textField.text = @"";
             textField.secureTextEntry = YES;
         }
     }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    
     if (textField == self.userName) {
         if ([textField.text isEqual:@""]) {
             textField.text = NSLocalizedString(@"loginVC.userName", @"");
         }
     } else if (textField == self.userPwd) {
         if ([textField.text isEqual:@""]) {
             textField.text = NSLocalizedString(@"loginVC.password", @"");
             textField.secureTextEntry = NO;
         }
     }
    
}

#pragma mark - 登录
- (IBAction)doLogin:(id)sender {
    if ([self.userName.text isEqual:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"loginVC.userName", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    } else if ([self.userPwd.text isEqual:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"loginVC.password", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    [self.userName resignFirstResponder];
    [self.userPwd resignFirstResponder];
    MBProgressHUD *HUD = [MBProgressHUD bwm_showHUDAddedTo:self.view title:NSLocalizedString(@"MBProgressHUD.login", @"")];
    //用户名密码登陆
    NSString *pwdStr = [MD5Helper md5:self.userPwd.text];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/user/loginUniversal.do?userName=%@&pwd=%@&roleType=3&terminal=%@", DNS, self.userName.text, pwdStr, [JPUSHService registrationID]];
    NSLog(@"%@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            
            NSDictionary *dic = [responseObject objectForKey:@"content"];
            NSString *huanxinUserName = [dic objectForKey:@"HuanXinUserName"];
            NSString *huanxinUserPwd = [dic objectForKey:@"HuanXinPwd"];
            [[NSUserDefaults standardUserDefaults] setValue:[dic objectForKey:@"token"] forKey:@"token"];
            [[NSUserDefaults standardUserDefaults] setValue:huanxinUserName forKey:@"HuanXinUserName"];
            [[NSUserDefaults standardUserDefaults] setValue:huanxinUserPwd forKey:@"HuanXinPwd"];
            [[NSUserDefaults standardUserDefaults] setValue:self.userName.text forKey:@"accountTel"];
            
            [[NSUserDefaults standardUserDefaults] setValue:self.userName.text forKey:@"loginName"];
            [[NSUserDefaults standardUserDefaults] setValue:self.userPwd.text forKey:@"loginPwd"];
//            [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"selectedIndex"];
//            EMError *error = nil;
//            NSDictionary *loginInfo = [[EaseMob sharedInstance].chatManager loginWithUsername:huanxinUserName password:huanxinUserPwd error:&error];
//            if (!error && loginInfo) {
//                NSLog(@"登陆成功");
//            } else
//                NSLog(@"%@",error);
            
            [self getWatchList];
//            [self getHuanXinFriends];
            [HUD hide:YES];

        } else if ([[responseObject objectForKey:@"code"] intValue] == -10007) {
            [HUD hide:YES];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"loginVC.noUserName", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([[responseObject objectForKey:@"code"] intValue] == -10006) {
            [HUD hide:YES];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"loginVC.noPassword", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([[responseObject objectForKey:@"code"] intValue] == -10005) {
            [HUD hide:YES];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"loginVC.noUser", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        }
        else {
            [HUD hide:YES];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:[responseObject objectForKey:@"showToUI"] delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [HUD hide:YES];
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
    }];
}

- (void)getWatchList {

    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/getCareWatchList.do?t=%@", DNS, [[NSUserDefaults standardUserDefaults] valueForKey:@"token"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
                NSArray *result = [responseObject objectForKey:@"content"];
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hadLogged"];
                //通知主要刷新
                NSNotification *notification = [NSNotification notificationWithName:@"setWatchUserInfo" object:result];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                
//                NSNotification *notification1 = [NSNotification notificationWithName:@"changeUser" object:nil userInfo:nil];
//                [[NSNotificationCenter defaultCenter] postNotification:notification1];
                
//                [self getHuanXinFriends];
                [self dismissViewControllerAnimated:YES completion:NULL];
            } else {
                NSLog(@"aad");
//                [self performSegueWithIdentifier:@"doLogin" sender:self];
                [self performSegueWithIdentifier:@"goPerfectVC" sender:self];
            }
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];

    }];
}

/*
- (void)getHuanXinFriends {
    //    MBProgressHUD *HUD = [MBProgressHUD bwm_showHUDAddedTo:self.view title:kBWMMBProgressHUDMsgLoading];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/huanxin/getHuanXinFriendsInMobile.do?t=%@&v=1",DNS, [[NSUserDefaults standardUserDefaults] valueForKey:@"token"]];
        NSLog(@"%@",urlStr);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            int a = [[responseObject objectForKey:@"code"] intValue];
            //            [HUD hide:YES];
            if (a == 1000) {
                if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
                    NSArray *list = [responseObject objectForKey:@"content"];
                    NSLog(@"%@",list);
//                    [[NSUserDefaults standardUserDefaults] setObject:list forKey:@"huanxinBuddy"];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                    NSString *fileName = [NSString stringWithFormat:@"%@_huanxinFriends",[[NSUserDefaults standardUserDefaults] valueForKey:@"loginName"]];
                    NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
                    //写缓存
                    [NSKeyedArchiver archiveRootObject:list toFile:filePath];
                }
                [self getWatchList];
            } else {
                
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:@"登陆失败，请重新登陆" delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }];
    });
}
 */
 
#pragma mark - 注册
- (IBAction)doRegister:(id)sender {
    [self performSegueWithIdentifier:@"doRegister" sender:self];
}

#pragma mark - 忘记密码
- (IBAction)forgetPwd:(id)sender {
    [self performSegueWithIdentifier:@"checkTel" sender:self];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqual:@"goPerfectVC"]) {
        PerfectInfoViewController *perfectVC = [segue destinationViewController];
        perfectVC.bindingInWhere = 1;
    }
}


@end
