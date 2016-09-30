//
//  TelCheckViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/3/18.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "TelCheckViewController.h"
#import "ForgetPwdViewController.h"

@interface TelCheckViewController ()<UITextFieldDelegate>
{
    NSString *_codeText;
}

@property (weak, nonatomic) IBOutlet UITextField *telNum;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;
@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;
@property (weak, nonatomic) IBOutlet UILabel *getCodeLabel;
@property (nonatomic, assign) int resetTime;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation TelCheckViewController


- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    self.resetTime = 60;

    self.navigationController.navigationBarHidden = NO;
    
    self.checkBtn.layer.cornerRadius = 15;
    self.checkBtn.layer.borderWidth = 1;
    self.checkBtn.layer.borderColor = RGBACOLOR(105, 206, 251, 1.0).CGColor;
    
//    self.getCodeBtn.layer.cornerRadius = 15;
//    self.getCodeBtn.layer.borderWidth = 2;
//    self.getCodeBtn.layer.borderColor = RGBACOLOR(250, 184, 186, 1.0).CGColor;
    
    [self.telNum addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.codeTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 输入框控制输入长度  手机号11位  验证码6位
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.telNum) {
        if (textField.text.length > 11) {
            textField.text = [textField.text substringToIndex:11];
        }
    } else if (textField == self.codeTF) {
        if (textField.text.length > 6) {
            textField.text = [textField.text substringToIndex:6];
        }
    }
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


- (IBAction)dismissKeyboard:(id)sender {
    [self.telNum resignFirstResponder];
    [self.codeTF resignFirstResponder];
}


- (IBAction)getCode:(id)sender {
    
    [self.getCodeBtn setBackgroundColor:[UIColor lightGrayColor]];
    self.getCodeBtn.userInteractionEnabled = NO;
    if (![self isMobileNumber:self.telNum.text]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:@"手机号码输入有误，请重新输入" delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
        [self.getCodeBtn setBackgroundColor:[UIColor whiteColor]];
        self.getCodeBtn.userInteractionEnabled = YES;
        return;
    }
    NSString *urlStr = [NSString stringWithFormat:@"http://%@/msg/sendIdCodeSMS.do?v=1&telNum=%@" ,DNS ,self.telNum.text];
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
            [self.timer fire];
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


- (IBAction)checkTel:(id)sender {
    [self.codeTF resignFirstResponder];
    [self.telNum resignFirstResponder];
    [self performSegueWithIdentifier:@"doChangePwd" sender:self];

    /*
    if ([self.codeTF.text isEqual:_codeText]) {
        [self performSegueWithIdentifier:@"doChangePwd" sender:self];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"") message:@"验证码错误" delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
    }
     */
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqual:@"doChangePwd"]) {
        ForgetPwdViewController *pwdVC = [segue destinationViewController];
        pwdVC.telNum = self.telNum.text;
    }
}


@end
