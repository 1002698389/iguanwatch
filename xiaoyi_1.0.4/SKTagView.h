//
//  SKTagView.h
//
//  Created by Shaokang Zhao on 15/1/12.
//  Copyright (c) 2015 Shaokang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKTag.h"

@protocol SKTagViewDelegate <NSObject>

- (void)deleteContentByTag:(NSUInteger) index;
- (void)changeTableViewFrameWithHeight:(float)height;

@end

@interface SKTagView : UIView

@property (nonatomic, assign) id<SKTagViewDelegate> delegate;

@property (nonatomic) UIEdgeInsets padding;
@property (nonatomic) int lineSpace;
@property (nonatomic) CGFloat insets;
@property (nonatomic) CGFloat preferredMaxLayoutWidth;
@property (nonatomic) BOOL singleLine;

- (void)addTag:(SKTag *)tag;
- (void)insertTag:(SKTag *)tag atIndex:(NSUInteger)index;
- (void)removeTag:(SKTag *)tag;
- (void)removeTagAtIndex:(NSUInteger)index;
- (void)removeAllTags;

@property (nonatomic, copy) void (^didClickTagAtIndex)(NSUInteger index);

@end

