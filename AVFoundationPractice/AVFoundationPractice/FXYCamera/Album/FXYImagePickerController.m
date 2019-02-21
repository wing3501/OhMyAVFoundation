//
//  FXYImagePickerController.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/19.
//  Copyright © 2019 styf. All rights reserved.
//

#import "FXYImagePickerController.h"
#import "FXYAlbumPickerView.h"
#import "FXYCommonTools.h"
#import "FXYImagePickerConfig.h"
#import "UIView+FXYLayout.h"
#import "FXYPhotoPickerController.h"
#import "NSBundle+FXYImagePicker.h"
#import "FXYImageManager.h"
#import "UIImage+FXYBundle.h"
#import "FXYPushAnimator.h"
@interface FXYImagePickerController ()<UINavigationControllerDelegate>{
    NSTimer *_timer;
    UILabel *_tipLabel;
    UIButton *_settingBtn;
    
    UIButton *_progressHUD;
    UIView *_HUDContainer;
    UIActivityIndicatorView *_HUDIndicatorView;
    UILabel *_HUDLabel;
    
    UIStatusBarStyle _originStatusBarStyle;
}

/// Default is 4, Use in photos collectionView in TZPhotoPickerController
/// 默认4列, TZPhotoPickerController中的照片collectionView
@property (nonatomic, assign) NSInteger columnNumber;
/// 相册视图
@property (nonatomic, strong) FXYAlbumPickerView *albumPickerView;
/// 照片选择控制器
@property (nonatomic, weak) FXYPhotoPickerController *photoPickerVc;
/// 底部工具条
@property (nonatomic, strong) UIView *bottomToolBar;
/// 相册按钮
@property (nonatomic, strong) UIButton *albumButton;
/// 拍照按钮
@property (nonatomic, strong) UIButton *takePhotoButton;
/// 转场动画
@property (nonatomic, strong) FXYPushAnimator *pushAnimator;
@end

@implementation FXYImagePickerController

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self = [self initWithMaxImagesCount:9 delegate:nil];
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)viewDidLoad {
    [super viewDidLoad];
    self.needShowStatusBar = ![UIApplication sharedApplication].statusBarHidden;
    self.view.backgroundColor = [UIColor whiteColor];
//    self.navigationBar.barStyle = UIBarStyleBlack;
//    self.navigationBar.translucent = YES;
    [self setNavigationBarHidden:YES];
    self.delegate = self;
    [FXYImageManager manager].shouldFixOrientation = NO;
    
    // Default appearance, you can reset these after this method
    // 默认的外观，你可以在这个方法后重置
    self.oKButtonTitleColorNormal   = [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0];
    self.oKButtonTitleColorDisabled = [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:0.5];
//    self.navigationBar.barTintColor = [UIColor whiteColor];
//    self.navigationBar.tintColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (self.needShowStatusBar) [UIApplication sharedApplication].statusBarHidden = NO;
    
    [self.view addSubview:self.bottomToolBar];
    [self.bottomToolBar addSubview:self.albumButton];
    [self.bottomToolBar addSubview:self.takePhotoButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = self.statusBarStyle;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = _originStatusBarStyle;
    [self hideProgressHUD];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<FXYImagePickerControllerDelegate>)delegate {
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:4 delegate:delegate];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<FXYImagePickerControllerDelegate>)delegate {
    
    FXYPhotoPickerController *photoPickerVc = [[FXYPhotoPickerController alloc] init];
    photoPickerVc.isFirstAppear = YES;
    photoPickerVc.columnNumber = columnNumber;
    __weak typeof(self) weakSelf = self;
    photoPickerVc.titleClickBlock = ^(BOOL buttonSelected) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf showAlbumPickerView:buttonSelected];
    };
    self = [super initWithRootViewController:photoPickerVc];
    if (self) {
        _photoPickerVc = photoPickerVc;
        
        FXYAlbumPickerView *albumPickerView = [[FXYAlbumPickerView alloc]initWithImagePickerController:self];
        albumPickerView.isFirstAppear = YES;
        albumPickerView.columnNumber = columnNumber;
        _albumPickerView = albumPickerView;
        
        self.maxImagesCount = maxImagesCount > 0 ? maxImagesCount : 9; // Default is 9 / 默认最大可选9张图片
        self.pickerDelegate = delegate;
        self.selectedAssets = [NSMutableArray array];
        
        // Allow user picking original photo and video, you also can set No after this method
        // 默认准许用户选择原图和视频, 你也可以在这个方法后置为NO
        self.allowPickingOriginalPhoto = YES;
        self.allowPickingVideo = YES;
        self.allowPickingImage = YES;
        self.allowTakePicture = YES;
        self.allowTakeVideo = YES;
        self.videoMaximumDuration = 10 * 60;
        self.sortAscendingByModificationDate = YES;
        self.autoDismiss = YES;
        self.columnNumber = columnNumber;
        //默认设置
        [self configDefaultSetting];
        
        if (![[FXYImageManager manager] authorizationStatusAuthorized]) {
            _tipLabel = [[UILabel alloc] init];
            _tipLabel.frame = CGRectMake(8, 120, self.view.fxy_width - 16, 60);
            _tipLabel.textAlignment = NSTextAlignmentCenter;
            _tipLabel.numberOfLines = 0;
            _tipLabel.font = [UIFont systemFontOfSize:16];
            _tipLabel.textColor = [UIColor blackColor];
            
            NSDictionary *infoDict = [FXYCommonTools fxy_getInfoDictionary];
            NSString *appName = [infoDict valueForKey:@"CFBundleDisplayName"];
            if (!appName) appName = [infoDict valueForKey:@"CFBundleName"];
            NSString *tipText = [NSString stringWithFormat:[NSBundle fxy_localizedStringForKey:@"Allow %@ to access your album in \"Settings -> Privacy -> Photos\""],appName];
            _tipLabel.text = tipText;
            [self.view addSubview:_tipLabel];
            
            _settingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            [_settingBtn setTitle:self.settingBtnTitleStr forState:UIControlStateNormal];
            _settingBtn.frame = CGRectMake(0, 180, self.view.fxy_width, 44);
            _settingBtn.titleLabel.font = [UIFont systemFontOfSize:18];
            [_settingBtn addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_settingBtn];
            
            if ([PHPhotoLibrary authorizationStatus] == 0) {
                _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:NO];
            }
        } else {
            [[FXYImageManager manager] getCameraRollAlbum:self.allowPickingVideo allowPickingImage:self.allowPickingImage needFetchAssets:NO completion:^(FXYAlbumModel *model) {
                photoPickerVc.model = model;
            }];
        }
    }
    return self;
}

