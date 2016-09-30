//
//  WatchSettingViewController.m
//  TravelConcomitant
//
//  Created by 冠一 科技 on 15/7/30.
//  Copyright (c) 2015年 冠一 科技. All rights reserved.
//

#import "WatchSettingViewController.h"

@interface WatchSettingViewController ()<UITableViewDataSource,UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *resultArray;
@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation WatchSettingViewController


- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getFrequency {
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/getWatchSetting.do?t=%@&deviceUserRefId=%@", DNS, [[NSUserDefaults standardUserDefaults] valueForKey:@"token"],[[NSUserDefaults standardUserDefaults] valueForKey:@"deviceUserRefId"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSDictionary *dic = [responseObject objectForKey:@"content"];
        if ([[dic objectForKey:@"LocationFrequency"] isEqual:[NSNull null]]) {
            self.selectedIndex = 2;
        } else {
            int a = [[dic objectForKey:@"LocationFrequency"] intValue];
            switch (a) {
                case 3:
                    self.selectedIndex = 0;
                    break;
                case 10:
                    self.selectedIndex = 1;
                    break;
                case 15:
                    self.selectedIndex = 2;
                    break;
                case 30:
                    self.selectedIndex = 3;
                    break;
                case 60:
                    self.selectedIndex = 4;
                    break;
                case 120:
                    self.selectedIndex = 5;
                    break;
                case 360:
                    self.selectedIndex = 5;
                    break;
                    
                default:
                    break;
            }
        }
        
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];

    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.selectedIndex = INT32_MAX;
    NSLog(@"%ld",(long)self.selectedIndex);
    self.resultArray = [NSArray arrayWithObjects:@"3", @"10", @"15", @"30", @"60", @"120", @"360",nil];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self getFrequency];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


#pragma mark - UITableView DataSource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"settingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",[self.resultArray objectAtIndex:indexPath.row], NSLocalizedString(@"watchSettingVC.unit", @"")];
    if (self.selectedIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;
    [self setFrequencyWith:[self.resultArray objectAtIndex:indexPath.row]];
    [tableView reloadData];
    
}

#pragma mark - 设置定位频率
- (void)setFrequencyWith:(NSString *)frequency {
    MBProgressHUD *hud = [MBProgressHUD bwm_showHUDAddedTo:self.view title:@""];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/settingLocationFrequency.do?t=%@&deviceUserRefId=%@&frequency=%@", DNS, [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceUserRefId"], frequency];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [hud hide:YES];
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"setting.saveSuccess", @"")];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
        [hud hide:YES];
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
