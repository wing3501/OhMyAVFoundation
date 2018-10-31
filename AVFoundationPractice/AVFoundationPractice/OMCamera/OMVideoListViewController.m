//
//  OMVideoListViewController.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/22.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "OMVideoListViewController.h"
#import "OMVideoModel.h"
#import "OMAssetsLibraryTool.h"

@interface OMVideoListViewController ()<UITableViewDelegate,UITableViewDataSource>
/// 列表
@property (nonatomic,strong) UITableView *tableView;
/// 数据
@property (nonatomic,strong) NSMutableArray *dataArray;
/// 选中的视频列表
@property (nonatomic,strong) NSMutableArray *selectedArray;
/// 导出会话
@property (nonatomic,strong) AVAssetExportSession *exportSession;
@end

@implementation OMVideoListViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

/**
 初始化
 */
- (void)commonInit {
    [self setupUI];
    [self autoLayout];
    [self setupData];
}

/**
 设置视图
 */
- (void)setupUI {
    [self.view addSubview:self.tableView];
    UIBarButtonItem *cuttingItem = [[UIBarButtonItem alloc]initWithTitle:@"裁剪" style:UIBarButtonItemStylePlain target:self action:@selector(cutting)];
    UIBarButtonItem *playItem = [[UIBarButtonItem alloc]initWithTitle:@"播放" style:UIBarButtonItemStylePlain target:self action:@selector(play)];
    self.navigationItem.rightBarButtonItems = @[playItem,cuttingItem];
}

/**
 自动布局
 */
- (void)autoLayout {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}
#pragma mark - overwrite

#pragma mark - public

#pragma mark - notification

#pragma mark - event response

#pragma mark - private

/**
 设置数据
 */
- (void)setupData {
    [self.dataArray removeAllObjects];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *home = NSTemporaryDirectory();
    NSError *error;
    NSArray<NSString *> *array = [manager contentsOfDirectoryAtPath:home error:&error];
    NSString *filepath = nil;
    BOOL isDirectory = NO;
    for (NSString *filename in array) {
        filepath = [home stringByAppendingPathComponent:filename];
        [manager fileExistsAtPath:filepath isDirectory:&isDirectory];
        if (!isDirectory&&[[filepath pathExtension]isEqualToString:@"mov"]) {
            OMVideoModel *model = [[OMVideoModel alloc]init];
            model.fileName = filename;
            model.filePath = filepath;
            [self.dataArray addObject:model];
        }
    }
}

/**
 加载资源
 */
- (void)loadAsset:(NSURL *)URL withCompletionBlock:(VoidBlock_id)completionBlock{
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};//可以计算出时长和时间信息
    AVAsset *asset = [AVURLAsset URLAssetWithURL:URL options:options];
    NSArray *keys = @[@"tracks",@"duration",@"commonMetadata"];
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        NSError *error = nil;
        AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
        switch (status) {
            case AVKeyValueStatusLoaded:
                completionBlock?completionBlock(asset):nil;
                break;
            case AVKeyValueStatusFailed:
                break;
            case AVKeyValueStatusCancelled:
                break;
            default:
                break;
        }
    }];
}

/**
 裁剪(裁剪中间的一半)
 */
- (void)cutting {
    if (self.selectedArray.count == 0 || self.selectedArray.count > 1) {
        [self showError:@"每次只能裁剪一个视频"];
        return;
    }
    
    OMVideoModel *model = self.selectedArray.firstObject;
    WEAKSELF
    [self loadAsset:[NSURL fileURLWithPath:model.filePath] withCompletionBlock:^(AVAsset *asset) {
        STRONGSELF
        AVMutableComposition *composition = [AVMutableComposition composition];
        AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        int64_t value = [NSString stringWithFormat:@"%.0f",asset.duration.value * 0.25].intValue;
        CMTime start = CMTimeMake(value, asset.duration.timescale);
        CMTime duration = CMTimeMake(value * 2, asset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        
        AVAssetTrack *assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        [videoTrack insertTimeRange:range ofTrack:assetVideoTrack atTime:kCMTimeZero error:nil];
        videoTrack.preferredTransform = assetVideoTrack.preferredTransform;
        
        AVAssetTrack *assetAudioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
        [audioTrack insertTimeRange:range ofTrack:assetAudioTrack atTime:kCMTimeZero error:nil];
        
        //导出操作
        NSURL *outputURL = [strongSelf outputURL];
        NSString *preset = AVAssetExportPreset1280x720;
        strongSelf.exportSession = [[AVAssetExportSession alloc]initWithAsset:composition presetName:preset];
        strongSelf.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        strongSelf.exportSession.outputURL = outputURL;
        strongSelf.exportSession.timeRange = CMTimeRangeMake(kCMTimeZero, duration);
        [strongSelf.exportSession exportAsynchronouslyWithCompletionHandler:^{
            STRONGSELF
            AVAssetExportSessionStatus status = strongSelf.exportSession.status;
            if (status == AVAssetExportSessionStatusFailed) {
                NSLog(@"error:%@",strongSelf.exportSession.error);
            }
            NSLog(@"导出结束...");
            if (status == AVAssetExportSessionStatusCompleted) {
                [strongSelf writeVideoToAssetsLibrary:outputURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    STRONGSELF
                    [strongSelf.selectedArray removeAllObjects];
                    [strongSelf setupData];
                    [strongSelf.tableView reloadData];
                });
            }
        }];
    }];
}

/**
 写入视频到相册
 
 @param videoURL 视频url
 */
- (void)writeVideoToAssetsLibrary:(NSURL *)videoURL {
    [OMAssetsLibraryTool writeVideoToAssetsLibrary:videoURL withCompletionHandler:^(id  _Nonnull obj, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"写入视频到相册失败");
        } else {
            NSLog(@"写入视频到相册成功");
        }
    }];
}


/**
 播放
 */
- (void)play {
    if (self.selectedArray.count == 0 || self.selectedArray.count > 1) {
        return;
    }
    OMVideoModel *model = self.selectedArray.firstObject;
    NSURL *url = [NSURL fileURLWithPath:model.filePath];

//    NSLog(@"视频方向==>%lu",(unsigned long)[self degressFromVideoFileWithURL:url]);
    
    AVPlayerViewController *controller = [[AVPlayerViewController alloc]init];
    controller.player = [AVPlayer playerWithURL:url];
    [self.navigationController pushViewController:controller animated:YES];
}
/**
 显示错误信息
 */
- (void)showError:(NSString *)errorMsg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:errorMsg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSURL *)outputURL {
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%.0f.mov",[[NSDate date]timeIntervalSince1970]]];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    }
    return url;
}

/**
 视频方向
 */
- (NSUInteger)degressFromVideoFileWithURL:(NSURL *)url
{
    NSUInteger degress = 0;
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    
    return degress;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OMVideoModel *model = self.dataArray[indexPath.row];
    [self.selectedArray addObject:model];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    OMVideoModel *model = self.dataArray[indexPath.row];
    [self.selectedArray removeObject:model];
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    OMVideoModel *model = self.dataArray[indexPath.row];
    cell.textLabel.text = model.fileName;
    return cell;
}

#pragma mark - getter and setter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
        _tableView.sectionHeaderHeight = 0.01;
        _tableView.sectionFooterHeight = 0.01;
        _tableView.allowsMultipleSelection = YES;
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[].mutableCopy;
    }
    return _dataArray;
}

- (NSMutableArray *)selectedArray {
    if (!_selectedArray) {
        _selectedArray = @[].mutableCopy;
    }
    return _selectedArray;
}
@end
