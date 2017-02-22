//
//  YCPhotoBrowserController.m
//  YCPhotoBrowser
//
//  Created by Durand on 16/5/18.
//  Copyright © 2016年 Durand. All rights reserved.
//

#import "YCPhotoBrowserController.h"
#import "YCPhotoBrowserCell.h"
#import "YCPhotoBrowserAnimator.h"

@interface PhotoBrowserViewLayout : UICollectionViewFlowLayout

@end

@implementation PhotoBrowserViewLayout

- (void)prepareLayout
{
    [super prepareLayout];
    
    self.itemSize = self.collectionView.bounds.size;
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView.pagingEnabled = YES;
    self.collectionView.bounces = NO;
    
    self.collectionView.showsHorizontalScrollIndicator = NO;
}

@end

static NSString *PhotoBrowserViewCellId = @"PhotoBrowserViewCellId";
@interface YCPhotoBrowserController ()<UICollectionViewDataSource,YCPhotoBrowserCellDelegate,YCPhotoBrowserDismissDelegate,UIActionSheetDelegate>

//@property (nonatomic,strong) UIButton *closeBtn;
//@property (nonatomic,strong) UIButton *saveBtn;
@end

@implementation YCPhotoBrowserController

- (void)loadView
{
    CGRect rect = [UIScreen mainScreen].bounds;
    rect.size.width += 20;
    self.view = [[UIView alloc] initWithFrame:rect];
    
    [self setupUI];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (instancetype)initWithImageURLs:(NSArray *)imageURLs indexPath:(NSIndexPath *)indexPath
{
    self = [super init];
    if (self) {
        self.imageURLs = imageURLs;
        self.currentIndexPath = indexPath;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView scrollToItemAtIndexPath:self.currentIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)savePhoto
{
    YCPhotoBrowserCell *cell = (YCPhotoBrowserCell*)[self.collectionView visibleCells][0];
    // imageView 中很可能会因为网络问题没有图片 -> 下载需要提示
    UIImage *img = cell.imageView.image;
    if (!img) {
        return;
    }
    
    // 2. 保存图片
    UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *msg = error == nil ? @"Success" : @"Fail";
    if (error) {
        [SVProgressHUD showErrorWithStatus:@"Fail"];
    }
    else
    {
        [SVProgressHUD showSuccessWithStatus:msg];
    }
}

- (void)setupUI
{
    
    [self.view addSubview:self.collectionView];
//    [self.view addSubview:self.saveBtn];
//    [self.view addSubview:self.closeBtn];
    
    _collectionView.frame = self.view.bounds;
//    CGSize size = CGSizeMake(100, 36);
//    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.view.mas_bottom).offset(-8);
//        make.left.equalTo(self.view.mas_left).offset(8);
//        make.size.mas_equalTo(size);
//    }];
//    
//    [_saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.view.mas_bottom).offset(-8);
//        make.right.equalTo(self.view.mas_right).offset(-28);
//        make.size.mas_equalTo(size);
//    }];
    
//    [self.closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
//    [self.saveBtn addTarget:self action:@selector(savePhoto) forControlEvents:UIControlEventTouchUpInside];
    
    [self.collectionView registerClass:[YCPhotoBrowserCell class] forCellWithReuseIdentifier:PhotoBrowserViewCellId];
    self.collectionView.dataSource = self;
}


#pragma mark - CollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageURLs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YCPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoBrowserViewCellId forIndexPath:indexPath];
    NSString *urlStr = self.imageURLs[indexPath.item];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    cell.imageURL = [NSURL URLWithString:urlStr];
    cell.photoDelegate = self;
    return cell;
}

#pragma mark - YCPhotoBrowserCellDelegate
- (void)photoBrowserCellShouldDismiss
{
    [self close];
}

- (void)photoBrowserSaveImage
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Save"
                                                    otherButtonTitles:nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

- (void)photoBrowserCellDidZoomScale:(CGFloat)scale
{
    BOOL isHidden = (scale < 1);
    [self hideControls:isHidden];
    
    if (isHidden) {
        // 1. 根据 scale 修改根视图的透明度 & 缩放比例
        self.view.alpha = scale;
        self.view.transform = CGAffineTransformMakeScale(scale, scale);
    } else {
        self.view.alpha = 1.0;
        self.view.transform = CGAffineTransformIdentity;
    }
}

/// 隐藏或者显示控件
- (void)hideControls:(BOOL)isHidden {
//    self.closeBtn.hidden = isHidden;
//    self.saveBtn.hidden = isHidden;
    
    self.collectionView.backgroundColor = isHidden ? [UIColor clearColor] : [UIColor blackColor];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self savePhoto];
    }
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[PhotoBrowserViewLayout alloc] init]];
    }
    return _collectionView;
}

//- (UIButton *)saveBtn
//{
//    if (!_saveBtn) {
//        _saveBtn = [[UIButton alloc] initWithTitle:@"Save" titleColor:[UIColor whiteColor] fontSize:14 backGroundColor:[UIColor darkGrayColor] cornerRadius:5 buttonType:UIButtonTypeSystem];
//    }
//    return _saveBtn;
//}

//- (UIButton *)closeBtn
//{
//    if (!_closeBtn) {
//        _closeBtn = [[UIButton alloc] initWithTitle:@"Close" titleColor:[UIColor whiteColor] fontSize:14 backGroundColor:[UIColor darkGrayColor] cornerRadius:5 buttonType:UIButtonTypeSystem];
//    }
//    return _closeBtn;
//}

#pragma mark - Animatior Dissmiss Delegate
- (UIImageView *)imageViewForDismiss
{
    UIImageView *iv = [[UIImageView alloc] init];
    
    // 设置填充模式
    iv.contentMode = UIViewContentModeScaleAspectFill;
    iv.clipsToBounds = YES;
    
    // 设置图像 - 直接从当前显示的 cell 中获取
    YCPhotoBrowserCell *cell = [self.collectionView visibleCells][0];
    iv.image = cell.imageView.image;
    
    // 设置位置 - 坐标转换(由父视图进行转换)
    iv.frame = [cell.scrollView convertRect:cell.imageView.frame toCoordinateSpace:[UIApplication sharedApplication].keyWindow];
    
    
    return iv;

}

- (NSIndexPath *)indexPathForDismiss
{
    return [self.collectionView indexPathsForVisibleItems][0];
}

@end

