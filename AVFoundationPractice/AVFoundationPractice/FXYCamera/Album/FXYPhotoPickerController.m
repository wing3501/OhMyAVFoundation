//
//  FXYPhotoPickerController.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/20.
//  Copyright © 2019 styf. All rights reserved.
//

#import "FXYPhotoPickerController.h"
#import "FXYImagePickerController.h"
#import "FXYAlbumModel.h"
#import "FXYAssetModel.h"
#import "FXYImageManager.h"
#import "FXYAssetCell.h"
#import "NSBundle+FXYImagePicker.h"
#import "UIView+FXYLayout.h"
#import "FXYCommonTools.h"
#import "FXYImagePickerConfig.h"
#import "FXYImageRequestOperation.h"
#import "FXYVideoPlayerController.h"
#import "FXYGifPhotoPreviewController.h"
#import "FXYPhotoPreviewController.h"
#import "UIImage+FXYBundle.h"
@interface FXYPhotoPickerController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate> {
    NSMutableArray *_models;//该相册的照片模型
    
    UIButton *_previewButton;
    UIButton *_doneButton;
    UIImageView *_numberImageView;
    UILabel *_numberLabel;
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLabel;
    UIView *_divideLine;
    
    BOOL _shouldScrollToBottom;
    
    CGFloat _offsetItemCount;
}
@property CGRect previousPreheatRect;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic, strong) FXYCollectionView *collectionView;
@property (nonatomic, strong) UILabel *noDataLabel;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
/// 自定义导航栏
@property (nonatomic, strong) UIView *customNavigationBar;
/// 标题按钮
@property (nonatomic, strong) UIButton *titleButton;
/// 关闭按钮
@property (nonatomic, strong) UIButton *closeButton;
/// 底部工具条
@property (nonatomic, strong) UIView *bottomToolBar;
@end

static CGSize AssetGridThumbnailSize;
static CGFloat itemMargin = 5;

@implementation FXYPhotoPickerController

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFirstAppear = YES;
    FXYImagePickerController *tzImagePickerVc = (FXYImagePickerController *)self.navigationController;
    _isSelectOriginalPhoto = tzImagePickerVc.isSelectOriginalPhoto;
    _shouldScrollToBottom = YES;
    self.view.backgroundColor = [UIColor whiteColor];
#warning 相册名字这里要用按钮，点击切换
//    self.navigationItem.title = _model.name;//相册名字
//    [self.titleButton setTitle:_model.name forState:UIControlStateNormal];
//    self.navigationItem.titleView = self.titleButton;
#warning 左边加一个叉叉的dismiss按钮
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage fxy_imageNamedFromMyBundle:@"priceReduce_close"]imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(cancelButtonClick)];
    
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:tzImagePickerVc.cancelBtnTitleStr style:UIBarButtonItemStylePlain target:tzImagePickerVc action:@selector(cancelButtonClick)];
//    if (tzImagePickerVc.navLeftBarButtonSettingBlock) {
//        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        leftButton.frame = CGRectMake(0, 0, 44, 44);
//        [leftButton addTarget:self action:@selector(navLeftBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
//        tzImagePickerVc.navLeftBarButtonSettingBlock(leftButton);
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
//    } else if (tzImagePickerVc.childViewControllers.count) {
//        [tzImagePickerVc.childViewControllers firstObject].navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle fxy_localizedStringForKey:@"Back"] style:UIBarButtonItemStylePlain target:nil action:nil];
//    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 3;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Determine the size of the thumbnails to request from the PHCachingImageManager
    CGFloat scale = 2.0;
    if ([UIScreen mainScreen].bounds.size.width > 600) {
        scale = 1.0;
    }
    CGSize cellSize = ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    
    if (!_models) {
        [self fetchAssetModels];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // [self updateCachedAssets];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    FXYImagePickerController *tzImagePickerVc = (FXYImagePickerController *)self.navigationController;
    tzImagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
}

- (void)initSubviews {
    dispatch_async(dispatch_get_main_queue(), ^{
        FXYImagePickerController *tzImagePickerVc = (FXYImagePickerController *)self.navigationController;
        [tzImagePickerVc hideProgressHUD];
        
        [self checkSelectedModels];
        [self configNavigationBar];
        [self configCollectionView];
        self->_collectionView.hidden = YES;
        [self configBottomToolBar];
        [self->_collectionView reloadData];
        [self scrollCollectionViewToBottom];
    });
}

