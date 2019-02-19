//
//  FXYAlbumModel.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/19.
//  Copyright © 2019 styf. All rights reserved.
//

#import "FXYAlbumModel.h"
#import "FXYImageManager.h"
#import "FXYAssetModel.h"
@implementation FXYAlbumModel
- (void)setResult:(PHFetchResult *)result needFetchAssets:(BOOL)needFetchAssets {
    _result = result;
    if (needFetchAssets) {
        [[FXYImageManager manager] getAssetsFromFetchResult:result completion:^(NSArray<FXYAssetModel *> *models) {
            self->_models = models;
            if (self->_selectedModels) {
                [self checkSelectedModels];
            }
        }];
    }
}

- (void)setSelectedModels:(NSArray *)selectedModels {
    _selectedModels = selectedModels;
    if (_models) {
        [self checkSelectedModels];
    }
}

/**
 计算该相册中选中的数量
 */
- (void)checkSelectedModels {
    self.selectedCount = 0;
    NSMutableArray *selectedAssets = [NSMutableArray array];
    for (FXYAssetModel *model in _selectedModels) {
        [selectedAssets addObject:model.asset];
    }
    for (FXYAssetModel *model in _models) {
        if ([selectedAssets containsObject:model.asset]) {
            self.selectedCount ++;
        }
    }
}

- (NSString *)name {
    if (_name) {
        return _name;
    }
    return @"";
}
@end
