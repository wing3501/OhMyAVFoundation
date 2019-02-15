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
@interface ViewController ()
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
                   @{@"name":@"仿闲鱼相机",@"method":@"fxyCameraViewController"}
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
    [self.navigationController pushViewController:vc animated:YES];
}
@end