#pragma mark - overwrite

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    FXYImagePickerController *tzImagePicker = (FXYImagePickerController *)self.navigationController;
    if (tzImagePicker && [tzImagePicker isKindOfClass:[FXYImagePickerController class]]) {
        return tzImagePicker.statusBarStyle;
    }
    return [super preferredStatusBarStyle];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    FXYImagePickerController *tzImagePickerVc = (FXYImagePickerController *)self.navigationController;
    
    CGFloat top = 0;
    CGFloat collectionViewHeight = 0;
    CGFloat naviBarHeight = self.navigationController.navigationBar.fxy_height;
    BOOL isStatusBarHidden = [UIApplication sharedApplication].isStatusBarHidden;
    CGFloat toolBarHeight = [FXYCommonTools fxy_isIPhoneX] ? 50 + (83 - 49) : 50;
    if (self.navigationController.navigationBar.isTranslucent) {
        top = naviBarHeight;
        if (!isStatusBarHidden) top += [FXYCommonTools fxy_statusBarHeight];
        collectionViewHeight = tzImagePickerVc.showSelectBtn ? self.view.fxy_height - toolBarHeight - top : self.view.fxy_height - top;;
    } else {
        collectionViewHeight = tzImagePickerVc.showSelectBtn ? self.view.fxy_height - toolBarHeight : self.view.fxy_height;
    }
    _collectionView.frame = CGRectMake(0, top, self.view.fxy_width, collectionViewHeight);
    _noDataLabel.frame = _collectionView.bounds;
    CGFloat itemWH = (self.view.fxy_width - (self.columnNumber + 1) * itemMargin) / self.columnNumber;
    _layout.itemSize = CGSizeMake(itemWH, itemWH);
    _layout.minimumInteritemSpacing = itemMargin;
    _layout.minimumLineSpacing = itemMargin;
    [_collectionView setCollectionViewLayout:_layout];
    if (_offsetItemCount > 0) {
        CGFloat offsetY = _offsetItemCount * (_layout.itemSize.height + _layout.minimumLineSpacing);
        [_collectionView setContentOffset:CGPointMake(0, offsetY)];
    }
    
    CGFloat toolBarTop = 0;
    if (!self.navigationController.navigationBar.isHidden) {
        toolBarTop = self.view.fxy_height - toolBarHeight;
    } else {
        CGFloat navigationHeight = naviBarHeight + [FXYCommonTools fxy_statusBarHeight];
        toolBarTop = self.view.fxy_height - toolBarHeight - navigationHeight;
    }
    _bottomToolBar.frame = CGRectMake(0, toolBarTop, self.view.fxy_width, toolBarHeight);
    
    CGFloat previewWidth = [tzImagePickerVc.previewBtnTitleStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size.width + 2;
    if (!tzImagePickerVc.allowPreview) {
        previewWidth = 0.0;
    }
    _previewButton.frame = CGRectMake(10, 3, previewWidth, 44);
    _previewButton.fxy_width = !tzImagePickerVc.showSelectBtn ? 0 : previewWidth;
    if (tzImagePickerVc.allowPickingOriginalPhoto) {
        CGFloat fullImageWidth = [tzImagePickerVc.fullImageBtnTitleStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size.width;
        _originalPhotoButton.frame = CGRectMake(CGRectGetMaxX(_previewButton.frame), 0, fullImageWidth + 56, 50);
        _originalPhotoLabel.frame = CGRectMake(fullImageWidth + 46, 0, 80, 50);
    }
    [_doneButton sizeToFit];
    _doneButton.frame = CGRectMake(self.view.fxy_width - _doneButton.fxy_width - 12, 0, _doneButton.fxy_width, 50);
    _numberImageView.frame = CGRectMake(_doneButton.fxy_left - 24 - 5, 13, 24, 24);
    _numberLabel.frame = _numberImageView.frame;
    _divideLine.frame = CGRectMake(0, 0, self.view.fxy_width, 1);
    
    [FXYImageManager manager].columnNumber = [FXYImageManager manager].columnNumber;
    [FXYImageManager manager].photoWidth = tzImagePickerVc.photoWidth;
    [self.collectionView reloadData];
    
}
#pragma mark - request

/**
 抓取相册对象数据
 */
- (void)fetchAssetModels {
    FXYImagePickerController *tzImagePickerVc = (FXYImagePickerController *)self.navigationController;
    if (_isFirstAppear && !_model.models.count) {
        [tzImagePickerVc showProgressHUD];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (!tzImagePickerVc.sortAscendingByModificationDate && self->_isFirstAppear && self->_model.isCameraRoll) {
            [[FXYImageManager manager] getCameraRollAlbum:tzImagePickerVc.allowPickingVideo allowPickingImage:tzImagePickerVc.allowPickingImage needFetchAssets:YES completion:^(FXYAlbumModel *model) {
                self->_model = model;
                self->_models = [NSMutableArray arrayWithArray:self->_model.models];
                [self initSubviews];
            }];
        } else {
            if (self->_isFirstAppear) {
                [[FXYImageManager manager] getAssetsFromFetchResult:self->_model.result completion:^(NSArray<FXYAssetModel *> *models) {
                    self->_models = [NSMutableArray arrayWithArray:models];
                    [self initSubviews];
                }];
            } else {
                self->_models = [NSMutableArray arrayWithArray:self->_model.models];
                [self initSubviews];
            }
        }
    });
}


#pragma mark - public

#pragma mark - notification

- (void)didChangeStatusBarOrientationNotification:(NSNotification *)noti {
    _offsetItemCount = _collectionView.contentOffset.y / (_layout.itemSize.height + _layout.minimumLineSpacing);
}

#pragma mark - event response

/**
 预览按钮点击
 */
- (void)previewButtonClick {
#warning 可能不需要
//    TZPhotoPreviewController *photoPreviewVc = [[TZPhotoPreviewController alloc] init];
//    [self pushPhotoPrevireViewController:photoPreviewVc needCheckSelectedModels:YES];
}

/**
 选中原图
 */
- (void)originalPhotoButtonClick {
#warning 可能不需要
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _isSelectOriginalPhoto = _originalPhotoButton.isSelected;
    _originalPhotoLabel.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) {
        [self getSelectedPhotoBytes];
    }
}

/**
 完成按钮点击
 */
