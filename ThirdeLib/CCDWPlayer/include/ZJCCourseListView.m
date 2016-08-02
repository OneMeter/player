//
//  ZJCCourseLIstView.m
//  CCRA
//
//  Created by htkg on 16/4/12.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCCourseListView.h"

#import "ZJCCourceCatalogueModel.h"
#import "ZJCCourceCatalogueSmallModel.h"




@implementation ZJCCourseListView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        // 初始化
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        self.userInteractionEnabled = YES;
        
        // 搭建自己的功能
        [self configSelf];
    }
    return self;
}

- (void)configSelf{
    // 标题
    [self creatTitleLabel];
    // 列表
    [self createTableView];
}



#pragma mark - 标题
- (void)creatTitleLabel{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, [ZJCFrameControl GetControl_Y:0], self.width - [ZJCFrameControl GetControl_X:40] , [ZJCFrameControl GetControl_weight:147])];
    [self addSubview:self.titleLabel];
    self.titleLabel .textColor = [UIColor whiteColor];
    self.titleLabel .textAlignment = NSTextAlignmentLeft;
    self.titleLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleLabelClicked:)];
    [self.titleLabel addGestureRecognizer:tap];
    // 分割线
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, _titleLabel.height-2, _titleLabel.width, 1)];
    label.backgroundColor = [UIColor grayColor];
    [self addSubview:label];
}







#pragma mark - 搭建表格
- (void)createTableView{
    self.tableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, [ZJCFrameControl GetControl_weight:147], self.width,self.height-[ZJCFrameControl GetControl_weight:147]) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.userInteractionEnabled = YES;
    // 注册cell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"aCell"];
    [self addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataSource.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    ZJCCourceCatalogueModel * model = _dataSource[section];
    return [model.son count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //static NSString *ID = @"ID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"aCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"aCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    ZJCCourceCatalogueModel * model = _dataSource[indexPath.section];
    ZJCCourceCatalogueSmallModel * smallModel = model.son[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%.2d %@",indexPath.row + 1,smallModel.name];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 根据数据传输类,初始化
    ZJCPassValueControlManager * manager = [ZJCPassValueControlManager defaultManager];
    if (manager.isSection == NO && manager.selectSection == indexPath.section && manager.selectRow == indexPath.row) {
        cell.textLabel.textColor = THEME_BACKGROUNDCOLOR;
    }else{
        cell.textLabel.textColor = ZJCGetColorWith(167, 167, 167, 1);
    }
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    // 底板
    _sectionBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 40)];
    _sectionBackView.tag = section;
    // 标题
    self.sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.width-10 , 40)];
    [_sectionBackView addSubview:self.sectionLabel];
    self.sectionLabel.tag = section + 1000;
    self.sectionLabel.textAlignment = NSTextAlignmentLeft;
    ZJCCourceCatalogueModel * model = _dataSource[section];
    self.sectionLabel.text = model.name;
    self.sectionLabel.userInteractionEnabled = YES;
    
    // 根据数据传输单例类,初始化
    ZJCPassValueControlManager * manager = [ZJCPassValueControlManager defaultManager];
    if (manager.isSection == YES && manager.selectSection == section) {
        self.sectionLabel.textColor = THEME_BACKGROUNDCOLOR;
    }else{
        self.sectionLabel.textColor = ZJCGetColorWith(167, 167, 167, 1);
    }
    // 分割线
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 38, self.width - 10*2, 1)];
    [ZJCDottedLine drawDashLine:label lineLength:3 lineSpacing:1 lineColor:[UIColor whiteColor]];
    [_sectionBackView addSubview:label];
    
    // 点击事件
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionBackViewTap:)];
    [_sectionBackView addGestureRecognizer:tap];
    _sectionBackView.userInteractionEnabled = YES;
    return _sectionBackView;
}





