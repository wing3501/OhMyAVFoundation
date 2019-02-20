//
//  FXYAlbumCell.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/20.
//  Copyright © 2019 styf. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FXYAlbumModel;
@interface FXYAlbumCell : UITableViewCell
@property (nonatomic, strong) FXYAlbumModel *model;
@property (nonatomic, weak) UIButton *selectedCountButton;
@end


