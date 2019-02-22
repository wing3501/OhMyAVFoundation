//
//  FXYImagePickerController.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/19.
//  Copyright © 2019 styf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXYImageManager.h"
@protocol FXYImagePickerControllerDelegate;

@interface FXYImagePickerController : UINavigationController
/// 是否需要状态栏
@property (nonatomic, assign) BOOL needShowStatusBar;
/// statusBar的样式，默认为UIStatusBarStyleLightContent
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

/// ===================== Appearance / 外观颜色 + 按钮文字 =====================
@property (nonatomic, strong) UIColor *oKButtonTitleColorNormal;
@property (nonatomic, strong) UIColor *oKButtonTitleColorDisabled;
@property (nonatomic, strong) UIColor *naviBgColor;
@property (nonatomic, strong) UIColor *naviTitleColor;
@property (nonatomic, strong) UIFont *naviTitleFont;

@property (nonatomic, copy) NSString *doneBtnTitleStr;
@property (nonatomic, copy) NSString *cancelBtnTitleStr;
@property (nonatomic, copy) NSString *previewBtnTitleStr;
@property (nonatomic, copy) NSString *fullImageBtnTitleStr;
@property (nonatomic, copy) NSString *settingBtnTitleStr;
@property (nonatomic, copy) NSString *processHintStr;
/// Icon theme color, default is green color like wechat, the value is r:31 g:185 b:34. Currently only support image selection icon when showSelectedIndex is YES. If you need it, please set it as soon as possible
/// icon主题色，默认是微信的绿色，值是r:31 g:185 b:34。目前仅支持showSelectedIndex为YES时的图片选中icon。如需要，请尽早设置它。
@property (nonatomic, strong) UIColor *iconThemeColor;
/// ===================== 权限设置 =====================
@property (nonatomic, assign) BOOL allowCrop;            ///< 允许裁剪,默认为YES，showSelectBtn为NO才生效
/// Default is YES, if set NO, the original photo button will hide. user can't picking original photo.
/// 默认为YES，如果设置为NO,原图按钮将隐藏，用户不能选择发送原图
@property (nonatomic, assign) BOOL allowPickingOriginalPhoto;
/// Default is YES, if set NO, user can't picking image.
/// 默认为YES，如果设置为NO,用户将不能选择发送图片
@property (nonatomic, assign) BOOL allowPickingImage;
/// Default is YES, if set NO, user can't picking video.
/// 默认为YES，如果设置为NO,用户将不能选择视频
@property (nonatomic, assign) BOOL allowPickingVideo;
/// Default is YES, if set NO, user can't take picture.
/// 默认为YES，如果设置为NO, 用户将不能拍摄照片
@property (nonatomic, assign) BOOL allowTakePicture;
@property (nonatomic, assign) BOOL allowCameraLocation;
/// Default is YES, if set NO, user can't take video.
/// 默认为YES，如果设置为NO, 用户将不能拍摄视频
@property (nonatomic, assign) BOOL allowTakeVideo;
/// Default is NO / 默认为NO，为YES时可以多选视频/gif/图片，和照片共享最大可选张数maxImagesCount的限制
@property (nonatomic, assign) BOOL allowPickingMultipleVideo;
/// Default is NO, if set YES, user can picking gif image.
/// 默认为NO，如果设置为YES,用户可以选择gif图片
@property (nonatomic, assign) BOOL allowPickingGif;
/// Default is YES, if set NO, user can't preview photo.
/// 默认为YES，如果设置为NO,预览按钮将隐藏,用户将不能去预览照片
@property (nonatomic, assign) BOOL allowPreview;