#pragma mark - overwrite

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusBarStyle;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (![UIApplication sharedApplication].statusBarHidden) {
            if (self.needShowStatusBar) [UIApplication sharedApplication].statusBarHidden = NO;
        }
    });
    if (size.width > size.height) {
        _cropRect = _cropRectLandscape;
    } else {
        _cropRect = _cropRectPortrait;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat progressHUDY = CGRectGetMaxY(self.navigationBar.frame);
    _progressHUD.frame = CGRectMake(0, progressHUDY, self.view.fxy_width, self.view.fxy_height - progressHUDY);
    _HUDContainer.frame = CGRectMake((self.view.fxy_width - 120) / 2, (_progressHUD.fxy_height - 90 - progressHUDY) / 2, 120, 90);
    _HUDIndicatorView.frame = CGRectMake(45, 15, 30, 30);
    _HUDLabel.frame = CGRectMake(0,40, 120, 50);
}
#pragma mark - request

#pragma mark - public

- (UIAlertController *)showAlertWithTitle:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle fxy_localizedStringForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    return alertController;
}

- (void)hideAlertView:(UIAlertController *)alertView {
    [alertView dismissViewControllerAnimated:YES completion:nil];
    alertView = nil;
}

- (void)showProgressHUD {
    if (!_progressHUD) {
        _progressHUD = [UIButton buttonWithType:UIButtonTypeCustom];
        [_progressHUD setBackgroundColor:[UIColor clearColor]];
        
        _HUDContainer = [[UIView alloc] init];
        _HUDContainer.layer.cornerRadius = 8;
        _HUDContainer.clipsToBounds = YES;
        _HUDContainer.backgroundColor = [UIColor darkGrayColor];
        _HUDContainer.alpha = 0.7;
        
        _HUDIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        _HUDLabel = [[UILabel alloc] init];
        _HUDLabel.textAlignment = NSTextAlignmentCenter;
        _HUDLabel.text = self.processHintStr;
        _HUDLabel.font = [UIFont systemFontOfSize:15];
        _HUDLabel.textColor = [UIColor whiteColor];
        
        [_HUDContainer addSubview:_HUDLabel];
        [_HUDContainer addSubview:_HUDIndicatorView];
        [_progressHUD addSubview:_HUDContainer];
    }
    [_HUDIndicatorView startAnimating];
    UIWindow *applicationWindow;
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(window)]) {
        applicationWindow = [[[UIApplication sharedApplication] delegate] window];
    } else {
        applicationWindow = [[UIApplication sharedApplication] keyWindow];
    }
    [applicationWindow addSubview:_progressHUD];
    [self.view setNeedsLayout];
    
    // if over time, dismiss HUD automatic
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf hideProgressHUD];
    });
}