- (void)doneButtonClick {
    FXYImagePickerController *tzImagePickerVc = (FXYImagePickerController *)self.navigationController;
    // 1.6.8 判断是否满足最小必选张数的限制
    if (tzImagePickerVc.minImagesCount && tzImagePickerVc.selectedModels.count < tzImagePickerVc.minImagesCount) {
        NSString *title = [NSString stringWithFormat:[NSBundle fxy_localizedStringForKey:@"Select a minimum of %zd photos"], tzImagePickerVc.minImagesCount];
        [tzImagePickerVc showAlertWithTitle:title];
        return;
    }
    
    [tzImagePickerVc showProgressHUD];
    NSMutableArray *assets = [NSMutableArray array];
    NSMutableArray *photos;
    NSMutableArray *infoArr;
    if (tzImagePickerVc.onlyReturnAsset) { // not fetch image
        for (NSInteger i = 0; i < tzImagePickerVc.selectedModels.count; i++) {
            FXYAssetModel *model = tzImagePickerVc.selectedModels[i];
            [assets addObject:model.asset];
        }
    } else { // fetch image
        photos = [NSMutableArray array];
        infoArr = [NSMutableArray array];
        for (NSInteger i = 0; i < tzImagePickerVc.selectedModels.count; i++) { [photos addObject:@1];[assets addObject:@1];[infoArr addObject:@1]; }
        
        __block BOOL havenotShowAlert = YES;
        [FXYImageManager manager].shouldFixOrientation = YES;
        __block UIAlertController *alertView;
        for (NSInteger i = 0; i < tzImagePickerVc.selectedModels.count; i++) {
            FXYAssetModel *model = tzImagePickerVc.selectedModels[i];
            FXYImageRequestOperation *operation = [[FXYImageRequestOperation alloc] initWithAsset:model.asset completion:^(UIImage * _Nonnull photo, NSDictionary * _Nonnull info, BOOL isDegraded) {
                if (isDegraded) return;
                if (photo) {
                    if (![FXYImagePickerConfig sharedInstance].notScaleImage) {
                        photo = [[FXYImageManager manager] scaleImage:photo toSize:CGSizeMake(tzImagePickerVc.photoWidth, (int)(tzImagePickerVc.photoWidth * photo.size.height / photo.size.width))];
                    }
                    [photos replaceObjectAtIndex:i withObject:photo];
                }
                if (info)  [infoArr replaceObjectAtIndex:i withObject:info];
                [assets replaceObjectAtIndex:i withObject:model.asset];
                
                for (id item in photos) { if ([item isKindOfClass:[NSNumber class]]) return; }
                
                if (havenotShowAlert) {
                    [tzImagePickerVc hideAlertView:alertView];
                    [self didGetAllPhotos:photos assets:assets infoArr:infoArr];
                }
            } progressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
                // 如果图片正在从iCloud同步中,提醒用户
                if (progress < 1 && havenotShowAlert && !alertView) {
                    [tzImagePickerVc hideProgressHUD];
                    alertView = [tzImagePickerVc showAlertWithTitle:[NSBundle fxy_localizedStringForKey:@"Synchronizing photos from iCloud"]];
                    havenotShowAlert = NO;
                    return;
                }
                if (progress >= 1) {
                    havenotShowAlert = YES;
                }
            }];
            [self.operationQueue addOperation:operation];
        }
    }
    if (tzImagePickerVc.selectedModels.count <= 0 || tzImagePickerVc.onlyReturnAsset) {
        [self didGetAllPhotos:photos assets:assets infoArr:infoArr];
    }
}

/**
 点击标题
 */
- (void)titleClick:(UIButton *)button {
    button.selected = !button.selected;
    !_titleClickBlock ?: _titleClickBlock(button.selected);
}
#pragma mark - private

/**
 设置该相册中选中的模型
 */
- (void)checkSelectedModels {
    NSMutableArray *selectedAssets = [NSMutableArray array];
    FXYImagePickerController *tzImagePickerVc = (FXYImagePickerController *)self.navigationController;
    for (FXYAssetModel *model in tzImagePickerVc.selectedModels) {
        [selectedAssets addObject:model.asset];
    }
    for (FXYAssetModel *model in _models) {
        model.isSelected = NO;
        if ([selectedAssets containsObject:model.asset]) {
            model.isSelected = YES;
        }
    }
}

/**
 设置导航栏
 */
- (void)configNavigationBar {
    [self.view addSubview:self.customNavigationBar];
    [self.customNavigationBar addSubview:self.titleButton];
    self.titleButton.center = CGPointMake(self.customNavigationBar.fxy_width * 0.5, self.customNavigationBar.fxy_height * 0.5);
    [self.customNavigationBar addSubview:self.closeButton];
}

/**
 设置列表
 */
