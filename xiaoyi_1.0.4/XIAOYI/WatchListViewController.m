//
//  WatchListViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/3/31.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "WatchListViewController.h"
#import "WatchCell.h"
#import "QRViewController.h"

#import "CustomeViewController.h"

#import "PerfectInfoViewController.h"

@interface WatchListViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,QRcodeDelegate/*,IChatManagerDelegate*/>
{
    NSInteger _deleteIndex;
    
    UIImageView *_tempView;
    UIView *_popView;
    UITextField *_tempSnTF;
    UITextField *_tempNameTF;
}


@property (weak, nonatomic) IBOutlet UITableView *watchListTableView;
@property (nonatomic, strong) NSArray *listArray;

@property (nonatomic, strong) NSArray *converstaionArray;



@end

@implementation WatchListViewController


- (void)getWatchList {
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/getCareWatchList.do?t=%@", DNS, [userdefault valueForKey:@"token"]];
    
//    MBProgressHUD *HUD = [MBProgressHUD bwm_showHUDAddedTo:self.view title:@"数据加载中"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        //        [HUD hide:YES];
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
                
                self.listArray = [responseObject objectForKey:@"content"];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *fileName = [NSString stringWithFormat:@"%@_getCareWatchList",[[NSUserDefaults standardUserDefaults] valueForKey:@"loginName"]];
                NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
                //写缓存
                [NSKeyedArchiver archiveRootObject:self.listArray toFile:filePath];
                
                NSNotification *notification = [NSNotification notificationWithName:@"refreshWatchData" object:nil];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            } else {
                self.listArray = nil;
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *fileName = [NSString stringWithFormat:@"%@_getCareWatchList",[[NSUserDefaults standardUserDefaults] valueForKey:@"loginName"]];
                NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    NSError *error;
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                }
            }
            [self.watchListTableView reloadData];
        } else if ([[responseObject objectForKey:@"code"] intValue] == -1006) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"Alert.expired", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            alertView.tag = 999;
            [alertView show];
        } else if ([[responseObject objectForKey:@"code"] intValue] == -1007) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"Alert.invalid", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            alertView.tag = 999;
            [alertView show];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:[responseObject objectForKey:@"showToUI"] delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        //        [HUD hide:YES];
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
    }];
}

- (void)getDataFromDocument {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *fileName = [NSString stringWithFormat:@"%@_getCareWatchList",[[NSUserDefaults standardUserDefaults] valueForKey:@"loginName"]];
    NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    NSLog(@"%@",filePath);
//    NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",@"getCareWatchList"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        //从本地读缓存文件
//        NSData *data = [NSData dataWithContentsOfFile:filePath];
//        self.listArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.listArray = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
}


#pragma mark-
- (void)dealloc {
//    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = YES;
    
    self.listArray = [NSArray array];
    self.converstaionArray = [NSArray array];
    
//    [self getWatchList];
    
    MJRefreshNormalHeader *mjHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshWatchList)];
    [mjHeader.lastUpdatedTimeLabel setTextColor:[UIColor whiteColor]];
    [mjHeader.stateLabel setTextColor:[UIColor whiteColor]];
    self.watchListTableView.header = mjHeader;
    
//    [self.watchListTableView.header beginRefreshing];
    
    [self getDataFromDocument];
    [self.watchListTableView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWatchList:) name:@"refreshWatchList" object:nil];
    
//    [[EaseMob sharedInstance].chatManager removeDelegate:self];
//    //注册为SDK的ChatManager的delegate
//    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    [self initTempView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
    [self loadHuanXinUnread];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)initTempView {
    _tempView = [[UIImageView alloc]initWithFrame:self.view.frame];
    _tempView.backgroundColor = [UIColor blackColor];
    _tempView.alpha = 0.8;
    _tempView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *cancelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissTempView)];
    [_tempView addGestureRecognizer:cancelTap];
    
    
    float popWidth = self.view.frame.size.width;
    float popHeight = self.view.frame.size.height;
    _popView = [[UIView alloc]initWithFrame:CGRectMake(popWidth/6, (popHeight - popWidth *2/3)/2 - 60, popWidth *2/3, popWidth *2/3)];
