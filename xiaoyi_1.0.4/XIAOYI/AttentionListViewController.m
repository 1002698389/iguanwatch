//
//  AttentionListViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/3/29.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "AttentionListViewController.h"
#import "AttentionCell.h"
#import "MGSwipeButton.h"
#import "SingleAttentionViewController.h"

@interface AttentionListViewController ()<UITableViewDataSource,UITableViewDelegate,FollowerDelegate>
{
    NSInteger _selectedIndex;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *resultArray;

@end

@implementation AttentionListViewController

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getList {
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/getConcerns.do?t=%@&watchSN=%@", DNS, [userdefault valueForKey:@"token"], [userdefault valueForKey:@"watchSN"]];
    NSLog(@"%@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
                self.resultArray = [responseObject objectForKey:@"content"];
                [self.tableView reloadData];
            }
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:[responseObject objectForKey:@"showToUI"] delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];

    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = NO;
    self.resultArray = [NSArray array];
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self getList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"attentionCell";
    AttentionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[AttentionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    NSDictionary *singleDic = [self.resultArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = [singleDic objectForKey:@"showName"];
    cell.timeLabel.text = [singleDic objectForKey:@"createTime"];
    [cell.headImage sd_setImageWithURL:[singleDic objectForKey:@"photo"] placeholderImage:[UIImage imageNamed:@"headDefault"]];
    cell.tag = indexPath.row + 10000;
    
    return cell;
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    _selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"showSingleAttention" sender:self];
}

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteConcernByIndex:indexPath.row];
    }
} */
/*
#pragma mark - MGSwipeTableCell Delegate
-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction {
    return YES;
}


-(BOOL) swipeTableCell:(MGSwipeTableCell*)cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    NSLog(@"Delegate: button tapped, %@ position, index %d, from Expansion: %@",
          direction == MGSwipeDirectionLeftToRight ? @"left" : @"right", (int)index, fromExpansion ? @"YES" : @"NO");
    NSInteger concernIndex = cell.tag - 10000;
    switch (index) {
        case 0: //删除
        {
            [self deleteConcernByIndex:concernIndex];
        }
            break;
        case 1: //设为管理员
        {
            [self endowRoleByIndex:concernIndex];
        }
            break;
            
        default:
            break;
    }
    return YES;
}
*/
#pragma mark - 设置管理员
- (void)endowRoleByIndex:(NSInteger )index {
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/endowRole.do?t=%@&concernRefId=%@&watchSN=%@", DNS, [userdefault valueForKey:@"token"], [[self.resultArray objectAtIndex:index] objectForKey:@"deviceUserRefId"], [userdefault valueForKey:@"watchSN"]];
    NSLog(@"%@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            /*
             if (self.delegate!=nil) {
             [self.delegate refreshWatchListInfo];
             }
             [self.navigationController popViewControllerAnimated:YES];
             */
            
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


#pragma mark - 删除关注者
- (void)deleteConcernByIndex:(NSInteger) index {
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/delConcern.do?t=%@&concernRefId=%@", DNS, [userdefault valueForKey:@"token"], [[self.resultArray objectAtIndex:index] objectForKey:@"deviceUserRefId"]];
    NSLog(@"%@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            [self getList];

        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];

    }];

}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([[segue identifier] isEqual:@"showSingleAttention"]) {
        SingleAttentionViewController *singleAttentionVC = [segue destinationViewController];
        singleAttentionVC.resultDic = [self.resultArray objectAtIndex:_selectedIndex];
        singleAttentionVC.delegate = self;
    }
}


- (void)refreshDataAfterDeleteFollower {
    [self getList];
}


@end
