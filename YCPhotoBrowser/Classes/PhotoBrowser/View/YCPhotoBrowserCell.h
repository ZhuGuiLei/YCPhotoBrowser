//
//  YCPhotoBrowserCell.h
//  YCPhotoBrowser
//
//  Created by Durand on 16/5/21.
//  Copyright © 2016年 Durand. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YCPhotoBrowserCellDelegate <NSObject>
/** 视图控制器将要关闭*/
- (void)photoBrowserCellShouldDismiss;
/** 通知代理缩放的比例*/
- (void)photoBrowserCellDidZoomScale:(CGFloat)scale;

- (void)photoBrowserSaveImage;

@end

@interface YCPhotoBrowserCell : UICollectionViewCell
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,weak) id<YCPhotoBrowserCellDelegate> photoDelegate;
@property (nonatomic,copy) NSURL *imageURL;
@property (nonatomic,strong) UIScrollView *scrollView;
@end
