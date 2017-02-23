//
//  YCPhotoBrowserAnimator.m
//  YCPhotoBrowser
//
//  Created by Durand on 16/5/21.
//  Copyright © 2016年 Durand. All rights reserved.
//

#import "YCPhotoBrowserAnimator.h"
#import "YCPhotoBrowserController.h"


@implementation YCPhotoBrowserAnimator
- (void)setDelegateParamsPresentDelegate:(id<YCPhotoBrowserPresentDelegate>)presentDelegate index:(NSInteger)index dismissDelegate:(id<YCPhotoBrowserDismissDelegate>)dismissDelegate
{
    self.presentDelegate = presentDelegate;
    self.dismissDelegate = dismissDelegate;
    self.index = index;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.isPresented = YES;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.isPresented = NO;
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

/// 实现具体的动画效果 - 
///
/// - parameter transitionContext: 转场动画的上下文 － 提供动画所需要的素材
/**
 1. 容器视图 － 会将 Modal 要展现的视图包装在容器视图中
 存放的视图要显示－必须自己指定大小！不会通过自动布局填满屏幕
 2. viewControllerForKey: fromVC / toVC
 3. viewForKey: fromView / toView
 4. completeTransition: 无论转场是否被取消，都必须调用
 否则，系统不做其他事件处理！
 */

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    // 自动布局系统不会对根视图做任何约束
    //        let v = UIView(frame: UIScreen.mainScreen().bounds)
    //        v.backgroundColor = UIColor.redColor()
//    UIViewController  *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    
//    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//
//    
//    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
//    
//    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];

    
    self.isPresented ? [self presentAnimation:transitionContext] : [self dismissAnimation:transitionContext];
}

- (void)dismissAnimation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (!self.presentDelegate || !self.dismissDelegate) {
        return;
    }
    
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    [fromView removeFromSuperview];
    
    UIImageView *iv = [self.dismissDelegate imageViewForDismiss];
    
    [transitionContext.containerView addSubview:iv];
    
    NSInteger index = [self.dismissDelegate indexForDismiss];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        iv.frame = [self.presentDelegate photoBrowserPresentFromRect:index];
    } completion:^(BOOL finished) {
        [iv removeFromSuperview];
        
        [transitionContext completeTransition:YES];
    }];
    
}

- (void)presentAnimation:(id <UIViewControllerContextTransitioning>)transitionContext
{
    if (!self.presentDelegate) {
        return;
    }
    // 1. 目标视图
    // 1> 获取 modal 要展现的控制器的根视图
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    // 2> 将视图添加到容器视图中
    [transitionContext.containerView addSubview:toView];
    // 2. 获取目标控制器 - 照片查看控制器
    YCPhotoBrowserController *toVC = (YCPhotoBrowserController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    // 隐藏 collectionView
    toVC.collectionView.hidden = YES;
    
    // 3. 图像视图
    UIImageView *iv = [self.presentDelegate imageViewForPresent:self.index];
    // 写到这里了 05-21
    
    iv.frame = [self.presentDelegate photoBrowserPresentFromRect:self.index];
    
    [transitionContext.containerView addSubview:iv];
    
    toView.alpha = 0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        iv.frame = [self.presentDelegate photoBrowserPresentToRect:self.index];
        toView.alpha = 1;
    } completion:^(BOOL finished) {
        
        // 将图像视图删除
        [iv removeFromSuperview];
        
        // 显示目标视图控制器的 collectioView
        toVC.collectionView.hidden = NO;
        
        // 告诉系统转场动画完成
        [transitionContext completeTransition:YES];
    }];
}


@end
