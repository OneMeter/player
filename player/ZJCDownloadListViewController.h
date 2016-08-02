//
//  ZJCDownloadListViewController.h
//  CCRA
//
//  Created by htkg on 16/3/30.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCBaseViewController.h"

@interface ZJCDownloadListViewController : ZJCBaseViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) UITableView * tableView;    // 展示表格
@property (nonatomic ,strong) NSMutableArray * dateArray;          // 保存所有的数据的数组
@property (nonatomic ,strong) NSMutableArray * displayDataArray;   // 保存需要显示的cell的数组


@property (nonatomic ,strong) UIView * confirmBackView;            // 下部确认下载的底板
@property (nonatomic ,strong) UIButton * confirmButton;            // 确认下载按钮
@property (nonatomic ,strong) UIButton * selectAllButton;          // 全选按钮

@property (nonatomic ,assign) BOOL isChoseSomething;               // 选择项目　　　　下载开关

@property (nonatomic ,strong) DWDownloader * downloader;           // 下载器

@end
