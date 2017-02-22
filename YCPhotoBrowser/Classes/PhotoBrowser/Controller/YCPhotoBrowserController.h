//
//  YCPhotoBrowserController.h
//  YCPhotoBrowser
//
//  Created by Durand on 16/5/18.
//  Copyright © 2016年 Durand. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YCPhotoBrowserController : UIViewController
@property (nonatomic,strong) NSIndexPath *currentIndexPath;
@property (nonatomic,copy) NSArray *imageURLs;
@property (nonatomic,strong) UICollectionView *collectionView;

- (instancetype)initWithImageURLs:(NSArray *)imageURLs indexPath:(NSIndexPath *)indexPath;
@end
