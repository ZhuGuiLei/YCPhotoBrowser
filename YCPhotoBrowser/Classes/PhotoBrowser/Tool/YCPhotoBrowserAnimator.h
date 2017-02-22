//
//  YCPhotoBrowserAnimator.h
//  YCPhotoBrowser
//
//  Created by Durand on 16/5/21.
//  Copyright © 2016年 Durand. All rights reserved.
//

#import <Foundation/Foundation.h>

// MARK: - 展现动画协议
@protocol YCPhotoBrowserPresentDelegate <NSObject>
/// 指定 indexPath 对应的 imageView，用来做动画效果
- (UIImageView *)imageViewForPresent:(NSIndexPath *)indexPath;
/// 动画转场的起始位置
- (CGRect)photoBrowserPresentFromRect:(NSIndexPath *)indexPath;
/// 动画转场的目标位置
- (CGRect)photoBrowserPresentToRect:(NSIndexPath *)indexPath;

@end

// MARK: - 解除动画协议
@protocol YCPhotoBrowserDismissDelegate <NSObject>
    
/// 解除转场的图像视图（包含起始位置）
- (UIImageView *)imageViewForDismiss;
    /// 解除转场的图像索引
- (NSIndexPath *)indexPathForDismiss;

@end

@interface YCPhotoBrowserAnimator : NSObject<UIViewControllerTransitioningDelegate,UIViewControllerAnimatedTransitioning>
@property (nonatomic,weak) id<YCPhotoBrowserPresentDelegate> presentDelegate;
@property (nonatomic,weak) id<YCPhotoBrowserDismissDelegate> dismissDelegate;
@property (nonatomic,assign) BOOL  isPresented;
/// 动画图像的索引
@property (nonatomic,strong) NSIndexPath *indexPath;

- (void)setDelegateParamsPresentDelegate:(id<YCPhotoBrowserPresentDelegate>)presentDelegate indexPath: (NSIndexPath *)indexPath dismissDelegate: (id<YCPhotoBrowserDismissDelegate> )dismissDelegate;

@end
