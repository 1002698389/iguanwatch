//
//  MineViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 15/10/20.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import "MineViewController.h"
#import "WatchCell.h"
#import "QRcodeViewController.h"
#import "MapLoctionViewController.h"
#import "PerfectInfoViewController.h"
#import "AboutWatchInfoViewController.h"
#import "RouteViewController.h"
#import "PopupView.h"
#import "LewPopupViewController.h"
#import "WatchUserInfoViewController.h"
#import "AttentionListViewController.h"
#import "WatchListViewController.h"
#import "ShareViewController.h"
#import "WatchInfoInquiryViewController.h"
#import "StepViewController.h"

//#import "EMConversation.h"
//#import "ChatViewController.h"

#import "NullString.h"


@interface MineViewController ()</*UITableViewDataSource,UITableViewDelegate,*/MKMapViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,WatchUserInfoDelegate,AttentionListDelegate,WatchListVCDelegate/*,IChatManagerDelegate*/,WatchInfoInquiryDelegate>
{
    BOOL _showWatchList;
    BOOL _showSettingsView;
    BOOL _showIChat;
    
    float _locationLat;
    float _locationLon;
    
    int _chooseBindingType;// 1：二维码  2：输入手表序列号
    
    NSInteger _selectedRowIndex;
    
    NSString *_cityString;
    
    NSInteger _managedIndex; //管理员标示

    UIView *_tempview;
    UIWebView *_tempWebview;
    UILabel *_tempStateLabel;
    
}

@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property (nonatomic, strong) NSArray *listArray;

@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MKPointAnnotation *userLocationAnnotation;


@property (weak, nonatomic) IBOutlet UIButton *setBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
@property (weak, nonatomic) IBOutlet UILabel *unreadMegCount;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageRightContraint;

@property (weak, nonatomic) IBOutlet UIImageView *watchUserHeadImage;
@property (weak, nonatomic) IBOutlet UILabel *watchUserName;
@property (weak, nonatomic) IBOutlet UILabel *watchUserCity;

@property (weak, nonatomic) IBOutlet UILabel *heartLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationTime;

//@property (weak, nonatomic) IBOutlet UIImageView *noDataBgImage;
@property (weak, nonatomic) IBOutlet UIView *nodataBgView;
@property (weak, nonatomic) IBOutlet UIImageView *noDataImage;


//@property (nonatomic, strong) EMConversation *conversation;


@property (nonatomic, strong) NSTimer *heartRateTimer; //心率被动检测，轮询定时器
@property (nonatomic, strong) NSTimer *locationTimer; //定位被动监测，轮询定时器
//@property (weak, nonatomic) IBOutlet UIButton *refreshHeartBtn;


@property (weak, nonatomic) IBOutlet UIView *locusView;
@property (weak, nonatomic) IBOutlet UIView *heartRateView;
@property (weak, nonatomic) IBOutlet UIView *stepView;
@property (weak, nonatomic) IBOutlet UIView *locationView;

@end

@implementation MineViewController


- (void)doCacheByFileName:(NSString *)fileName AndObject:(nonnull id)obj {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    [NSKeyedArchiver archiveRootObject:obj toFile:filePath];

}

#pragma mark -
- (void)getUserInfo {
    NSString *urlString = [NSString stringWithFormat:@"http://%@/user/getUserDetail.do?t=%@", DNS, [[NSUserDefaults standardUserDefaults] valueForKey:@"token"]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
                NSString *fileName = [NSString stringWithFormat:@"%@_getUserDetail",[[NSUserDefaults standardUserDefaults] valueForKey:@"loginName"]];
                [self doCacheByFileName:fileName AndObject:[responseObject objectForKey:@"content"]];
            }
            NSString *photoUrl = [[responseObject objectForKey:@"content"] objectForKey:@"photo"];
            [[NSUserDefaults standardUserDefaults] setValue:photoUrl forKey:@"userPhoto"];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
    }];
}


/*
#pragma mark - 获取环信好友
- (void)getHuanXinFriends {
//    MBProgressHUD *HUD = [MBProgressHUD bwm_showHUDAddedTo:self.view title:kBWMMBProgressHUDMsgLoading];
    NSString *urlStr = [NSString stringWithFormat:@"http://%@/huanxin/getHuanXinFriendsInMobile.do?t=%@&v=1",DNS, [[NSUserDefaults standardUserDefaults] valueForKey:@"token"]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        int a = [[responseObject objectForKey:@"code"] intValue];
        //            [HUD hide:YES];
        if (a == 1000) {
            if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
                NSArray *list = [responseObject objectForKey:@"content"];
                NSLog(@"%@",list);
                //                    [[NSUserDefaults standardUserDefaults] setObject:list forKey:@"huanxinBuddy"];
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *fileName = [NSString stringWithFormat:@"%@_huanxinFriends",[[NSUserDefaults standardUserDefaults] valueForKey:@"loginName"]];
                NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
                //写缓存
                [NSKeyedArchiver archiveRootObject:list toFile:filePath];
                
            }
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:[responseObject objectForKey:@"showToUI"] delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            alertView.tag = 999;
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:@"登陆失败，请重新登陆" delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        //            alertView.tag = 999;
        //            [alertView show];
        [self showToastWithMessage:@"获取环信朋友失败"];
        return;
    }];
}
 */


