//
//  YCProgressImageView.m
//  YCPhotoBrowser
//
//  Created by Durand on 16/5/21.
//  Copyright © 2016年 Durand. All rights reserved.
//

#import "YCProgressImageView.h"

@interface YCPhotoProgressView : UIView
@property (nonatomic,assign) CGFloat progress;
@end

@implementation YCPhotoProgressView
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.progress = 0;
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGPoint center = CGPointMake(rect.size.width * 0.5,rect.size.height * 0.5);
    CGFloat r = MIN(rect.size.width, rect.size.height) * 0.5;
    CGFloat start = (CGFloat)(-M_PI_2);
    CGFloat end = start + self.progress * 2 * (CGFloat)(M_PI);
    
    /**
     参数：
     1. 中心点
     2. 半径
     3. 起始弧度
     4. 截至弧度
     5. 是否顺时针
     */
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:r startAngle:start endAngle:end clockwise:YES];
    
    // 添加到中心点的连线
    [path addLineToPoint:center];
    [path closePath];
    
    [[UIColor colorWithWhite:1 alpha:0.3] setFill];
    
    [path fill];
    
}

@end

@interface YCProgressImageView ()
@property (nonatomic,strong) YCPhotoProgressView *progressView;
@end

@implementation YCProgressImageView
- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.progress = 0;
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self addSubview:self.progressView];
    self.progressView.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.progressView.frame = self.bounds;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    self.progressView.progress = progress;
}

- (YCPhotoProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[YCPhotoProgressView alloc] init];
    }
    return _progressView;
}
@end


