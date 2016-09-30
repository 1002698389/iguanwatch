//
//  AppDelegate.m
//  XIAOYI
//
//  Created by 冠一 科技 on 15/10/19.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import "AppDelegate.h"



#define APP_URL @"http://itunes.apple.com/lookup?id=1073870448"

NSString * const huanxinNeiceKey = @"iguan#aliyuntest";
NSString * const huanxinZhengshiKey = @"iguan#aliyunformal";
NSString * const huanxinCeshiKey = @"iguan#t";

NSString * const huanxinDevelopCertName = @"develop";
NSString * const huanxinProductCertName = @"product";

NSString * const JPushDevelopAppKey = @"d58c68664eaee4a418fd5bc4";
NSString * const JPushProductAppKey = @"c12149e894e7f337063860bc";

NSString * const JPushDevelopChannel = @"PublishChannel";
NSString * const JPushProductChannel = @"App Store";

NSString * const UMSocialAppKey = @"5694a2b867e58eea2a00063c";

@interface AppDelegate ()<UIAlertViewDelegate,JPUSHRegisterDelegate>
{
    NSString *_trackViewUrl;
}
@end

@implementation AppDelegate

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSURL *url = [NSURL URLWithString:_trackViewUrl];
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - 检查版本更新
- (void)checkVersion {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSLog(@"%@",infoDic);
    NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[APP_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        NSArray *result = [responseObject objectForKey:@"results"];
        if (result.count != 0) {
            NSString *lastVersion = [[result firstObject] objectForKey:@"version"];
            if (![lastVersion isEqual:appVersion]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"") message:@"更新版本" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"sure", @""), nil];
                [alertView show];
            }
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

- (void)checkVersionUpdate {
    //检测更新
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:APP_URL parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        
        /*responseObject是个字典{}，有两个key
         
         KEYresultCount = 1//表示搜到一个符合你要求的APP
         results =（）//这是个只有一个元素的数组，里面都是app信息，那一个元素就是一个字典。里面有各种key。其中有 trackName （名称）trackViewUrl = （下载地址）version （可显示的版本号）等等
         */
        
        //具体实现为
        NSArray *arr = [responseObject objectForKey:@"results"];
        NSDictionary *dic = [arr firstObject];
        NSString *versionStr = [dic objectForKey:@"version"];
        _trackViewUrl = [dic objectForKey:@"trackViewUrl"];
//        NSString *releaseNotes = [dic objectForKey:@"releaseNotes"];//更新日志
        //NSString* buile = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString*) kCFBundleVersionKey];build号
        NSString* thisVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        if ([self compareVersionsFormAppStore:versionStr WithAppVersion:thisVersion]) {
            /*
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"发现新版本:%@",versionStr] message:releaseNotes preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction  = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"点击了取消");
            }];
            UIAlertAction *OKAction  = [UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"点击了知道了");
                NSURL * url = [NSURL URLWithString:trackViewUrl];//itunesURL = trackViewUrl的内容
                [[UIApplication sharedApplication] openURL:url];
            }];
            [alertVC addAction:cancelAction];
            [alertVC addAction:OKAction];
            [self presentViewController:alertVC animated:YES completion:nil];
             */
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"") message:[NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"AppDelegate.version", @""), versionStr] delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"sure", @""), nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (BOOL)compareVersionsFormAppStore:(NSString*)AppStoreVersion WithAppVersion:(NSString*)AppVersion {
    
    BOOL littleSunResult = false;
    
    NSMutableArray* a = (NSMutableArray*) [AppStoreVersion componentsSeparatedByString: @"."];
    NSMutableArray* b = (NSMutableArray*) [AppVersion componentsSeparatedByString: @"."];
    while (a.count < b.count) {
        [a addObject: @"0"];
    }
    while (b.count < a.count) {
        [b addObject: @"0"];
    }
    for (int j = 0; j<a.count; j++) {
        if ([[a objectAtIndex:j] integerValue] > [[b objectAtIndex:j] integerValue]) {
            littleSunResult = true;
            break;
        }else if([[a objectAtIndex:j] integerValue] < [[b objectAtIndex:j] integerValue]){
            littleSunResult = false;
            break;
        }else{
            littleSunResult = false;
        }
    }
    return littleSunResult;//true就是有新版本，false就是没有新版本
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    /*
     //语言
    NSArray *allLanguages = [NSLocale availableLocaleIdentifiers];
    NSLog(@"%@",allLanguages);
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    NSLog(@"%@",currentLanguage);
    */
    //清理缓存
//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
//    [self clearCache:path];
    
    //检查版本更新
//    [self checkVersion];
    [self checkVersionUpdate];
    
    //环信
//    [[EaseMob sharedInstance] registerSDKWithAppKey:huanxinNeiceKey apnsCertName:@"AppStoreProduct"];
//    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    
    //友盟统计
//    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    [MobClick setAppVersion:version];
//    [MobClick startWithAppkey:@"5694a2b867e58eea2a00063c" reportPolicy:BATCH  channelId:@"App Store"];
    UMConfigInstance.appKey = @"5694a2b867e58eea2a00063c";
    UMConfigInstance.channelId = @"App Store";
    UMConfigInstance.eSType = E_UM_NORMAL;
    [MobClick startWithConfigure:UMConfigInstance];
    
    //友盟分享
    //打开调试日志
//    [[UMSocialShare defaultManager] openLog:YES];
//    
//    //设置友盟appkey
//    [[UMSocialManager defaultManager] setUmSocialAppkey:@"57b432afe0f55a9832001a0a"];
    
    [UMSocialData setAppKey:UMSocialAppKey];
    [UMSocialWechatHandler setWXAppId:@"wx20a9191b367e8dab" appSecret:@"7e954017139232871fabe8293d528f49" url:@"http://www.i-guan.com"];
//    [UMSocialQQHandler setQQWithAppId:@"1105032151" appKey:@"aZ55eKBuaekFLUjX" url:@"http://www.i-guan.com"];

    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    //JPush
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    // Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    } else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
#ifdef __IPHONE_8_0
        //       categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    } else {
        //categories    nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
#endif
    

    // Required
//    [JPUSHService setupWithOption:launchOptions appKey:@"d58c68664eaee4a418fd5bc4" channel:@"PublishChannel" apsForProduction:false];
    [JPUSHService setupWithOption:launchOptions
                           appKey:JPushProductAppKey
                          channel:JPushProductChannel
                 apsForProduction:YES
            advertisingIdentifier:advertisingId];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    
    
    
//    [[SDImageCache sharedImageCache] cleanDisk];

    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.navc = [mainSB instantiateInitialViewController];
//    NSArray *array = self.navc.viewControllers;
    
    //新建PPRevealSideViewController,并设置根视图（主页面的导航视图）
    PPRevealSideViewController *sideViewController = [[PPRevealSideViewController alloc] initWithRootViewController:self.navc];
//    sideViewController.fakeiOS7StatusBarColor = RGBACOLOR(0, 161, 232, 1);
    sideViewController.fakeiOS7StatusBarColor = [UIColor clearColor];
    [sideViewController setOption:PPRevealSideOptionsNoStatusBar];
    //把sideViewController设置成根视图控制器
    self.window.rootViewController = sideViewController;
    [self.window makeKeyAndVisible];

    return YES;
}

