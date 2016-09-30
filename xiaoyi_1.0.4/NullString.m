//
//  NullString.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/9/9.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "NullString.h"

@implementation NullString


+ (NSString *)contrastString:(id) object {
    NSString *lastString = @"";
    if ([object isEqual:[NSNull null]]) {
        return lastString;
    } else {
        return object;
    }
}

+ (BOOL)contrastContent:(id) object {
    if ([object isEqual:[NSNull null]]) {
        return NO;
    } else {
        return YES;
    }
}

@end
