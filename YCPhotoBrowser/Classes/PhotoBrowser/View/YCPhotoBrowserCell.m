//
//  YCPhotoBrowserCell.m
//  YCPhotoBrowser
//
//  Created by Durand on 16/5/21.
//  Copyright © 2016年 Durand. All rights reserved.
//

#import "YCPhotoBrowserCell.h"
#import <UIImageView+WebCache.h>
#import "YCProgressImageView.h"

@interface YCPhotoBrowserCell ()<UIScrollViewDelegate>


@property (nonatomic,strong) YCProgressImageView *placeHolder;
@end

@implementation YCPhotoBrowserCell

- (void)tapImage
{
    [self.photoDelegate photoBrowserCellShouldDismiss];
}

- (void)longPressImage:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.photoDelegate photoBrowserSaveImage];
    }
}

- (void)setImageURL:(NSURL *)imageURL
{
    if (!imageURL) {
        return;
    }
    
    [self resetScrollView];
    [self setProgress];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:imageURL.path]) {
        
        self.placeHolder.hidden = YES;
        UIImage *img = [UIImage imageWithContentsOfFile:imageURL.path];
        self.imageView.image = img;
        [self setPositon:img];
        self.imageView.alpha = 0;
        self.imageView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        [UIView animateWithDuration:0.2 animations:^{
            self.imageView.alpha = 1;
            self.imageView.transform = CGAffineTransformMakeScale(1, 1);
        }];
        return;
    }
//    UIImage *placeHolderImage = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:self.imageURL.absoluteString];
    __weak typeof(self) weakSelf = self;
    [self.imageView sd_setImageWithURL:imageURL placeholderImage:nil options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.placeHolder.progress = (CGFloat)receivedSize / (CGFloat)expectedSize;
        });
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image == nil) {
            [SVProgressHUD showErrorWithStatus:@"connect error"];
            return ;
        }
        
        weakSelf.placeHolder.hidden = YES;
        
        [weakSelf setPositon:image];
        weakSelf.imageView.alpha = 0;
        weakSelf.imageView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.imageView.alpha = 1;
            weakSelf.imageView.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }];
    
}

- (void)resetScrollView
{
    // 重设 imageView 的内容属性 - scrollView 在处理缩放的时候，是调整代理方法返回视图的 transform 来实现的
    self.imageView.transform = CGAffineTransformIdentity;
    
    // 重设 scrollView 的内容属性
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.contentOffset = CGPointZero;
    self.scrollView.contentSize = CGSizeZero;
}

- (void)setProgress
{
    self.placeHolder.hidden = NO;
}

- (void)setPositon:(UIImage *)image
{
    // 自动设置大小
    CGSize size = [self displaySize:image];
    
    // 判断图片高度
    if (size.height < self.scrollView.bounds.size.height) {
        // 上下局中显示 - 调整 frame 的 x/y，一旦缩放，影响滚动范围
        self.imageView.frame = CGRectMake(0, 0, size.width, size.height);
        
        // 内容边距 － 会调整控件位置，但是不会影响控件的滚动
        CGFloat y = (self.scrollView.bounds.size.height - size.height) * 0.5;
        self.scrollView.contentInset = UIEdgeInsetsMake(y, 0, 0, 0);
    } else {
        self.imageView.frame = CGRectMake(0, 0, size.width, size.height);
        self.scrollView.contentSize = size;
    }

}

- (CGSize)displaySize:(UIImage *)image
{
    CGFloat w = self.scrollView.bounds.size.width;
    CGFloat h = image.size.height * w / image.size.width;
    
    return CGSizeMake(w, h);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}
- (void)setupUI
{
    [self.contentView addSubview:self.scrollView];
    [_scrollView addSubview:self.imageView];
    [_scrollView addSubview:self.placeHolder];
    
    // 2. 设置位置
    CGRect rect = self.bounds;
    rect.size.width -= 20;
    _scrollView.frame = rect;
    
    // 3. 设置 scrollView 缩放
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = 0.5;
    _scrollView.maximumZoomScale = 2.0;
    
    // 4. 添加手势识别
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage)];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressImage:)];
    _imageView.userInteractionEnabled = YES;
    [_imageView addGestureRecognizer:tap];
    [_imageView addGestureRecognizer:longPress];
    
    _placeHolder.frame = CGRectMake(0, 0, 60, 60);
    _placeHolder.center = _scrollView.center;
}

/// 返回被缩放的视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


/// 缩放完成后执行一次
///
/// - parameter scrollView: scrollView
/// - parameter view:       view 被缩放的视图
/// - parameter scale:      被缩放的比例
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view  atScale:(CGFloat)scale
{
    
    // 如果缩放比例 < 1，直接关闭
    if (scale < 1) {
        [self.photoDelegate photoBrowserCellShouldDismiss];
        return;
    }
    
    CGFloat offsetY = (scrollView.bounds.size.height - view.frame.size.height) * 0.5;
    offsetY = offsetY < 0 ? 0 : offsetY;
    
    CGFloat offsetX = (scrollView.bounds.size.width - view.frame.size.width) * 0.5;
    offsetX = offsetX < 0 ? 0 : offsetX;
    
    // 设置间距
    scrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, 0, 0);
}

/// 只要缩放就会被调用
/**
 a d => 缩放比例
 a b c d => 共同决定旋转
 tx ty => 设置位移
 
 定义控件位置 frame = center + bounds * transform
 */
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    // 通知代理缩放比例
    [self.photoDelegate photoBrowserCellDidZoomScale:self.imageView.transform.a];
}


- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
    }
    return _scrollView;
}

- (YCProgressImageView *)placeHolder
{
    if (!_placeHolder) {
        _placeHolder = [[YCProgressImageView alloc]init];
    }
    return _placeHolder;
}
@end