- (void)configCollectionView {
    if (!_collectionView) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[FXYCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        _collectionView.backgroundColor = [UIColor lightGrayColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.alwaysBounceHorizontal = NO;
        _collectionView.contentInset = UIEdgeInsetsMake(itemMargin, itemMargin, itemMargin, itemMargin);
        
        _collectionView.contentSize = CGSizeMake(self.view.fxy_width, ((_model.count + self.columnNumber - 1) / self.columnNumber) * self.view.fxy_width);
        if (_models.count == 0) {
            _noDataLabel = [UILabel new];
            _noDataLabel.textAlignment = NSTextAlignmentCenter;
            _noDataLabel.text = [NSBundle fxy_localizedStringForKey:@"No Photos or Videos"];
            CGFloat rgb = 153 / 256.0;
            _noDataLabel.textColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
            _noDataLabel.font = [UIFont boldSystemFontOfSize:20];
            [_collectionView addSubview:_noDataLabel];
        }
        [self.view addSubview:_collectionView];
        [_collectionView registerClass:[FXYAssetCell class] forCellWithReuseIdentifier:@"FXYAssetCell"];
    }
}

/**
 设置底部工具条
 */
- (void)configBottomToolBar {
    FXYImagePickerController *tzImagePickerVc = (FXYImagePickerController *)self.navigationController;
    if (!tzImagePickerVc.showSelectBtn) return;
    
    
#warning 底部条的效果待定，切换拍照等+选中的图片
    
//    _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_previewButton addTarget:self action:@selector(previewButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    _previewButton.titleLabel.font = [UIFont systemFontOfSize:16];
//    [_previewButton setTitle:tzImagePickerVc.previewBtnTitleStr forState:UIControlStateNormal];
//    [_previewButton setTitle:tzImagePickerVc.previewBtnTitleStr forState:UIControlStateDisabled];
//    [_previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [_previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
//    _previewButton.enabled = tzImagePickerVc.selectedModels.count;
//
//    if (tzImagePickerVc.allowPickingOriginalPhoto) {
//        _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, [FXYCommonTools fxy_isRightToLeftLayout] ? 10 : -10, 0, 0);
//        [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
//        _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:16];
//        [_originalPhotoButton setTitle:tzImagePickerVc.fullImageBtnTitleStr forState:UIControlStateNormal];
//        [_originalPhotoButton setTitle:tzImagePickerVc.fullImageBtnTitleStr forState:UIControlStateSelected];
//        [_originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//        [_originalPhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
//        [_originalPhotoButton setImage:tzImagePickerVc.photoOriginDefImage forState:UIControlStateNormal];
//        [_originalPhotoButton setImage:tzImagePickerVc.photoOriginSelImage forState:UIControlStateSelected];
//        _originalPhotoButton.imageView.clipsToBounds = YES;
//        _originalPhotoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
//        _originalPhotoButton.selected = _isSelectOriginalPhoto;
//        _originalPhotoButton.enabled = tzImagePickerVc.selectedModels.count > 0;
//
//        _originalPhotoLabel = [[UILabel alloc] init];
//        _originalPhotoLabel.textAlignment = NSTextAlignmentLeft;
//        _originalPhotoLabel.font = [UIFont systemFontOfSize:16];
//        _originalPhotoLabel.textColor = [UIColor blackColor];
//        if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
//    }
//
//    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
//    [_doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    [_doneButton setTitle:tzImagePickerVc.doneBtnTitleStr forState:UIControlStateNormal];
//    [_doneButton setTitle:tzImagePickerVc.doneBtnTitleStr forState:UIControlStateDisabled];
//    [_doneButton setTitleColor:tzImagePickerVc.oKButtonTitleColorNormal forState:UIControlStateNormal];
//    [_doneButton setTitleColor:tzImagePickerVc.oKButtonTitleColorDisabled forState:UIControlStateDisabled];
//    _doneButton.enabled = tzImagePickerVc.selectedModels.count || tzImagePickerVc.alwaysEnableDoneBtn;
//
//    _numberImageView = [[UIImageView alloc] initWithImage:tzImagePickerVc.photoNumberIconImage];
//    _numberImageView.hidden = tzImagePickerVc.selectedModels.count <= 0;
//    _numberImageView.clipsToBounds = YES;
//    _numberImageView.contentMode = UIViewContentModeScaleAspectFit;
//    _numberImageView.backgroundColor = [UIColor clearColor];
//
//    _numberLabel = [[UILabel alloc] init];
//    _numberLabel.font = [UIFont systemFontOfSize:15];
//    _numberLabel.textColor = [UIColor whiteColor];
//    _numberLabel.textAlignment = NSTextAlignmentCenter;
//    _numberLabel.text = [NSString stringWithFormat:@"%zd",tzImagePickerVc.selectedModels.count];
//    _numberLabel.hidden = tzImagePickerVc.selectedModels.count <= 0;
//    _numberLabel.backgroundColor = [UIColor clearColor];
//
//    _divideLine = [[UIView alloc] init];
//    CGFloat rgb2 = 222 / 255.0;
//    _divideLine.backgroundColor = [UIColor colorWithRed:rgb2 green:rgb2 blue:rgb2 alpha:1.0];
//
//    [_bottomToolBar addSubview:_divideLine];
//    [_bottomToolBar addSubview:_previewButton];
//    [_bottomToolBar addSubview:_doneButton];
//    [_bottomToolBar addSubview:_numberImageView];
//    [_bottomToolBar addSubview:_numberLabel];
//    [_bottomToolBar addSubview:_originalPhotoButton];
//    [self.view addSubview:self.bottomToolBar];
//    [_originalPhotoButton addSubview:_originalPhotoLabel];
}

/**
 设置选中图片的大小
 */
- (void)getSelectedPhotoBytes {
    // 越南语 && 5屏幕时会显示不下，暂时这样处理
    if ([[FXYImagePickerConfig sharedInstance].preferredLanguage isEqualToString:@"vi"] && self.view.fxy_width <= 320) {
        return;
    }
    FXYImagePickerController *imagePickerVc = (FXYImagePickerController *)self.navigationController;
    [[FXYImageManager manager] getPhotosBytesWithArray:imagePickerVc.selectedModels completion:^(NSString *totalBytes) {
        self->_originalPhotoLabel.text = [NSString stringWithFormat:@"(%@)",totalBytes];
    }];
}

- (void)didGetAllPhotos:(NSArray *)photos assets:(NSArray *)assets infoArr:(NSArray *)infoArr {
    FXYImagePickerController *tzImagePickerVc = (FXYImagePickerController *)self.navigationController;
    [tzImagePickerVc hideProgressHUD];
    
    if (tzImagePickerVc.autoDismiss) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethodWithPhotos:photos assets:assets infoArr:infoArr];
        }];
    } else {
        [self callDelegateMethodWithPhotos:photos assets:assets infoArr:infoArr];
    }
}