/**
 隐藏进度提示
 */
- (void)hideProgressHUD {
    if (_progressHUD) {
        [_HUDIndicatorView stopAnimating];
        [_progressHUD removeFromSuperview];
    }
}

#pragma mark - notification

#pragma mark - event response

/**
 监听权限改变
 */
- (void)observeAuthrizationStatusChange {
    [_timer invalidate];
    _timer = nil;
    if ([PHPhotoLibrary authorizationStatus] == 0) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:NO];
    }
    
    if ([[FXYImageManager manager] authorizationStatusAuthorized]) {
        [_tipLabel removeFromSuperview];
        [_settingBtn removeFromSuperview];
        //刷新照片列表
        [[FXYImageManager manager] getCameraRollAlbum:self.allowPickingVideo allowPickingImage:self.allowPickingImage needFetchAssets:NO completion:^(FXYAlbumModel *model) {
            self.photoPickerVc.model = model;
        }];
        //刷新相册列表
        [self.albumPickerView configTableView];
    }
}

/**
 关闭按钮点击
 */
- (void)cancelButtonClick {
    if (self.autoDismiss) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethod];
        }];
    } else {
        [self callDelegateMethod];
    }
}

/**
 设置按钮点击
 */
- (void)settingBtnClick {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

/**
 相册按钮点击
 */
- (void)albumButtonClick {
    
}

/**
 拍照按钮点击
 */
- (void)takePhotoButtonClick {
    
}
#pragma mark - private

/**
 设置导航栏标题颜色、字体
 */
- (void)configNaviTitleAppearance {
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    if (self.naviTitleColor) {
        textAttrs[NSForegroundColorAttributeName] = self.naviTitleColor;
    }
    if (self.naviTitleFont) {
        textAttrs[NSFontAttributeName] = self.naviTitleFont;
    }
    self.navigationBar.titleTextAttributes = textAttrs;
}

/**
 默认设置
 */
- (void)configDefaultSetting {
    self.timeout = 15;
    self.photoWidth = 828.0;
    self.photoPreviewMaxWidth = 600;
    self.naviTitleColor = [UIColor blackColor];
    self.naviTitleFont = [UIFont systemFontOfSize:17];
    self.allowPreview = YES;
    // 2.2.26版本，不主动缩放图片，降低内存占用
    self.notScaleImage = YES;
    self.needFixComposition = NO;
    self.statusBarStyle = UIStatusBarStyleLightContent;
    self.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    self.allowCameraLocation = YES;
    
    self.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
    [self configDefaultBtnTitle];
    
    CGFloat cropViewWH = MIN(self.view.fxy_width, self.view.fxy_height) / 3 * 2;
    self.cropRect = CGRectMake((self.view.fxy_width - cropViewWH) / 2, (self.view.fxy_height - cropViewWH) / 2, cropViewWH, cropViewWH);
}

/**
 初始化默认按钮图片
 */
- (void)configDefaultImageName {
    self.takePictureImageName = @"takePicture80";
    self.photoSelImageName = @"photo_sel_photoPickerVc";
    self.photoDefImageName = @"photo_def_photoPickerVc";
    self.photoNumberIconImage = [self createImageWithColor:nil size:CGSizeMake(24, 24) radius:12]; // @"photo_number_icon";
    self.photoPreviewOriginDefImageName = @"preview_original_def";
    self.photoOriginDefImageName = @"photo_original_def";
    self.photoOriginSelImageName = @"photo_original_sel";
}

- (void)configDefaultBtnTitle {
    self.doneBtnTitleStr = [NSBundle fxy_localizedStringForKey:@"Done"];
    self.cancelBtnTitleStr = [NSBundle fxy_localizedStringForKey:@"Cancel"];
    self.previewBtnTitleStr = [NSBundle fxy_localizedStringForKey:@"Preview"];
    self.fullImageBtnTitleStr = [NSBundle fxy_localizedStringForKey:@"Full image"];
    self.settingBtnTitleStr = [NSBundle fxy_localizedStringForKey:@"Setting"];
    self.processHintStr = [NSBundle fxy_localizedStringForKey:@"Processing..."];
}

- (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size radius:(CGFloat)radius {
    if (!color) {
        color = self.iconThemeColor;
    }
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    CGContextAddPath(context, path.CGPath);
    CGContextFillPath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)addSelectedModel:(FXYAssetModel *)model {
    [_selectedModels addObject:model];
    [_selectedAssetIds addObject:model.asset.localIdentifier];
}

- (void)removeSelectedModel:(FXYAssetModel *)model {
    [_selectedModels removeObject:model];
    [_selectedAssetIds removeObject:model.asset.localIdentifier];
}

- (void)callDelegateMethod {
    if ([self.pickerDelegate respondsToSelector:@selector(fxy_imagePickerControllerDidCancel:)]) {
        [self.pickerDelegate fxy_imagePickerControllerDidCancel:self];
    }
    if (self.imagePickerControllerDidCancelHandle) {
        self.imagePickerControllerDidCancelHandle();
    }
}

/**
 显示\隐藏相册选择视图
 */
- (void)showAlbumPickerView:(BOOL)show {
    if (show) {
        [self.albumPickerView showInView:self.view];
    }else{
        [self.albumPickerView close];
    }
}

#pragma mark - UINavigationControllerDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    self.pushAnimator.operation = operation;
    return self.pushAnimator;
}

#pragma mark - getter and setter

- (FXYPushAnimator *)pushAnimator {
    if (!_pushAnimator) {
        _pushAnimator = [[FXYPushAnimator alloc]init];
    }
    return _pushAnimator;
}

- (UIView *)bottomToolBar {
    if (!_bottomToolBar) {
        CGFloat toolBarHeight = [FXYCommonTools fxy_isIPhoneX] ? 50 + (83 - 49) : 50;
        _bottomToolBar = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - toolBarHeight, [UIScreen mainScreen].bounds.size.width, toolBarHeight)];
        _bottomToolBar.backgroundColor = [UIColor redColor];
    }
    return _bottomToolBar;
}

