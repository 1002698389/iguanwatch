
//
//  RegisterViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/3/3.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()
{
    NSString *_codeText;
}
@property (weak, nonatomic) IBOutlet UITextField *telTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UITextField *pwdTF;
@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;
@property (weak, nonatomic) IBOutlet UILabel *getCodeLabel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int resetTime;

@property (weak, nonatomic) IBOutlet UITextField *upPwd;

@property (weak, nonatomic) IBOutlet UIButton *registerBtn;


@end

@implementation RegisterViewController



- (IBAction)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.resetTime = 60;

//    self.getCodeBtn.layer.cornerRadius = 15;
//    self.getCodeBtn.layer.borderWidth = 2;
//    self.getCodeBtn.layer.borderColor = RGBACOLOR(250, 184, 186, 1.0).CGColor;
    self.registerBtn.layer.cornerRadius = 15;
    self.registerBtn.layer.borderWidth = 2;
    self.registerBtn.layer.borderColor = RGBACOLOR(105, 206, 251, 1.0).CGColor;
    
    [self.telTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.codeTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.telTF) {
        if (textField.text.length > 11) {
            textField.text = [textField.text substringToIndex:11];
        }
    } else if (textField == self.codeTF) {
        if (textField.text.length > 6) {
            textField.text = [textField.text substringToIndex:6];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFeild Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField becomeFirstResponder];
    /*
    if (textField == self.telTF) {
        if ([textField.text isEqual:@"请输入手机号"]) {
            textField.text = @"";
        }
    } else if (textField == self.codeTF) {
        if ([textField.text isEqual:@"请输入验证码"]) {
            textField.text = @"";
        }
    } else if (textField == self.pwdTF) {
        if ([textField.text isEqual:@"请输入登陆密码（至少6位）"]) {
            textField.text = @"";
            textField.secureTextEntry = YES;
        }
    }    */
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    /*
    if (textField == self.telTF) {
        if ([textField.text isEqual:@""]) {
            textField.text = @"请输入手机号";
        }
    } else if (textField == self.codeTF) {
        if ([textField.text isEqual:@""]) {
            textField.text = @"请输入验证码";
        }
    } else if (textField == self.pwdTF) {
        if ([textField.text isEqual:@""]) {
            textField.secureTextEntry = NO;
            textField.text = @"请输入登陆密码（至少6位）";
        }
    }
     */
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    [UIView beginAnimations:@"stratEditing" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.3];
    self.view.frame = CGRectMake(0, -60, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [UIView beginAnimations:@"endEditing" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.3];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
    
    return YES;
}

#pragma mark - dismissKeyboard
- (IBAction)dismissKeyboard:(id)sender {
    [UIView beginAnimations:@"endEditing" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.3];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.telTF resignFirstResponder];
    [self.codeTF resignFirstResponder];
    [self.upPwd resignFirstResponder];
    [self.pwdTF resignFirstResponder];
    [UIView commitAnimations];
}

# pragma mark - /*手机号码验证 MODIFIED BY HELENSONG*/
- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9])\\d{8}$";
    /**
     10 * 中国移动：China Mobile
     11 * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12 */
    NSString * CM = @"^1(34[0-8]|47[0-9]|(3[5-9]|5[017-9]|8[2378])\\d)\\d{7}$";
    /**
     15 * 中国联通：China Unicom
     16 * 130,131,132,152,155,156,185,186
     17 */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20 * 中国电信：China Telecom
     21 * 133,1349,153,180,181,189
     22 */
    NSString * CT = @"^1((33|53|8[019])[0-9]|349)\\d{7}$";
    /**
     25 * 大陆地区固话及小灵通
     26 * 区号：010,020,021,022,023,024,025,027,028,029
     27 * 号码：七位或八位
     28 */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - 获取验证码
- (IBAction)getCode:(id)sender {
    [self.getCodeBtn setBackgroundColor:[UIColor lightGrayColor]];
    self.getCodeBtn.userInteractionEnabled = NO;
    if (![self isMobileNumber:self.telTF.text]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:@"手机号码输入有误，请重新输入" delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
        [self.getCodeBtn setBackgroundColor:[UIColor whiteColor]];
        self.getCodeBtn.userInteractionEnabled = YES;
        return;
    }
    //    NSError *error;
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@/msg/sendIdCodeSMS.do?v=1&telNum=%@" ,DNS ,self.telTF.text];
    NSLog(@"%@",urlStr);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        int a = [[responseObject objectForKey:@"code"] intValue];
        if (a == 1000) {
            _codeText = [responseObject objectForKey:@"content"];
            self.timer =  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeBottomBtnState) userInfo:nil repeats:YES];
            self.getCodeBtn.backgroundColor = [UIColor lightGrayColor];
            self.getCodeLabel.textColor = [UIColor whiteColor];
