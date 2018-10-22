//
//  OMVideoListViewController.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/22.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "OMVideoListViewController.h"
#import "OMVideoModel.h"
@interface OMVideoListViewController ()<UITableViewDelegate,UITableViewDataSource>
/// 列表
@property (nonatomic,strong) UITableView *tableView;
/// 数据
@property (nonatomic,strong) NSMutableArray *dataArray;
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataArray[indexPath.section];
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
@end