//    _popView.userInteractionEnabled = YES;
    _popView.layer.cornerRadius = 5.0;
    _popView.backgroundColor = [UIColor whiteColor];
    _popView.alpha = 1.0;
//    [_tempView addSubview:_popView];
//    [_popView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(_tempView.mas_centerX).with.offset(0);
//        make.centerY.mas_equalTo(_tempView.mas_centerY).with.offset(-10);
////        make.width.mas_equalTo(_tempView.mas_width).multipliedBy(0.66);
////        make.width.mas_equalTo(_tempView.mas_width).multipliedBy(0.66);
//        make.width.mas_equalTo(260);
//        make.height.mas_equalTo(260);
//    }];
    
    _tempSnTF = [[UITextField alloc]init];
    _tempSnTF.delegate = self;
    _tempSnTF.borderStyle = UITextBorderStyleRoundedRect;
    _tempSnTF.placeholder = @"请输入手表序列号";
    [_popView addSubview:_tempSnTF];
    [_tempSnTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_popView.mas_top).with.offset(16);
        make.left.mas_equalTo(_popView.mas_left).with.offset(20);
        make.right.mas_equalTo(_popView.mas_right).with.offset(-20);
        make.height.mas_equalTo(30);
    }];
    
    UIButton *scanBtn = [UIButton buttonWithType:0];
//    [scanBtn setBackgroundColor:[UIColor redColor]];
    [scanBtn setBackgroundImage:[UIImage imageNamed:@"scan"] forState:UIControlStateNormal];
    [scanBtn addTarget:self action:@selector(doScan) forControlEvents:UIControlEventTouchUpInside];
    [_popView addSubview:scanBtn];
    [scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_tempSnTF.mas_right).with.offset(0);
        make.top.mas_equalTo(_tempSnTF.mas_top).with.offset(0);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    _tempNameTF = [[UITextField alloc]init];
    _tempNameTF.borderStyle = UITextBorderStyleRoundedRect;
    _tempNameTF.delegate = self;
    _tempNameTF.placeholder = @"我是...";
    [_popView addSubview:_tempNameTF];
    [_tempNameTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_tempSnTF.mas_bottom).with.offset(16);
        make.left.mas_equalTo(_popView.mas_left).with.offset(20);
        make.right.mas_equalTo(_popView.mas_right).with.offset(-20);
        make.height.mas_equalTo(30);
    }];
    
    UIButton *submitBtn = [UIButton buttonWithType:0];
    [submitBtn setTitle:@"确定" forState:UIControlStateNormal];
    submitBtn.backgroundColor = RGBACOLOR(76, 76, 76, 1);
    submitBtn.layer.borderWidth = 2;
    submitBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    submitBtn.layer.cornerRadius = 15;
    [submitBtn addTarget:self action:@selector(doSubmit) forControlEvents:UIControlEventTouchUpInside];
    [_popView addSubview:submitBtn];
    [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_popView.mas_left).with.offset(40);
        make.right.mas_equalTo(_popView.mas_right).with.offset(-40);
        make.height.mas_equalTo(30);
        make.bottom.mas_equalTo(_popView.mas_bottom).with.offset(-20);
    }];
    
}

- (void)initPopView {
    
}

- (void)doScan {
    [self dismissTempView];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
    QRViewController *one = [storyboard instantiateViewControllerWithIdentifier:@"BindingByQRCode"];
    one.delegate = self;
    one.bindingFrom = 3;
    [self presentViewController:one animated:YES completion:NULL];
}

- (void)doSubmit {
    [_tempSnTF resignFirstResponder];
    [_tempNameTF resignFirstResponder];
    
    if ([_tempNameTF.text isEqual:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"Alert.nickname", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/userAddWatch.do?t=%@&watchSN=%@&careName=%@&photo=%@&showName=%@",DNS, [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], _tempSnTF.text, /*self.watchUserName.text*/@"", @"", _tempNameTF.text];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            [self dismissTempView];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"perfectInfoVC.bindingSuccess", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            alertView.tag = 1010;
            [alertView show];
            
        } else if ([[responseObject objectForKey:@"code"] intValue] == 1005) {
            NSLog(@"%@",[responseObject objectForKey:@"devMessage"]);
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[[[responseObject objectForKey:@"devMessage"] componentsSeparatedByString:@"。"] lastObject] message:[responseObject objectForKey:@"showToUI"] delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([[responseObject objectForKey:@"code"] intValue] == -1006 || [[responseObject objectForKey:@"code"] intValue] == -1007) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:[responseObject objectForKey:@"showToUI"] delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Alert.bindFails", @"") message:[responseObject objectForKey:@"showToUI"] delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
        
    }];
}

