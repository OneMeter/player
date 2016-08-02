//
//  ZJCCourceCatalogueView.m
//  CCRA
//
//  Created by htkg on 16/3/29.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCCourceCatalogueView.h"
#import "CircleProgressView.h"
#import "ZJCCourceCatelogueTableViewCell.h"

//#import "ZJCPracticeTestsViewController.h"
//#import "ZJCNewPracticeTestsViewController.h"   // 新版的练习题界面


#import "ZJCButtonWithEdgeBottomLine.h"



@interface ZJCCourceCatalogueView ()

@property (nonatomic ,strong) ZJCCourceCatalogueModel * model;

@property (nonatomic ,strong) ZJCButtonWithEdgeBottomLine * sectionBackView;           // 头视图底板
@property (nonatomic ,strong) UIView * sectionBackMatte;                               // 头视图蒙版(选中状态用的)
@property (nonatomic ,strong) UILabel * titleLabel;               // 课程名称     
@property (nonatomic ,strong) UILabel * timeLabel;                // 课程时间   
@property (nonatomic ,strong) UILabel * statusLabel;              // 缓冲状态
@property (nonatomic ,strong) UIButton * testButton;              // 练习题按钮
@property (nonatomic ,strong) CircleProgressView * progressView;  // 圆形进度条

@property (nonatomic ,strong) UIButton * downListButton;          // 下载列表 按钮


@end





@implementation ZJCCourceCatalogueView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        // 初始化
        if (_dataSource == nil) {
            _dataSource = [NSMutableArray array];
        }
        
        // 配置自己
        [self configSelf];
    }
    return self;
}



/**
 初始化
 */
- (void)configSelf{
    self.backgroundColor = [UIColor whiteColor];
    //    _mySelectIndex.isSection = YES;
    //    _mySelectIndex.row = 100000;
    //    _mySelectIndex.section = 10000;
}




/**
 加载数据
 */
- (void)setDataSource:(NSMutableArray *)dataSource{
    _dataSource = dataSource;
    
    // 搭建展示表格
    if (self.tableView == nil) {
        [self createTableView];
    }else{
        [self.tableView reloadData];
    }
    // 底部下载缓存列表按钮
    //    [self createDownListButton];
}