- (void)showToastWithMessage:(NSString *)message {
    UILabel *hintLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 20, self.view.frame.size.width- 120, 44)];
    hintLabel.layer.cornerRadius = 5;
    hintLabel.backgroundColor = [UIColor lightGrayColor];
    hintLabel.alpha = 0.0;
    hintLabel.text = message;
    [self.view addSubview:hintLabel];
    [UIView animateWithDuration:0.5 animations:^{
        hintLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        [hintLabel removeFromSuperview];
    }];
}

#pragma mark -
- (void)getDataFromDocument {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *fileName = [NSString stringWithFormat:@"%@_getCareWatchList",[[NSUserDefaults standardUserDefaults] valueForKey:@"loginName"]];
    NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
//    NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",@"getCareWatchList"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        //从本地读缓存文件
//        NSData *data = [NSData dataWithContentsOfFile:filePath];
//        self.listArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        self.listArray = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (self.listArray.count != 0) {
            self.nodataBgView.hidden = YES;
        } else {
            self.nodataBgView.hidden = NO;
        }
    }
}

/*
- (NSArray *)getHuanxinFriendsFromDocuments {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *fileName = [NSString stringWithFormat:@"%@_huanxinFriends",[[NSUserDefaults standardUserDefaults] valueForKey:@"loginName"]];
    NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];

    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {

        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        return array;
    } else {
        return nil;
    }
}
 */

#pragma mark -
- (void)getWatchList {
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/getCareWatchList.do?t=%@", DNS, [userdefault valueForKey:@"token"]];
    MBProgressHUD *HUD = [MBProgressHUD bwm_showHUDAddedTo:self.view title:kBWMMBProgressHUDMsgLoading];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        [HUD hide:YES];
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {

                self.listArray = [responseObject objectForKey:@"content"];
                self.messageBtn.hidden = YES;
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *fileName = [NSString stringWithFormat:@"%@_getCareWatchList",[[NSUserDefaults standardUserDefaults] valueForKey:@"loginName"]];
                NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
                //写缓存
                [NSKeyedArchiver archiveRootObject:self.listArray toFile:filePath];
                
                NSNotification *notification1 = [NSNotification notificationWithName:@"refreshWatchList" object:nil];
                [[NSNotificationCenter defaultCenter] postNotification:notification1];
                NSLog(@"%ld",(long)_selectedRowIndex);
                [self setWatchUserInfoWithDictionary:[self.listArray objectAtIndex:_selectedRowIndex]];
                [self setWatchDefaultInfo];
                self.nodataBgView.hidden = YES;
            } else {
                self.listArray = nil;
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *fileName = [NSString stringWithFormat:@"%@_getCareWatchList",[[NSUserDefaults standardUserDefaults] valueForKey:@"loginName"]];
                NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
                //写缓存
                [NSKeyedArchiver archiveRootObject:self.listArray toFile:filePath];
                self.messageBtn.hidden = YES;
                self.shareBtn.hidden = YES;
                self.setBtn.hidden = YES;
                self.watchUserHeadImage.image = [UIImage imageNamed:@"headImageDefault"];
                self.watchUserName.text = NSLocalizedString(@"setting.profileNickname", @"");
                self.watchUserCity.text = @"";
                self.locationTime.text = @"";
                
                [self.mapView removeAnnotation:self.userLocationAnnotation];
                self.nodataBgView.hidden = NO;
                
//                self.locationView.hidden = YES;
            }
            
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
        [HUD hide:YES];
        [self getDataFromDocument];
        [self setWatchUserInfoWithDictionary:[self.listArray objectAtIndex:_selectedRowIndex]];
        [self setWatchDefaultInfo];
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
    }];
}


- (void)getHeadImage {
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/userGetWatchPhoto.do?t=%@&deviceId=%@&deviceUserRefId=%@", DNS, [userdefault valueForKey:@"token"], [userdefault valueForKey:@"deviceId"], [userdefault valueForKey:@"deviceUserRefId"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
            [self.watchUserHeadImage sd_setImageWithURL:[NSURL URLWithString:[[responseObject objectForKey:@"content"] objectForKey:@"photo"]] placeholderImage:[UIImage imageNamed:@"headImageDefault.png"]];
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];

    }];
}