- (void)dismissTempView {
    [_tempSnTF resignFirstResponder];
    [_tempNameTF resignFirstResponder];
    _tempNameTF.text = @"";
    _tempSnTF.text = @"";
    [_popView removeFromSuperview];
    [_tempView removeFromSuperview];
}

#pragma mark - QRcodeDelegate
- (void)doCancelScanQRcode {
    [[UIApplication sharedApplication].keyWindow addSubview:_tempView];
    [[UIApplication sharedApplication].keyWindow addSubview:_popView];

}

- (void)scanCompleteWithWatchId:(NSString *)resultValue {
    [[UIApplication sharedApplication].keyWindow addSubview:_tempView];
    [[UIApplication sharedApplication].keyWindow addSubview:_popView];
    _tempSnTF.text = resultValue;
}

#pragma mark - UITextFeild Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 通知
- (void)refreshWatchList:(NSNotification *)notification {
    [self getDataFromDocument];
    [self.watchListTableView reloadData];
}


- (void)refreshWatchList {
    [self getWatchList];
    [self.watchListTableView.header endRefreshing];
}

#pragma mark - 环信未读列表 
- (void)loadHuanXinUnread {
//    self.converstaionArray = [[EaseMob sharedInstance].chatManager conversations];
//    [self.watchListTableView reloadData];
}

#pragma mark - IChatMangerDelegate

-(void)didUnreadMessagesCountChanged {
    [self loadHuanXinUnread];
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else {
        return self.listArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellStr = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
        }
//        cell.backgroundColor = RGBACOLOR(30, 26, 25, 0.8);
        cell.backgroundColor = [UIColor clearColor];
        [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"watchListVC.scan", @"");
            cell.imageView.image = [UIImage imageNamed:@"qrcode.png"];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"watchListVC.binding", @"");;
            cell.imageView.image = [UIImage imageNamed:@"add.png"];
        }
        
        return cell;
    } else if (indexPath.section == 1) {
        static NSString *cellIdentifier = @"watchCell";
        WatchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[WatchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//            cell.separatorInset = UIEdgeInsetsZero;
        }
        NSString *photoUrl;
        NSDictionary *singleInfoDic = [self.listArray objectAtIndex:indexPath.row];
        if ([[singleInfoDic objectForKey:@"photoURL"] isEqual:[NSNull null]]) {
            photoUrl = @"";
        } else {
            photoUrl = [singleInfoDic objectForKey:@"photoURL"];
        }
        [cell.headImage sd_setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:[UIImage imageNamed:@"headDefault.png"]];
        cell.nameLabel.text = [singleInfoDic objectForKey:@"name"];
        
        if (![[singleInfoDic objectForKey:@"report"] isEqual:[NSNull null]]) {
            int batteryNum = [[[singleInfoDic objectForKey:@"report"] objectForKey:@"battery"] intValue];
            if (batteryNum >= 70) {
                cell.batteryImage.image = [UIImage imageNamed:@"bet_full.png"];
            } else if (batteryNum >= 35 && batteryNum < 70) {
                cell.batteryImage.image = [UIImage imageNamed:@"bet_mid.png"];
            } else if (batteryNum < 35 && batteryNum >= 15 ) {
                cell.batteryImage.image = [UIImage imageNamed:@"bet_lit.png"];
            } else if (batteryNum < 15) {
                cell.batteryImage.image = [UIImage imageNamed:@"bet_empty.png"];
            }
        }
        
        /*
        NSString *huanxinName;
        NSArray *huanxinArray = [NSArray array];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *fileName = [NSString stringWithFormat:@"%@_huanxinFriends",[[NSUserDefaults standardUserDefaults] valueForKey:@"loginName"]];
        NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            huanxinArray = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        }
        for (NSDictionary *dic in huanxinArray) {
            if ([[dic objectForKey:@"showName"] isEqual:cell.nameLabel.text]) {
                huanxinName = [dic objectForKey:@"huanXinUserName"];
                break;
            }
        }
         */
        
        //环信未读消息数量
        /*
        NSString *chatter = [NSString stringWithFormat:@"w%@",[singleInfoDic objectForKey:@"watchId"]];
        cell.badgeCount.backgroundColor = [UIColor clearColor];
        for (EMConversation *conversation in self.converstaionArray) {
            if ([conversation.chatter isEqual:chatter]) {
                if (conversation.unreadMessagesCount == 0) {
                    cell.badgeCount.text = @"";
                    cell.badgeCount.backgroundColor = [UIColor clearColor];
                } else {
                    
                    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                    paragraph.alignment = NSTextAlignmentCenter;
                    NSAttributedString *badgeText = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%lu",(unsigned long)conversation.unreadMessagesCount] attributes:@{NSParagraphStyleAttributeName: paragraph}];
                    cell.badgeCount.attributedText = badgeText;
                    cell.badgeCount.backgroundColor = [UIColor redColor];
                }
            }
        }
         */
        
        return cell;
    }
    return nil;
}

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return NO;
    } else
        return YES;
    return YES;
}
*/
/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _deleteIndex = indexPath.row;
        NSLog(@"%@",[self.listArray objectAtIndex:indexPath.row]);
        [self deleteUserWatchWithDeviceRefid:[[self.listArray objectAtIndex:indexPath.row] objectForKey:@"id"]];
    }
} */


