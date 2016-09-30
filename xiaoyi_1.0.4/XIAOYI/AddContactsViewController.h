//
//  AddContactsViewController.h
//  XIAOYI
//
//  Created by 冠一 科技 on 15/11/2.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReloadContactsDelegate <NSObject>

- (void)reloadContacts;

@end

@interface AddContactsViewController : UIViewController


@property (nonatomic, assign) NSInteger contactsIndex;
@property (nonatomic, strong) NSArray *allContactAry;
@property (nonatomic, assign) id<ReloadContactsDelegate> delegate;

@property (nonatomic, assign) BOOL isAdding;
@property (nonatomic, assign) NSInteger selectedIndex;

@end
