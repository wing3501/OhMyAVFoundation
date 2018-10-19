//
//  OMCircleProgressView.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/15.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "OMCircleProgressView.h"

static NSTimeInterval const kTimelimit = 15.0;

@interface OMCircleProgressView()
/// 白色视图
@property (nonatomic,strong) UIView *whiteView;
/// 单击手势
@property (nonatomic,strong) UITapGestureRecognizer *tapGestureRecognizer;
/// 长按手势
@property (nonatomic,strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
/// 定时器
@property (nonatomic,strong) NSTimer *timer;
/// 计时
@property (nonatomic,assign) NSTimeInterval timeCount;
@end

@implementation OMCircleProgressView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

/**
 初始化
 */
- (void)commonInit {
    [self setupUI];
    
}

/**
 设置视图
 */
- (void)setupUI {
    self.backgroundColor = [UIColor grayColor];
    self.layer.cornerRadius = self.frame.size.width * 0.5;
    self.layer.masksToBounds = YES;

    [self addSubview:self.whiteView];
    [self addGestureRecognizer:self.tapGestureRecognizer];
    [self addGestureRecognizer:self.longPressGestureRecognizer];
}

#pragma mark - overwrite

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    if (_timeCount) {
        CGFloat progress = _timeCount / kTimelimit;
        CGContextRef ctx = UIGraphicsGetCurrentContext();//获取上下文
        CGPoint center = self.whiteView.center;  //设置圆心位置
        CGFloat radius = self.whiteView.center.x - 5;  //设置半径
        CGFloat startA = -M_PI_2;  //圆起点位置
        CGFloat endA = -M_PI_2 + M_PI * 2 * progress;  //圆终点位置

        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
        CGContextSetLineWidth(ctx, 10); //设置线条宽度
        [[UIColor greenColor] setStroke]; //设置描边颜色
        CGContextAddPath(ctx, path.CGPath); //把路径添加到上下文
        CGContextStrokePath(ctx);  //渲染
    }
}
#pragma mark - public

#pragma mark - notification

#pragma mark - event response

/**
 单击事件
 */
- (void)singleTap:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(progressViewDidSingleTap:)]) {
        [self.delegate progressViewDidSingleTap:self];
    }
}

/**
 长按事件
 */
- (void)longPress:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        //开始动画
        [UIView animateWithDuration:0.2 animations:^{
            self.transform = CGAffineTransformMakeScale(1.4, 1.4);
            self.whiteView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        }];
        _timeCount = 0;
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
        if ([self.delegate respondsToSelector:@selector(progressViewBeganLongPress:)]) {
            [self.delegate progressViewBeganLongPress:self];
        }
    }else if (sender.state == UIGestureRecognizerStateChanged) {
        //更新动画进度中
    }else if (sender.state == UIGestureRecognizerStateEnded) {
        //动画结束
        [self stopCountDown];
        [self setNeedsDisplay];
    }
}

/**
 定时器倒数计时
 */
- (void)countdown {
    _timeCount += 0.1;
    if (_timeCount >= kTimelimit) {
        [self stopCountDown];
    }
    
    [self setNeedsDisplay];
}
#pragma mark - private

/**
 停止计时
 */
- (void)stopCountDown {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }else{
        return;
    }
     _timeCount = 0;
    //动画结束
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformIdentity;
        self.whiteView.transform = CGAffineTransformIdentity;
    }];
    
    if ([self.delegate respondsToSelector:@selector(progressViewStopCountDown:)]) {
        [self.delegate progressViewStopCountDown:self];
    }
}

#pragma mark - getter and setter

- (UIView *)whiteView {
    if (!_whiteView) {
        CGFloat width = self.bounds.size.width * 0.7;
        _whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, width)];
        _whiteView.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
        _whiteView.backgroundColor = [UIColor whiteColor];
        _whiteView.layer.cornerRadius = width * 0.5;
        _whiteView.layer.masksToBounds = YES;
    }
    return _whiteView;
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    }
    return _tapGestureRecognizer;
}

- (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (!_longPressGestureRecognizer) {
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    }
    return _longPressGestureRecognizer;
}
@end
