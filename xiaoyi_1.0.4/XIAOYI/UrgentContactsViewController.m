//
//  UrgentContactsViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/1/18.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "UrgentContactsViewController.h"

@interface UrgentContactsViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *telTF;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet UIView *upView;

@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructuionContent;


@end

@implementation UrgentContactsViewController

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getUrgentContacts {
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/getDeviceUrgents.do?watchSn=%@&v=%@", DNS, [userdefault valueForKey:@"watchSN"], @"1"];
    NSLog(@"%@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        self.nameTF.text = [[responseObject objectForKey:@"content"] objectForKey:@"name1"];
//        [self.nameTF becomeFirstResponder];
        self.telTF.text = [[responseObject objectForKey:@"content"] objectForKey:@"code1"];
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];

    }];
    
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField == self.telTF) {
        if (textField.text.length > 11) {
            textField.text = [textField.text substringToIndex:11];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = NO;
    
    self.submitBtn.layer.cornerRadius = 15;
    self.submitBtn.layer.borderWidth = 2;
    self.submitBtn.layer.borderColor = RGBACOLOR(0, 161, 232, 1).CGColor;
    self.upView.layer.borderColor = RGBACOLOR(185, 185, 185, 1.0).CGColor;
    self.upView.layer.borderWidth = 1;
    
    [self.telTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.instructionLabel.text = NSLocalizedString(@"urgentVC.instruction", @"");
    self.instructuionContent.text = NSLocalizedString(@"urgentVC.instructionContent", @"");
    
    [self getUrgentContacts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)doSubmit:(id)sender {
    if ([self.nameTF.text isEqual:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"urgentVC.name", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
    } else if ([self.telTF.text isEqual:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"urgentVC.tel", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
    } else {
//        MBProgressHUD *HUD = [MBProgressHUD bwm_showHUDAddedTo:self.view title:kBWMMBProgressHUDMsgLoading];
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/addDeviceUrgents.do?t=%@&watchSn=%@&v=%@&urgname1=%@&urgcode1=%@", DNS, [userdefault objectForKey:@"token"], [userdefault valueForKey:@"watchSN"], @"1", self.nameTF.text, self.telTF.text];
        NSLog(@"%@",urlString);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            NSLog(@"%@",responseObject);
            if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                NSLog(@"%@",[responseObject objectForKey:@"showToUI"]);
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:[responseObject objectForKey:@"devMessage"] delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
                [alertView show];
            }
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
            [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];

        }];
    }
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)dismissKeyboard:(id)sender {
    [self.nameTF resignFirstResponder];
    [self.telTF resignFirstResponder];
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