- (void)getPersonHealthData {
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/data/getPersonHealthDataSet.do?t=%@&deviceId=%@", DNS, [userdefault valueForKey:@"token"], [userdefault objectForKey:@"deviceId"]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
            NSDictionary *healthDic = [responseObject objectForKey:@"content"];
            self.heartLabel.text = [NSString stringWithFormat:@"%@",[healthDic objectForKey:@"lastHeartRate"]];
            self.stepLabel.text = [NSString stringWithFormat:@"%@",[healthDic objectForKey:@"todayWalkStep"]];
//            self.kcalLabel.text = [NSString stringWithFormat:@"%@kcal",[healthDic objectForKey:@"todayCalorie"]];
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
    }];
}

- (void)setWatchUserInfoWithDictionary:(NSDictionary *)infoDic {
    
    NSLog(@"%@",infoDic);
    [self.mapView removeAnnotation:self.userLocationAnnotation];
    NSString *photoUrl;
    photoUrl = [NullString contrastString:[infoDic objectForKey:@"photoURL"]];
//    if ([[infoDic objectForKey:@"photoURL"] isEqual:[NSNull null]]) {
//        photoUrl = @"";
//    } else {
//        photoUrl = [infoDic objectForKey:@"photoURL"];
//    }
    [self.watchUserHeadImage sd_setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:[UIImage imageNamed:@"headImageDefault.png"]];
    self.watchUserHeadImage.layer.cornerRadius = self.watchUserHeadImage.frame.size.height/2;
    self.locusView.layer.cornerRadius = self.locusView.frame.size.width/2;
    self.heartRateView.layer.cornerRadius = self.heartRateView.frame.size.width/2;
    self.stepView.layer.cornerRadius = self.stepView.frame.size.width/2;
    self.locationView.layer.cornerRadius = self.locationView.frame.size.width/2;
    
    self.watchUserName.text = [infoDic objectForKey:@"name"];
    [self.navigationView removeConstraint:self.messageRightContraint];
    if ([[infoDic objectForKey:@"watchRole"] intValue] == 1) { //判断管理员权限 -- 1：不是管理员
        self.setBtn.hidden = YES;
        self.shareBtn.hidden = YES;
        self.messageRightContraint = [NSLayoutConstraint constraintWithItem:self.messageBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.navigationView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-2];
        [self.navigationView addConstraint:self.messageRightContraint];
        
//        self.locationView.hidden = YES;
        _managedIndex = 1;
    } else {
        self.setBtn.hidden = NO;
        self.shareBtn.hidden = NO;
        self.messageRightContraint = [NSLayoutConstraint constraintWithItem:self.messageBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.navigationView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-86];
        [self.navigationView addConstraint:self.messageRightContraint];
        //        self.locationView.hidden = NO; //管理员权限可以实时定位
        _managedIndex = 2;
    }
    
    if (![[infoDic objectForKey:@"report"] isEqual:[NSNull null]]) {
        NSDictionary *report = [infoDic objectForKey:@"report"];
        [self drawMapWithReport:report];
        [[NSUserDefaults standardUserDefaults] setValue:[report objectForKey:@"pathId"] forKey:@"pathId"];
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"pathId"];
    }
    
    /*
    NSString *chatter = [NSString stringWithFormat:@"w%@",[infoDic objectForKey:@"watchId"]];
    self.conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:chatter conversationType:eConversationTypeChat];
    NSString *badge = [NSString stringWithFormat:@"%lu",(unsigned long)self.conversation.unreadMessagesCount];
    if (self.conversation.unreadMessagesCount == 0) {
        self.unreadMegCount.text = @"";
        self.unreadMegCount.backgroundColor = [UIColor clearColor];
    } else {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc]init];
        paragraph.alignment = NSTextAlignmentCenter;
        NSAttributedString *badgeText = [[NSAttributedString alloc]initWithString:badge attributes:@{NSParagraphStyleAttributeName: paragraph}];
        self.unreadMegCount.attributedText = badgeText;
        self.unreadMegCount.backgroundColor = [UIColor redColor];
    }
     */
}


- (void)drawMapWithReport:(NSDictionary *)report {
    NSLog(@"%@",report);
    NSString *city;
    NSString *country;
    country = [NullString contrastString:[report objectForKey:@"country"]];
    city = [NullString contrastString:[report objectForKey:@"city"]];
    
//    if ([[report objectForKey:@"country"] isEqual:[NSNull null]]) {
//        country = @"";
//    } else {
//        country = [report objectForKey:@"country"];
//    }
//    if ([[report objectForKey:@"city"] isEqual:[NSNull null]]) {
//        city = @"";
//    } else {
//        city = [report objectForKey:@"city"];
//    }
    
    _cityString = [country stringByAppendingString:city];
    
    if (![[report objectForKey:@"detailAddress"] isEqual:[NSNull null]]) {
        self.watchUserCity.text = [[[report objectForKey:@"detailAddress"] componentsSeparatedByString:NSLocalizedString(@"mineVC.nearby", @"")] lastObject];
    } else {
        self.watchUserCity.text = @"";
    }
    
    NSString *timeCount = [report objectForKey:@"lastDatetime"];
    NSDate *lastDate = [NSDate dateWithTimeIntervalSince1970:[timeCount longLongValue]/1000];
    self.locationTime.text = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"mainVC.locationTime",@"") , [self compareDate:lastDate]];
    
    _locationLat = [[report objectForKey:@"lastLatitude"] floatValue];
    _locationLon = [[report objectForKey:@"lastLongitude"] floatValue];
    self.userLocationAnnotation.coordinate = CLLocationCoordinate2DMake(_locationLat, _locationLon);
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(_locationLat, _locationLon);
    
    [self.mapView addAnnotation:self.userLocationAnnotation];
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(_locationLat, _locationLon), 1000, 1000)];
}

