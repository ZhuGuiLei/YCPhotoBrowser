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
- (UIImageView *)imageViewForPresent:(NSInteger)index;
/// 动画转场的起始位置
- (CGRect)photoBrowserPresentFromRect:(NSInteger)index;
/// 动画转场的目标位置
- (CGRect)photoBrowserPresentToRect:(NSInteger)index;

@end

// MARK: - 解除动画协议
@protocol YCPhotoBrowserDismissDelegate <NSObject>
    
/// 解除转场的图像视图（包含起始位置）
- (UIImageView *)imageViewForDismiss;
    /// 解除转场的图像索引
- (NSInteger)indexForDismiss;

@end

@interface YCPhotoBrowserAnimator : NSObject<UIViewControllerTransitioningDelegate,UIViewControllerAnimatedTransitioning>
@property (nonatomic, weak) id<YCPhotoBrowserPresentDelegate> presentDelegate;
@property (nonatomic, weak) id<YCPhotoBrowserDismissDelegate> dismissDelegate;
@property (nonatomic, assign) BOOL  isPresented;
/// 动画图像的索引
@property (nonatomic, assign) NSInteger index;

- (void)setDelegateParamsPresentDelegate:(id<YCPhotoBrowserPresentDelegate>)presentDelegate index:(NSInteger)index dismissDelegate:(id<YCPhotoBrowserDismissDelegate>)dismissDelegate;

@end