#pragma mark - UITableView Delegate
/*
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    UIButton *btn = [UIButton buttonWithType:0];
    btn.frame = view.frame;
    [view addSubview:btn];
    UIImageView *iconImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 8, 26, 26)];
    iconImg.image = [UIImage imageNamed:@"tab_4_selected"];
    [view addSubview:iconImg];
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(40, 10, 60, 20)];
    title.text = @"更多";
    [view addSubview:title];
    return view;
}
 */


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 44;
    } else
        return 0;
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
//        view.backgroundColor = RGBACOLOR(30, 26, 25, 0.8);
        return view;
    } else {
        return nil;
    }
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    [self doScan];
                }
                    break;
                case 1:
                {
                    [[UIApplication sharedApplication].keyWindow addSubview:_tempView];
                    [[UIApplication sharedApplication].keyWindow addSubview:_popView];

//                    [self.view addSubview:_tempView];
                }
                    break;
                    
                default:
                    break;
            }
            
            /*
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            PerfectInfoViewController *one = [storyboard instantiateViewControllerWithIdentifier:@"prefectInfo"];
            one.bindingInWhere = 2;
            UINavigationController *navc = [[UINavigationController alloc]initWithRootViewController:one];
            switch (indexPath.row) {
                case 0:
                {
                    one.selectedQRcode = 1;
                }
                    break;
                case 1:
                {
                    one.selectedQRcode = 2;
                }
                    break;
                    
                default:
                    break;
            }
            [self presentViewController:navc animated:YES completion:NULL];
            PP_RELEASE(one);
            PP_RELEASE(navc);
            */
        }
            break;
        case 1:
        {
            if (self.delegate != nil) {
                [self.delegate selectOneWatchWithIndex:indexPath.row];
            }
            [self.revealSideViewController popViewControllerAnimated:YES];
            
            
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - 取消关注某一手表
- (void)deleteUserWatchWithDeviceRefid:(NSString *)deviceRefId {
    MBProgressHUD *HUD = [MBProgressHUD bwm_showHUDAddedTo:self.view title:@"系统删除中..."];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/userDelWatch.do?t=%@&deviceUserRefId=%@", DNS, [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], deviceRefId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        [HUD hide:YES];
        NSLog(@"%@",[responseObject objectForKey:@"devMessage"]);
        if (self.delegate != nil) {
            [self.delegate deleteWatchWithIndex:_deleteIndex];
        }
        [self getWatchList];
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [HUD hide:YES];
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
    }];
}


#pragma mark - 展示更多
- (IBAction)showMore:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UINavigationController *one = [storyboard instantiateViewControllerWithIdentifier:@"moreNavc"];
    [self.revealSideViewController popViewControllerWithNewCenterController:one animated:YES];
    PP_RELEASE(one);
    
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
