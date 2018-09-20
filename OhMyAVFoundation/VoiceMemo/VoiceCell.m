//
//  VoiceCell.m
//  OhMyAVFoundation
//
//  Created by 申屠云飞 on 2018/8/29.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "VoiceCell.h"
@interface VoiceCell()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
@implementation VoiceCell

- (void)setVoiceModel:(VoiceModel *)voiceModel {
    _voiceModel = voiceModel;
    self.textLabel.text = voiceModel.name;
    self.dateLabel.text = voiceModel.date;
    self.dateLabel.text = voiceModel.time;
}

@end
