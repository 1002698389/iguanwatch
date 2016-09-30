//
//  ShareViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/4/14.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController ()<UMSocialUIDelegate>
{
    NSString *_startTimeString;
    NSString *_endTimeString;
    NSString *_timeLimitString;
    NSString *_shareUrl;
}
@property (weak, nonatomic) IBOutlet UISwitch *shareSwitch;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (strong, nonatomic) IBOutlet UIDatePicker *dataPicker;
@property (strong, nonatomic) IBOutlet UIToolbar *setTimeTool;

@property (weak, nonatomic) IBOutlet UITextField *startTimeTF;
@property (weak, nonatomic) IBOutlet UITextField *endTimeTF;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionContent;


@end

@implementation ShareViewController

- (IBAction)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = NO;
  
    self.startTimeTF.inputView = self.dataPicker;
    self.startTimeTF.inputAccessoryView = self.setTimeTool;
    self.endTimeTF.inputView = self.dataPicker;
    self.endTimeTF.inputAccessoryView = self.setTimeTool;
    
    _startTimeString = @"";
    _endTimeString = @"";
    _timeLimitString = @"0";
    
    self.descriptionContent.text = NSLocalizedString(@"shareVC.description", @"");
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    _startTimeString = [dateFormatter stringFromDate:now];
    self.startTimeTF.text = _startTimeString;
    self.startDate = [dateFormatter dateFromString:_startTimeString];

    _endTimeString = [dateFormatter stringFromDate:now];
    self.endTimeTF.text = _endTimeString;
    self.endDate = [dateFormatter dateFromString:_startTimeString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.startTimeTF resignFirstResponder];
    [self.endTimeTF resignFirstResponder];
}

- (IBAction)timeLimit:(UISwitch *)sender {
    
    [UIView animateWithDuration:0.5 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [self.timeView removeConstraint:self.timeViewHeightConstraint];
//        [self.view removeConstraint:self.descriptionTopConstraint];

        if (sender.on) {
            _timeLimitString = @"0";
            
            self.timeViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.timeView
                                                                         attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:99];
            [self.timeView addConstraint:self.timeViewHeightConstraint];
//            [self.view removeConstraint:self.descriptionTopConstraint];
//            self.descriptionTopConstraint = [NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.timeView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:16];
//            [self.view addConstraint:self.descriptionTopConstraint];
            
//            [self.view removeConstraint:self.timeViewHeightConstraint];
//            self.timeViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.timeView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeCenterYWithinMargins multiplier:1.0 constant:99];
//            [self.view addConstraint:self.timeViewHeightConstraint];
            
//            self.timeView.hidden = NO;
            self.timeView.alpha = 1.0;
        } else {
            _timeLimitString = @"1";
            self.timeViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.timeView
                                                                         attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
            [self.timeView addConstraint:self.timeViewHeightConstraint];
//            [self.view removeConstraint:self.descriptionTopConstraint];
//            self.descriptionTopConstraint = [NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.shareSwitch attribute:NSLayoutAttributeBottom multiplier:1.0 constant:16];
//            [self.view addConstraint:self.descriptionTopConstraint];
            
//            self.timeView.hidden = YES;
            self.timeView.alpha = 0;
        }
        [self.timeView layoutIfNeeded];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        NSLog(@"finished");
    }];
}


- (IBAction)chooseTime:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *selectDateString = [dateFormatter stringFromDate:[self.dataPicker date]];
    if ([self.startTimeTF isFirstResponder] ) {
        NSDate *start = [self.dataPicker date];
        if (start == self.endDate) {
            self.startTimeTF.text = selectDateString;
            [self.startTimeTF resignFirstResponder];
            self.startDate = start;
            return;
        }
        NSDate *earlierDate = [start earlierDate:self.endDate];
        if (earlierDate == self.endDate) {
//            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"shareVC.reselectTime", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
//            [alertView show];
            
            self.startTimeTF.text = selectDateString;
            self.startDate = start;
            _endTimeString = selectDateString;
            self.endTimeTF.text = selectDateString;
            self.endDate = start;
            [self.startTimeTF resignFirstResponder];
            return;
        }
        self.startTimeTF.text = selectDateString;
        _startTimeString = selectDateString;
        self.startDate = start;
        [self.startTimeTF resignFirstResponder];
    } else if ( [self.endTimeTF isFirstResponder] ) {
        NSDate *end = [self.dataPicker date];
        if (self.startDate == end) {
            self.endTimeTF.text = selectDateString;
            [self.endTimeTF resignFirstResponder];
            self.endDate = end;
            return;
        }
        NSDate *laterDate = [end laterDate:self.startDate];
        if (laterDate == self.startDate) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"shareVC.reselectTime", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        self.endTimeTF.text = selectDateString;
        _endTimeString = selectDateString;
        self.endDate = end;
        [self.endTimeTF resignFirstResponder];
    }
}

- (IBAction)share:(id)sender {
    [self.startTimeTF resignFirstResponder];
    [self.endTimeTF resignFirstResponder];
    
    if (self.shareSwitch.on) {
        if ([_startTimeString isEqual:@""]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"") message:@"请选择开始时间" delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([_endTimeString isEqual:@""]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"shareVC.endtime", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            [self getShartUrl];

        }
    } else
        [self getShartUrl];
}

- (void)getShartUrl {
    MBProgressHUD *HUD = [MBProgressHUD bwm_showHUDAddedTo:self.view title:kBWMMBProgressHUDMsgLoading];
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"watchSN"]);
    NSString *urlString = [NSString stringWithFormat:@"http://%@/share/addShare.do?t=%@&watchSN=%@&status=%@&startDate=%@&endDate=%@", DNS, [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], [[NSUserDefaults standardUserDefaults] valueForKey:@"watchSN"], _timeLimitString, _startTimeString, _endTimeString];
    NSLog(@"%@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        int a = [[responseObject objectForKey:@"code"] intValue];
        [HUD hide:YES];
        if (a == 1000) {
            if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
                NSDictionary *dic = [responseObject objectForKey:@"content"];
                _shareUrl = [NSString stringWithFormat:@"http://weixin.i-guan.com/share.do?shareKey=%@", [dic objectForKey:@"shareKey"]];
                
                [UMSocialWechatHandler setWXAppId:@"wx20a9191b367e8dab" appSecret:@"afc2507d0616e0e4ff39a39df70ac77b" url:_shareUrl];
//                [UMSocialQQHandler setQQWithAppId:@"1105032151" appKey:@"aZ55eKBuaekFLUjX" url:_shareUrl];
                
                [UMSocialData openLog:YES];
                NSLog(@"%@",self.shareTitle);
                NSLog(@"%@",self.shareImage);
                [UMSocialData defaultData].extConfig.title = self.shareTitle;
                [UMSocialSnsService presentSnsIconSheetView:self
                                                     appKey:@"5694a2b867e58eea2a00063c"
                                                  shareText:[NSString stringWithFormat:@"%@分享了他(她)的佩戴状况，快点击查看!", self.shareName]
                                                 shareImage:self.shareImage
                                            shareToSnsNames:@[UMShareToWechatSession, UMShareToWechatTimeline/*UMShareToSina,, UMShareToTencent, UMShareToQQ, UMShareToQzone, UMShareToEmail, UMShareToSms, UMShareToFacebook, UMShareToTwitter*/]
                                                   delegate:self];
            }
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:[responseObject objectForKey:@"showToUI"] delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            alertView.tag = 999;
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [HUD hide:YES];
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