/// ===================== 选择设置 =====================
/// Default is 9 / 默认最大可选9张图片
@property (nonatomic, assign) NSInteger maxImagesCount;
/// The minimum count photos user must pick, Default is 0
/// 最小照片必选张数,默认是0
@property (nonatomic, assign) NSInteger minImagesCount;
/// Always enale the done button, not require minimum 1 photo be picked
/// 让完成按钮一直可以点击，无须最少选择一张图片
@property (nonatomic, assign) BOOL alwaysEnableDoneBtn;
/// Sort photos ascending by modificationDate，Default is YES
/// 对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面，内部的拍照按钮会排在第一个
@property (nonatomic, assign) BOOL sortAscendingByModificationDate;
/// Default is YES, if set NO, the picker don't dismiss itself.
/// 默认为YES，如果设置为NO, 选择器将不会自己dismiss
@property (nonatomic, assign) BOOL autoDismiss;
/// Single selection mode, valid when maxImagesCount = 1
/// 单选模式,maxImagesCount为1时才生效
@property (nonatomic, assign) BOOL showSelectBtn;        ///< 在单选模式下，照片列表页中，显示选择按钮,默认为NO
/// Default value is 10 minutes / 视频最大拍摄时间，默认是10分钟，单位是秒
@property (nonatomic, assign) NSTimeInterval videoMaximumDuration;
/// Default is 15, While fetching photo, HUD will dismiss automatic if timeout;
/// 超时时间，默认为15秒，当取图片时间超过15秒还没有取成功时，会自动dismiss HUD；
@property (nonatomic, assign) NSInteger timeout;
/// The pixel width of output image, Default is 828px / 导出图片的宽度，默认828像素宽
@property (nonatomic, assign) CGFloat photoWidth;
/// Default is 600px / 默认600像素宽
@property (nonatomic, assign) CGFloat photoPreviewMaxWidth;
/// Default is YES, if set NO, the result photo will be scaled to photoWidth pixel width. The photoWidth default is 828px
/// 默认是YES，如果设置为NO，内部会缩放图片到photoWidth像素宽
@property (nonatomic, assign) BOOL notScaleImage;
/// 默认是NO，如果设置为YES，导出视频时会修正转向（慎重设为YES，可能导致部分安卓下拍的视频导出失败）
@property (nonatomic, assign) BOOL needFixComposition;
/// Default is NO, if set YES, when selected photos's count up to maxImagesCount, other photo will show float layer what's color is cannotSelectLayerColor.
/// 默认是NO，如果设置为YES，当照片选择张数达到maxImagesCount时，其它照片会显示颜色为cannotSelectLayerColor的浮层
@property (nonatomic, assign) BOOL showPhotoCannotSelectLayer;
/// Default is white color with 0.8 alpha;
@property (nonatomic, strong) UIColor *cannotSelectLayerColor;
/// Default is NO, if set YES, in the delegate method the photos and infos will be nil, only assets hava value.
/// 默认为NO，如果设置为YES，代理方法里photos和infos会是nil，只返回assets
@property (assign, nonatomic) BOOL onlyReturnAsset;
/// Default is NO, if set YES, will show the image's selected index.
/// 默认为NO，如果设置为YES，会显示照片的选中序号
@property (nonatomic, assign) BOOL showSelectedIndex;
/// Minimum selectable photo width, Default is 0
/// 最小可选中的图片宽度，默认是0，小于这个宽度的图片不可选中
@property (nonatomic, assign) NSInteger minPhotoWidthSelectable;
@property (nonatomic, assign) NSInteger minPhotoHeightSelectable;
/// Hide the photo what can not be selected, Default is NO
/// 隐藏不可以选中的图片，默认是NO，不推荐将其设置为YES
@property (nonatomic, assign) BOOL hideWhenCanNotSelect;
/// 首选语言，如果设置了就用该语言，不设则取当前系统语言。
/// 由于目前只支持中文、繁体中文、英文、越南语。故该属性只支持zh-Hans、zh-Hant、en、vi四种值，其余值无效。
@property (nonatomic, copy) NSString *preferredLanguage;

/// 语言bundle，preferredLanguage变化时languageBundle会变化
/// 可通过手动设置bundle，让选择器支持新的的语言（需要在设置preferredLanguage后设置languageBundle）。欢迎提交PR把语言文件提交上来~
@property (nonatomic, strong) NSBundle *languageBundle;

/// ===================== 按钮图片相关 =====================
@property (nonatomic, copy) NSString *takePictureImageName __attribute__((deprecated("Use -takePictureImage.")));
@property (nonatomic, copy) NSString *photoSelImageName __attribute__((deprecated("Use -photoSelImage.")));
@property (nonatomic, copy) NSString *photoDefImageName __attribute__((deprecated("Use -photoDefImage.")));
@property (nonatomic, copy) NSString *photoOriginSelImageName __attribute__((deprecated("Use -photoOriginSelImage.")));
@property (nonatomic, copy) NSString *photoOriginDefImageName __attribute__((deprecated("Use -photoOriginDefImage.")));
@property (nonatomic, copy) NSString *photoPreviewOriginDefImageName __attribute__((deprecated("Use -photoPreviewOriginDefImage.")));
@property (nonatomic, copy) NSString *photoNumberIconImageName __attribute__((deprecated("Use -photoNumberIconImage.")));
@property (nonatomic, strong) UIImage *takePictureImage;
@property (nonatomic, strong) UIImage *photoSelImage;
@property (nonatomic, strong) UIImage *photoDefImage;
@property (nonatomic, strong) UIImage *photoOriginSelImage;
@property (nonatomic, strong) UIImage *photoOriginDefImage;
@property (nonatomic, strong) UIImage *photoPreviewOriginDefImage;
@property (nonatomic, strong) UIImage *photoNumberIconImage;

