//
//  ChangeRemarkNameViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/4/22.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "ChangeRemarkNameViewController.h"

@interface ChangeRemarkNameViewController ()

@property (weak, nonatomic) IBOutlet UITextField *contentTF;
@end

@implementation ChangeRemarkNameViewController

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.contentTF becomeFirstResponder];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.contentTF.text = self.remarkNameString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismissKeyboard:(id)sender {
    [self.contentTF resignFirstResponder];
}

- (IBAction)saveRemarkName:(id)sender {
    MBProgressHUD *HUD = [MBProgressHUD bwm_showHUDAddedTo:self.view title:NSLocalizedString(@"MBProgressHUD.saveSetting", @"")];

    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/nickUp.do?t=%@&watchId=%@&nickName=%@", DNS, [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceId"] ,self.contentTF.text];
    NSLog(@"%@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        [HUD hide:YES];
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            if (self.delegate != nil) {
                [self.delegate changeRemarkNameWith:self.contentTF.text];
            }
            NSNotification *notification = [NSNotification notificationWithName:@"refreshWatchData" object:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [HUD hide:YES];
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
        NSLog(@"%@",error);
    }];
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
