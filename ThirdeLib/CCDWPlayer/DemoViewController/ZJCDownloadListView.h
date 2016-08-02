//
//  ZJCDownloadListView.h
//  CCRA
//
//  Created by htkg on 16/4/12.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJCDownloadListTableViewCell.h"
#import "ZJCPopDownloadListViewModel.h"
#import "ZJCCourceCatalogueModel.h"
#import "ZJCCourceCatalogueSmallModel.h"
#import "ZJCCourseViewController.h"


@interface ZJCDownloadListView : UIView <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,strong) UIView * headerView;             // 标题框
@property (nonatomic ,strong) UILabel * headerTitleView;       // 顶部标题
@property (nonatomic ,copy) NSString * titleString;            // 标题
@property (nonatomic ,strong) UIButton * ensureLoadButton;     // 确认下载
@property (nonatomic ,strong) UIButton * selectAllButton;      // 全选按钮

@property (nonatomic ,strong) UITableView * tableView;         // 展示列表
@property (nonatomic ,strong) NSMutableArray * dataSource;     // 数据源
@property (nonatomic ,strong) UIView * sectionBackView;        // 头部视图
@property (nonatomic ,strong) UILabel * sectionTitleLabel;     // 标题

@property (nonatomic ,strong) NSDictionary * dicOfFirstLevelCourse;         // 第一层级请求到的数据
@property (nonatomic ,strong) ZJCCourseViewController * currentController;  // 当前的控制器

@end
