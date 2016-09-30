//
//  NetworkService.h
//  XIAOYI
//
//  Created by 冠一 科技 on 15/12/4.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkService : NSObject


+ (void)GetServiceWithUrl:(NSString *)urlString parameters:(id)parameters finish:(void (^)(id resultObj, NSError *error))cb ;
@end