- (UIButton *)albumButton {
    if (!_albumButton) {
        _albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_albumButton setTitle:@"相册" forState:UIControlStateNormal];
        [_albumButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_albumButton setBackgroundColor:[UIColor yellowColor]];
        [_albumButton addTarget:self action:@selector(albumButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _albumButton.frame = CGRectMake(30, 5, 50, 35);
    }
    return _albumButton;
}

- (UIButton *)takePhotoButton {
    if (!_takePhotoButton) {
        _takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_takePhotoButton setTitle:@"拍照" forState:UIControlStateNormal];
        [_takePhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_takePhotoButton setBackgroundColor:[UIColor yellowColor]];
        [_takePhotoButton addTarget:self action:@selector(takePhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _takePhotoButton.frame = CGRectMake(100, 5, 50, 35);
    }
    return _takePhotoButton;
}

- (void)setNaviBgColor:(UIColor *)naviBgColor {
    _naviBgColor = naviBgColor;
    self.navigationBar.barTintColor = naviBgColor;
}

- (void)setNaviTitleColor:(UIColor *)naviTitleColor {
    _naviTitleColor = naviTitleColor;
    [self configNaviTitleAppearance];
}

- (void)setNaviTitleFont:(UIFont *)naviTitleFont {
    _naviTitleFont = naviTitleFont;
    [self configNaviTitleAppearance];
}

- (void)setMaxImagesCount:(NSInteger)maxImagesCount {
    _maxImagesCount = maxImagesCount;
    if (maxImagesCount > 1) {
        _showSelectBtn = YES;
        _allowCrop = NO;
    }
}

- (void)setColumnNumber:(NSInteger)columnNumber {
    _columnNumber = columnNumber;
    if (columnNumber <= 2) {
        _columnNumber = 2;
    } else if (columnNumber >= 6) {
        _columnNumber = 6;
    }
    
    self.albumPickerView.columnNumber = _columnNumber;
    [FXYImageManager manager].columnNumber = _columnNumber;
}

- (void)setShowSelectBtn:(BOOL)showSelectBtn {
    _showSelectBtn = showSelectBtn;
    // 多选模式下，不允许让showSelectBtn为NO
    if (!showSelectBtn && _maxImagesCount > 1) {
        _showSelectBtn = YES;
    }
}

- (void)setTimeout:(NSInteger)timeout {
    _timeout = timeout;
    if (timeout < 5) {
        _timeout = 5;
    } else if (_timeout > 60) {
        _timeout = 60;
    }
}

- (void)setPhotoPreviewMaxWidth:(CGFloat)photoPreviewMaxWidth {
    _photoPreviewMaxWidth = photoPreviewMaxWidth;
    if (photoPreviewMaxWidth > 800) {
        _photoPreviewMaxWidth = 800;
    } else if (photoPreviewMaxWidth < 500) {
        _photoPreviewMaxWidth = 500;
    }
    [FXYImageManager manager].photoPreviewMaxWidth = _photoPreviewMaxWidth;
}

- (void)setPhotoWidth:(CGFloat)photoWidth {
    _photoWidth = photoWidth;
    [FXYImageManager manager].photoWidth = photoWidth;
}

- (void)setPickerDelegate:(id<FXYImagePickerControllerDelegate>)pickerDelegate {
    _pickerDelegate = pickerDelegate;
    [FXYImageManager manager].pickerDelegate = pickerDelegate;
}

- (void)setMinPhotoWidthSelectable:(NSInteger)minPhotoWidthSelectable {
    _minPhotoWidthSelectable = minPhotoWidthSelectable;
    [FXYImageManager manager].minPhotoWidthSelectable = minPhotoWidthSelectable;
}

- (void)setMinPhotoHeightSelectable:(NSInteger)minPhotoHeightSelectable {
    _minPhotoHeightSelectable = minPhotoHeightSelectable;
    [FXYImageManager manager].minPhotoHeightSelectable = minPhotoHeightSelectable;
}

- (void)setHideWhenCanNotSelect:(BOOL)hideWhenCanNotSelect {
    _hideWhenCanNotSelect = hideWhenCanNotSelect;
    [FXYImageManager manager].hideWhenCanNotSelect = hideWhenCanNotSelect;
}

- (void)setShowPhotoCannotSelectLayer:(BOOL)showPhotoCannotSelectLayer {
    _showPhotoCannotSelectLayer = showPhotoCannotSelectLayer;
    [FXYImagePickerConfig sharedInstance].showPhotoCannotSelectLayer = showPhotoCannotSelectLayer;
}

- (void)setNotScaleImage:(BOOL)notScaleImage {
    _notScaleImage = notScaleImage;
    [FXYImagePickerConfig sharedInstance].notScaleImage = notScaleImage;
}

- (void)setNeedFixComposition:(BOOL)needFixComposition {
    _needFixComposition = needFixComposition;
    [FXYImagePickerConfig sharedInstance].needFixComposition = needFixComposition;
}

- (void)setIconThemeColor:(UIColor *)iconThemeColor {
    _iconThemeColor = iconThemeColor;
    [self configDefaultImageName];
}

- (void)setTakePictureImageName:(NSString *)takePictureImageName {
    _takePictureImageName = takePictureImageName;
    _takePictureImage = [UIImage fxy_imageNamedFromMyBundle:takePictureImageName];
}

- (void)setPhotoSelImageName:(NSString *)photoSelImageName {
    _photoSelImageName = photoSelImageName;
    _photoSelImage = [UIImage fxy_imageNamedFromMyBundle:photoSelImageName];
}

- (void)setPhotoDefImageName:(NSString *)photoDefImageName {
    _photoDefImageName = photoDefImageName;
    _photoDefImage = [UIImage fxy_imageNamedFromMyBundle:photoDefImageName];
}

- (void)setPhotoNumberIconImageName:(NSString *)photoNumberIconImageName {
    _photoNumberIconImageName = photoNumberIconImageName;
    _photoNumberIconImage = [UIImage fxy_imageNamedFromMyBundle:photoNumberIconImageName];
}

- (void)setPhotoPreviewOriginDefImageName:(NSString *)photoPreviewOriginDefImageName {
    _photoPreviewOriginDefImageName = photoPreviewOriginDefImageName;
    _photoPreviewOriginDefImage = [UIImage fxy_imageNamedFromMyBundle:photoPreviewOriginDefImageName];
}

- (void)setPhotoOriginDefImageName:(NSString *)photoOriginDefImageName {
    _photoOriginDefImageName = photoOriginDefImageName;
    _photoOriginDefImage = [UIImage fxy_imageNamedFromMyBundle:photoOriginDefImageName];
}

- (void)setPhotoOriginSelImageName:(NSString *)photoOriginSelImageName {
    _photoOriginSelImageName = photoOriginSelImageName;
    _photoOriginSelImage = [UIImage fxy_imageNamedFromMyBundle:photoOriginSelImageName];
}

- (void)setAllowCrop:(BOOL)allowCrop {
    _allowCrop = _maxImagesCount > 1 ? NO : allowCrop;
    if (allowCrop) { // 允许裁剪的时候，不能选原图和GIF
        self.allowPickingOriginalPhoto = NO;
        self.allowPickingGif = NO;
    }
}

- (void)setCircleCropRadius:(NSInteger)circleCropRadius {
    _circleCropRadius = circleCropRadius;
    self.cropRect = CGRectMake(self.view.fxy_width / 2 - circleCropRadius, self.view.fxy_height / 2 - _circleCropRadius, _circleCropRadius * 2, _circleCropRadius * 2);
}

- (void)setCropRect:(CGRect)cropRect {
    _cropRect = cropRect;
    _cropRectPortrait = cropRect;
    CGFloat widthHeight = cropRect.size.width;
    _cropRectLandscape = CGRectMake((self.view.fxy_height - widthHeight) / 2, cropRect.origin.x, widthHeight, widthHeight);
}

- (void)setShowSelectedIndex:(BOOL)showSelectedIndex {
    _showSelectedIndex = showSelectedIndex;
    if (showSelectedIndex) {
        self.photoSelImage = [self createImageWithColor:nil size:CGSizeMake(24, 24) radius:12];
    }
    [FXYImagePickerConfig sharedInstance].showSelectedIndex = showSelectedIndex;
}

- (void)setSelectedAssets:(NSMutableArray *)selectedAssets {
    _selectedAssets = selectedAssets;
    _selectedModels = [NSMutableArray array];
    _selectedAssetIds = [NSMutableArray array];
    for (PHAsset *asset in selectedAssets) {
        FXYAssetModel *model = [FXYAssetModel modelWithAsset:asset type:[[FXYImageManager manager] getAssetType:asset]];
        model.isSelected = YES;
        [self addSelectedModel:model];
    }
}

- (void)setAllowPickingImage:(BOOL)allowPickingImage {
#warning 不能点击拍照
    _allowPickingImage = allowPickingImage;
    [FXYImagePickerConfig sharedInstance].allowPickingImage = allowPickingImage;
    if (!allowPickingImage) {
        _allowTakePicture = NO;
    }
}

- (void)setAllowTakeVideo:(BOOL)allowTakeVideo {
    _allowTakeVideo = allowTakeVideo;
#warning 不能点击拍视频
}

- (void)setAllowPickingVideo:(BOOL)allowPickingVideo {
    _allowPickingVideo = allowPickingVideo;
    [FXYImagePickerConfig sharedInstance].allowPickingVideo = allowPickingVideo;
    if (!allowPickingVideo) {
        _allowTakeVideo = NO;
    }
}

- (void)setPreferredLanguage:(NSString *)preferredLanguage {
    _preferredLanguage = preferredLanguage;
    [FXYImagePickerConfig sharedInstance].preferredLanguage = preferredLanguage;
    [self configDefaultBtnTitle];
}

- (void)setLanguageBundle:(NSBundle *)languageBundle {
    _languageBundle = languageBundle;
    [FXYImagePickerConfig sharedInstance].languageBundle = languageBundle;
    [self configDefaultBtnTitle];
}

- (void)setSortAscendingByModificationDate:(BOOL)sortAscendingByModificationDate {
    _sortAscendingByModificationDate = sortAscendingByModificationDate;
    [FXYImageManager manager].sortAscendingByModificationDate = sortAscendingByModificationDate;
}
#pragma clang diagnostic pop

@end
