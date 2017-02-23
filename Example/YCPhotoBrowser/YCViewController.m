//
//  YCViewController.m
//  YCPhotoBrowser
//
//  Created by flappyFeline on 01/17/2017.
//  Copyright (c) 2017 flappyFeline. All rights reserved.
//

#import "YCViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <YCPhotoBrowser/YCPhotoBrowserHeader.h>

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height


@interface YCViewController () <YCPhotoBrowserPresentDelegate>
@property (nonatomic, strong) UIImageView *testImageView;
@property (nonatomic, strong) id animator;
@property (nonatomic, copy) NSArray *imageURLs;
@end

@implementation YCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _testImageView = ({
        UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"3523321514_371d9ac42f_b.jpg"]];
        CGFloat imgViewWH = self.view.bounds.size.width;
        imgV.frame = CGRectMake(0, 20, imgViewWH, imgViewWH);
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        imgV.backgroundColor = [UIColor blackColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageView)];
        [imgV addGestureRecognizer:tap];
        imgV.userInteractionEnabled = YES;
        [self.view addSubview:imgV];
        
        imgV;
    });
    
    
    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn setTitle:@"Check Photo" forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(didClickCheckPhotoButton) forControlEvents:UIControlEventTouchUpInside];
//    btn.frame = CGRectMake(100, 100, 200, 100);
//    [self.view addSubview:btn];
    
    
}
/* 
 let photosWithURLArray = [NSURL.init(string: "http://farm4.static.flickr.com/3567/3523321514_371d9ac42f_b.jpg"),
 NSURL.init(string: "http://farm4.static.flickr.com/3629/3339128908_7aecabc34b_b.jpg"),
 NSURL.init(string: "http://farm4.static.flickr.com/3364/3338617424_7ff836d55f_b.jpg"),
 NSURL.init(string: "http://farm4.static.flickr.com/3590/3329114220_5fbc5bc92b_b.jpg")]
 */

- (void)didTapImageView
{
    if (!_imageURLs) {
        _imageURLs = @[
                       @"http://farm4.static.flickr.com/3567/3523321514_371d9ac42f_b.jpg",
                       @"http://farm4.static.flickr.com/3629/3339128908_7aecabc34b_b.jpg",
                       @"http://farm4.static.flickr.com/3364/3338617424_7ff836d55f_b.jpg",
                       @"http://farm4.static.flickr.com/3590/3329114220_5fbc5bc92b_b.jpg",
                       ];
    }
    NSLog(@"didTapImageView");
    YCPhotoBrowserController *vc = [[YCPhotoBrowserController alloc] initWithImageURLs:_imageURLs currentIndex:0];
    
    YCPhotoBrowserAnimator *animator = [[YCPhotoBrowserAnimator alloc] init];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.transitioningDelegate = animator;
    [animator setDelegateParamsPresentDelegate:self index:0 dismissDelegate:vc];
    _animator = animator;
    [self presentViewController:vc animated:YES completion:nil];
}

/// 指定 indexPath 对应的 imageView，用来做动画效果
- (UIImageView *)imageViewForPresent:(NSInteger)index
{
    UIImageView *iv = [[UIImageView alloc] init];
    iv.contentMode = UIViewContentModeScaleAspectFill;
    iv.clipsToBounds = YES;
    [iv sd_setImageWithURL:[NSURL URLWithString:self.imageURLs[index]]];
    return iv;
}
/// 动画转场的起始位置
- (CGRect)photoBrowserPresentFromRect:(NSInteger)index
{
    CGRect rect = [_testImageView convertRect:_testImageView.frame toCoordinateSpace:[UIApplication sharedApplication].keyWindow];
    return rect;
}
/// 动画转场的目标位置
- (CGRect)photoBrowserPresentToRect:(NSInteger)index
{
    NSString *imageKey = self.imageURLs[index];
    if (!imageKey) {
        return CGRectMake(0, (kScreenH - kScreenW) * 0.5, kScreenW, kScreenW);
    }
    
    UIImage *image = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:imageKey];
    if (!image) {
        return CGRectMake(0, (kScreenH - kScreenW) * 0.5, kScreenW, kScreenW);
    }
    
    // 根据图像大小，计算全屏的大小
    CGFloat w = kScreenW;
    CGFloat h = image.size.height * w / image.size.width;
    
    // 对高度进行额外处理
    CGFloat screenHeight = kScreenH;
    CGFloat y = 0;
    if (h < screenHeight)
    {       // 图片短，垂直居中显示
        y = (screenHeight - h) * 0.5;
    }
    
    CGRect rect = CGRectMake(0, y, w, h);
    
    return rect;
}



- (void)didClickCheckPhotoButton
{
    
}

@end
