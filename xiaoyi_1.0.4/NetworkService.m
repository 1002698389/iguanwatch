//
//  NetworkService.m
//  XIAOYI
//
//  Created by 冠一 科技 on 15/12/4.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import "NetworkService.h"

@implementation NetworkService

+ (void)GetServiceWithUrl:(NSString *)urlString parameters:(id)parameters finish:(void (^)(id, NSError *))finished {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            finished( responseObject ,nil);
        } else if ([[responseObject objectForKey:@"code"] intValue] == 1006) {
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        finished( nil ,error);
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提醒" message:@"网路连接出错，请稍后再试" delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
    }];
}

@end
