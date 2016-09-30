//
//  MainNavcViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/4/14.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "MainNavcViewController.h"
//#import "EMCDDeviceManager.h"

//#import "ChatViewController.h"
//#import "ChatListViewController.h"
//#import "LinkmanViewController.h"
#import "AppDelegate.h"

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;
static NSString *kMessageType = @"MessageType";
static NSString *kConversationChatter = @"ConversationChatter";
static NSString *kGroupName = @"GroupName";

@interface MainNavcViewController ()/*<IChatManagerDelegate,EMCallManagerDelegate>*/
{
//    ChatListViewController *_chatListVC;
    
}

@property (strong, nonatomic) NSDate *lastPlaySoundDate;

@property (nonatomic, weak) AppDelegate *myDelegate;

@property (nonatomic, strong) NSArray *resultArray;



@end

@implementation MainNavcViewController


- (NSArray *)getDataFromDocument {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *fileName = [NSString stringWithFormat:@"%@_getCareWatchList",[[NSUserDefaults standardUserDefaults] valueForKey:@"loginName"]];
    NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    NSLog(@"%@",filePath);
    NSArray *array = [NSArray array];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        //从本地读缓存文件
        array = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    } else {
        array = nil;
    }
    return array;
}

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
//    
//    self.myDelegate = [[UIApplication sharedApplication] delegate];
//    
////    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeUser:) name:@"changeUser" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setIconBadgeNumber:) name:UIApplicationDidEnterBackgroundNotification object:nil];
//    
//    [self setupSubviews];
}

//- (void)networkChanged:(EMConnectionState)connectionState
//{
//    _connectionState = connectionState;
//    [_chatListVC networkChanged:connectionState];
//}

//- (void)setupSubviews {
//    UIStoryboard *secondStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    _chatListVC = [secondStoryboard instantiateViewControllerWithIdentifier:@"chatList"];
//    [_chatListVC networkChanged:_connectionState];
//    _chatListVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"title.conversation", @"Conversations")
//                                                           image:nil
//                                                             tag:0];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)changeUser:(NSNotification*)notification {
//    [self setSelectedIndex:0];
}

- (void)setIconBadgeNumber:(NSNotification *) notification {
//    [self setupUnreadMessageCount];
}

- (void)jumpToChatList {
    /*
    if ([self.topViewController isKindOfClass:[ChatViewController class]]) {
        ChatViewController *chatController = (ChatViewController *)self.topViewController;
        [chatController hideImagePicker];
    }
    else if(self.myDelegate)
    {
        //        [self popToViewController:self animated:NO];
        //        [self setSelectedViewController:_chatListVC];
//        [self setSelectedIndex:1];
    } else if (_chatListVC) {
//        [self setSelectedViewController:_chatListVC];
        //        self.selectedIndex = 1;
    } else {
        [self popToViewController:self animated:NO];
//        self.selectedIndex = 1;
    }
     */
}



// 统计未读消息数
-(void)setupUnreadMessageCount
{
//    NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
//    NSInteger unreadCount = 0;
//    for (EMConversation *conversation in conversations) {
//        unreadCount += conversation.unreadMessagesCount;
//    }
//    if (_chatListVC) {
//        if (unreadCount > 0) {
//            _chatListVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
//        }else{
//            _chatListVC.tabBarItem.badgeValue = nil;
//        }
//    }
//    
//    UIApplication *application = [UIApplication sharedApplication];
//    [application setApplicationIconBadgeNumber:unreadCount];
}

//-(void)didReceiveCmdMessage:(EMMessage *)message
//{
//    [self showHint:NSLocalizedString(@"receiveCmd", @"receive cmd message")];
//}


