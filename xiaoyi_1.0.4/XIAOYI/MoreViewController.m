//
//  MoreViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 15/10/20.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import "MoreViewController.h"
#import "UserInfoCell.h"
#import "UserInfoViewController.h"
#import "AppDelegate.h"
#import <StoreKit/StoreKit.h>
#import "NullString.h"



@interface MoreViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,SKStoreProductViewControllerDelegate>
{
    NSArray *_listArray;
    NSArray *_imageNameArray;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSDictionary *infoDic;


@property (nonatomic, strong) AppDelegate *myDelegate;

@end

@implementation MoreViewController


- (IBAction)goToMain {
    [self.revealSideViewController popViewControllerWithNewCenterController:self.myDelegate.navc animated:YES];
}

- (void)getInfoFromCache {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *fileName = [NSString stringWithFormat:@"%@_getUserDetail",[[NSUserDefaults standardUserDefaults] valueForKey:@"loginName"]];
    NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        self.infoDic = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
}

- (void)getUserInfo {
    NSString *urlString = [NSString stringWithFormat:@"http://%@/user/getUserDetail.do?t=%@", DNS, [[NSUserDefaults standardUserDefaults] valueForKey:@"token"]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            if ([NullString contrastContent:[responseObject objectForKey:@"content"]]) {
                self.infoDic = [responseObject objectForKey:@"content"];
            } else {
                self.infoDic = nil;
            }
            [self.tableView reloadData];

        } else if ([[responseObject objectForKey:@"code"] intValue] == -1006) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"Alert.expired", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            alertView.tag = 999;
            [alertView show];
        } else if ([[responseObject objectForKey:@"code"] intValue] == -1007) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"Alert.invalid", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            alertView.tag = 999;
            [alertView show];
        } else {
            [self getInfoFromCache];
        }

    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [self getInfoFromCache];
        [self.tableView reloadData];
//        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.view.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0];
    UIImage *imageNormal = [UIImage imageNamed:@"tab_4"];
    UIImage *imageSelected = [UIImage imageNamed:@"tab_4_selected"];
    self.tabBarItem.selectedImage = [imageSelected imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.image = [imageNormal imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.infoDic = [NSDictionary dictionary];
    
    [self setExtraCellLineHidden:self.tableView];
    
    _listArray = [NSArray arrayWithObjects:NSLocalizedString(@"moreVC.aboutUs", @""), NSLocalizedString(@"moreVC.changePwd", @""),NSLocalizedString(@"moreVC.evaluate", @""), /*NSLocalizedString(@"moreVC.feedback", @""),*/ NSLocalizedString(@"moreVC.logout", @""), nil];
    _imageNameArray = [NSArray arrayWithObjects:@"more_0", @"more_1", @"more_2",/* @"more_3",*/ @"more_4", nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doLogout) name:@"doLogout" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
//    self.navigationController.navigationBarHidden = YES;
    [super viewWillAppear:YES];
    [self getUserInfo];
    
}

-(void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView *view = [[UIView alloc]init];
    
    view.backgroundColor = [UIColor clearColor];
    
    [tableView setTableFooterView:view];
}

//- (void)tableView {
//    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
//    
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 999) {
        if (buttonIndex == 0) {
            [self doLogout];
        }
    }
}


#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return _listArray.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"userCell";
        UserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UserInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if (self.infoDic == nil) {
            cell.nameLabel.text = @"";
            [cell.headImage sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"headImageDefault"]];
        } else {
            cell.nameLabel.text = [self.infoDic objectForKey:@"nickname"];
            [cell.headImage sd_setImageWithURL:[NSURL URLWithString:[self.infoDic objectForKey:@"photo"]] placeholderImage:[UIImage imageNamed:@"headImageDefault"]];
        }
        return cell;
    } else {
        static NSString *cellIdentifier = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.textLabel.text = [_listArray objectAtIndex:indexPath.row];
//        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", _imageNameArray[indexPath.row]]];
        cell.textLabel.textColor = [UIColor grayColor];
//        if (indexPath.row == _listArray.count-1) {
//            cell.textLabel.textColor = [UIColor redColor];
//        }
        return cell;
    }
    return nil;
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return 15;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 60;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:@"showUserInfo" sender:self];
    } else {
        switch (indexPath.row) {
            case 0:
                [self performSegueWithIdentifier:@"showAboutUs" sender:self];
                break;
            case 1:
                [self performSegueWithIdentifier:@"changePwd" sender:self];
                break;
            case 2:
            {
//                [self performSegueWithIdentifier:@"showEvaluation" sender:self];

//                NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",APPID];
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                
                [self loadAppStoreController];
            }
                break;
//            case 3:
//                [self performSegueWithIdentifier:@"showFeedback" sender:self];
//                break;
            case 3:
            {
//                EMError *error = nil;
//                NSDictionary *info = [[EaseMob sharedInstance].chatManager logoffWithUnbindDeviceToken:YES error:&error];
//                if (!error && info) {
//                    NSLog(@"退出成功");
//                }
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hadLogged"];
                UIStoryboard *loginSB = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                [self presentViewController:[loginSB instantiateInitialViewController] animated:NO completion:^{
                    [self.revealSideViewController popViewControllerWithNewCenterController:self.myDelegate.navc animated:NO];
                }];
            }
                break;
                
            default:
                break;
        }
    }
    
}


- (void)doLogout {
//    EMError *error = nil;
//    NSDictionary *info = [[EaseMob sharedInstance].chatManager logoffWithUnbindDeviceToken:YES error:&error];
//    if (!error && info) {
//        NSLog(@"退出成功");
//    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hadLogged"];
    UIStoryboard *loginSB = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    [self presentViewController:[loginSB instantiateInitialViewController] animated:NO completion:^{
        [self.revealSideViewController popViewControllerWithNewCenterController:self.myDelegate.navc animated:NO];
    }];

}

#pragma mark - AppStore评分
- (void)loadAppStoreController
{
    MBProgressHUD *HUD = [MBProgressHUD bwm_showHUDAddedTo:self.view title:@"" animated:YES];
    // 初始化控制器
    SKStoreProductViewController *storeProductViewContorller = [[SKStoreProductViewController alloc] init];
    // 设置代理请求为当前控制器本身
    storeProductViewContorller.delegate = self;
    [storeProductViewContorller loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:APPID}  completionBlock:^(BOOL result, NSError *error)   {
        [HUD hide:YES];
        if(error) {
            NSLog(@"error %@ with userInfo %@",error,[error userInfo]);
        }  else {
            // 模态弹出appstore
            [self presentViewController:storeProductViewContorller animated:YES completion:^{
            }];
        }
    }];
}

//AppStore取消按钮监听
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController  
{
//    [self dismissViewControllerAnimated:YES completion:NULL];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqual:@"showUserInfo"]) {
        UserInfoViewController *infoVC = [segue destinationViewController];
        infoVC.userInfo = self.infoDic;
    }
}


@end
