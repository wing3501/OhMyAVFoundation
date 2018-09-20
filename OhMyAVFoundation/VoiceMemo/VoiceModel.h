//
//  VoiceModel.h
//  OhMyAVFoundation
//
//  Created by 申屠云飞 on 2018/8/30.
//  Copyright © 2018年 styf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoiceModel : NSObject
/// <#name#>
@property (nonatomic,copy) NSString *name;
/// <#name#>
@property (nonatomic,copy) NSString *date;
/// <#name#>
@property (nonatomic,copy) NSString *time;
/// <#name#>
@property (nonatomic,strong) NSURL *url;
@end