- (void)playSoundAndVibration{
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }
    
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
//    // 收到消息时，播放音频
//    [[EMCDDeviceManager sharedInstance] playNewMessageSound];
//    // 收到消息时，震动
//    [[EMCDDeviceManager sharedInstance] playVibration];
}
/*
- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == ePushNotificationDisplayStyle_messageSummary) {
        id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
        NSString *messageStr = nil;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Text:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case eMessageBodyType_Image:
            {
                messageStr = NSLocalizedString(@"message.image", @"Image");
            }
                break;
            case eMessageBodyType_Location:
            {
                messageStr = NSLocalizedString(@"message.location", @"Location");
            }
                break;
            case eMessageBodyType_Voice:
            {
                messageStr = NSLocalizedString(@"message.voice", @"Voice");
            }
                break;
            case eMessageBodyType_Video:{
                messageStr = NSLocalizedString(@"message.video", @"Video");
            }
                break;
            default:
                break;
        }
        
        NSString *title = message.from;
        BOOL state = NO;
        for (NSDictionary *dic in self.resultArray) {
            if ([[dic objectForKey:@"huanXinUserName"] isEqual:message.from]) {
                title = [dic objectForKey:@"showName"];
                state = YES;
            }
        }
        
        if (message.messageType == eMessageTypeGroupChat) {
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:message.conversationChatter]) {
                    title = [NSString stringWithFormat:@"%@(%@)", message.groupSenderName, group.groupSubject];
                    break;
                }
            }
        }
        else if (message.messageType == eMessageTypeChatRoom)
        {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:@"username" ]];
            NSMutableDictionary *chatrooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
            NSString *chatroomName = [chatrooms objectForKey:message.conversationChatter];
            if (chatroomName)
            {
                title = [NSString stringWithFormat:@"%@(%@)", message.groupSenderName, chatroomName];
            }
        }
        
        notification.alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
    }
    else{
        notification.alertBody = NSLocalizedString(@"receiveMessage", @"you have a new message");
    }
    
#warning 去掉注释会显示[本地]开头, 方便在开发中区分是否为本地推送
    //notification.alertBody = [[NSString alloc] initWithFormat:@"[本地]%@", notification.alertBody];
    
    notification.alertAction = NSLocalizedString(@"open", @"Open");
    notification.timeZone = [NSTimeZone defaultTimeZone];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
    } else {
        notification.soundName = UILocalNotificationDefaultSoundName;
        self.lastPlaySoundDate = [NSDate date];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:message.messageType] forKey:kMessageType];
    [userInfo setObject:message.conversationChatter forKey:kConversationChatter];
    notification.userInfo = userInfo;
    
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    //    UIApplication *application = [UIApplication sharedApplication];
    //    application.applicationIconBadgeNumber += 1;
    [self setupUnreadMessageCount];
}
*/

/*
- (EMConversationType)conversationTypeFromMessageType:(EMMessageType)type
{
    EMConversationType conversatinType = eConversationTypeChat;
    switch (type) {
        case eMessageTypeChat:
            conversatinType = eConversationTypeChat;
            break;
        case eMessageTypeGroupChat:
            conversatinType = eConversationTypeGroupChat;
            break;
        case eMessageTypeChatRoom:
            conversatinType = eConversationTypeChatRoom;
            break;
        default:
            break;
    }
    return conversatinType;
}
*/


