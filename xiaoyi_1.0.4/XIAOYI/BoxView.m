//
//  BoxView.m
//  DHT
//
//  Created by xiatian on 14-9-3.
//  Copyright (c) 2014年 xiatian. All rights reserved.
//

#import "BoxView.h"
#import <QuartzCore/QuartzCore.h>

@implementation BoxView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        // Initialization code
        
        self.rimView = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - 250.0f)/2, (frame.size.height - 250.0f)/2, 250.0f, 250.0f)];
        [self addSubview:self.rimView];
        
        
        UIImageView *scanImageView = [UIImageView imageViewWithFrame:CGRectMake(0, 0, self.rimView.frame.size.width, 6) imageName:@"scan_Animate" tag:0];
        [self.rimView addSubview:scanImageView];
        [self scanAnimate:scanImageView];
  
                
        
        [self.rimView addSubview:[UIImageView imageViewWithFrame:CGRectMake(-1, -1, 15, 15) imageName:@"Common_Boox_1" tag:0]];
        [self.rimView addSubview:[UIImageView imageViewWithFrame:CGRectMake(self.rimView.frame.size.width - 14, 0, 15, 15) imageName:@"Common_Boox_2" tag:0]];
        [self.rimView addSubview:[UIImageView imageViewWithFrame:CGRectMake(-1, self.rimView.frame.size.height - 14, 15, 15) imageName:@"Common_Boox_3" tag:0]];
        [self.rimView addSubview:[UIImageView imageViewWithFrame:CGRectMake(self.rimView.frame.size.width - 14, self.rimView.frame.size.height - 14, 15, 15) imageName:@"Common_Boox_4" tag:0]];
        
        self.contentLabel = [UILabel labelWithFrame:CGRectMake(0, self.rimView.frame.size.height + self.rimView.frame.origin.y + 15, frame.size.width, 14) text:@"将二维码放入框内，即可自动扫描" font:[UIFont systemFontOfSize:12.0f] textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter tag:0];
        [self addSubview:self.contentLabel];
        
    }
    return self;
}
-(void)scanAnimate:(UIView *)scanImageView
{
    __weak BoxView *selfController = self;
    [UIView animateWithDuration:2 //时长
                          delay:0 //延迟时间
                        options:UIViewAnimationOptionTransitionFlipFromLeft//动画效果
                     animations:^{
                         
                         //动画设置区域
                         scanImageView.frame=CGRectMake(0, selfController.rimView.frame.size.height - 10, selfController.rimView.frame.size.width, 10);
                         
                     } completion:^(BOOL finish){
                         scanImageView.frame=CGRectMake(0, 0, selfController.rimView.frame.size.width, 10);
                         [selfController scanAnimate:scanImageView];
                         //动画结束时调用
                         //............
                     }];
}
-(void) drawRect:(CGRect)rect2
{
    [super drawRect:rect2];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = self.rimView.frame;
    
    
    
    CGContextSetRGBFillColor(context,   0.0, 0.0, 0.0, 0.5);
    CGContextSetRGBStrokeColor(context, 0.8, 0.8, 0.8, 0.5);
    
    
    CGFloat lengths[2];
    lengths[0] = 0.0;
    lengths[1] = 0.0;
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 3.0);
    CGContextSetLineDash(context, 0.0f, lengths, 2);
    
    
    float w = self.bounds.size.width;
    float h = self.bounds.size.height;
    
    CGRect clips2[] =
	{
        CGRectMake(0, 0, w, rect.origin.y),
        CGRectMake(0, rect.origin.y,rect.origin.x, rect.size.height),
        CGRectMake(0, rect.origin.y + rect.size.height, w, h-(rect.origin.y+rect.size.height)),
        CGRectMake(rect.origin.x + rect.size.width, rect.origin.y, w-(rect.origin.x + rect.size.width), rect.size.height),
	};
    CGContextClipToRects(context, clips2, sizeof(clips2) / sizeof(clips2[0]));
    
    CGContextFillRect(context, self.bounds);
    CGContextStrokeRect(context, rect);
    UIGraphicsEndImageContext();
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

@implementation UIImageView (extension)

+ (UIImageView *)imageViewWithFrame:(CGRect)frame imageName:(NSString *)name tag:(NSInteger)tag{
    __autoreleasing UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.tag = tag;
    //    [imageView setUserInteractionEnabled:NO];
    //        [imageView setImage:[UIImage reSizeImage:[UIImage imageNamed:name] toSize:frame.size]];
    [imageView setImage:[UIImage imageNamed:name]];
    
    return imageView;
}

@end


@implementation UILabel (extension)

+ (UILabel *)labelWithFrame:(CGRect)frame
                       text:(NSString *)text
                       font:(UIFont *)font
                  textColor:(UIColor *)textColor
                  alignment:(NSTextAlignment)alignment
                        tag:(NSInteger)tag
{
    __autoreleasing UILabel *label_f = [[UILabel alloc] initWithFrame:frame];
    [label_f setText:text];
    [label_f setTextColor:textColor];
    [label_f setFont:font];
    label_f.textAlignment = alignment;
    //[label_f setTextAlignment:alignment];
    [label_f setBackgroundColor:[UIColor clearColor]];
    [label_f setTag:tag];
    return label_f;
}
@end

@implementation UIButton (extension)

+(UIButton *)buttonWithFrame:(CGRect)frame
                       title:(NSString *)title
                 normalImage:(UIImage *)normalImage
              highlightImage:(UIImage *)highlightImage
               selectedImage:(UIImage *)selectedImage
                        font:(UIFont *)font
                      target:(id)target
                      action:(SEL)action
                controlEvent:(UIControlEvents)controlEvent
                         tag:(NSInteger)tag
{
    __autoreleasing UIButton *button_f = [[UIButton alloc] initWithFrame:frame];
    [button_f setBackgroundColor:[UIColor clearColor]];
    if (title)
        [button_f setTitle:title forState:UIControlStateNormal];
    if (normalImage)
        [button_f setBackgroundImage:normalImage forState:UIControlStateNormal];
    if (highlightImage)
        [button_f setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    if (selectedImage)
        [button_f setBackgroundImage:selectedImage forState:UIControlStateSelected];
    if (font)
        [button_f.titleLabel setFont:font];
    if (action && target)
        [button_f addTarget:target action:action forControlEvents:controlEvent];
    [button_f setTag:tag];
    return button_f;
}
@end
