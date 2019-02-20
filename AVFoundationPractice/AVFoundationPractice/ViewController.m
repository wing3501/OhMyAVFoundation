//
//  ViewController.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/11.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "ViewController.h"
#import "OMCameraViewController.h"
#import "NSFileManager+Ext.h"
#import "OMVideoWriteViewController.h"
#import "OMFilterCameraViewController.h"
#import "OMVideoListViewController.h"
#import "FXYCameraViewController.h"
#import "FXYImagePickerController.h"
@interface ViewController ()<FXYImagePickerControllerDelegate>
/// 列表
@property (nonatomic,strong) NSArray *dataArray;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = @[@{@"name":@"自定义相机",@"method":@"cameraViewController"},
                   @{@"name":@"视频读写",@"method":@"videoWriteViewController"},
                   @{@"name":@"滤镜相机(打开VideoDataOutputON)",@"method":@"filterCameraViewController"},
                   @{@"name":@"视频编辑",@"method":@"videoListViewController"},
                   @{@"name":@"仿闲鱼相机",@"method":@"fxyCameraViewController"},
                   @{@"name":@"仿闲鱼图片选择器",@"method":@"fxyImagePickerController"}
                   ];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = _dataArray[indexPath.row];
    cell.textLabel.text = dic[@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = _dataArray[indexPath.row];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:NSSelectorFromString(dic[@"method"])];
#pragma clang diagnostic pop
}

- (void)cameraViewController {
    OMCameraViewController *vc = [[OMCameraViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)videoWriteViewController {
    OMVideoWriteViewController *vc = [[OMVideoWriteViewController alloc]init];
    vc.title = @"视频读写";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)filterCameraViewController {
    OMFilterCameraViewController *vc = [[OMFilterCameraViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)videoListViewController {
    OMVideoListViewController *vc = [[OMVideoListViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)fxyCameraViewController {
    FXYCameraViewController *vc = [[FXYCameraViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)fxyImagePickerController {
    FXYImagePickerController *imagePickerVc = [[FXYImagePickerController alloc]initWithMaxImagesCount:5 delegate:self];
    imagePickerVc.allowTakePicture = YES;
    imagePickerVc.showPhotoCannotSelectLayer = YES;
    imagePickerVc.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingMultipleVideo = NO;
    imagePickerVc.sortAscendingByModificationDate = YES;
    imagePickerVc.showSelectedIndex = YES;
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}
@end