- (void)didReceiveLocalNotification:(UILocalNotification *)notification
{
//
////    NSLog(@"%@",self.topViewController);
////
////    NSString *conversationChatter = notification.userInfo[kConversationChatter];
////    EMMessageType messageType = [notification.userInfo[kMessageType] intValue];
////    
////    ChatViewController *chatViewController = [[ChatViewController alloc] initWithChatter:conversationChatter
////                                                                        conversationType:[self conversationTypeFromMessageType:messageType]];
//    /*
//    NSArray *buddyArray = [NSArray array];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *fileName = [NSString stringWithFormat:@"%@_huanxinFriends",[[NSUserDefaults standardUserDefaults] valueForKey:@"loginName"]];
//    NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
//        
//        buddyArray = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//    }
//    for (NSDictionary *buddy in buddyArray) {
//        if ([[buddy objectForKey:@"huanXinUserName"] isEqual:conversationChatter]) {
//            chatViewController.title = [buddy objectForKey:@"showName"];
//            break;
//        }
//    }
//     */
//    
//    NSArray *listArray = [self getDataFromDocument];
//    for (NSDictionary *singleInfo in listArray) {
//        NSString *chatter = [NSString stringWithFormat:@"w%@",[singleInfo objectForKey:@"watchId"]];
//        if ([chatter isEqual:conversationChatter]) {
//            chatViewController.title = [singleInfo objectForKey:@"name"];
//            chatViewController.chatterPhotoUrl = [singleInfo objectForKey:@"photoURL"];
//            break;
//        }
//    }
//    [self pushViewController:chatViewController animated:NO];
//    return;
//    
//    NSLog(@"%@",self);
//    NSDictionary *userInfo = notification.userInfo;
//    if (userInfo)
//    {
//        NSLog(@"%@",self.topViewController);
//        NSLog(@"self.topViewController = %@",[self.topViewController class]);
//        if ([self.topViewController isKindOfClass:[ChatViewController class]]) {
//            ChatViewController *chatController = (ChatViewController *)self.topViewController;
//            [chatController hideImagePicker];
//        }
//        
//        NSArray *viewControllers = self.viewControllers;
//        NSLog(@"%@",viewControllers);
//        [viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop){
//            if (obj != self)
//            {
//                if (![obj isKindOfClass:[ChatViewController class]])
//                {
//                    [self popViewControllerAnimated:NO];
//                }
//                else
//                {
//                    NSString *conversationChatter = userInfo[kConversationChatter];
//
//                    ChatViewController *chatViewController = (ChatViewController *)obj;
//                    if (![chatViewController.chatter isEqualToString:conversationChatter])
//                    {
//                        [self popViewControllerAnimated:NO];
//                        EMMessageType messageType = [userInfo[kMessageType] intValue];
//                        chatViewController = [[ChatViewController alloc] initWithChatter:conversationChatter conversationType:[self conversationTypeFromMessageType:messageType]];
//                        switch (messageType) {
//                            case eMessageTypeGroupChat:
//                            {
//                                NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
//                                for (EMGroup *group in groupArray) {
//                                    if ([group.groupId isEqualToString:conversationChatter]) {
//                                        chatViewController.title = group.groupSubject;
//                                        break;
//                                    }
//                                }
//                            }
//                                break;
//                            default:
//                            {
//                                NSArray *listArray = [self getDataFromDocument];
//                                for (NSDictionary *singleInfo in listArray) {
//                                    NSString *chatter = [NSString stringWithFormat:@"w%@",[singleInfo objectForKey:@"watchId"]];
//                                    if ([chatter isEqual:conversationChatter]) {
//                                        chatViewController.title = [singleInfo objectForKey:@"name"];
//                                        chatViewController.chatterPhotoUrl = [singleInfo objectForKey:@"photoURL"];
//                                        break;
//                                    }
//                                }
//                                
//                                /*
//                                NSArray *buddyArray = [NSArray array];
//                                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//                                NSString *fileName = [NSString stringWithFormat:@"%@_huanxinFriends",[[NSUserDefaults standardUserDefaults] valueForKey:@"loginName"]];
//                                NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
//                                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
//                                    
//                                    buddyArray = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//                                }
//                                for (NSDictionary *buddy in buddyArray) {
//                                    if ([[buddy objectForKey:@"huanXinUserName"] isEqual:conversationChatter]) {
//                                        chatViewController.title = [buddy objectForKey:@"showName"];
//                                        break;
//                                    }
//                                }
//                                 */
//                            }
//                                
//                                break;
//                        }
//                        [self pushViewController:chatViewController animated:NO];
//                    }
//                    *stop= YES;
//                }
//            }
//            else
//            {
//                ChatViewController *chatViewController = (ChatViewController *)obj;
//                NSString *conversationChatter = userInfo[kConversationChatter];
//                EMMessageType messageType = [userInfo[kMessageType] intValue];
//                
//                chatViewController = [[ChatViewController alloc] initWithChatter:conversationChatter
//                                                                conversationType:[self conversationTypeFromMessageType:messageType]];
//                chatViewController.showLinkman = 2;
//                switch (messageType) {
//                    case eMessageTypeGroupChat:
//                    {
//                        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
//                        for (EMGroup *group in groupArray) {
//                            if ([group.groupId isEqualToString:conversationChatter]) {
//                                chatViewController.title = group.groupSubject;
//                                break;
//                            }
//                        }
//                    }
//                        break;
//                    default:
//                    {
//                        NSArray *listArray = [self getDataFromDocument];
//                        for (NSDictionary *singleInfo in listArray) {
//                            NSString *chatter = [NSString stringWithFormat:@"w%@",[singleInfo objectForKey:@"watchId"]];
//                            if ([chatter isEqual:conversationChatter]) {
//                                chatViewController.title = [singleInfo objectForKey:@"name"];
//                                chatViewController.chatterPhotoUrl = [singleInfo objectForKey:@"photoURL"];
//                                break;
//                            }
//                        }
//                        /*
//                        NSArray *buddyArray = [NSArray array];
//                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//                        NSString *fileName = [NSString stringWithFormat:@"%@_huanxinFriends",[[NSUserDefaults standardUserDefaults] valueForKey:@"loginName"]];
//                        NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
//                        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
//                            
//                            buddyArray = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//                        }
//                        for (NSDictionary *buddy in buddyArray) {
//                            if ([[buddy objectForKey:@"huanXinUserName"] isEqual:conversationChatter]) {
//                                chatViewController.title = [buddy objectForKey:@"showName"];
//                                break;
//                            }
//                        }
//                         */
//                    }
//                        break;
//                }
//                [self pushViewController:chatViewController animated:NO];
//            }
//        }];
//    }
//    else if (_chatListVC)
//    {
//        [self popToViewController:self animated:NO];
////        [self setSelectedViewController:_chatListVC];
//    }
//    
//    
//    
//    
    
}

