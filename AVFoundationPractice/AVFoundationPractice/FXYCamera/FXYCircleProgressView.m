//
//  FXYCircleProgressView.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/15.
//  Copyright © 2019 styf. All rights reserved.
//

#import "FXYCircleProgressView.h"

static NSTimeInterval const kTimelimit = 15.0;

@interface FXYCircleProgressView(){
    CFTimeInterval beginTime;
    CFTimeInterval progressTime;
    CFTimeInterval tempTime;
}
/// 白色视图
@property (nonatomic,strong) UIView *whiteView;
/// 单击手势
@property (nonatomic,strong) UITapGestureRecognizer *tapGestureRecognizer;
/// 定时器
@property (nonatomic,strong) CADisplayLink *displayLink;
/// 进度动画
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end
@implementation FXYCircleProgressView

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
    self.layer.cornerRadius = self.frame.size.width * 0.5;
    self.layer.masksToBounds = YES;
    
    [self addSubview:self.whiteView];
    [self.whiteView.layer addSublayer:self.shapeLayer];
    [self addGestureRecognizer:self.tapGestureRecognizer];
}

#pragma mark - overwrite

#pragma mark - public

#pragma mark - notification

#pragma mark - event response

/**
 单击事件
 */
- (void)singleTap:(UITapGestureRecognizer *)sender {
    if (!self.displayLink.paused) {
        //暂停
        self->tempTime = self->progressTime;
    }else{
        //开始
        self->beginTime = CACurrentMediaTime();
        if (self->tempTime > 0) {
            self->beginTime -= self->tempTime;
            self->tempTime = 0;
        }
    }
    self.displayLink.paused = !self.displayLink.paused;
}

/**
 更新动画
 */
- (void)updateContent {
    self->progressTime = CACurrentMediaTime() - self->beginTime;
    CGFloat progress = self->progressTime / kTimelimit;
//    CGPoint center = ;  //设置圆心位置
//    CGFloat radius = ;  //设置半径
//    CGFloat startA = ;  //圆起点位置
//    CGFloat endA = ;  //圆终点位置
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.shapeLayer.center radius:self.shapeLayer.center.x - 5 startAngle:-M_PI_2 endAngle:-M_PI_2 + M_PI * 2 * progress clockwise:YES];
    self.shapeLayer.path = path.CGPath;
    if (progress >= 1) {
        self.displayLink.paused = YES;
    }
}
#pragma mark - private

#pragma mark - getter and setter

- (UIView *)whiteView {
    if (!_whiteView) {
        CGFloat width = self.bounds.size.width;
        _whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, width)];
        _whiteView.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
        _whiteView.backgroundColor = [UIColor redColor];
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

- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateContent)];
        _displayLink.paused = YES;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.strokeColor = [UIColor greenColor].CGColor;
        _shapeLayer.lineWidth = 3;
        _shapeLayer.frame = self.whiteView.bounds;
        _shapeLayer.fillColor = [UIColor redColor].CGColor;
    }
    return _shapeLayer;
}
@end