#pragma mark - MapView Delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *newAnnotation=[[MKAnnotationView alloc] init];
    newAnnotation.image = [UIImage imageNamed:@"point_1"];
    newAnnotation.canShowCallout=YES;
    return newAnnotation;
}

#pragma mark-
- (void)dealloc {
//    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.watchUserHeadImage.layer.borderWidth = 6;
    self.watchUserHeadImage.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.noDataImage.image = [UIImage imageNamed:NSLocalizedString(@"mineVC.noDataImageName", @"")];
    
//    self.locusView.layer.cornerRadius = 30;
//    self.heartRateView.layer.cornerRadius = 30;
//    self.stepView.layer.cornerRadius = 30;
//    self.locationView.layer.cornerRadius = 30;
    
    self.listArray = [NSArray array];
    
    self.userLocationAnnotation = [[MKPointAnnotation alloc]init];
    [self.mapView addAnnotation:self.userLocationAnnotation];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWatchUsers:) name:@"refreshWatchData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserHeadImage:) name:@"refreshUserHeadImage" object:nil]; //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setWatchUserInfo:) name:@"setWatchUserInfo" object:nil]; //登陆后，刷新数据
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWatchListInfo) name:@"refreshWatchListInfo" object:nil]; //设置管理员后，刷新数据
    
    //环信设置
//    [[EaseMob sharedInstance].chatManager removeDelegate:self];
//    //注册为SDK的ChatManager的delegate
//    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
//    self.unreadMegCount.layer.cornerRadius = 7;
//    self.unreadMegCount.clipsToBounds = YES;
    
    
    BOOL hadLogged = [[NSUserDefaults standardUserDefaults] boolForKey:@"hadLogged"];
    if (!hadLogged) {
        UIStoryboard *loginSB = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        [self presentViewController:[loginSB instantiateInitialViewController] animated:NO completion:NULL];
        self.nodataBgView.hidden = NO;
    } else {
//        [self autoLoginHuanxin];
        [self getWatchList];
        [self getUserInfo];
    }
    
    //初始化主动定位的View
    [self initTempView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    _selectedRowIndex = [[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedIndex"] integerValue];

    self.watchUserHeadImage.layer.masksToBounds = YES;
    self.watchUserHeadImage.layer.cornerRadius = self.watchUserHeadImage.frame.size.height/2;
    
    //统计环信未读消息数量
//    [self didUnreadMessagesCountChanged];
    
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(preloadLeft) object:nil];
//    [self performSelector:@selector(preloadLeft) withObject:nil afterDelay:0.3];
    
}


- (void)initTempView {
    _tempview = [[UIView alloc]initWithFrame:self.view.frame];
    _tempview.backgroundColor = [UIColor blackColor];
    _tempview.alpha = 0.9;
    
    UIButton *cancelBtn = [UIButton buttonWithType:0];
    [cancelBtn setTitle:NSLocalizedString(@"cancel", @"") forState:UIControlStateNormal];
    cancelBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    cancelBtn.layer.borderWidth = 2;
    cancelBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    cancelBtn.layer.cornerRadius = 15;
    [cancelBtn addTarget:self action:@selector(dismissTempview) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_tempview addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_tempview.mas_bottom).with.offset(-60);
        make.centerX.mas_equalTo(_tempview.mas_centerX).with.offset(0);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"point" ofType:@"html"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
    _tempWebview = [[UIWebView alloc]init];
    [_tempWebview loadRequest:request];
    _tempWebview.backgroundColor = [UIColor blackColor];
    _tempWebview.alpha = 0.9;
    _tempWebview.scrollView.scrollEnabled = NO;
    
    [_tempview addSubview:_tempWebview];
    [_tempWebview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_tempview.mas_centerX);
        make.top.mas_equalTo(_tempview.mas_top).with.offset(150);
        make.size.mas_equalTo(CGSizeMake(120, 120));
    }];
    
    _tempStateLabel = [[UILabel alloc]init];
    [_tempview addSubview:_tempStateLabel];
    _tempStateLabel.font = [UIFont systemFontOfSize:15];
    _tempStateLabel.textColor = [UIColor whiteColor];
    _tempStateLabel.textAlignment = NSTextAlignmentCenter;
    _tempStateLabel.text = NSLocalizedString(@"mineVC.positioning", @"");
    [_tempStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_tempWebview.mas_bottom).with.offset(16);
        make.left.mas_equalTo(_tempview.mas_left).with.offset(20);
        make.right.mas_equalTo(_tempview.mas_right).with.offset(-20);
        make.height.mas_equalTo(30);
    }];
    
}