/// ===================== 按钮图片相关 =====================
@property (nonatomic, assign) CGRect cropRect;           ///< 裁剪框的尺寸
@property (nonatomic, assign) CGRect cropRectPortrait;   ///< 裁剪框的尺寸(竖屏)
@property (nonatomic, assign) CGRect cropRectLandscape;  ///< 裁剪框的尺寸(横屏)
@property (nonatomic, assign) BOOL needCircleCrop;       ///< 需要圆形裁剪框
@property (nonatomic, assign) NSInteger circleCropRadius;  ///< 圆形裁剪框半径大小
@property (nonatomic, copy) void (^cropViewSettingBlock)(UIView *cropView);     ///< 自定义裁剪框的其他属性
/// ===================== 弹窗相关 =====================
- (UIAlertController *)showAlertWithTitle:(NSString *)title;
- (void)hideAlertView:(UIAlertController *)alertView;

/**
 显示进度提示
 */
- (void)showProgressHUD;

/**
 隐藏进度提示
 */
- (void)hideProgressHUD;


/// 用户是否选择了原图
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
/// The photos user have selected
/// 用户选中过的图片数组
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) NSMutableArray<FXYAssetModel *> *selectedModels;
@property (nonatomic, strong) NSMutableArray *selectedAssetIds;
- (void)addSelectedModel:(FXYAssetModel *)model;
- (void)removeSelectedModel:(FXYAssetModel *)model;

/// ===================== 对应代理的Block回调 =====================
// For method annotations, see the corresponding method in TZImagePickerControllerDelegate / 方法注释见TZImagePickerControllerDelegate中对应方法
@property (nonatomic, copy) void (^didFinishPickingPhotosHandle)(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto);
@property (nonatomic, copy) void (^didFinishPickingPhotosWithInfosHandle)(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto,NSArray<NSDictionary *> *infos);
@property (nonatomic, copy) void (^imagePickerControllerDidCancelHandle)(void);
@property (nonatomic, copy) void (^didFinishPickingVideoHandle)(UIImage *coverImage,PHAsset *asset);
@property (nonatomic, copy) void (^didFinishPickingGifImageHandle)(UIImage *animatedImage,id sourceAssets);

@property (nonatomic, weak) id<FXYImagePickerControllerDelegate> pickerDelegate;


- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<FXYImagePickerControllerDelegate>)delegate;
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<FXYImagePickerControllerDelegate>)delegate;
@end

@protocol FXYImagePickerControllerDelegate <NSObject>
@optional
// The picker should dismiss itself; when it dismissed these callback will be called.
// You can also set autoDismiss to NO, then the picker don't dismiss itself.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 你也可以设置autoDismiss属性为NO，选择器就不会自己dismis了
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(FXYImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto;
- (void)imagePickerController:(FXYImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos;
- (void)fxy_imagePickerControllerDidCancel:(FXYImagePickerController *)picker;

// If user picking a video and allowPickingMultipleVideo is NO, this callback will be called.
// If allowPickingMultipleVideo is YES, will call imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
// 如果用户选择了一个视频且allowPickingMultipleVideo是NO，下面的代理方法会被执行
// 如果allowPickingMultipleVideo是YES，将会调用imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
- (void)imagePickerController:(FXYImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset;

// If user picking a gif image and allowPickingMultipleVideo is NO, this callback will be called.
// If allowPickingMultipleVideo is YES, will call imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
// 如果用户选择了一个gif图片且allowPickingMultipleVideo是NO，下面的代理方法会被执行
// 如果allowPickingMultipleVideo是YES，将会调用imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
- (void)imagePickerController:(FXYImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(PHAsset *)asset;

// Decide album show or not't
// 决定相册显示与否 albumName:相册名字 result:相册原始数据
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(PHFetchResult *)result;

// Decide asset show or not't
// 决定照片显示与否
- (BOOL)isAssetCanSelect:(PHAsset *)asset;
@end