- (void)callDelegateMethodWithPhotos:(NSArray *)photos assets:(NSArray *)assets infoArr:(NSArray *)infoArr {
    FXYImagePickerController *tzImagePickerVc = (FXYImagePickerController *)self.navigationController;
    //只选择了一个视频
    if (tzImagePickerVc.allowPickingVideo && tzImagePickerVc.maxImagesCount == 1) {
        if ([[FXYImageManager manager] isVideo:[assets firstObject]]) {
            if ([tzImagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingVideo:sourceAssets:)]) {
                [tzImagePickerVc.pickerDelegate imagePickerController:tzImagePickerVc didFinishPickingVideo:[photos firstObject] sourceAssets:[assets firstObject]];
            }
            if (tzImagePickerVc.didFinishPickingVideoHandle) {
                tzImagePickerVc.didFinishPickingVideoHandle([photos firstObject], [assets firstObject]);
            }
            return;
        }
    }
    
    if ([tzImagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:)]) {
        [tzImagePickerVc.pickerDelegate imagePickerController:tzImagePickerVc didFinishPickingPhotos:photos sourceAssets:assets isSelectOriginalPhoto:_isSelectOriginalPhoto];
    }
    if ([tzImagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:infos:)]) {
        [tzImagePickerVc.pickerDelegate imagePickerController:tzImagePickerVc didFinishPickingPhotos:photos sourceAssets:assets isSelectOriginalPhoto:_isSelectOriginalPhoto infos:infoArr];
    }
    if (tzImagePickerVc.didFinishPickingPhotosHandle) {
        tzImagePickerVc.didFinishPickingPhotosHandle(photos,assets,_isSelectOriginalPhoto);
    }
    if (tzImagePickerVc.didFinishPickingPhotosWithInfosHandle) {
        tzImagePickerVc.didFinishPickingPhotosWithInfosHandle(photos,assets,_isSelectOriginalPhoto,infoArr);
    }
}

/**
 刷新底部栏
 */
- (void)refreshBottomToolBarStatus {
#warning 功能不一样
//    FXYImagePickerController *tzImagePickerVc = (FXYImagePickerController *)self.navigationController;
//
//    _previewButton.enabled = tzImagePickerVc.selectedModels.count > 0;
//    _doneButton.enabled = tzImagePickerVc.selectedModels.count > 0 || tzImagePickerVc.alwaysEnableDoneBtn;
//
//    _numberImageView.hidden = tzImagePickerVc.selectedModels.count <= 0;
//    _numberLabel.hidden = tzImagePickerVc.selectedModels.count <= 0;
//    _numberLabel.text = [NSString stringWithFormat:@"%zd",tzImagePickerVc.selectedModels.count];
//
//    _originalPhotoButton.enabled = tzImagePickerVc.selectedModels.count > 0;
//    _originalPhotoButton.selected = (_isSelectOriginalPhoto && _originalPhotoButton.enabled);
//    _originalPhotoLabel.hidden = (!_originalPhotoButton.isSelected);
//    if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
}

/**
 跳转照片预览控制器

 @param photoPreviewVc 照片预览控制器
 */
- (void)pushPhotoPrevireViewController:(FXYPhotoPreviewController *)photoPreviewVc {
    [self pushPhotoPrevireViewController:photoPreviewVc needCheckSelectedModels:NO];
}

/**
 跳转照片预览控制器

 @param photoPreviewVc 照片预览控制器
 @param needCheckSelectedModels 是否需要设置选中
 */
- (void)pushPhotoPrevireViewController:(FXYPhotoPreviewController *)photoPreviewVc needCheckSelectedModels:(BOOL)needCheckSelectedModels {
    __weak typeof(self) weakSelf = self;
    photoPreviewVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    [photoPreviewVc setBackButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        if (needCheckSelectedModels) {
            [strongSelf checkSelectedModels];
        }
        [strongSelf.collectionView reloadData];
        [strongSelf refreshBottomToolBarStatus];
    }];
    [photoPreviewVc setDoneButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [strongSelf doneButtonClick];
    }];
    [photoPreviewVc setDoneButtonClickBlockCropMode:^(UIImage *cropedImage, id asset) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf didGetAllPhotos:@[cropedImage] assets:@[asset] infoArr:nil];
    }];
    [self.navigationController pushViewController:photoPreviewVc animated:YES];
}

/**
 列表滚动到底部
 */
