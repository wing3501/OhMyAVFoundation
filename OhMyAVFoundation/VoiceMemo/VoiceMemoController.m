//
//  VoiceMemoController.m
//  OhMyAVFoundation
//
//  Created by 申屠云飞 on 2018/8/29.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "VoiceMemoController.h"
#import "VoiceCell.h"
#import "VoiceModel.h"
#import "MeterTable.h"
#import "LevelPair.h"
@interface VoiceMemoController ()<AVAudioRecorderDelegate>
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
/// 数据
@property (nonatomic,strong) NSMutableArray *dataArray;

@property (nonatomic,strong) AVAudioPlayer *player;
@property (nonatomic,strong) AVAudioRecorder *recorder;
/// 正在录音
@property (nonatomic,assign) BOOL isRecording;
/// 计时定时器
@property (nonatomic,strong) NSTimer *timer;
/// 分贝定时器
@property (nonatomic,strong) CADisplayLink *levelTimer;
/// 分贝线性表
@property (nonatomic,strong) MeterTable *meterTable;
@end

@implementation VoiceMemoController
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSString *tmpDir = NSTemporaryDirectory();
        NSString *filePath = [tmpDir stringByAppendingPathComponent:@"memo.caf"];
        NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
        
        NSDictionary *settings = @{
                                   AVFormatIDKey : @(kAudioFormatAppleIMA4),
                                   AVSampleRateKey : @44100.0f,
                                   AVNumberOfChannelsKey : @1,
                                   AVEncoderBitDepthHintKey : @16,
                                   AVEncoderAudioQualityKey : @(AVAudioQualityMedium)
                                   };
        NSError *error;
        self.recorder = [[AVAudioRecorder alloc]initWithURL:fileUrl settings:settings error:&error];
        if (self.recorder) {
            self.recorder.delegate = self;
            [self.recorder prepareToRecord];
        }else{
            NSLog(@"Error: %@",[error localizedDescription]);
        }
        
        _meterTable = [[MeterTable alloc]init];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [_tableView registerNib:[UINib nibWithNibName:@"VoiceCell" bundle:nil] forCellReuseIdentifier:@"VoiceCell"];
}
//开始录音或暂停
- (IBAction)recordOrPause:(UIButton *)sender {
    if (_isRecording) {
        _isRecording = NO;
        _recordButton.selected = NO;
        [self stopTimer];
        [self startMeterTimer];
        [_recorder  pause];
    }else{
        _isRecording = YES;
        _recordButton.selected = YES;
        [self startTimer];
        [self stopMeterTimer];
        [_recorder record];
    }
}

- (IBAction)stop:(UIButton *)sender {
    [self.recorder stop];
    [self saveRecording];
}

/**
 保存录音
 */
- (void)saveRecording {
    NSTimeInterval timestamp = [NSDate timeIntervalSinceReferenceDate];
    NSString *filename = [NSString stringWithFormat:@"%f.caf",timestamp];
    NSString *docsDir = [self documentsDirectory];
    NSString *destPath = [docsDir stringByAppendingPathComponent:filename];
    NSURL *srcURL = self.recorder.url;
    NSURL *destURL = [NSURL fileURLWithPath:destPath];
    
    NSError *error;
    BOOL success = [[NSFileManager defaultManager]copyItemAtURL:srcURL toURL:destURL error:&error];
    if (success) {
        [self.recorder prepareToRecord];
        //添加到列表
        VoiceModel *model = [[VoiceModel alloc]init];
        model.name = filename;
        model.url = destURL;
        NSDate *date = [NSDate date];
        model.date = [self dateStringWithDate:date];
        model.time = [self timeStringWithDate:date];
        [self.dataArray addObject:model];
        [self.tableView reloadData];
    }else{
        NSLog(@"Save Error: %@",error.localizedDescription);
    }
}

- (void)startTimer {
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(updateTimeDisplay) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)updateTimeDisplay {
    self.timeLabel.text = [self formattedCurrentTime];
}

- (void)startMeterTimer {
    [self.levelTimer invalidate];
    self.levelTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeter)];
//    可以根据需要调整指定方法的调用频率，只要修改 CADisplayLink 的属性 frameInterval 或 preferredFramesPerSecond 值即可。但是，frameInterval（已废弃）的值指的是刷新多少次才触发一次刷新方法，如设置该值为 5 ，那么对于 60Hz 的屏幕刷新频率而言，刷新方法的调用频率为 12Hz 。preferredFramesPerSecond 则是直接表示指定方法每秒钟的调用次数，即帧的刷新频率。
    self.levelTimer.preferredFramesPerSecond = 12;
    [self.levelTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopMeterTimer {
    [self.levelTimer invalidate];
    self.levelTimer = nil;
}

- (void)updateMeter {
    LevelPair *levels = [self levels];
    NSLog(@"当前分贝========>%@",levels);
}

- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

- (NSString *)dateStringWithDate:(NSDate *)date {
    NSDateFormatter *formatter = [self formatterWithFormat:@"MMddyyyy"];
    return [formatter stringFromDate:date];
}

- (NSString *)timeStringWithDate:(NSDate *)date {
    NSDateFormatter *formatter = [self formatterWithFormat:@"HHmmss"];
    return [formatter stringFromDate:date];
}

- (NSDateFormatter *)formatterWithFormat:(NSString *)template {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    NSString *format = [NSDateFormatter dateFormatFromTemplate:template options:0 locale:[NSLocale currentLocale]];
    [formatter setDateFormat:format];
    return formatter;
}

- (NSString *)formattedCurrentTime {
    NSUInteger time = self.recorder.currentTime;
    NSInteger hours = (time / 3600);
    NSInteger minutes = (time / 60) % 60;
    NSInteger seconds = time % 60;
    NSString *format = @"%02i:%02i:%02i";
    return [NSString stringWithFormat:format,hours,minutes,seconds];
}

/**
 获取当前分贝等级

 */
- (LevelPair *)levels {
    [self.recorder updateMeters];//一定要在读取当前等级值之前调用,以保证读取的级别是最新的
    float avgPower = [self.recorder averagePowerForChannel:0];//单声道
    float peakPower = [self.recorder peakPowerForChannel:0];//单声道
    float linearLevel = [self.meterTable valueForPower:avgPower];
    float linearPeak = [self.meterTable valueForPower:peakPower];
    LevelPair *levelPair = [[LevelPair alloc]init];
    levelPair.level = linearLevel;
    levelPair.peakLevel = linearPeak;
    return levelPair;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoiceCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.voiceModel = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VoiceModel *voiceModel = self.dataArray[indexPath.row];
    [self.player stop];
    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:voiceModel.url error:nil];
    if (self.player) {
        [self.player play];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark - AVAudioRecorderDelegate

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[].mutableCopy;
    }
    return _dataArray;
}
@end