//- (BOOL)needShowNotification:(NSString *)fromChatter
//{
//    BOOL ret = YES;
//    NSArray *igGroupIds = [[EaseMob sharedInstance].chatManager ignoredGroupIds];
//    for (NSString *str in igGroupIds) {
//        if ([str isEqualToString:fromChatter]) {
//            ret = NO;
//            break;
//        }
//    }
//    
//    return ret;
//}


// 收到消息回调
/*
-(void)didReceiveMessage:(EMMessage *)message
{
    BOOL needShowNotification = (message.messageType != eMessageTypeChat) ? [self needShowNotification:message.conversationChatter] : YES;
    if (needShowNotification) {
        //#if !TARGET_IPHONE_SIMULATOR
        
        BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
        if (!isAppActivity) {
            [self showNotificationWithMessage:message];
            //            [self showLocationNotificationWithMessage:message];
        }else {
            [self playSoundAndVibration];
        }
        //#endif
    }
}
 

- (void)showLocationNotificationWithMessage:(EMMessage *)message {
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == ePushNotificationDisplayStyle_messageSummary) {
        id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
        NSString *messageStr = nil;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Text:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case eMessageBodyType_Image:
            {
                messageStr = NSLocalizedString(@"message.image", @"Image");
            }
                break;
            case eMessageBodyType_Location:
            {
                messageStr = NSLocalizedString(@"message.location", @"Location");
            }
                break;
            case eMessageBodyType_Voice:
            {
                messageStr = NSLocalizedString(@"message.voice", @"Voice");
            }
                break;
            case eMessageBodyType_Video:{
                messageStr = NSLocalizedString(@"message.video", @"Video");
            }
                break;
            default:
                break;
        }
        
        NSString *title = message.from;
        BOOL state = NO;
        for (NSDictionary *dic in self.resultArray) {
            if ([[dic objectForKey:@"huanXinUserName"] isEqual:message.from]) {
                title = [dic objectForKey:@"showName"];
                state = YES;
            }
        }
        
        if (message.messageType == eMessageTypeGroupChat) {
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:message.conversationChatter]) {
                    title = [NSString stringWithFormat:@"%@(%@)", message.groupSenderName, group.groupSubject];
                    break;
                }
            }
        }
        else if (message.messageType == eMessageTypeChatRoom)
        {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:@"username" ]];
            NSMutableDictionary *chatrooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
            NSString *chatroomName = [chatrooms objectForKey:message.conversationChatter];
            if (chatroomName)
            {
                title = [NSString stringWithFormat:@"%@(%@)", message.groupSenderName, chatroomName];
            }
        }
        
        notification.alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
    }
    else{
        notification.alertBody = NSLocalizedString(@"receiveMessage", @"you have a new message");
    }
    
#warning 去掉注释会显示[本地]开头, 方便在开发中区分是否为本地推送
    //notification.alertBody = [[NSString alloc] initWithFormat:@"[本地]%@", notification.alertBody];
    
    notification.alertAction = NSLocalizedString(@"open", @"Open");
    notification.timeZone = [NSTimeZone defaultTimeZone];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
    } else {
        notification.soundName = UILocalNotificationDefaultSoundName;
        self.lastPlaySoundDate = [NSDate date];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:message.messageType] forKey:kMessageType];
    [userInfo setObject:message.conversationChatter forKey:kConversationChatter];
    notification.userInfo = userInfo;
    
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    //    UIApplication *application = [UIApplication sharedApplication];
    //    application.applicationIconBadgeNumber += 1;
    [self setupUnreadMessageCount];
}
 */

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