- (void)scrollCollectionViewToBottom {
    FXYImagePickerController *tzImagePickerVc = (FXYImagePickerController *)self.navigationController;
    if (_shouldScrollToBottom && _models.count > 0) {
        NSInteger item = 0;
        if (tzImagePickerVc.sortAscendingByModificationDate) {
            item = _models.count - 1;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            self->_shouldScrollToBottom = NO;
            self->_collectionView.hidden = NO;
        });
    } else {
        _collectionView.hidden = NO;
    }
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FXYImagePickerController *tzImagePickerVc = (FXYImagePickerController *)self.navigationController;
    // the cell dipaly photo or video / 展示照片或视频的cell
    FXYAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FXYAssetCell" forIndexPath:indexPath];
    cell.allowPickingMultipleVideo = tzImagePickerVc.allowPickingMultipleVideo;
    cell.photoDefImage = tzImagePickerVc.photoDefImage;
    cell.photoSelImage = tzImagePickerVc.photoSelImage;
    FXYAssetModel *model = _models[indexPath.item];
    cell.allowPickingGif = tzImagePickerVc.allowPickingGif;
    cell.model = model;
    if (model.isSelected && tzImagePickerVc.showSelectedIndex) {
        cell.index = [tzImagePickerVc.selectedAssetIds indexOfObject:model.asset.localIdentifier] + 1;
    }
    cell.showSelectBtn = tzImagePickerVc.showSelectBtn;
    cell.allowPreview = tzImagePickerVc.allowPreview;
    
    if (tzImagePickerVc.selectedModels.count >= tzImagePickerVc.maxImagesCount && tzImagePickerVc.showPhotoCannotSelectLayer && !model.isSelected) {
        cell.cannotSelectLayerButton.backgroundColor = tzImagePickerVc.cannotSelectLayerColor;
        cell.cannotSelectLayerButton.hidden = NO;
    } else {
        cell.cannotSelectLayerButton.hidden = YES;
    }
    
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    __weak typeof(_numberImageView.layer) weakLayer = _numberImageView.layer;
    cell.didSelectPhotoBlock = ^(BOOL isSelected) {
        __strong typeof(weakCell) strongCell = weakCell;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        __strong typeof(weakLayer) strongLayer = weakLayer;
        FXYImagePickerController *tzImagePickerVc = (FXYImagePickerController *)strongSelf.navigationController;
        // 1. cancel select / 取消选择
        if (isSelected) {
            strongCell.selectPhotoButton.selected = NO;
            model.isSelected = NO;
            NSArray *selectedModels = [NSArray arrayWithArray:tzImagePickerVc.selectedModels];
            for (FXYAssetModel *model_item in selectedModels) {
                if ([model.asset.localIdentifier isEqualToString:model_item.asset.localIdentifier]) {
                    [tzImagePickerVc removeSelectedModel:model_item];
                    break;
                }
            }
            [strongSelf refreshBottomToolBarStatus];
            if (tzImagePickerVc.showSelectedIndex || tzImagePickerVc.showPhotoCannotSelectLayer) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FXY_PHOTO_PICKER_RELOAD_NOTIFICATION" object:strongSelf.navigationController];
            }
            [UIView showOscillatoryAnimationWithLayer:strongLayer type:FXYOscillatoryAnimationToSmaller];
        } else {
            // 2. select:check if over the maxImagesCount / 选择照片,检查是否超过了最大个数的限制
            if (tzImagePickerVc.selectedModels.count < tzImagePickerVc.maxImagesCount) {
                if (tzImagePickerVc.maxImagesCount == 1 && !tzImagePickerVc.allowPreview) {
                    model.isSelected = YES;
                    [tzImagePickerVc addSelectedModel:model];
                    [strongSelf doneButtonClick];
                    return;
                }
                strongCell.selectPhotoButton.selected = YES;
                model.isSelected = YES;
                [tzImagePickerVc addSelectedModel:model];
                if (tzImagePickerVc.showSelectedIndex || tzImagePickerVc.showPhotoCannotSelectLayer) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"FXY_PHOTO_PICKER_RELOAD_NOTIFICATION" object:strongSelf.navigationController];
                }
                [strongSelf refreshBottomToolBarStatus];
                [UIView showOscillatoryAnimationWithLayer:strongLayer type:FXYOscillatoryAnimationToSmaller];
            } else {
                NSString *title = [NSString stringWithFormat:[NSBundle fxy_localizedStringForKey:@"Select a maximum of %zd photos"], tzImagePickerVc.maxImagesCount];
                [tzImagePickerVc showAlertWithTitle:title];
            }
        }
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // take a photo / 去拍照
    FXYImagePickerController *tzImagePickerVc = (FXYImagePickerController *)self.navigationController;
//    if (((tzImagePickerVc.sortAscendingByModificationDate && indexPath.item >= _models.count) || (!tzImagePickerVc.sortAscendingByModificationDate && indexPath.item == 0)) && _showTakePhotoBtn)  {
//        [self takePhoto]; return;
//    }
    // preview phote or video / 预览照片或视频
    NSInteger index = indexPath.item;
    FXYAssetModel *model = _models[index];
    if (model.type == FXYAssetModelMediaTypeVideo && !tzImagePickerVc.allowPickingMultipleVideo) {
        if (tzImagePickerVc.selectedModels.count > 0) {
            FXYImagePickerController *imagePickerVc = (FXYImagePickerController *)self.navigationController;
            [imagePickerVc showAlertWithTitle:[NSBundle fxy_localizedStringForKey:@"Can not choose both video and photo"]];
        } else {
            FXYVideoPlayerController *videoPlayerVc = [[FXYVideoPlayerController alloc] init];
            videoPlayerVc.model = model;
            [self.navigationController pushViewController:videoPlayerVc animated:YES];
        }
    } else if (model.type == FXYAssetModelMediaTypePhotoGif && tzImagePickerVc.allowPickingGif && !tzImagePickerVc.allowPickingMultipleVideo) {
        if (tzImagePickerVc.selectedModels.count > 0) {
            FXYImagePickerController *imagePickerVc = (FXYImagePickerController *)self.navigationController;
            [imagePickerVc showAlertWithTitle:[NSBundle fxy_localizedStringForKey:@"Can not choose both photo and GIF"]];
        } else {
            FXYGifPhotoPreviewController *gifPreviewVc = [[FXYGifPhotoPreviewController alloc] init];
            gifPreviewVc.model = model;
            [self.navigationController pushViewController:gifPreviewVc animated:YES];
        }
    } else {
        FXYPhotoPreviewController *photoPreviewVc = [[FXYPhotoPreviewController alloc] init];
        photoPreviewVc.currentIndex = index;
        photoPreviewVc.models = _models;
        [self pushPhotoPrevireViewController:photoPreviewVc];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // [self updateCachedAssets];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - getter and setter

- (void)setModel:(FXYAlbumModel *)model {
    _model = model;
    self.titleButton.selected = NO;
    [self.titleButton setTitle:model.name forState:UIControlStateNormal];
    _shouldScrollToBottom = YES;
    [self fetchAssetModels];
#warning 设置数据
}

- (UIButton *)titleButton {
    if (!_titleButton) {
        FXYImagePickerController *tzImagePickerVc = (FXYImagePickerController *)self.navigationController;
        _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_titleButton setTitleColor:tzImagePickerVc.naviTitleColor forState:UIControlStateNormal];
        _titleButton.titleLabel.font = tzImagePickerVc.naviTitleFont;
        _titleButton.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 2 / 3, 35);
        [_titleButton setBackgroundColor:[UIColor redColor]];
        [_titleButton addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _titleButton;
}

- (UIView *)bottomToolBar {
    if (!_bottomToolBar) {
        _bottomToolBar = [[UIView alloc]init];
        CGFloat rgb = 253 / 255.0;
        _bottomToolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
    }
    return _bottomToolBar;
}

- (UIView *)customNavigationBar {
    if (!_customNavigationBar) {
        _customNavigationBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [FXYCommonTools fxy_statusBarHeight] + 44)];
        _customNavigationBar.backgroundColor = [UIColor blueColor];
    }
    return _customNavigationBar;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage fxy_imageNamedFromMyBundle:@"priceReduce_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self.navigationController action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.frame = CGRectMake(20, 15, 30, 30);
    }
    return _closeButton;
}