- (void)dismissTempview {
    [_tempview removeFromSuperview];
    [self.locationTimer invalidate];
    _tempStateLabel.text = @"";
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lD",(long)_selectedRowIndex] forKey:@"selectedIndex"];
}



- (void)preloadLeft {
    PPRevealSideInteractions inter = PPRevealSideInteractionNone;
    inter |= PPRevealSideInteractionNavigationBar;
    inter |= PPRevealSideInteractionContentView;
    self.revealSideViewController.panInteractionsWhenClosed = inter;

    UIStoryboard *storybaord = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    WatchListViewController *listVC = [storybaord instantiateViewControllerWithIdentifier:@"watchList"];
    listVC.delegate = self;
    [self.revealSideViewController preloadViewController:listVC
                                                 forSide:PPRevealSideDirectionLeft
                                              withOffset:self.view.frame.size.width/4];
//    PP_RELEASE(listVC);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 下拉刷新
- (void)refreshWatchList {
    [self getWatchList];
}

#pragma mark - 判断时间是否为昨天今天
-(NSString *)compareDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm"];
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *tomorrow, *yesterday;
    
    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    NSString * tomorrowString = [[tomorrow description] substringToIndex:10];
    
    NSString * dateString = [[date description] substringToIndex:10];
    
    if ([dateString isEqualToString:todayString])
    {
        return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"mineVC.today", @""),[formatter stringFromDate:date]];
    } else if ([dateString isEqualToString:yesterdayString])
    {
        return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"mineVC.yesterday", @""),[formatter stringFromDate:date]];
    }else if ([dateString isEqualToString:tomorrowString])
    {
        return @"明天";
    }
    else
    {
        return [NSString stringWithFormat:@"%@ %@", dateString, [formatter stringFromDate:date]];
    }
}

#pragma mark - 通知
- (void)refreshWatchUsers:(NSNotification *)notification {
    [self getWatchList];
//    [self getHuanXinFriends];
}

- (void)refreshUserHeadImage:(NSNotification *)notification {
    [self getHeadImage];
}


- (void)setWatchUserInfo:(NSNotification *)notification {
    //登陆验证完成后，如果已绑定手表，直接跳转到主界面
    self.listArray = [notification object];
    self.nodataBgView.hidden = YES;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *fileName = [NSString stringWithFormat:@"%@_getCareWatchList",[[NSUserDefaults standardUserDefaults] valueForKey:@"loginName"]];
    NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    //写缓存
    [NSKeyedArchiver archiveRootObject:self.listArray toFile:filePath];

    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *watchId = [[self.listArray firstObject] objectForKey:@"watchId"];
    NSString *watchSN = [[self.listArray firstObject] objectForKey:@"watchSN"];
    NSString *userRefId = [[self.listArray firstObject] objectForKey:@"id"];
    [userDefault setValue:[NSString stringWithFormat:@"%@",watchId] forKey:@"deviceId"];
    [userDefault setValue:[NSString stringWithFormat:@"%@",watchSN] forKey:@"watchSN"];
    [userDefault setValue:[NSString stringWithFormat:@"%@",userRefId] forKey:@"deviceUserRefId"];
    
    
    [self setWatchUserInfoWithDictionary:[self.listArray firstObject]];
    _selectedRowIndex = 0;
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lD",(long)_selectedRowIndex] forKey:@"selectedIndex"];
    [self getUserInfo];
}


/*
#pragma  自动登录环信
- (void)autoLoginHuanxin { //免登陆时，自动登录环信
    NSString *huanxinUserName = [[NSUserDefaults standardUserDefaults] valueForKey:@"HuanXinUserName"];
    NSString *huanxinUserPwd = [[NSUserDefaults standardUserDefaults] valueForKey:@"HuanXinPwd"];
    EMError *error = nil;
    NSDictionary *loginInfo = [[EaseMob sharedInstance].chatManager loginWithUsername:huanxinUserName password:huanxinUserPwd error:&error];
    if (!error && loginInfo) {
        NSLog(@"登陆成功");
        _showIChat = YES;
//        [self getWatchList];
//        [self getUserInfo];
    } else {
        NSLog(@"%@",error);
//        [self getDataFromDocument];
//        [self setWatchUserInfoWithDictionary:[self.listArray objectAtIndex:_selectedRowIndex]];
//        [self setWatchDefaultInfo];
    }
}
*/