#pragma mark - 这里是个坑......
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ZJCPassValueControlManager * manager = [ZJCPassValueControlManager defaultManager];
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (manager.isSection == NO) {
        if (manager.selectSection == indexPath.section && manager.selectRow == indexPath.row) {
            return;
        }else{
            // 回传值
            ZJCCourceCatalogueModel * model = _dataSource[indexPath.section];
            ZJCCourceCatalogueSmallModel * smallModel = model.son[indexPath.row];
            NSString * videoId = @"";
            NSString * title = @"";
            NSString * lessonId = @"";
            videoId = [smallModel.videoid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            lessonId = smallModel.id;
            title = smallModel.name;
            BOOL isSection = manager.isSection;
            NSInteger selectSection = manager.selectSection;
            NSInteger selectRow = manager.selectRow;
            
            // 更新
            manager.isSection = NO;
            manager.selectSection = indexPath.section;
            manager.selectRow = indexPath.row;
            [_tableView reloadData];
            
            
            if (self.cellDidSelected) {
                self.cellDidSelected(cell,videoId,title,lessonId,isSection,selectSection,selectRow);
            }
        }
    }else if (manager.isSection == YES){
        // 回传值
        ZJCCourceCatalogueModel * model = _dataSource[indexPath.section];
        ZJCCourceCatalogueSmallModel * smallModel = model.son[indexPath.row];
        NSString * videoId = @"";
        NSString * title = @"";
        NSString * lessonId = @"";
        videoId = [smallModel.videoid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        lessonId = smallModel.id;
        title = smallModel.name;
        BOOL isSection = manager.isSection;
        NSInteger selectSection = manager.selectSection;
        NSInteger selectRow = manager.selectRow;
        
        // 更新
        manager.isSection = NO;
        manager.selectSection = indexPath.section;
        manager.selectRow = indexPath.row;
        [_tableView reloadData];
        
        if (self.cellDidSelected) {
            self.cellDidSelected(cell,videoId,title,lessonId,isSection,selectSection,selectRow);
        }
    }
}





- (void)sectionBackViewTap:(UITapGestureRecognizer *)tap{ 
    ZJCPassValueControlManager * manager = [ZJCPassValueControlManager defaultManager];
    if ([[_dataSource[tap.view.tag] son] count] == 0) {
        if (manager.isSection == YES) {
            if (manager.selectSection == tap.view.tag) {
                return;
            }
            // 2.回传值
            ZJCCourceCatalogueModel * model = _dataSource[tap.view.tag];
            NSString * videoId = @"";
            NSString * title = @"";
            NSString * lessonId = @"";
            videoId = [model.videoid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            title = model.name;
            lessonId = model.id;
            BOOL isSection = manager.isSection;
            NSInteger selectSection = manager.selectSection;
            NSInteger selectRow = manager.selectRow;
            
            // 1.更新
            manager.isSection = YES;
            manager.selectSection = tap.view.tag;
            manager.selectRow = LONG_MAX;
            [_tableView reloadData];
            if (self.cellDidSelected) {
                self.cellDidSelected(tap,videoId,title,lessonId,isSection,selectSection,selectRow);
            }
            
        }else if(manager.isSection == NO){
            // 2.回传值
            ZJCCourceCatalogueModel * model = _dataSource[tap.view.tag];
            NSString * videoId = @"";
            NSString * title = @"";
            NSString * lessonId = @"";
            videoId = [model.videoid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            title = model.name;
            lessonId = model.id;
            BOOL isSection = manager.isSection;
            NSInteger selectSection = manager.selectSection;
            NSInteger selectRow = manager.selectRow;
            
            // 1.更新
            manager.isSection = YES;
            manager.selectSection = tap.view.tag;
            manager.selectRow = LONG_MAX;
            [_tableView reloadData];
            
            
            if (self.cellDidSelected) {
                self.cellDidSelected(tap,videoId,title,lessonId,isSection,selectSection,selectRow);
            }
        }
    }
}




/**
 *  @brief 拦截点击事件,简单易行
 */
- (void)titleLabelClicked:(UITapGestureRecognizer *)tap{
    return;
}





/**
 *  @brief 懒加载
 */
- (void)setDataSource:(NSMutableArray *)dataSource{
    _dataSource = dataSource;
    // 
    self.titleLabel .text = self.titleString;
    [_tableView reloadData];
}

@end