//            [self.getCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.timer fire];
//            [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(setVerificationBtnColor) userInfo:nil repeats:NO];
        } else {
            [self.getCodeBtn setBackgroundColor:[UIColor whiteColor]];
            self.getCodeBtn.userInteractionEnabled = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self setVerificationBtnColor];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:@"获取验证码失败,请稍后再试" delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
    }];
}

- (void)changeBottomBtnState
{
    self.resetTime--;
    if (self.resetTime != 0) {
//        [self.getCodeBtn setTitle:[NSString stringWithFormat:@"%ds后重试",self.resetTime] forState:UIControlStateNormal];
        self.getCodeLabel.text = [NSString stringWithFormat:@"%ds后重试",_resetTime];
        
        self.getCodeBtn.userInteractionEnabled = NO;
    } else {
        [self.timer invalidate];
        self.resetTime = 60;
//        [self.getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.getCodeLabel.text = @"重新获取验证码";
        self.getCodeLabel.textColor = [UIColor colorWithRed:239.0/255.0 green:106.0/255.0 blue:107.0/255.0 alpha:1.0];
        [self.getCodeBtn setBackgroundColor:[UIColor whiteColor]];
        [self.getCodeBtn setTitleColor:[UIColor colorWithRed:109.0/255.0 green:193.0/255.0 blue:242.0/255.0 alpha:1] forState:UIControlStateNormal];
        self.getCodeBtn.userInteractionEnabled = YES;
    }
}

- (void)setVerificationBtnColor {
    [self.getCodeBtn setBackgroundColor:[UIColor whiteColor]];
    self.getCodeBtn.userInteractionEnabled = YES;
}


#pragma mark - 注册
- (IBAction)doRegister:(id)sender {
    if ([self.upPwd.text length] < 6 || [self.pwdTF.text length] < 6) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"registerVC.passwordLength", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    NSString *uppwd = [MD5Helper md5:self.upPwd.text];
    NSString *pwd = [MD5Helper md5:self.pwdTF.text];
    
    if (![self.upPwd.text isEqual:self.pwdTF.text]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"register.confirmPassword", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if ([self.telTF.text isEqual:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"registerVC.noTel", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    

//    if (![self.codeTF.text isEqual:_codeText]) {
//        return;
//    }
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/user/registerUser.do?userName=%@&pwd=%@&upPwd=%@" , DNS, self.telTF.text, uppwd, pwd];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
//            UILabel *hintLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, self.view.frame.size.height-90, self.view.frame.size.width- 120, 40)];
//            hintLabel.layer.cornerRadius = 5;
//            hintLabel.backgroundColor = RGBACOLOR(236.0, 236.0, 236.0, 1.0);
//            hintLabel.alpha = 0.0;
//            hintLabel.text = @"注册成功";
//            [self.view addSubview:hintLabel];
//            [UIView animateWithDuration:0.5 animations:^{
//                hintLabel.alpha = 1.0;
//            } completion:^(BOOL finished) {
//                [hintLabel removeFromSuperview];
//            }];
            [Hint showAlertIn:self.view WithMessage:@"注册成功"];
            [[NSUserDefaults standardUserDefaults] setValue:self.telTF.text forKey:@"loginName"];
            [[NSUserDefaults standardUserDefaults] setValue:self.pwdTF.text forKey:@"loginPwd"];
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(goBack) userInfo:nil repeats:NO];
//            [self.navigationController popViewControllerAnimated:YES];
        } else if ([[responseObject objectForKey:@"code"] intValue] == -10003) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"registerVC.telBeRegistered", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"") message:[responseObject objectForKey:@"showToUI"] delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];

    }];
    
}

#pragma mark - 用户隐私协议

- (IBAction)showPrivacyAgreement:(id)sender {
    [self performSegueWithIdentifier:@"showUserPrivacyAgreement" sender:self];
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