#pragma mark - 显示手表列表
- (IBAction)showWatchList {
    
    UIStoryboard *storybaord = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    WatchListViewController *listVC = [storybaord instantiateViewControllerWithIdentifier:@"watchList"];
    self.revealSideViewController.panInteractionsWhenClosed = PPRevealSideInteractionNone;
    [self.revealSideViewController resetOption:PPRevealSideOptionsShowShadows];
    listVC.delegate = self;
    [self.revealSideViewController pushViewController:listVC onDirection:PPRevealSideDirectionLeft withOffset:self.view.frame.size.width/6 animated:YES];
    
//    UINavigationController *navc = [[UINavigationController alloc]initWithRootViewController:listVC];
//    [self.revealSideViewController pushViewController:navc onDirection:PPRevealSideDirectionLeft withOffset:self.view.frame.size.width/6 animated:YES];
    return;
}


#pragma mark - show Chat
- (IBAction)showChat:(id)sender {
    /*
    if (_showIChat) {
        NSString *chatter = [NSString stringWithFormat:@"w%@",[[self.listArray objectAtIndex:_selectedRowIndex] objectForKey:@"watchId"]];
        ChatViewController *chatVC = [[ChatViewController alloc]initWithChatter:chatter conversationType:eConversationTypeChat];
        chatVC.title = self.watchUserName.text;
        chatVC.chatterPhotoUrl = [[self.listArray objectAtIndex:_selectedRowIndex] objectForKey:@"photoURL"];
        [self.navigationController pushViewController:chatVC animated:YES];
    } else {
        NSLog(@"环信登陆失败");
    }
    */
}

#pragma mark - 分享
- (IBAction)doShare:(id)sender {
    [self performSegueWithIdentifier:@"doShare" sender:self];
}

#pragma mark - 查询手表用户信息（点击首页头像）
- (IBAction)showWatchUserInfo:(id)sender {
    [self performSegueWithIdentifier:@"showWatchUserInfo" sender:self];
}

#pragma mark - IChatMangerDelegate
/*
-(void)didUnreadMessagesCountChanged {
    NSString *badge = [NSString stringWithFormat:@"%lu",(unsigned long)self.conversation.unreadMessagesCount];
    if (self.conversation.unreadMessagesCount == 0) {
        self.unreadMegCount.text = @"";
        self.unreadMegCount.backgroundColor = [UIColor clearColor];
    } else {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc]init];
        paragraph.alignment = NSTextAlignmentCenter;
        NSAttributedString *badgeText = [[NSAttributedString alloc]initWithString:badge attributes:@{NSParagraphStyleAttributeName: paragraph}];
        self.unreadMegCount.attributedText = badgeText;
//        self.unreadMegCount.text = badge;
        self.unreadMegCount.backgroundColor = [UIColor redColor];
    }
}
*/

#pragma mark - show Setting List

- (IBAction)showWatchSettings:(id)sender {
    if (self.listArray.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:@"请先绑定手表" delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    [self performSegueWithIdentifier:@"showSettingsList" sender:self];
    
    /*
    PopupView *popupView = [PopupView defaultPopupView];
    popupView.parentVC = self;
    LewPopupViewAnimationSlide *animation = [[LewPopupViewAnimationSlide alloc]init];
    animation.type = LewPopupViewAnimationSlideTypeTopTop;
    [self lew_presentPopupView:popupView animation:animation dismissed:^{
        NSLog(@"动画结束");
    }];
     */
}


- (void)showWatchParameters {
    [self performSegueWithIdentifier:@"showWatchParameters" sender:self];
}

- (void)showContacts {
    [self performSegueWithIdentifier:@"showContacts" sender:self];
}

- (void)showUserInfo {
    [self performSegueWithIdentifier:@"showUserInfo" sender:self];
}

- (void)changeUserHeadImage {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"actsheet.photo", @""), NSLocalizedString(@"actsheet.images", @""), nil];
    [actionSheet showInView:self.view];
}

- (void)showUrgentContacts {
    [self performSegueWithIdentifier:@"showUrgentContacts" sender:self];
}

#pragma mark - PopupViewDelegate
- (void)chooseSettingListWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
            [self showWatchParameters];
            break;
        case 1:
            [self showContacts];
            break;
        case 2:
            [self showUserInfo];
            break;
        case 3:
            [self changeUserHeadImage];
            break;
        case 4:
            [self showUrgentContacts];
            break;
        default:
            break;
    }
}





#pragma mark - 显示轨迹
- (IBAction)showMap:(UITapGestureRecognizer *)sender {
    [self performSegueWithIdentifier:@"showRouteFromMine" sender:self];
    return;
    /*
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"pathId"] isEqual:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:@"没有定位信息" delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        [self performSegueWithIdentifier:@"showMapLocation" sender:self];        
    }
    */
}


#pragma mark - 显示心率
- (IBAction)showHeartRate:(id)sender {
    [self performSegueWithIdentifier:@"showHeartRate" sender:self];
}

#pragma mark - 显示记步
- (IBAction)showStep:(id)sender {
    [self performSegueWithIdentifier:@"showStep" sender:self];
}

#pragma mark - 主动定位
- (IBAction)doLocating:(id)sender {
    [[UIApplication sharedApplication].keyWindow addSubview:_tempview];
    [self openLocationPassiveGauging];
}


