//
//  FXYAlbumPickerView.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/19.
//  Copyright © 2019 styf. All rights reserved.
//

#import "FXYAlbumPickerView.h"
#import "UIView+FXYLayout.h"
#import "FXYImageManager.h"
#import "FXYCommonTools.h"
#import "FXYAlbumModel.h"
#import "FXYAlbumCell.h"

@interface FXYAlbumPickerView ()<UITableViewDataSource,UITableViewDelegate> {
    UITableView *_tableView;
}
/// 相册数组
@property (nonatomic, strong) NSMutableArray *albumArr;
/// 控制器
@property (nonatomic, weak) FXYImagePickerController *imagePickerController;
@end

@implementation FXYAlbumPickerView

#pragma mark - life cycle

- (instancetype)initWithImagePickerController:(FXYImagePickerController *)imagePickerController {
    CGFloat navigationBarHeight = [FXYCommonTools fxy_statusBarHeight] + 44;
    self = [super initWithFrame:CGRectMake(0, navigationBarHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - navigationBarHeight)];
    if (self) {
        self.imagePickerController = imagePickerController;
        [self commonInit];
    }
    return self;
}
/**
 初始化
 */
- (void)commonInit {
    [self setupUI];
    [self configTableView];
}

/**
 设置视图
 */
- (void)setupUI {
    self.isFirstAppear = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
}

#pragma mark - overwrite

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self showAnimation:YES];
    }
}

#pragma mark - public

- (void)configTableView {
    if (![[FXYImageManager manager] authorizationStatusAuthorized]) {
        return;
    }
    
    if (self.isFirstAppear) {
        [self.imagePickerController showProgressHUD];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //获取到所有相册
        [[FXYImageManager manager] getAllAlbums:self.imagePickerController.allowPickingVideo allowPickingImage:self.imagePickerController.allowPickingImage needFetchAssets:!self.isFirstAppear completion:^(NSArray<FXYAlbumModel *> *models) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_albumArr = [NSMutableArray arrayWithArray:models];
                for (FXYAlbumModel *albumModel in self->_albumArr) {
                    albumModel.selectedModels = self.imagePickerController.selectedModels;
                }
                [self.imagePickerController hideProgressHUD];
                
                if (self.isFirstAppear) {
                    self.isFirstAppear = NO;
                    [self configTableView];
                }
                
                if (!self->_tableView) {
                    self->_tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
                    self->_tableView.rowHeight = 70;
                    self->_tableView.tableFooterView = [[UIView alloc] init];
                    self->_tableView.dataSource = self;
                    self->_tableView.delegate = self;
                    self->_tableView.backgroundColor = [UIColor blueColor];
                    [self->_tableView registerClass:[FXYAlbumCell class] forCellReuseIdentifier:@"FXYAlbumCell"];
                    [self addSubview:self->_tableView];
                } else {
                    [self->_tableView reloadData];
                }
            });
        }];
    });
}

- (void)close {
    [self showAnimation:NO];
}
#pragma mark - notification

#pragma mark - event response

#pragma mark - private

/**
 显示和收起的动画

 @param show 是否显示
 */
- (void)showAnimation:(BOOL)show {
    CGFloat navigationBarHeight = [FXYCommonTools fxy_statusBarHeight] + 44;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - navigationBarHeight;
    CGFloat fromHeight = show ? 0 : height;
    CGFloat toHeight = show ? height : 0;
    self.fxy_height = fromHeight;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.fxy_height = toHeight;
    } completion:^(BOOL finished) {
        show ?: [self removeFromSuperview];
    }];
}

#pragma mark - getter and setter

#pragma mark - Layout

#pragma mark - UITableViewDataSource && Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _albumArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FXYAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FXYAlbumCell"];
    cell.model = _albumArr[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
#warning 收起相册页面，刷新图片页面
    
//    TZPhotoPickerController *photoPickerVc = [[TZPhotoPickerController alloc] init];
//    photoPickerVc.columnNumber = self.columnNumber;
//    TZAlbumModel *model = _albumArr[indexPath.row];
//    photoPickerVc.model = model;
//    [self.navigationController pushViewController:photoPickerVc animated:YES];
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
@end
