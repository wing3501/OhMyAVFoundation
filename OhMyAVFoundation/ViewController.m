//
//  ViewController.m
//  OhMyAVFoundation
//
//  Created by 申屠云飞 on 2018/8/24.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "ViewController.h"
#import "AudioLooperController.h"
#import "VoiceMemoController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MetaManagerViewController.h"
#import "AVPlayerDemoViewController.h"
#import <AVKit/AVKit.h>
#import "OMCameraViewController.h"
@interface ViewController ()
/// 列表
@property (nonatomic,strong) NSArray *dataArray;
/// 音频播放器
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;
/// 录音器
@property (nonatomic,strong) AVAudioRecorder *audioRecorder;
/// 导出会话
@property (nonatomic,strong) AVAssetExportSession *exportSession;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = @[@{@"name":@"语音合成",@"method":@"speechSynthesis"},
                   @{@"name":@"使用AVAudioPlayer播放音频",@"method":@"playAudio"},
                   @{@"name":@"Audio Looper",@"method":@"audioLooper"},
                   @{@"name":@"使用AVAudioRecorder录制音频",@"method":@"recordAudio"},
                   @{@"name":@"Voice Memo",@"method":@"voiceMemo"},
                   @{@"name":@"AVAsset Demo",@"method":@"AVAssetDemo"},
                   @{@"name":@"MetaManager",@"method":@"metaManager"},
                   @{@"name":@"AVPlayer",@"method":@"AVPlayerDemo"},
                   @{@"name":@"显示字幕",@"method":@"zimu"},
                   @{@"name":@"AirPlay",@"method":@"AirPlay"},
                   @{@"name":@"AVPlayerViewController",@"method":@"AVPlayerViewControllerDemo"},
                   @{@"name":@"相机示例",@"method":@"kamera"},
                   @{@"name":@"CMTime",@"method":@"CMTimeDemo"},
                   @{@"name":@"媒体组合",@"method":@"zuhe"},
                   @{@"name":@"混音",@"method":@"mix"},
                   @{@"name":@"视频过渡动画",@"method":@"guodu"},
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

//语音合成
- (void)speechSynthesis {
    
    NSArray *array = [AVSpeechSynthesisVoice speechVoices];
    for (AVSpeechSynthesisVoice *voice in array) {
        NSLog(@"%@",voice.language);
    }
    
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:@"公元前607——赵穿杀晋灵公于桃园。79年——庞贝古城毁于维苏威火山大爆发。410年——西哥特人在阿拉里克的率领下开始对罗马的三天洗劫。1101年——苏轼逝世"];
    utterance.rate = 0.4f;//播放速率 0-1
    utterance.pitchMultiplier = 0.8f;//音调
    utterance.postUtteranceDelay = 0.1f;//语音合成器在播放下一语句之前的短时间暂停
    //    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"ja-JP"];
    //    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:@"どういうことですか"];
    utterance.voice = voice;
    [synthesizer speakUtterance:utterance];
    
}
//使用AVAudioPlayer播放音频
- (void)playAudio {
    if (!_audioPlayer) {
        NSURL *fileUrl = [[NSBundle mainBundle]URLForResource:@"test" withExtension:@"mp3"];
        _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:fileUrl error:nil];
    }
    
    if (_audioPlayer) {
        [_audioPlayer prepareToPlay];
    }
    
    [_audioPlayer play];
}
//Audio Looper 案例
- (void)audioLooper {
    AudioLooperController *vc = [[AudioLooperController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

//使用AVAudioRecorder录制音频
- (void)recordAudio {
    NSString *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [directory stringByAppendingPathComponent:@"voice.m4a"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSDictionary *settings = @{
                              AVFormatIDKey : @(kAudioFormatMPEG4AAC),//写入内容的音频格式,与url文件类型保持一致  (kAudioFormatLinearPCM不压缩保真)
                              AVSampleRateKey : @22050.0f,//采样率 尽量使用标准的采样率8000、16000、22050、44100
                              AVNumberOfChannelsKey : @1//通道数 1-单声道录制 2-立体声录制(外部硬件)
                              };
    
    NSError *error;
    self.audioRecorder = [[AVAudioRecorder alloc]initWithURL:url settings:settings error:&error];
    if (self.audioRecorder) {
        [self.audioRecorder prepareToRecord];
        //开始录音
    }else{
        //处理错误
    }
}
//voiceMemo 语音备忘 案例
- (void)voiceMemo {
    VoiceMemoController *vc = [[VoiceMemoController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}
//AVAsset
- (void)AVAssetDemo {
//    NSURL *assetURL = nil;
//    AVAsset *asset = [AVAsset assetWithURL:assetURL];
    
//    NSURL *assetURL = nil;
//    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey: @YES};
//    AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:assetURL options:options];
    
    
//    iOS Assets库 #import <AssetsLibrary/AssetsLibrary.h> 9.0过期
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
//    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//        [group setAssetsFilter:[ALAssetsFilter allVideos]];//过滤掉非视频
//        //抓取第一个视频
//        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:0] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *stop) {
//            if (alAsset) {
//                id representation = [alAsset defaultRepresentation];
//                NSURL *url = [representation url];
//                AVAsset *asset = [AVAsset assetWithURL:url];
//                //开始使用
//            }
//        }];
//    } failureBlock:^(NSError *error) {
//        NSLog(@"Error: %@",error.localizedDescription);
//    }];
    
    
//    iOS Photos库 #import <Photos/Photos.h>
//    PHPhotoLibrary *library = [PHPhotoLibrary sharedPhotoLibrary];
//    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
//    for (PHAssetCollection *collection in collectionResult) {
//        PHFetchResult<PHAsset *> *assetResult = [PHAsset fetchAssetsInAssetCollection:collection options:0];
//        for (PHAsset *asset in assetResult) {
//            //异步的
//            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:option resultHandler:^(AVAsset * avasset, AVAudioMix * audioMix, NSDictionary * info) {
//
//            }];
//        }
//    }

    
//    iOS iPod库 #import <MediaPlayer/MediaPlayer.h>
    //在Foo Fighters的In Your Honor唱片中查找Best of You
//    MPMediaPropertyPredicate *artistPredicate = [MPMediaPropertyPredicate predicateWithValue:@"Foo Fighters" forProperty:MPMediaItemPropertyArtist];
//    MPMediaPropertyPredicate *albumPredicate = [MPMediaPropertyPredicate predicateWithValue:@"In Your Honor" forProperty:MPMediaItemPropertyAlbumTitle];
//    MPMediaPropertyPredicate *songPredicate = [MPMediaPropertyPredicate predicateWithValue:@"Best of You" forProperty:MPMediaItemPropertyTitle];
//    MPMediaQuery *query = [[MPMediaQuery alloc]init];
//    [query addFilterPredicate:artistPredicate];
//    [query addFilterPredicate:albumPredicate];
//    [query addFilterPredicate:songPredicate];
//    NSArray *results = [query items];
//    if (results.count > 0) {
//        MPMediaItem *item = results[0];
//        NSURL *assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
//        AVAsset *asset = [AVAsset assetWithURL:assetURL];
//    }
    
//    Mac iTunes库
//    iTunesLibrary
    
//    异步载入属性
//    NSURL *assetURL = [[NSBundle mainBundle]URLForResource:@"sunset" withExtension:@"mov"];
//    AVAsset *asset = [AVAsset assetWithURL:assetURL];
//
//    NSArray *keys = @[@"tracks"];//即使是多个属性，回调也只执行一次，要为每个属性分别调用statusOfValueForKey
//    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
//        //如果要更新UI,记得先切回主队列
//        NSError *error = nil;
//        AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
//        switch (status) {
//            case AVKeyValueStatusLoaded:
//                //可以获取到该属性了
//                break;
//            case AVKeyValueStatusFailed:
//                break;
//            case AVKeyValueStatusCancelled:
//                break;
//            default:
//                break;
//        }
//    }];

//    元数据
//    NSURL *assetURL = [[NSBundle mainBundle]URLForResource:@"nier" withExtension:@"mp3"];
//    AVAsset *asset = [AVAsset assetWithURL:assetURL];
//    NSArray *keys = @[@"availableMetadataFormats"];
//    NSMutableArray *metadata = [NSMutableArray array];
//    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
//        for (NSString *format in asset.availableMetadataFormats) {
//            [metadata addObjectsFromArray:[asset metadataForFormat:format]];
//        }
//    }];
    //查找元数据
//    NSString *keySpace = AVMetadataKeySpaceiTunes;
//    NSString *artistKey = AVMetadataiTunesMetadataKeyArtist;
//    NSString *albumKey = AVMetadataiTunesMetadataKeyAlbum;
//    NSArray *artistMetadata = [AVMetadataItem metadataItemsFromArray:metadata withKey:artistKey keySpace:keySpace];
//    NSArray *albumMetadata = [AVMetadataItem metadataItemsFromArray:metadata withKey:albumKey keySpace:keySpace];
//    AVMetadataItem *artistItem,*albumItem;
//    if (artistMetadata.count > 0) {
//        artistItem = artistMetadata[0];
//    }
//    if (albumMetadata.count > 0) {
//        albumItem = albumMetadata[0];
//    }
    
    //章元数据
//    NSURL *url = nil;
//    AVAsset *asset = [AVAsset assetWithURL:url];
//    NSString *key = @"availableChapterLocales";
//    [asset loadValuesAsynchronouslyForKeys:@[key] completionHandler:^{
//        AVKeyValueStatus status = [asset statusOfValueForKey:key error:nil];
//        if (status == AVKeyValueStatusLoaded) {
//            NSArray *langs = [NSLocale preferredLanguages];
//            NSArray *chapterMetadata = [asset chapterMetadataGroupsBestMatchingPreferredLanguages:langs];
//            AVTimedMetadataGroup
//        }
//    }];
    
    //使用AVMetadataItem
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        for (AVMetadataItem *item in metadata) {
//            NSLog(@"%@:%@",item.key,item.value);
//        }
//    });
}
//MetaManager案例 查看并编辑元数据
- (void)metaManager {
    MetaManagerViewController *vc = [[MetaManagerViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

//AVPlayerDemo
- (void)AVPlayerDemo {
    AVPlayerDemoViewController *vc = [[AVPlayerDemoViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

//显示字幕
- (void)zimu {
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Charlie The Unicorn" ofType:@"m4v"];
    NSURL *URL = [NSURL fileURLWithPath:path];
    AVAsset *asset = [AVAsset assetWithURL:URL];
    NSArray *mediaCharacteristics = asset.availableMediaCharacteristicsWithMediaSelectionOptions;
    for (NSString *characteristic in mediaCharacteristics) {
        AVMediaSelectionGroup *group = [asset mediaSelectionGroupForMediaCharacteristic:characteristic];
        NSLog(@"[%@]",characteristic);
        for (AVMediaSelectionOption *option in group.options) {
            NSLog(@"Option: %@",option.displayName);
        }
    }
//    //显示俄文字幕
//    AVMediaSelectionGroup *group = [asset mediaSelectionGroupForMediaCharacteristic:characteristic];
//    NSLocale *russianLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
//    NSArray *options = [AVMediaSelectionGroup mediaSelectionOptionsFromArray:group.options withLocale:russianLocale];
//    AVMediaSelectionOption *option = [options firstObject];
//    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
//    [playerItem selectMediaOption:option inMediaSelectionGroup:group];
    
    //设置字幕流程
//    NSArray *keys = @[
//                      @"tracks",
//                      @"duration",
//                      @"commonMetadata",
//                      @"availableMediaCharacteristicsWithMediaSelectionOptions"
//                      ];
//    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset          // 2
//                           automaticallyLoadedAssetKeys:keys];
}

//- (void)loadMediaOptions {
//    NSString *mc = AVMediaCharacteristicLegible;                            // 1
//    AVMediaSelectionGroup *group =
//    [self.asset mediaSelectionGroupForMediaCharacteristic:mc];          // 2
//    if (group) {
//        NSMutableArray *subtitles = [NSMutableArray array];                 // 3
//        for (AVMediaSelectionOption *option in group.options) {
//            [subtitles addObject:option.displayName];
//        }
//        [self.transport setSubtitles:subtitles];                            // 4
//    } else {
//        [self.transport setSubtitles:nil];
//    }
//}
//
//- (void)subtitleSelected:(NSString *)subtitle {
//    NSString *mc = AVMediaCharacteristicLegible;
//    AVMediaSelectionGroup *group =
//    [self.asset mediaSelectionGroupForMediaCharacteristic:mc];          // 1
//    BOOL selected = NO;
//    for (AVMediaSelectionOption *option in group.options) {
//        if ([option.displayName isEqualToString:subtitle]) {
//            [self.playerItem selectMediaOption:option                       // 2
//                         inMediaSelectionGroup:group];
//            selected = YES;
//        }
//    }
//    if (!selected) {
//        [self.playerItem selectMediaOption:nil                              // 3
//                     inMediaSelectionGroup:group];
//    }
//}

///AirPlay
- (void)AirPlay {
//    #import <MediaPlayer/MediaPlayer.h>
    MPVolumeView *volumeView = [[MPVolumeView alloc]initWithFrame:CGRectMake(50, 150, 200, 200)];
    volumeView.showsVolumeSlider = YES;
    [self.view addSubview:volumeView];
}

///AVKit
- (void)AVPlayerViewControllerDemo {
//    #import <AVKit/AVKit.h>
    NSURL *URL = [[NSBundle mainBundle]URLForResource:@"Charlie The Unicorn" withExtension:@"m4v"];
    AVPlayerViewController *controller = [[AVPlayerViewController alloc]init];
    controller.player = [AVPlayer playerWithURL:URL];
    [self.navigationController pushViewController:controller animated:YES];
}
///相机示例
- (void)kamera {
    OMCameraViewController *vc = [[OMCameraViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}
///CMTime
- (void)CMTimeDemo {
    //3秒的不同形式
    CMTime t1 = CMTimeMake(3, 1);//{3/1 = 3.000}
    CMTime t2 = CMTimeMake(1800, 600);
    CMTime t3 = CMTimeMake(3000, 1000);
    //打印
    CMTimeShow(t1);
    //时间想加减
    CMTime time1 = CMTimeMake(5, 1);
    CMTime time2 = CMTimeMake(3, 1);
    CMTime result;
    result = CMTimeAdd(time1, time2);
    CMTimeShow(result);
    result = CMTimeSubtract(time1, time2);
    CMTimeShow(result);
    //时间轴的5秒开始，持续5秒
    CMTime fiveSecondsTime = CMTimeMake(5, 1);
    CMTimeRange timeRange = CMTimeRangeMake(fiveSecondsTime, fiveSecondsTime);
    CMTimeRangeShow(timeRange);
    //另一种方式创建CMTimeRange
    CMTime fiveSeconds = CMTimeMake(5, 1);
    CMTime tenSenconds = CMTimeMake(10, 1);
    CMTimeRange timeRange1 = CMTimeRangeFromTimeToTime(fiveSeconds, tenSenconds);
    CMTimeRangeShow(timeRange1);
    //获取交集和并集
    CMTimeRange range1 = CMTimeRangeMake(kCMTimeZero, CMTimeMake(5, 1));
    CMTimeRange range2 = CMTimeRangeMake(CMTimeMake(2, 1), CMTimeMake(5, 1));
    CMTimeRange intersectionRange = CMTimeRangeGetIntersection(range1, range2);
    CMTimeRange unionRange = CMTimeRangeGetUnion(range1, range2);
    
}

- (AVAsset *)prepareAssetWithName:(NSString *)name ext:(NSString *)ext completionHandler:(nullable void (^)(void))handler {
    NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:ext];
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};//确保载入时计算出准确的时长和时间信息
    AVAsset *asset = [AVURLAsset URLAssetWithURL:url options:options];
    NSArray *keys = @[@"tracks",@"duration",@"commonMetadata"];
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:handler];
    return asset;
}

/// 媒体组合
- (void)zuhe {
    AVAsset *goldGateAsset = [self prepareAssetWithName:@"test1" ext:@"mp4" completionHandler:nil];
    AVAsset *teaGardenAsset = [self prepareAssetWithName:@"test2" ext:@"mp4" completionHandler:nil];
    AVAsset *soundtrackAsset = [self prepareAssetWithName:@"nier" ext:@"mp3" completionHandler:nil];

    sleep(3);
    NSLog(@"开始组合。。。。");
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];

    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    CMTime cursorTime = kCMTimeZero;

    CMTime videoDuration = CMTimeMake(5, 1);
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoDuration);

    AVAssetTrack *assetTrack = [[goldGateAsset tracksWithMediaType:AVMediaTypeVideo]firstObject];
    [videoTrack insertTimeRange:videoTimeRange ofTrack:assetTrack atTime:cursorTime error:nil];
    cursorTime = CMTimeAdd(cursorTime, videoDuration);

    assetTrack = [[teaGardenAsset tracksWithMediaType:AVMediaTypeVideo]firstObject];
    [videoTrack insertTimeRange:videoTimeRange ofTrack:assetTrack atTime:cursorTime error:nil];

    cursorTime = kCMTimeZero;
    CMTime audioDuration = composition.duration;
    CMTime audioStart = CMTimeMake(42, 1);
    CMTimeRange audioTimeRange = CMTimeRangeMake(audioStart, audioDuration);

    assetTrack = [[soundtrackAsset tracksWithMediaType:AVMediaTypeAudio]firstObject];
    [audioTrack insertTimeRange:audioTimeRange ofTrack:assetTrack atTime:cursorTime error:nil];

    NSLog(@"开始导出.....");
    //导出
    NSString *preset = AVAssetExportPreset1280x720;
    self.exportSession = [[AVAssetExportSession alloc]initWithAsset:composition presetName:preset];
//    NSLog(@"%@", [self.exportSession.supportedFileTypes firstObject]);
    self.exportSession.timeRange = CMTimeRangeMake(cursorTime, audioDuration);
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    NSURL *url = [NSURL fileURLWithPath:@"/Users/shentuyunfei/Downloads/mytest.mp4"];
    if (url) {
        NSLog(@"文件路径正确");
    }else{
        NSLog(@"文件路径不正确");
    }
    self.exportSession.outputURL = url;
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus status = self.exportSession.status;
        if (status == 4) {
            NSLog(@"error:%@",self.exportSession.error);
        }
        NSLog(@"导出结束...");
    }];
}
///混音
- (void)mix {
    AVCompositionTrack *track = nil;
    CMTime twoSeconds = CMTimeMake(2, 1);
    CMTime fourSeconds = CMTimeMake(4, 1);
    CMTime sevenSeconds = CMTimeMake(7, 1);
    AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
    [parameters setVolume:0.5 atTime:kCMTimeZero];
    CMTimeRange range = CMTimeRangeFromTimeToTime(twoSeconds, fourSeconds);
    [parameters setVolumeRampFromStartVolume:0.5f toEndVolume:0.8f timeRange:range];
    [parameters setVolume:0.3f atTime:sevenSeconds];
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = @[parameters];
    //使用
    AVPlayerItem *playerItem = nil;
    playerItem.audioMix = audioMix;
    //或者
    AVAssetExportSession *session = nil;
    session.audioMix = audioMix;
}
///视频过渡动画
- (void)guodu {
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *trackA = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *trackB = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    NSArray *videoTracks = @[trackA,trackB];
    
    AVAsset *asset1 = [self prepareAssetWithName:@"test1" ext:@"mp4" completionHandler:nil];
    AVAsset *asset2 = [self prepareAssetWithName:@"test2" ext:@"mp4" completionHandler:nil];
    AVAsset *asset3 = [self prepareAssetWithName:@"test3" ext:@"mp4" completionHandler:nil];
    NSArray *videoAssets = @[asset1,asset2,asset3];

    //添加到媒体组合
    CMTime cursorTime = kCMTimeZero;
    CMTime transitionDuration = CMTimeMake(2, 1);//定义重叠区域
    for (NSUInteger i = 0; i < videoAssets.count; i++) {
        NSUInteger trackIndex = i % 2;
        AVMutableCompositionTrack *currentTrack = videoTracks[trackIndex];
        
        AVAsset *asset = videoAssets[i];
        AVAssetTrack *assetTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
        [currentTrack insertTimeRange:timeRange ofTrack:assetTrack atTime:cursorTime error:nil];
        
        cursorTime = CMTimeAdd(cursorTime, timeRange.duration);
        cursorTime = CMTimeSubtract(cursorTime, transitionDuration);//重叠2秒
    }
    
    //加点音乐
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAsset *soundtrackAsset = [self prepareAssetWithName:@"test" ext:@"mp3" completionHandler:nil];
    AVAssetTrack *assetTrack = [[soundtrackAsset tracksWithMediaType:AVMediaTypeAudio]firstObject];
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, composition.duration) ofTrack:assetTrack atTime:kCMTimeZero error:nil];
    
    //计算通过和过渡的时间范围
    cursorTime = kCMTimeZero;
    NSMutableArray *passThroughTimeRanges = @[].mutableCopy;
    NSMutableArray *transitionTimeRanges = @[].mutableCopy;
    NSUInteger videoCount = [videoAssets count];
    for (NSUInteger i = 0; i < videoCount; i++) {
        AVAsset *asset = videoAssets[i];
        CMTimeRange timeRange = CMTimeRangeMake(cursorTime, asset.duration);
        if (i > 0) {
            timeRange.start = CMTimeAdd(timeRange.start, transitionDuration);
            timeRange.duration = CMTimeSubtract(timeRange.duration, transitionDuration);
        }
        
        if (i + 1 < videoCount) {
            timeRange.duration = CMTimeSubtract(timeRange.duration, transitionDuration);
        }
        [passThroughTimeRanges addObject:[NSValue valueWithCMTimeRange:timeRange]];
        cursorTime = CMTimeAdd(cursorTime, asset.duration);
        cursorTime = CMTimeSubtract(cursorTime, transitionDuration);
        
        if (i + 1 < videoCount) {
            timeRange = CMTimeRangeMake(cursorTime, transitionDuration);
            NSValue *timeRangeValue = [NSValue valueWithCMTimeRange:timeRange];
            [transitionTimeRanges addObject:timeRangeValue];
        }
    }
    
    //创建组合和层指令
    NSMutableArray *compositionInstructions = [NSMutableArray array];
    NSArray *tracks = [composition tracksWithMediaType:AVMediaTypeVideo];
    for (NSUInteger i = 0; i < passThroughTimeRanges.count; i++) {
        NSUInteger trackIndex = i % 2;
        AVMutableCompositionTrack * currentTrack = tracks[trackIndex];
        
        AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        instruction.timeRange = [passThroughTimeRanges[i] CMTimeRangeValue];
        
        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:currentTrack];
        instruction.layerInstructions = @[layerInstruction];
        
        [compositionInstructions addObject:instruction];
        
        if (i < transitionTimeRanges.count) {
            AVCompositionTrack *foregroundTrack = tracks[trackIndex];
            AVCompositionTrack *backgroundTrack = tracks[1 - trackIndex];
            
            AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            CMTimeRange timeRange = [transitionTimeRanges[i] CMTimeRangeValue];
            instruction.timeRange = timeRange;
            
            AVMutableVideoCompositionLayerInstruction *fromLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:foregroundTrack];
            AVMutableVideoCompositionLayerInstruction *toLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:backgroundTrack];
            //push效果
            CGAffineTransform identityTransform = CGAffineTransformIdentity;
            CGFloat videoWidth = 540.0f;
            CGAffineTransform fromDestTransform = CGAffineTransformMakeTranslation(-videoWidth, 0);
            CGAffineTransform toStartTransform = CGAffineTransformMakeTranslation(videoWidth, 0);
            [fromLayerInstruction setTransformRampFromStartTransform:identityTransform toEndTransform:fromDestTransform timeRange:timeRange];
            [toLayerInstruction setTransformRampFromStartTransform:toStartTransform toEndTransform:identityTransform timeRange:timeRange];
            
            instruction.layerInstructions = @[fromLayerInstruction,toLayerInstruction];
            
            [compositionInstructions addObject:instruction];
        }
    }
    
    //创建和配置AVVideoComposition
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.instructions = compositionInstructions;
    videoComposition.renderSize = CGSizeMake(540.f, 960.f);
    videoComposition.frameDuration = CMTimeMake(1, 30);//30FPS
    videoComposition.renderScale = 1.0f;//视频组合应用的缩放，大部分情况设置1.0
    //创建AVVideoComposition的简便方法
//    videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:<#(nonnull AVAsset *)#>]
    
    //使用
//    playerItem.videoComposition = self.videoComposition;
//    exportSession.videoComposition = self.videoComposition;
    
    //导出
    NSString *preset = AVAssetExportPreset960x540;
    self.exportSession = [[AVAssetExportSession alloc]initWithAsset:composition presetName:preset];
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    self.exportSession.videoComposition = videoComposition;
    NSURL *url = [NSURL fileURLWithPath:@"/Users/shentuyunfei/Downloads/mytest.mp4"];
    if (url) {
        NSLog(@"文件路径正确");
    }else{
        NSLog(@"文件路径不正确");
    }
    self.exportSession.outputURL = url;
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus status = self.exportSession.status;
        if (status == 4) {
            NSLog(@"error:%@",self.exportSession.error);
        }
        NSLog(@"导出结束...");
    }];

}
@end