#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 999) {
        if (buttonIndex == 0) {
            [self doLogout];
        }
    }
}

- (void)doLogout {
    /*
    EMError *error = nil;
    NSDictionary *info = [[EaseMob sharedInstance].chatManager logoffWithUnbindDeviceToken:YES error:&error];
    if (!error && info) {
        NSLog(@"退出成功");
    }
     */
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hadLogged"];
    UIStoryboard *loginSB = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    [self presentViewController:[loginSB instantiateInitialViewController] animated:NO completion:NULL];
}


#pragma mark - 设置watchId、watchSn、deviceId、deviceUserRefId
- (void)setWatchDefaultInfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *watchId = [[self.listArray objectAtIndex:_selectedRowIndex] objectForKey:@"watchId"];
    NSString *userRefId = [[self.listArray objectAtIndex:_selectedRowIndex] objectForKey:@"id"];
    NSString *watchSn = [[self.listArray objectAtIndex:_selectedRowIndex] objectForKey:@"watchSN"];
    
    [userDefaults setValue:watchId forKey:@"deviceId"];
    [userDefaults setValue:userRefId forKey:@"deviceUserRefId"];
    [userDefaults setValue:watchSn forKey:@"watchSN"];
    [userDefaults setValue:[NSString stringWithFormat:@"%ld",(long)_selectedRowIndex] forKey:@"selectedIndex"];
    
//    NSLog(@"%@",[userDefaults valueForKey:@"watchSN"]);
    
    [self getPersonHealthData];
}

#pragma mark - 取消关注某一手表
- (void)deleteUserWatchWithDeviceRefid:(NSString *)deviceRefId {
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/userDelWatch.do?t=%@&deviceUserRefId=%@", DNS, [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], deviceRefId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        NSLog(@"%@",[responseObject objectForKey:@"devMessage"]);
        [self getWatchList];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];

    }];
}


#pragma mark - Navigation Storyboard跳转

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqual:@"showBindingWithQRcode"]) { //扫描二维码
        UINavigationController *navc = [segue destinationViewController];
        QRcodeViewController *qrVC = [navc.viewControllers firstObject];
        qrVC.bindingInWhere = 2;
    } else if ([[segue identifier] isEqual:@"showMapLocation"]) { //
        MapLoctionViewController *mapVC = [segue destinationViewController];
        mapVC.lat = _locationLat;
        mapVC.lon = _locationLon;
    } else if ([[segue identifier] isEqual:@"showAboutWatchInfo"]) {  //关于手表
        AboutWatchInfoViewController *infoVC = [segue destinationViewController];
        infoVC.watchSN = [[self.listArray objectAtIndex:_selectedRowIndex] objectForKey:@"watchSN"];
    } else if ([[segue identifier] isEqual:@"showRouteFromMine"]) {  //旅程
        RouteViewController *routeVC = [segue destinationViewController];
        routeVC.watchSN = [[NSUserDefaults standardUserDefaults] valueForKey:@"pathId"];
        routeVC.watchUserName = [[self.listArray objectAtIndex:_selectedRowIndex] objectForKey:@"name"];
    } else if ([[segue identifier] isEqual:@"showUserInfo"]) {  //用户信息
        WatchUserInfoViewController *infoVC = [segue destinationViewController];
        infoVC.delegate = self;
    } else if ([[segue identifier] isEqual:@"showAttentionList"]) { //关注者列表
        AttentionListViewController *attentionVC = [segue destinationViewController];
        attentionVC.delegate = self;
    } else if ([[segue identifier] isEqual:@"doShare"]) { //分享
        ShareViewController *shareVC = [segue destinationViewController];
        shareVC.shareTitle = self.watchUserName.text;
        shareVC.shareImage = self.watchUserHeadImage.image;
        shareVC.watchSN = [[self.listArray objectAtIndex:_selectedRowIndex] objectForKey:@"watchSN"];
        shareVC.shareName = self.watchUserName.text;
    } else if ([[segue identifier] isEqual:@"showWatchUserInfo"]) {
        WatchInfoInquiryViewController *inquiryVC = [segue destinationViewController];
        inquiryVC.locationDetail = _cityString;
        inquiryVC.remarkString = self.watchUserName.text;
        inquiryVC.deviceRefId = [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceUserRefId"];
        inquiryVC.delegate = self;
        inquiryVC.managedIndex = _managedIndex;
    } else if ([[segue identifier] isEqual:@"showStep"]) {
        StepViewController *stepVC = [segue destinationViewController];
        stepVC.stepNum = self.stepLabel.text;
    }
}

#pragma mark - WatchInfoInquiry Delegate  解除绑定
- (void)removeBindingWatch {
    _selectedRowIndex = 0;
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lD",(long)_selectedRowIndex] forKey:@"selectedIndex"];
    [self getWatchList];
}