#pragma mark - 展示表格
- (void)createTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor whiteColor];
    // 注册cell
    [_tableView registerClass:[ZJCCourceCatelogueTableViewCell class] forCellReuseIdentifier:@"aCell"];
    [self addSubview:_tableView];
    
    
    
    // 添加刷新控件
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    ZJCCourceCatalogueModel * model = _dataSource[section];
    return model.son.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    ZJCCourceCatalogueModel * model = _dataSource[section];
    int height = 0;
    if (model.son.count != 0) {
        height = [ZJCFrameControl GetControl_Y:140] + 1;
        return height;
    }else{
        height = [ZJCFrameControl GetControl_height:230] + 1;
        return height;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ZJCFrameControl GetControl_Y:206];
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //static NSString *ID = @"ID";
    ZJCCourceCatelogueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"aCell"];
    if (!cell) {
        cell = [[ZJCCourceCatelogueTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"aCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0);
    ZJCCourceCatalogueModel * model = _dataSource[indexPath.section];
    ZJCCourceCatalogueSmallModel * smallModel = model.son[indexPath.row];
    if (indexPath.row == (model.son.count - 1)) {
        cell.edgeLineSize = 0;
    }else{
        cell.edgeLineSize = 30;
    }
    cell.cellIndexpath = indexPath;
    NSInteger maxSection = _dataSource.count - 1;
    NSInteger maxRow = [[_dataSource[maxSection] son] count] - 1;
    cell.maxIndexPath = [NSIndexPath indexPathForRow:maxRow inSection:_dataSource.count - 1];
    cell.model = smallModel;
    
    // 蒙板
    ZJCPassValueControlManager * manager = [ZJCPassValueControlManager defaultManager];
    if (manager.isSection == NO && manager.selectSection == indexPath.section && manager.selectRow == indexPath.row) {
        cell.selected = YES;
    }else{
        cell.selected =  NO;
    }
    
    return cell;
}




- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    ZJCCourceCatalogueModel * model = _dataSource[section];
    CGFloat fontsize = 14;
    if (model.son.count == 0) {
        // 底板
        _sectionBackView = [[ZJCButtonWithEdgeBottomLine alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:0], [ZJCFrameControl GetControl_Y:0], [ZJCFrameControl GetControl_weight:1080], (int)[ZJCFrameControl GetControl_height:230])];
        _sectionBackView.backgroundColor = [UIColor whiteColor];
        _sectionBackView.tag = section;
        _sectionBackView.lineEdgeInsetRight = _sectionBackView.width;
        [_sectionBackView addTarget:self action:@selector(sectionBackViewClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView * sectionBackMatte = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _sectionBackView.width, _sectionBackView.height+1)];
        sectionBackMatte.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];
        sectionBackMatte.tag = section + 100;
        
        // 蒙板
        ZJCPassValueControlManager * manager = [ZJCPassValueControlManager defaultManager];
        [_sectionBackView addSubview:sectionBackMatte];
        if (manager.isSection == YES && manager.selectSection == section) {
            sectionBackMatte.hidden = NO;
        }else{
            sectionBackMatte.hidden = YES;
        }
        
        
        // 标题
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:40], [ZJCFrameControl GetControl_Y:90], [ZJCFrameControl GetControl_weight:700], [ZJCFrameControl GetControl_height:45])];
        //    _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.font = [UIFont systemFontOfSize:fontsize];
        _titleLabel.textColor = ZJCGetColorWith(77, 77, 77, 1);
        [_sectionBackView addSubview:_titleLabel];
        _titleLabel.text = model.name;
        
        // 时长
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:40], [ZJCFrameControl GetControl_Y:70+45+35], [ZJCFrameControl GetControl_weight:180], [ZJCFrameControl GetControl_height:40])];
        _timeLabel.textColor = [UIColor grayColor];
        //    _timeLabel.adjustsFontSizeToFitWidth = YES;
        _timeLabel.font = [UIFont systemFontOfSize:11];
        [_sectionBackView addSubview:_timeLabel];
        
        _timeLabel.text = [NSString stringWithFormat:@"%@分钟",model.videoduration];
        
        // 状态
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:40+110+80], [ZJCFrameControl GetControl_Y:70+45+35], [ZJCFrameControl GetControl_weight:160], [ZJCFrameControl GetControl_height:40])];
        _statusLabel.textColor = THEME_BACKGROUNDCOLOR;
        //    _statusLabel.adjustsFontSizeToFitWidth = YES;
        _statusLabel.font = [UIFont systemFontOfSize:11];
        [_sectionBackView addSubview:_statusLabel];
        // 是否已经缓存了
        ZJCFMDBManager * fmdbManager = [ZJCFMDBManager defaultManager];
        NSArray * array = [fmdbManager selectRecordWithMyid:model.id];
        if (array.count != 0) {
            if ([array[0][@"isover"] isEqualToString:@"1"]) {
                _statusLabel.hidden = NO;
                _statusLabel.text = @"已缓存";
            }else{
                _statusLabel.hidden = YES;
            }
        }else{
            _statusLabel.hidden = YES;
        }
        
        
        
        // 练习题按钮
        _testButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _testButton.frame = CGRectMake([ZJCFrameControl GetControl_X:1080-40-78-40-190], [ZJCFrameControl GetControl_Y:120], [ZJCFrameControl GetControl_weight:180], [ZJCFrameControl GetControl_height:65]);
        [_testButton setTitle:@"练习题" forState:UIControlStateNormal];
        if (IPhone4s) {
            _testButton.titleLabel.font = [UIFont systemFontOfSize:9];
        }else {
            _testButton.titleLabel.font = [UIFont systemFontOfSize:13];
        }
        [_testButton setTitleColor:THEME_BACKGROUNDCOLOR forState:UIControlStateNormal];
        if ([model.ispaper isEqualToString:@"1"]) {
            UIImage * imageDown   = [[UIImage imageNamed:@"down_over"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [_testButton setImage:imageDown forState:UIControlStateNormal];
        }else{
            UIImage * imageNormal = [[UIImage imageNamed:@"down_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [_testButton setImage:imageNormal forState:UIControlStateNormal];
        }
        if ([model.eid isEqualToString:@"0"] || [model.eid isEqualToString:@""] || model.eid == nil) {
            _testButton.hidden = YES;
        }else{
            _testButton.hidden = NO;
        }
        
        _testButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        _testButton.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 40);
        _testButton.titleEdgeInsets = UIEdgeInsetsMake(-1, -30, 2, -5);
        _testButton.tag = section + 10;
        [_testButton addTarget:self action:@selector(testButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_sectionBackView addSubview:_testButton];
        
        // 圆形进度条
        _progressView = [[CircleProgressView alloc] init];
        [self.sectionBackView addSubview:_progressView];
        _progressView.backgroundColor = [UIColor clearColor];
        _progressView.arcBackColor = ZJCGetColorWith(229, 229, 229, 1);
        _progressView.arcFinishColor = ZJCGetColorWith(95, 151, 228, 1);
        _progressView.arcUnfinishColor = ZJCGetColorWith(95, 151, 228, 1);
        _progressView.width = 2;
        _progressView.percent = [model.studybar floatValue]/100.0;
        __weak typeof(self) weakSelf = self;
        [weakSelf.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.sectionBackView).offset([ZJCFrameControl GetControl_X:93]);
            make.right.equalTo(weakSelf.sectionBackView).offset(-[ZJCFrameControl GetControl_Y:80]);
            make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:90], [ZJCFrameControl GetControl_weight:90]));
        }];
        return _sectionBackView;
        
        
    }else{
        
        // 底板
        _sectionBackView = [[ZJCButtonWithEdgeBottomLine alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:0], [ZJCFrameControl GetControl_Y:0], [ZJCFrameControl GetControl_weight:1080], [ZJCFrameControl GetControl_height:140])];
        _sectionBackView.backgroundColor = [UIColor whiteColor];
        _sectionBackView.tag = section;
        _sectionBackView.lineEdgeInsetRight = 0;
        [_sectionBackView addTarget:self action:@selector(sectionBackViewClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        // 标题
        _titleLabel = [[UILabel alloc] init];
        [_sectionBackView addSubview:_titleLabel];
        __weak __typeof(self) weakSelf = self; 
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.sectionBackView).offset([ZJCFrameControl GetControl_X:40]);
            make.centerY.equalTo(weakSelf.sectionBackView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:700], [ZJCFrameControl GetControl_height:45]));
        }];
        _titleLabel.font = [UIFont systemFontOfSize:fontsize];
        _titleLabel.text = model.name;
        _titleLabel.textColor = ZJCGetColorWith(77, 77, 77, 1);
        
        // 练习题按钮
        _testButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_sectionBackView addSubview:_testButton];
        [_testButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(weakSelf.sectionBackView.mas_right).offset(-[ZJCFrameControl GetControl_X:40]);
            make.centerY.equalTo(weakSelf.sectionBackView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:180], [ZJCFrameControl GetControl_height:65]));
        }];
        [_testButton setTitle:@"练习题" forState:UIControlStateNormal];
        if (IPhone4s) {
            _testButton.titleLabel.font = [UIFont systemFontOfSize:9];
        }else {
            _testButton.titleLabel.font = [UIFont systemFontOfSize:13];
        }
        [_testButton setTitleColor:THEME_BACKGROUNDCOLOR forState:UIControlStateNormal];
        
        if ([model.ispaper isEqualToString:@"1"]) {
            UIImage * imageDown   = [[UIImage imageNamed:@"down_over"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [_testButton setImage:imageDown forState:UIControlStateNormal];
        }else{
            UIImage * imageNormal = [[UIImage imageNamed:@"down_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [_testButton setImage:imageNormal forState:UIControlStateNormal];
        }
        if ([model.eid isEqualToString:@"0"] || [model.eid isEqualToString:@""] || model.eid == nil) {
            _testButton.hidden = YES;
        }else{
            _testButton.hidden = NO;
        }
        
        _testButton.tag = section + 10;
        
        _testButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        _testButton.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 40);
        _testButton.titleEdgeInsets = UIEdgeInsetsMake(-1, -30, 2, -5);
        [_testButton addTarget:self action:@selector(testButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        return _sectionBackView;
    }
    return nil;
}




/**
 *  @brief cell点击
 */
//课程页面 tableview的点击切换视频的方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 先取消所有蒙版,再给自己加上蒙版
    // 1.
    ZJCPassValueControlManager * manager = [ZJCPassValueControlManager defaultManager];
    
    if (manager.isSection == YES) {
        UIView * sectionView = [_tableView viewWithTag:manager.selectSection];
        UIView * sectionMatte = [sectionView viewWithTag:manager.selectSection + 100];
        sectionMatte.hidden = YES;
    }else{
        NSIndexPath * myindexpath = [NSIndexPath indexPathForRow:manager.selectRow inSection:manager.selectSection];
        if ([myindexpath isEqual:indexPath]) {
            return;
        }else{
            [_tableView deselectRowAtIndexPath:myindexpath animated:NO];
        }
    }
    
    // 2.系统自动给加上了蒙板,所有这里只需要给manager赋新值就行了
    manager.isSection = NO;
    manager.selectSection = indexPath.section;
    manager.selectRow = indexPath.row;    
    
    // 3.回传值,用来给player赋新值,更新播放
    ZJCCourceCatalogueModel * model = _dataSource[indexPath.section];
    ZJCCourceCatalogueSmallModel * smallModel = model.son[indexPath.row];
    ZJCCourceCatelogueTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString * videoId = @"";
    NSString * title = @"";
    NSString * lessonId = @"";
    videoId = [smallModel.videoid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    lessonId = smallModel.id;
    title = smallModel.name;
    if (self.cellClicked) {
        self.cellClicked(cell,videoId,title,lessonId,manager.isSection,manager.selectSection,manager.selectRow);
    }
}




/**
 *  @brief 组头点击事件
 */
- (void)sectionBackViewClicked:(UIButton *)button{
    ZJCPassValueControlManager * mangager = [ZJCPassValueControlManager defaultManager];
    NSInteger section = button.tag;
    ZJCCourceCatalogueModel * model = _dataSource[section];
    // 1.区分该组头是否可以点击
    if (model.son.count == 0) {
        // 1.先取消其他 位置 蒙版,再给自己加上蒙版
        if (mangager.isSection == YES) {
            if (mangager.selectSection == button.tag) {
                return;
            }else{
                UIView * sectionView = [_tableView viewWithTag:mangager.selectSection];
                UIView * sectionMatte = [sectionView viewWithTag:mangager.selectSection + 100];
                sectionMatte.hidden = YES;
            }
            
        }else{
            NSIndexPath * indexpath = [NSIndexPath indexPathForRow:mangager.selectRow inSection:mangager.selectSection];
            [_tableView deselectRowAtIndexPath:indexpath animated:NO];
        }
        
        // 2.给Manager赋新值,更新蒙板的状态
        mangager.isSection = YES;
        mangager.selectSection = button.tag;
        UIView * sectionView = [_tableView viewWithTag:mangager.selectSection];
        UIView * sectionMatte = [sectionView viewWithTag:mangager.selectSection + 100];
        sectionMatte.hidden = NO;
        
        // 3.回传值,控制当前播放的视频
        NSString * videoId = @"";
        NSString * title = @"";
        NSString * lessonID = @"";
        videoId = [model.videoid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        title = model.name;
        lessonID = model.id;
        if (self.cellClicked) {
            self.cellClicked(button,videoId,title,lessonID,mangager.isSection,mangager.selectSection,mangager.selectRow);
        }
        
    }else{
        // 章下面没有节的时候,章不可以点击
        //        ZJCCourceCatalogueSmallModel * smallModel = [_dataSource[section] son][0];
        //        videoId = [smallModel.videoid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //        title = smallModel.name;
        //        if (self.cellClicked) {
        //            self.cellClicked(button,videoId,title);
        //        }
    }
}
        




/**
 *  @brief 练习题按钮点击事件
 */
- (void)testButtonClicked:(UIButton *)button{
    NSInteger section = button.tag - 10;
    ZJCCourceCatalogueModel * model = _dataSource[section];
    NSString * testId = model.eid;
    BOOL isDown = NO;
    if ([model.ispaper isEqualToString:@"0"]) {
        isDown = NO;
    }else{
        isDown = YES;
    }
    if (self.pushPraBlock) {
        self.pushPraBlock(button,testId,isDown);
    }
}


@end


