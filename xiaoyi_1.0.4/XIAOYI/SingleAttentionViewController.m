//
//  SingleAttentionViewController.m
//  XIAOYI
//
//  Created by 王帅 on 16/6/28.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "SingleAttentionViewController.h"

@interface SingleAttentionViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *followType;
@property (weak, nonatomic) IBOutlet UILabel *followLimit;
@property (weak, nonatomic) IBOutlet UILabel *followTime;

@property (weak, nonatomic) IBOutlet UIButton *administratorBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@end

@implementation SingleAttentionViewController


- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.administratorBtn.layer.cornerRadius = 15;
    self.deleteBtn.layer.cornerRadius = 15;
    self.headImage.layer.cornerRadius = 50;
    self.headImage.layer.masksToBounds = YES;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    NSLog(@"%@",self.resultDic);
    [self.headImage sd_setImageWithURL:[self.resultDic objectForKey:@"photo"] placeholderImage:[UIImage imageNamed:@"headDefault"]];
    self.nameLabel.text = [self.resultDic objectForKey:@"showName"];
    
    int type = [[self.resultDic objectForKey:@"type"] intValue];
    if (type == 2) {
        self.followType.text = NSLocalizedString(@"singleAttentionVC.permanent", @"");
    } else {
        self.followType.text = NSLocalizedString(@"singleAttentionVC.limit", @"");
    }
    
    if ([[self.resultDic objectForKey:@"bindEnd"] isEqual:[NSNull null]]) {
        self.followLimit.text = NSLocalizedString(@"singleAttentionVC.permanent", @"");
    } else {
        self.followLimit.text = [NSString stringWithFormat:@"%@", [self.resultDic objectForKey:@"bindENd"]];
    }
    self.followTime.text = [[[self.resultDic objectForKey:@"createTime"] componentsSeparatedByString:@" "] firstObject];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)endowRole:(id)sender {
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/endowRole.do?t=%@&concernRefId=%@&watchSN=%@", DNS, [userdefault valueForKey:@"token"], [self.resultDic objectForKey:@"deviceUserRefId"], [userdefault valueForKey:@"watchSN"]];
    NSLog(@"%@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            NSNotification *notification1 = [NSNotification notificationWithName:@"refreshWatchListInfo" object:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification1];
            [self dismissViewControllerAnimated:YES completion:NULL];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:[responseObject objectForKey:@"showToUI"] delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
        
    }];
}
- (IBAction)deleteFollower:(id)sender {
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/delConcern.do?t=%@&concernRefId=%@", DNS, [userdefault valueForKey:@"token"], [self.resultDic objectForKey:@"deviceUserRefId"]];
    NSLog(@"%@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            if (self.delegate != nil) {
                [self.delegate refreshDataAfterDeleteFollower];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
        
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