#pragma mark - WatchUserInfoDelegate 修改用户信息后刷新数据
- (void)refreshWatchUserInfo {
    [self getWatchList];
}

#pragma mark - AttentionListDelegate 设置管理员权限后，刷新数据
- (void)refreshWatchListInfo {
    self.setBtn.hidden = YES;
    self.shareBtn.hidden = YES;
    [self.navigationView removeConstraint:self.messageRightContraint];
    self.messageRightContraint = [NSLayoutConstraint constraintWithItem:self.messageBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.navigationView attribute:NSLayoutAttributeRight multiplier:1.0 constant:2];
    [self.navigationView addConstraint:self.messageRightContraint];
    
    [self getWatchList];
}

#pragma mark - WatchListDelegate 在手表列表选择手表回到主页更新信息
- (void)selectOneWatchWithIndex:(NSInteger)index {
    
    _selectedRowIndex = index;
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lD",(long)_selectedRowIndex] forKey:@"selectedIndex"];
    [self getDataFromDocument];
    [self setWatchUserInfoWithDictionary:[self.listArray objectAtIndex:index]];
    [self setWatchDefaultInfo];
    
}

- (void)deleteWatchWithIndex:(NSInteger)index {
    
    if (_selectedRowIndex == index) {
        _selectedRowIndex = 0;
    }
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lD",(long)_selectedRowIndex] forKey:@"selectedIndex"];
    [self getWatchList];
    
}


#pragma mark - 被动检测


//开始心率监测
- (void)openHeartRatePassiveGauging {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/data/passiveGaugingHeartOpen.do?t=%@&watchSN=%@", DNS, [userDefault valueForKey:@"token"], [userDefault valueForKey:@"watchSN"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSLog(@"%@",urlString);
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            self.heartRateTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(cometHeartRate) userInfo:nil repeats:YES];
            [self.heartRateTimer fire];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
        
    }];
}

- (void)cometHeartRate {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/data/passiveGaugingHeartComet.do?t=%@&watchSN=%@", DNS, [userDefault valueForKey:@"token"], [userDefault valueForKey:@"watchSN"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
                NSDictionary *dic = [responseObject objectForKey:@"content"];
                NSLog(@"%@",[dic objectForKey:@"content"]);

                if ([[dic objectForKey:@"type"] intValue] == 3 /*监测成功*/ || [[dic objectForKey:@"type"] intValue] == 4 /*手表没有检测出心率*/) {
                    [self.heartRateTimer invalidate];
                } else if ([[dic objectForKey:@"type"] intValue] == 5) { //监测失败
                    [self.heartRateTimer invalidate];
                }
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
        [self.heartRateTimer invalidate];

    }];
}


#pragma mark - 被动检测

//开始定位监测
- (void)openLocationPassiveGauging {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/data/passiveGaugingLocationOpen.do?t=%@&watchSN=%@", DNS, [userDefault valueForKey:@"token"], [userDefault valueForKey:@"watchSN"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000 ) {
            self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(cometLocation) userInfo:nil repeats:YES];
            [self.locationTimer fire];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
    }];
}

- (void)cometLocation {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/data/passiveGaugingLocationComet.do?t=%@&watchSN=%@", DNS, [userDefault valueForKey:@"token"], [userDefault valueForKey:@"watchSN"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
                NSDictionary *dic = [responseObject objectForKey:@"content"];
                NSLog(@"%@",[dic objectForKey:@"content"]);
                if ([[dic objectForKey:@"type"] intValue] == 1 /*正在连接手表*/ ) {
                    _tempStateLabel.text = NSLocalizedString(@"mineVC.positioning_1", @"");
                    
                } else if ([[dic objectForKey:@"type"] intValue] == 2 /*连接成功，正在检测定位*/) {
                    _tempStateLabel.text = NSLocalizedString(@"mineVC.positioning_2", @"");
                    
                } else if ([[dic objectForKey:@"type"] intValue] == 3 /*监测成功*/ ) {
                    _tempStateLabel.text = NSLocalizedString(@"mineVC.positioning_3", @"");
                    
                    [_tempview removeFromSuperview];
                    [self drawMapWithReport:[dic objectForKey:@"report"]];
                    [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"mineVC.positioning_3", @"")];
                    [self.locationTimer invalidate];
                } else if ([[dic objectForKey:@"type"] intValue] == 4 /*没有定位出地点*/) {
                    _tempStateLabel.text = NSLocalizedString(@"mineVC.positioning_4", @"");
                    
                    [_tempview removeFromSuperview];
                    [self.locationTimer invalidate];
                    [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"mineVC.positioning_4", @"")];
                } else if ([[dic objectForKey:@"type"] intValue] == 5) { //定位失败
                    _tempStateLabel.text = NSLocalizedString(@"mineVC.positioning_4", @"");
                    
                    [_tempview removeFromSuperview];
                    [self.locationTimer invalidate];
                }
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
        [self.locationTimer invalidate];
    }];
}




@end