//- (UIImagePickerController *)imagePickerVc {
//    if (_imagePickerVc == nil) {
//        _imagePickerVc = [[UIImagePickerController alloc] init];
//        _imagePickerVc.delegate = self;
//        // set appearance / 改变相册选择页的导航栏外观
//        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
//        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
//        UIBarButtonItem *tzBarItem, *BarItem;
//        if (@available(iOS 9, *)) {
//            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[FXYImagePickerController class]]];
//            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
//        } else {
//            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[FXYImagePickerController class], nil];
//            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
//        }
//        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
//        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
//    }
//    return _imagePickerVc;
//}






















#pragma mark - Private Method

///// 拍照按钮点击事件
//- (void)takePhoto {
//    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//    if ((authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)) {
//
//        NSDictionary *infoDict = [TZCommonTools fxy_getInfoDictionary];
//        // 无权限 做一个友好的提示
//        NSString *appName = [infoDict valueForKey:@"CFBundleDisplayName"];
//        if (!appName) appName = [infoDict valueForKey:@"CFBundleName"];
//
//        NSString *message = [NSString stringWithFormat:[NSBundle fxy_localizedStringForKey:@"Please allow %@ to access your camera in \"Settings -> Privacy -> Camera\""],appName];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSBundle fxy_localizedStringForKey:@"Can not use camera"] message:message delegate:self cancelButtonTitle:[NSBundle fxy_localizedStringForKey:@"Cancel"] otherButtonTitles:[NSBundle fxy_localizedStringForKey:@"Setting"], nil];
//        [alert show];
//    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
//        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
//        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//            if (granted) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self pushImagePickerController];
//                });
//            }
//        }];
//    } else {
//        [self pushImagePickerController];
//    }
//}

//// 调用相机
//- (void)pushImagePickerController {
//    // 提前定位
//    TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
//    if (tzImagePickerVc.allowCameraLocation) {
//        __weak typeof(self) weakSelf = self;
//        [[TZLocationManager manager] startLocationWithSuccessBlock:^(NSArray<CLLocation *> *locations) {
//            __strong typeof(weakSelf) strongSelf = weakSelf;
//            strongSelf.location = [locations firstObject];
//        } failureBlock:^(NSError *error) {
//            __strong typeof(weakSelf) strongSelf = weakSelf;
//            strongSelf.location = nil;
//        }];
//    }
//
//    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
//    if ([UIImagePickerController isSourceTypeAvailable: sourceType]) {
//        self.imagePickerVc.sourceType = sourceType;
//        NSMutableArray *mediaTypes = [NSMutableArray array];
//        if (tzImagePickerVc.allowTakePicture) {
//            [mediaTypes addObject:(NSString *)kUTTypeImage];
//        }
//        if (tzImagePickerVc.allowTakeVideo) {
//            [mediaTypes addObject:(NSString *)kUTTypeMovie];
//            self.imagePickerVc.videoMaximumDuration = tzImagePickerVc.videoMaximumDuration;
//        }
//        self.imagePickerVc.mediaTypes= mediaTypes;
//        if (tzImagePickerVc.uiImagePickerControllerSettingBlock) {
//            tzImagePickerVc.uiImagePickerControllerSettingBlock(_imagePickerVc);
//        }
//        [self presentViewController:_imagePickerVc animated:YES completion:nil];
//    } else {
//        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
//    }
//}






#pragma mark - UIImagePickerControllerDelegate

//- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    [picker dismissViewControllerAnimated:YES completion:nil];
//    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
//    if ([type isEqualToString:@"public.image"]) {
//        TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
//        [imagePickerVc showProgressHUD];
//        UIImage *photo = [info objectForKey:UIImagePickerControllerOriginalImage];
//        if (photo) {
//            [[TZImageManager manager] savePhotoWithImage:photo location:self.location completion:^(PHAsset *asset, NSError *error){
//                if (!error) {
//                    [self addPHAsset:asset];
//                }
//            }];
//            self.location = nil;
//        }
//    } else if ([type isEqualToString:@"public.movie"]) {
//        TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
//        [imagePickerVc showProgressHUD];
//        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
//        if (videoUrl) {
//            [[TZImageManager manager] saveVideoWithUrl:videoUrl location:self.location completion:^(PHAsset *asset, NSError *error) {
//                if (!error) {
//                    [self addPHAsset:asset];
//                }
//            }];
//            self.location = nil;
//        }
//    }
//}
//
//- (void)addPHAsset:(PHAsset *)asset {
//    TZAssetModel *assetModel = [[TZImageManager manager] createModelWithAsset:asset];
//    TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
//    [tzImagePickerVc hideProgressHUD];
//    if (tzImagePickerVc.sortAscendingByModificationDate) {
//        [_models addObject:assetModel];
//    } else {
//        [_models insertObject:assetModel atIndex:0];
//    }
//
//    if (tzImagePickerVc.maxImagesCount <= 1) {
//        if (tzImagePickerVc.allowCrop && asset.mediaType == PHAssetMediaTypeImage) {
//            TZPhotoPreviewController *photoPreviewVc = [[TZPhotoPreviewController alloc] init];
//            if (tzImagePickerVc.sortAscendingByModificationDate) {
//                photoPreviewVc.currentIndex = _models.count - 1;
//            } else {
//                photoPreviewVc.currentIndex = 0;
//            }
//            photoPreviewVc.models = _models;
//            [self pushPhotoPrevireViewController:photoPreviewVc];
//        } else {
//            [tzImagePickerVc addSelectedModel:assetModel];
//            [self doneButtonClick];
//        }
//        return;
//    }
//
//    if (tzImagePickerVc.selectedModels.count < tzImagePickerVc.maxImagesCount) {
//        if (assetModel.type == TZAssetModelMediaTypeVideo && !tzImagePickerVc.allowPickingMultipleVideo) {
//            // 不能多选视频的情况下，不选中拍摄的视频
//        } else {
//            assetModel.isSelected = YES;
//            [tzImagePickerVc addSelectedModel:assetModel];
//            [self refreshBottomToolBarStatus];
//        }
//    }
//    _collectionView.hidden = YES;
//    [_collectionView reloadData];
//
//    _shouldScrollToBottom = YES;
//    [self scrollCollectionViewToBottom];
//}
//
//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//    [picker dismissViewControllerAnimated:YES completion:nil];
//}



#pragma mark - Asset Caching

//- (void)resetCachedAssets {
//    [[FXYImageManager manager].cachingImageManager stopCachingImagesForAllAssets];
//    self.previousPreheatRect = CGRectZero;
//}
//
//- (void)updateCachedAssets {
//    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
//    if (!isViewVisible) { return; }
//    
//    // The preheat window is twice the height of the visible rect.
//    CGRect preheatRect = _collectionView.bounds;
//    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
//    
//    /*
//     Check if the collection view is showing an area that is significantly
//     different to the last preheated area.
//     */
//    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
//    if (delta > CGRectGetHeight(_collectionView.bounds) / 3.0f) {
//        
//        // Compute the assets to start caching and to stop caching.
//        NSMutableArray *addedIndexPaths = [NSMutableArray array];
//        NSMutableArray *removedIndexPaths = [NSMutableArray array];
//        
//        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
//            NSArray *indexPaths = [self aapl_indexPathsForElementsInRect:removedRect];
//            [removedIndexPaths addObjectsFromArray:indexPaths];
//        } addedHandler:^(CGRect addedRect) {
//            NSArray *indexPaths = [self aapl_indexPathsForElementsInRect:addedRect];
//            [addedIndexPaths addObjectsFromArray:indexPaths];
//        }];
//        
//        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
//        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
//        
//        // Update the assets the PHCachingImageManager is caching.
//        [[FXYImageManager manager].cachingImageManager startCachingImagesForAssets:assetsToStartCaching
//                                                                       targetSize:AssetGridThumbnailSize
//                                                                      contentMode:PHImageContentModeAspectFill
//                                                                          options:nil];
//        [[FXYImageManager manager].cachingImageManager stopCachingImagesForAssets:assetsToStopCaching
//                                                                      targetSize:AssetGridThumbnailSize
//                                                                     contentMode:PHImageContentModeAspectFill
//                                                                         options:nil];
//        
//        // Store the preheat rect to compare against in the future.
//        self.previousPreheatRect = preheatRect;
//    }
//}
//
//- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
//    if (CGRectIntersectsRect(newRect, oldRect)) {
//        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
//        CGFloat oldMinY = CGRectGetMinY(oldRect);
//        CGFloat newMaxY = CGRectGetMaxY(newRect);
//        CGFloat newMinY = CGRectGetMinY(newRect);
//        
//        if (newMaxY > oldMaxY) {
//            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
//            addedHandler(rectToAdd);
//        }
//        
//        if (oldMinY > newMinY) {
//            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
//            addedHandler(rectToAdd);
//        }
//        
//        if (newMaxY < oldMaxY) {
//            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
//            removedHandler(rectToRemove);
//        }
//        
//        if (oldMinY < newMinY) {
//            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
//            removedHandler(rectToRemove);
//        }
//    } else {
//        addedHandler(newRect);
//        removedHandler(oldRect);
//    }
//}
//
//- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
//    if (indexPaths.count == 0) { return nil; }
//    
//    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
//    for (NSIndexPath *indexPath in indexPaths) {
//        if (indexPath.item < _models.count) {
//            FXYAssetModel *model = _models[indexPath.item];
//            [assets addObject:model.asset];
//        }
//    }
//    
//    return assets;
//}
//
//- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
//    NSArray *allLayoutAttributes = [_collectionView.collectionViewLayout layoutAttributesForElementsInRect:rect];
//    if (allLayoutAttributes.count == 0) { return nil; }
//    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
//    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
//        NSIndexPath *indexPath = layoutAttributes.indexPath;
//        [indexPaths addObject:indexPath];
//    }
//    return indexPaths;
//}
#pragma clang diagnostic pop

@end

@implementation FXYCollectionView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:[UIControl class]]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}

@end