-(void)clearCache:(NSString *)path{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        NSLog(@"%@",childerFiles);
        for (NSString *fileName in childerFiles) {
            NSLog(@"%@",fileName);
            //如有需要，加入条件，过滤掉不想删除的文件
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
//    [[SDImageCache sharedImageCache] cleanDisk];
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDictionary *extras = [userInfo valueForKey:@"extras"];
    NSString *customizeField1 = [extras valueForKey:@"customizeField1"]; //自定义参数，key是自己定义的
    NSLog(@"%@",content);
    NSLog(@"%@",extras);
    NSLog(@"%@",customizeField1);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%@",deviceToken);
    
//    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];

    // Required
    [JPUSHService registerDeviceToken:deviceToken];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
//    [[EaseMob sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];

    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // IOS 7 Support Required
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"%@",userInfo);
    if ([[userInfo objectForKey:@"type"] isEqual:@"result_bind"]) {
        if ([[userInfo objectForKey:@"status"] isEqual:@"1"]) {
            NSNotification *notification = [NSNotification notificationWithName:@"refreshWatchData" object:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
        }
    } else if ([[userInfo objectForKey:@"type"] isEqual:@"result_urgent"]) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            UILabel *hintLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, self.window.frame.size.height-90, self.window.frame.size.width- 120, 40)];
            hintLabel.layer.cornerRadius = 5;
            hintLabel.backgroundColor = [UIColor lightGrayColor];
            hintLabel.alpha = 0.0;
            hintLabel.text = [userInfo objectForKey:@"message"];
            [self.window addSubview:hintLabel];
            [UIView animateWithDuration:1.0 animations:^{
                hintLabel.alpha = 1.0;
            } completion:^(BOOL finished) {
                [hintLabel removeFromSuperview];
            }];
        }
    } else if ([[userInfo objectForKey:@"type"] isEqual:@"result_user_prompt"]) {
        if ([[userInfo objectForKey:@"telnum"] isEqual:[[NSUserDefaults standardUserDefaults] valueForKey:@"accountTel"]]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"") message:@"用户账号在其他端登陆" delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
            NSNotification *notification = [NSNotification notificationWithName:@"doLogout" object:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    } else if ([[userInfo objectForKey:@"type"] isEqual:@"result_role"]) { //管理员权限变更，关注者被删除
        NSNotification *notification = [NSNotification notificationWithName:@"refreshWatchData" object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    } else {
        if (self.navc) {
            [self.navc jumpToChatList];
        }
    }
    
    
    completionHandler(UIBackgroundFetchResultNewData);
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (self.navc) {
        [self.navc didReceiveLocalNotification:notification];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//    [[EaseMob sharedInstance] applicationWillResignActive:application];

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
//    [[EaseMob sharedInstance] applicationDidEnterBackground:application];

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//    [[EaseMob sharedInstance] applicationWillEnterForeground:application];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [JPUSHService resetBadge];
    
//    [[EaseMob sharedInstance] applicationDidBecomeActive:application];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
//    [[EaseMob sharedInstance] applicationWillTerminate:application];

}

#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

@end
