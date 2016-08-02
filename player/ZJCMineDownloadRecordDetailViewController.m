//
//  ZJCMineDownloadRecordDetailViewController.m
//  CCRA
//
//  Created by htkg on 16/4/1.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCMineDownloadRecordDetailViewController.h"
#import "ZJCCourseViewController.h"

#import "ZJCTreeTableView.h"
#import "ZJCTreeModel.h"

#import "ZJCFirstLevelModel.h"
#import "ZJCSecondLevelModel.h"
#import "ZJCThirdLevelModel.h"
#import "ZJCFirstLevelTableViewCell.h"
#import "ZJCSecondLevelTableViewCell.h"
#import "ZJCThirdLevelTableViewCell.h"


/*
 缓存列表－详情列表
 
 */


@interface ZJCMineDownloadRecordDetailViewController ()

@property (nonatomic ,strong) UIImageView * deleteImage;                     // 右上角编辑按钮
@property (nonatomic ,strong) UILabel * deleteLabel;
@property (nonatomic ,strong) UIBarButtonItem * rightBarButton;

@property (nonatomic ,assign) BOOL isEdit;
@property (nonatomic ,assign) NSInteger seletedNumber;

@property (nonatomic ,strong) UIButton  * topStartBackView;                  // 顶部全部开始按钮  底板
@property (nonatomic ,strong) UIImageView * topStartImageView;               // 开始图片
@property (nonatomic ,strong) UILabel * topStartLabel;                       // 开始字体

@property (nonatomic ,strong) ZJCTreeTableView * tableView;                  // 表格
@property (nonatomic ,strong) NSMutableArray * dataSource;                   // 数据源

@property (nonatomic ,strong) UIView * deleteBackView;                       // 下部删除的底板
@property (nonatomic ,strong) UIButton * deleteButton;                       // 删除按钮
@property (nonatomic ,strong) UIButton * selectAllButton;                    // 全选按钮

@property (nonatomic ,strong) NSTimer * timer;                          // 计时器 (初始化关闭状态,界面appear的时候打开)
@property (nonatomic ,strong) ZJCDownControl * downControManager;       // 下载控制器
@property (nonatomic ,assign) BOOL isTimerGoing;                        // 标记计时器的go状态

@property (nonatomic ,assign) float progress;
@property (nonatomic ,assign) NSInteger totalBytesWritten;
@property (nonatomic ,assign) NSInteger totalBytesExpectedToWrite;
@property (nonatomic ,strong) ZJCDownItem * currentItem;
@property (nonatomic ,strong) ZJCDownItem * oldItem;
@property (nonatomic ,strong) NSIndexPath * currentIndexPath;
@property (nonatomic ,assign) NSInteger currentProgress;
@property (nonatomic ,assign) NSInteger oldSpeedProgress;
@property (nonatomic ,assign) NSInteger speedProgress;

@end





@implementation ZJCMineDownloadRecordDetailViewController

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化
    [self selfInitDownloadRecordDetailVC];
    // 请求数据
    [self loadDownloadRecordDetailData];
    // 搭建UI
    //    [self creatDownloadRecordDetailUI];
    // 下一步
    [self nextStep];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 设置状态栏的类型
    [self setNeedsStatusBarAppearanceUpdate];
    // 隐藏tabbar
    self.tabBarController.tabBar.hidden = YES;
    // 导航栏的颜色
    [self.navigationController.navigationBar setBarTintColor:ZJCGetColorWith(25, 25, 25, 1)];
    // 开始定时器 (本来是手动开启,后来加了回调里面自动开启计时器以后,就直接给参数进行回调就行了)
    [self startTimer];
    self.isTimerGoing = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 隐藏tabbar
    self.tabBarController.tabBar.hidden = NO;
    // 导航栏的颜色
    [self.navigationController.navigationBar setBarTintColor:THEME_BACKGROUNDCOLOR];
    // 干掉计时器
    [self pauseTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// 隐藏状态栏
- (BOOL)prefersStatusBarHidden{
    return NO;
}








#pragma mark - 初始化
- (void)selfInitDownloadRecordDetailVC{
    // 编辑状态
    _isEdit = NO;
    _seletedNumber = 0;
    _oldItem = [[ZJCDownItem alloc] init];
    _isAllDownload = NO;
    
    // 背景色
    self.view.backgroundColor = ZJCGetColorWith(219, 219, 219, 1);
    
    // 右边的那个按钮
    [self creatDelegateButton];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    
    // 界面进度量
    _progress = 0;
    _totalBytesExpectedToWrite = 0;
    _totalBytesWritten = 0;
    _currentProgress = 0;
    _oldSpeedProgress = 0;
}


- (void)creatDelegateButton{
    _deleteImage = [[UIImageView alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:0], [ZJCFrameControl GetControl_Y:0], [ZJCFrameControl GetControl_weight:60], [ZJCFrameControl GetControl_height:60])];
    _deleteImage.image = [UIImage imageNamed:@"delegate_btn"];
    UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteBarButtonClicked:)];
    [_deleteImage addGestureRecognizer:tap1];
    
    _deleteLabel = [[UILabel alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:0], [ZJCFrameControl GetControl_Y:0], [ZJCFrameControl GetControl_weight:120], [ZJCFrameControl GetControl_height:60])];
    _deleteLabel.text = @"取消";
    _deleteLabel.textColor = [UIColor whiteColor];
    _deleteLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteBarButtonClicked:)];
    [_deleteLabel addGestureRecognizer:tap2];
    
    _rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:_deleteImage];
    self.navigationItem.rightBarButtonItem = _rightBarButton;
}


- (void)deleteBarButtonClicked:(UIButton *)button{
    [_tableView removeFromSuperview];
    if (_isEdit == YES) {        // 结束编辑
        _rightBarButton.customView = _deleteImage;  
        _topStartBackView.hidden = NO;
        _deleteBackView.hidden = YES;
        _isEdit = !_isEdit;
        
        // 重置选中参数
        for (ZJCTreeModel * model in _dataSource) {
            model.isSelected = NO;
        }
        _seletedNumber = 0;
        [_deleteButton setTitle:@"删  除" forState:UIControlStateNormal];
        
        [self creatTableView];
        
    }else if(_isEdit == NO){    // 开始编辑
        _rightBarButton.customView = _deleteLabel;
        _topStartBackView.hidden = YES;
        _deleteBackView.hidden = NO;
        _isEdit = !_isEdit;
        [self creatTableView];
        
    }
}











#pragma mark - 请求数据
- (void)loadDownloadRecordDetailData{
    /**
     *  @brief 请求数据库的数据
     */
    // 1.获取默认数据库管理 再来一个接数据的数组~
    ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
    NSArray * arrayTemp1 = [manager selectRecordWithMyParentid:_myParentId];
    NSMutableArray * dataArr = [[NSMutableArray alloc] init];
    
    // 2. ********特殊处理
    //         查看 下载管理器 的下载队列里是否含有该item
    //         如果有  该项目是 等待下载的项目
    //         如果没有  该项目是暂停的项目
    ZJCDownControl * downManager = [ZJCDownControl defaultControl];
    NSArray * downQueueArr = [NSArray arrayWithArray:downManager.downloadWaitingArr];
    ZJCDownItem * currentItem = downManager.currentItem;
    
    // 3.从数据库获取 "章节" 数据   根据 "章节" 数据,获取 "小节" 数据
    NSArray * arrayOfFirstLevelModels = [ZJCFirstLevelModel arrayOfModelsFromDictionaries:arrayTemp1];
    NSUInteger nodeIDCountFlog = arrayOfFirstLevelModels.count;
    
    for (int i = 0 ; i < arrayOfFirstLevelModels.count ; i++) {
        // 1>> 树形列表一级结构
        ZJCFirstLevelModel * firstLevelModel = arrayOfFirstLevelModels[i];
        firstLevelModel.speed = 0;
        if ([firstLevelModel.isover floatValue] == 1) {
            firstLevelModel.treeModelStatus = ZJCTreeModelStatusFinish;
        }else{
            firstLevelModel.treeModelStatus = ZJCTreeModelStatusPause;
            for (ZJCDownItem * item in downQueueArr) {
                if ([item.myid isEqualToString:firstLevelModel.myid]) {
                    if ([item.myid isEqualToString:currentItem.myid]) {
                        firstLevelModel.treeModelStatus = ZJCTreeModelStatusDownloading;
                    }else{
                        firstLevelModel.treeModelStatus = ZJCTreeModelStatusWait;
                    }
                    break;
                }
            }
        }
        ZJCTreeModel * modeltemp1 = [[ZJCTreeModel alloc] initWithParentId:-1 andNodeId:i andDepth:0 andExpand:YES andData:firstLevelModel];
        [dataArr addObject:modeltemp1];
        
        // 2>> 从数据库查询,该节点下的子节点
        NSArray * arrayTemp2 = [manager selectRecordWithMyParentid:[arrayOfFirstLevelModels[i] myid]];
        NSArray * arrayOfSecondLevelModels = [ZJCThirdLevelModel arrayOfModelsFromDictionaries:arrayTemp2];
        if (arrayTemp2.count == 0) {
            
        }else{
            firstLevelModel.treeModelStatus = ZJCTreeModelStatusError;
            for (int j = 0 ; j < arrayOfSecondLevelModels.count ; j++) {
                // 3>> 树形列表二级结构
                ZJCThirdLevelModel * thirdLevelModel = arrayOfSecondLevelModels[j];
                thirdLevelModel.speed = 0;
                if ([thirdLevelModel.isover floatValue] == 1) {
                    thirdLevelModel.treeModelStatus = ZJCTreeModelStatusFinish;
                }else{
                    thirdLevelModel.treeModelStatus = ZJCTreeModelStatusPause;
                    for (ZJCDownItem * item in downQueueArr) {
                        if ([item.myid isEqualToString:thirdLevelModel.myid]) {
                            if ([item.myid isEqualToString:currentItem.myid]) {
                                thirdLevelModel.treeModelStatus = ZJCTreeModelStatusDownloading;
                            }else{
                                thirdLevelModel.treeModelStatus = ZJCTreeModelStatusWait;
                            }
                            break;
                        }
                    }
                    
                }
                
                ZJCTreeModel * modeltemp2 = [[ZJCTreeModel alloc] initWithParentId:i andNodeId:nodeIDCountFlog+j andDepth:2 andExpand:YES andData:thirdLevelModel];
                [dataArr addObject:modeltemp2];
            }
        }
        
        // 标志量加上总节点数
        nodeIDCountFlog += arrayOfSecondLevelModels.count;
    }
    // 3.加载到数据源里面去
    _dataSource = [NSMutableArray arrayWithArray:dataArr];
}




- (void)nextStep{
    // 4.搭建界面
    [self creatDownloadRecordDetailUI];
    
    // 5.***初始化计时器(并没有打开appear的时候打开)
    [self addTimer];
    
    // 6.开始下载  (开始接受下载器的回调)
    [self getDownControlBlock];
}











#pragma mark - 搭建UI
- (void)creatDownloadRecordDetailUI{
    // 顶部的全部开始按钮
    [self creatTopStartView];
    // 展示表格
    [self creatTableView];
    // 底部删除按钮
    [self creatDeleteView];
}











#pragma mark - 顶部"全部开始"、"全部暂停"相关
- (void)creatTopStartView{
    __weak __typeof(self) weakSelf = self;
    // 底板
    self.topStartBackView = [[UIButton alloc] init];
    [self.view addSubview:self.topStartBackView];
    self.topStartBackView.selected = NO;
    self.topStartBackView.backgroundColor = [UIColor whiteColor];
    [self.topStartBackView addTarget:self action:@selector(allStartTap:) forControlEvents:UIControlEventTouchUpInside];
    [weakSelf.topStartBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset([ZJCFrameControl GetControl_X:0]);
        make.top.equalTo(weakSelf.view).offset(64);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:1080], [ZJCFrameControl GetControl_height:156]));
    }];
    
    // 图片
    self.topStartImageView = [[UIImageView alloc] init];
    [self.topStartBackView addSubview:self.topStartImageView];
    [self.topStartImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.topStartBackView).offset([ZJCFrameControl GetControl_X:40]);
        make.top.equalTo(weakSelf.topStartBackView).offset([ZJCFrameControl GetControl_Y:156/2 - 95/2]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:95], [ZJCFrameControl GetControl_weight:95]));
    }];
    
    // label
    self.topStartLabel = [[UILabel alloc] init];
    [self.topStartBackView addSubview:self.topStartLabel];
    self.topStartLabel.font = [UIFont systemFontOfSize:17];
    [self.topStartLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.topStartBackView).offset([ZJCFrameControl GetControl_X:40 + 95 + 35]);
        make.top.equalTo(weakSelf.topStartBackView).offset([ZJCFrameControl GetControl_Y:156/2 - 58/2]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:300], [ZJCFrameControl GetControl_height:58]));
    }];
    
    // 根据当前界面的状态,初始化 "全部XX" 按钮
    if (self.isDownloading == YES) {
        self.topStartBackView.selected = NO;
        self.topStartImageView.image = [UIImage imageNamed:@"startAll"];
        self.topStartLabel.text = @"全部开始";
    }else{
        self.topStartBackView.selected = YES;
        self.topStartImageView.image = [UIImage imageNamed:@"pauseAll"];
        self.topStartLabel.text = @"全部暂停";
    }
}


// "全部开始""全部暂停"点击处理
- (void)allStartTap:(UIButton *)button{
    // 1.反转状态
    _topStartBackView.selected = !_topStartBackView.selected;
    // 2.根据改变后的当前状态比较好判断
    if (_topStartBackView.selected == YES) {       // 当前 都在 正下
        
        
        // 判断本界面是否下载完毕了,如果下载完毕了就弹窗提示 "当前界面已经下载完毕"
        ZJCFMDBManager * fmdbManager = [ZJCFMDBManager defaultManager];
        NSArray * arrayTemp = [fmdbManager selectRecordWithMyid:_myParentId];
        NSDictionary * dicTemp = [arrayTemp firstObject];
        if ([dicTemp[@"isover"] floatValue] == 1) {
            self.isAllDownload = YES;
        }else{
            self.isAllDownload = NO;
        }
        if (self.isAllDownload == YES) {
            [ZJCAlertView presentAlertWithAlertTitle:@"" andAlertMessage:@"当前已经下载完毕!" andAlertStyle:UIAlertControllerStyleAlert andSupportController:self completion:nil andDelay:1.5];
            _topStartBackView.selected = !_topStartBackView.selected;
            return;
        }
        
        
        _topStartLabel.text = @"全部暂停";
        _topStartImageView.image = [UIImage imageNamed:@"pauseAll"];
        [self startAllItems];
    }else{                                         // 当前 都在 等待
        
        _topStartLabel.text = @"全部开始";
        _topStartImageView.image = [UIImage imageNamed:@"startAll"];
        [self stopAllItems];
    }
}



/**
 *  @brief 全部开始的方法
 */
- (void)startAllItems{
    // 1.暂停下载,暂停定时器
    [self.downControManager.downloader pause];
    [self pauseTimer];
    self.isTimerGoing = NO;
    
    
    // 2.处理模型 , 倒序循环 , 插入开头 ,这样最后一个处理的就是当前界面最前面的那个item ,也就在下载队列的开头了, 符合正常的顺序\
    处理pause状态的item  加入到下载队列开头 \
    处理wait状态的item   替换到当前的队列开头
    for (int i = (int)self.tableView.displayArray.count-1 ; i >= 0  ; i--) {
        ZJCTreeModel * modelBig = self.tableView.displayArray[i];
        
        if (modelBig.depth == 0) {
            // 取出当前模型
            ZJCFirstLevelModel * firstlevelModel = modelBig.data;
            // 2.1.1 当前暂停状态的item  (已经不在下载队列了,要从总队列里找出来,放到下载队列的开头)
            if (firstlevelModel.treeModelStatus == ZJCTreeModelStatusPause) {
                // 2.1.1.1 改变当前的模型的状态
                firstlevelModel.treeModelStatus = ZJCTreeModelStatusWait;
                // 2.1.1.2 将对应的item加载到下载队列里面去
                for (ZJCDownItem * item in self.downControManager.arraySumUseful) {
                    if ([item.myid isEqualToString:firstlevelModel.myid]) {
                        [self.downControManager.downloadWaitingArr insertObject:item atIndex:0];
                        break;
                    }
                }
            }
            // 2.1.2 当前wait状态的item  (还在下载队列里面  但是不知道其当前的位置,所以替换到当前处理的位置来)
            else if (firstlevelModel.treeModelStatus == ZJCTreeModelStatusWait){
                // 不需要改变等待状态,只需要放到下载队列 当前 最前面就行了
                for (int j = 0 ; j < self.downControManager.downloadWaitingArr.count ; j++) {
                    ZJCDownItem * item = self.downControManager.downloadWaitingArr[j];
                    if ([item.myid isEqualToString:firstlevelModel.myid]) {
                        ZJCDownItem * itemTemp = self.downControManager.downloadWaitingArr[j];
                        [self.downControManager.downloadWaitingArr removeObjectAtIndex:j];
                        [self.downControManager.downloadWaitingArr insertObject:itemTemp atIndex:0];
                        break;
                    }
                }
            }
        }
        
        else if(modelBig.depth == 2){
            // 取出当前模型
            ZJCThirdLevelModel * thirdlevelModel = modelBig.data;
            // 2.2.1 当前暂停状态的item  (已经不在下载队列了,要从总队列里找出来,放到下载队列的开头)
            if (thirdlevelModel.treeModelStatus == ZJCTreeModelStatusPause) {
                // 2.2.1.1 改变当前的模型的状态
                thirdlevelModel.treeModelStatus = ZJCTreeModelStatusWait;
                // 2.2.1.2 将对应的item加载到下载队列里面去
                for (ZJCDownItem * item in self.downControManager.arraySumUseful) {
                    if ([item.myid isEqualToString:thirdlevelModel.myid]) {
                        [self.downControManager.downloadWaitingArr insertObject:item atIndex:0];
                        break;
                    }
                }
            }
            // 2.2.2 当前wait状态的item  (还在下载队列里面  但是不知道其当前的位置,所以替换到当前处理的位置来)
            else if (thirdlevelModel.treeModelStatus == ZJCTreeModelStatusWait){
                for (int j = 0 ; j < self.downControManager.downloadWaitingArr.count ; j++) {
                    ZJCDownItem * item = self.downControManager.downloadWaitingArr[j];
                    if ([item.myid isEqualToString:thirdlevelModel.myid]) {
                        ZJCDownItem * itemTemp = self.downControManager.downloadWaitingArr[j];
                        [self.downControManager.downloadWaitingArr removeObjectAtIndex:j];
                        [self.downControManager.downloadWaitingArr insertObject:itemTemp atIndex:0];
                        break;
                    }
                }
            }
        }
    }
    // 3.刷新界面
    [self.tableView reloadData];
    // 4.处理好了下载列表,拿出下载列表的第一个item开始下载
    if (self.downControManager.downloadWaitingArr.count != 0) {
        ZJCDownItem * item = [self.downControManager.downloadWaitingArr firstObject];
        [self.downControManager startWithMyid:item.myid];
    }
}





/**
 *  @brief 全部暂停的方法
 */
- (void)stopAllItems{
    // 1.暂停下载,暂停定时器
    [self.downControManager.downloader pause];
    [self pauseTimer];
    self.isTimerGoing = NO;
    
    
    // 2.处理模型
    for (ZJCTreeModel * modelBig in self.tableView.displayArray) {
        
        if (modelBig.depth == 0) {
            // 先取到当前的数据模型
            ZJCFirstLevelModel * firstlevelModel = modelBig.data;
            // 不管当前的状态是啥 (正在下载  暂停  等待)  (还有两种状态的不可以操作  finish完成  error没有进度条和下载项目)
            if (firstlevelModel.treeModelStatus == ZJCTreeModelStatusPause || firstlevelModel.treeModelStatus == ZJCTreeModelStatusWait || firstlevelModel.treeModelStatus == ZJCTreeModelStatusDownloading) {
                // 2.1 改变当前的模型的状态
                firstlevelModel.treeModelStatus = ZJCTreeModelStatusPause;
                // 2.2 将对应的item从下载队列里面删去
                for (ZJCDownItem * item in self.downControManager.downloadWaitingArr) {
                    if ([item.myid isEqualToString:firstlevelModel.myid]) {
                        [self.downControManager.downloadWaitingArr removeObject:item];
                        break;
                    }
                }
            }
            
        }
        
        else if(modelBig.depth == 2){
            ZJCThirdLevelModel * thirdlevelModel = modelBig.data;
            if (thirdlevelModel.treeModelStatus == ZJCTreeModelStatusPause || thirdlevelModel.treeModelStatus == ZJCTreeModelStatusDownloading || thirdlevelModel.treeModelStatus == ZJCTreeModelStatusWait) {
                // 2.1改变当前的模型
                thirdlevelModel.treeModelStatus = ZJCTreeModelStatusPause;
                // 2.2将对应的item从下载队列里面删除
                for (ZJCDownItem * item in self.downControManager.downloadWaitingArr) {
                    if ([item.myid isEqualToString:thirdlevelModel.myid]) {
                        [self.downControManager.downloadWaitingArr removeObject:item];
                        break;
                    }
                }
            }
        }
    }
    // 3.刷新界面
    [self.tableView reloadData];
    // 4.既然当前点击了全部暂停按钮,那就说明之前下载的时候,是在当前界面下载的,所以并不会出现在其他界面下载的情况,不需要考虑该种情况 \
    只需要考虑,本界面全部暂停以后 当前下载队列是否为空的情况
    if (self.downControManager.downloadWaitingArr.count != 0) {
        ZJCDownItem * item = [self.downControManager.downloadWaitingArr firstObject];
        [self.downControManager startWithMyid:item.myid];
    }else{
        self.downControManager.downloader = nil;
        self.downControManager.currentItem = nil;
    }
}























#pragma mark - 展示表格
- (void)creatTableView{
    CGRect frame = CGRectZero;
    if (_isEdit == YES) {
        frame = CGRectMake(0, 64, self.view.width, self.view.height - 64 - [ZJCFrameControl GetControl_height:106]);
    }else{
        frame = CGRectMake(0, 64 + [ZJCFrameControl GetControl_Y:156+28], self.view.width, self.view.height - 64 - [ZJCFrameControl GetControl_Y:156+28]);
    }
    _tableView = [[ZJCTreeTableView alloc] initWithFrame:frame andData:_dataSource];
    [self.view insertSubview:_tableView belowSubview:self.topStartBackView];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.tableViewType = ZJCTreeTableViewTypeDownList;    // "缓冲列表" 类型的tableview
    if (_isEdit == YES) {                                       // "编辑状态" 是否打开
        _tableView.editStatus = ZJCTableViewEditingStatusEdit;
    }else if (_isEdit == NO){
        _tableView.editStatus = ZJCTableViewEditingStatusNone;
    }
    
    
    /////////////////////////////////////////
    // cell 点击回调方法
    __weak typeof(self)weakSelf = self;
    _tableView.cellDidSelectedBlock = ^(ZJCTreeTableView * tableView,NSIndexPath * indexpath){
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexpath];
        if ([cell isKindOfClass:[ZJCFirstLevelTableViewCell class]]) {
            loginfo(@"一级列表被点击了");
            // 1.取到当前对应的模型
            ZJCTreeModel * modelBig = weakSelf.tableView.displayArray[indexpath.row];
            ZJCFirstLevelModel * firstLevelModel = modelBig.data;
            // 2.根据模型的状态进行不同的操作
            switch (firstLevelModel.treeModelStatus) {
                case ZJCTreeModelStatusPause:
                {
                    logdebug(@"已暂停 准备下载");
                    // 3.暂停之前的类,如果是在下载队里里面,就从队列里面删除掉
                    // ** 之前还有item在下载
                    // ** 已经没有item在队列
                    [weakSelf.downControManager.downloader pause];
                    if (weakSelf.downControManager.downloadWaitingArr.count != 0) {
                        [weakSelf.downControManager.downloadWaitingArr removeObjectAtIndex:0];
                    }
                    // ** 之前下载的item在本界面  \
                    取到当前下载的那个,将其置成暂停的就行了
                    // ** 之前下载的item不在本界面 >>> 不需要特殊处理,因为进入界面进行数据初始化的时候,已经分类别处理了  \
                    正在进行的     在队列里面的      不在队列里面的
                    if (weakSelf.currentIndexPath != nil && weakSelf.isDownloading == YES) {
                        ZJCTreeModel * model = weakSelf.tableView.displayArray[weakSelf.currentIndexPath.row];
                        if (model.depth == 0) {
                            ZJCFirstLevelModel * oldFirstlevelMode = model.data;
                            if (oldFirstlevelMode.treeModelStatus == ZJCTreeModelStatusDownloading) {
                                oldFirstlevelMode.treeModelStatus = ZJCTreeModelStatusPause;
                            }
                            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:weakSelf.currentIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                        }else if(model.depth == 2){
                            ZJCThirdLevelModel * oldThirdlevelMode = model.data;
                            if (oldThirdlevelMode.treeModelStatus == ZJCTreeModelStatusDownloading) {
                                oldThirdlevelMode.treeModelStatus = ZJCTreeModelStatusPause;
                            }
                            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:weakSelf.currentIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                        }
                    }
                    
                    
                    // 4.改变当前model的状态
                    firstLevelModel.treeModelStatus = ZJCTreeModelStatusDownloading;
                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
                    
                    // ****添加 改变全部按钮的状态
                    weakSelf.topStartBackView.selected = YES;
                    weakSelf.topStartLabel.text = @"全部暂停";
                    weakSelf.topStartImageView.image = [UIImage imageNamed:@"pauseAll"];
                    
                    
                    // 5.从总队列里面找出来对应的 已暂停的item,加入下载队列最开始的位置,开始下载\
                    下载方法会自动从"可用的队列"里面找到当前需要下载的item来下载,所以只需要传入一个myid就行了
                    for (ZJCDownItem * item in weakSelf.downControManager.arraySumUseful) {
                        if ([item.myid isEqualToString:firstLevelModel.myid]) {
                            [weakSelf.downControManager.downloadWaitingArr insertObject:item atIndex:0];
                            break;
                        }
                    }
                    [weakSelf.downControManager startWithMyid:firstLevelModel.myid];
                    
                    // 6.阻塞计时器计时,等待下载重新开始以后,再打开计时器重新下载
                    [weakSelf pauseTimer];
                    weakSelf.isTimerGoing = NO;
                }
                    break;
                    
                    
                case ZJCTreeModelStatusWait:
                {
                    logdebug(@"等待中 准备下载");
                    // 3.暂停之前的类,如果是在下载队里里面,就从队里里面删除掉
                    // ** 之前还有item在下载
                    // ** 已经没有item在队列
                    [weakSelf.downControManager.downloader pause];
                    if (weakSelf.downControManager.downloadWaitingArr.count != 0) {
                        [weakSelf.downControManager.downloadWaitingArr removeObjectAtIndex:0];
                    }
                    // ** 之前下载的item在本界面  \
                    取到当前下载的那个,将其置成暂停的就行了
                    // ** 之前下载的item不在本界面 >>> 不需要特殊处理,因为进入界面进行数据初始化的时候,已经分类别处理了  \
                    正在进行的     在队列里面的      不在队列里面的
                    if (weakSelf.currentIndexPath != nil && weakSelf.isDownloading == YES) {
                        ZJCTreeModel * model = weakSelf.tableView.displayArray[weakSelf.currentIndexPath.row];
                        if (model.depth == 0) {
                            ZJCFirstLevelModel * oldFirstlevelMode = model.data;
                            oldFirstlevelMode.treeModelStatus = ZJCTreeModelStatusPause;
                            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:weakSelf.currentIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                        }else if(model.depth == 2){
                            ZJCThirdLevelModel * oldThirdlevelMode = model.data;
                            oldThirdlevelMode.treeModelStatus = ZJCTreeModelStatusPause;
                            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:weakSelf.currentIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                        }
                    }
                    
                    // 4.改变当前model的状态
                    firstLevelModel.treeModelStatus = ZJCTreeModelStatusDownloading;
                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
                    
                    // ****添加 改变全部按钮的状态
                    weakSelf.topStartBackView.selected = YES;
                    weakSelf.topStartLabel.text = @"全部暂停";
                    weakSelf.topStartImageView.image = [UIImage imageNamed:@"pauseAll"];
                    
                    // 5.开始下载当前类   因为之前的状态是wait,说明当前item是在下载队列里面的,所以省去了加入到下载队列的操作
                    [weakSelf.downControManager startWithMyid:firstLevelModel.myid];
                    
                    // 6.阻塞计时器计时,等待下载重新开始以后,再打开计时器重新下载
                    [weakSelf pauseTimer];
                    weakSelf.isTimerGoing = NO;
                }
                    break;
                case ZJCTreeModelStatusFinish:
                {
                    logdebug(@"已完成 播放本地对应的视频文件");
                    ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
                    NSArray * arrayTemp = [manager selectRecordWithMyid:firstLevelModel.myparentid];
                    NSString * middleNameString = [arrayTemp firstObject][@"name"];
                    ZJCCourseViewController * courseVC = [[ZJCCourseViewController alloc] init];
                    courseVC.courseID = firstLevelModel.myparentid;
                    courseVC.middelname = middleNameString;
                    
                    // 请求到数据以后就可以"点击播放"
                    __block ZJCCourseViewController * blockCourseVC = courseVC;
                    courseVC.alreadyGetData = ^(BOOL isGetData){
                        // 模仿点击播放按钮
                        NSString * destination  = [NSString stringWithFormat:@"%@/%@%@.pcm",DWPlayer_Destion,firstLevelModel.myid,firstLevelModel.vedioid];
                        [blockCourseVC playNewVedioWithLocalPath:destination andLessonid:firstLevelModel.myid andTitle:firstLevelModel.title andDepth:1 andSectionId:firstLevelModel.myid];
                    };
                    
                    [weakSelf.navigationController pushViewController:courseVC animated:YES];
                }
                    break;
                case ZJCTreeModelStatusDownloading:
                {
                    logdebug(@"下载中 准备暂停");
                    // 3.当前的下载器的设置成暂停,当前下载的item可能有两种情况\
                    一种是自动下载的下载队列的最先一个\
                    一种是没有下载队列了,本item是点击了开始下载,才加入到下载队列的,只有一个在下载的
                    [weakSelf.downControManager.downloader pause];
                    if (weakSelf.downControManager.downloadWaitingArr.count != 0) {
                        [weakSelf.downControManager.downloadWaitingArr removeObjectAtIndex:0];
                    }
                    
                    // 4.改变当前model的状态
                    firstLevelModel.treeModelStatus = ZJCTreeModelStatusPause;
                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
                    
                    
                    // 5.继续下载下一个
                    if (weakSelf.downControManager.downloadWaitingArr.count != 0) {
                        ZJCDownItem * item = weakSelf.downControManager.downloadWaitingArr[0];
                        [weakSelf.downControManager startWithMyid:item.myid];
                    }else{
                        // ****添加 改变全部按钮的状态
                        weakSelf.topStartBackView.selected = NO;
                        weakSelf.topStartLabel.text = @"全部开始";
                        weakSelf.topStartImageView.image = [UIImage imageNamed:@"startAll"];
                    }
                    
                    // 6.阻塞计时器计时,等待下载重新开始以后,再打开计时器重新下载
                    [weakSelf pauseTimer];
                    weakSelf.isTimerGoing = NO;
                }
                    break;
                case ZJCTreeModelStatusError:
                {
                    logdebug(@"章头不做操作!");
                }
                default:
                    break;
            }
            
            
        }else if ([cell isKindOfClass:[ZJCSecondLevelTableViewCell class]]){
            loginfo(@"二级列表被点击了");
            
            
        }else if ([cell isKindOfClass:[ZJCThirdLevelTableViewCell class]]){
            loginfo(@"三级列表被点击了");
            // 1.取到当前对应的模型
            ZJCTreeModel * modelBig = weakSelf.tableView.displayArray[indexpath.row];
            ZJCThirdLevelModel * thirdlevelmodel = modelBig.data;
            // 2.根据模型的状态进行不同的操作
            switch (thirdlevelmodel.treeModelStatus) {
                case ZJCTreeModelStatusPause:
                {
                    logdebug(@"已暂停 准备下载");
                    // 3.暂停之前的类,如果是在下载队里里面,就从队里里面删除掉
                    // ** 之前还有item在下载
                    // ** 已经没有item在队列
                    [weakSelf.downControManager.downloader pause];
                    if (weakSelf.downControManager.downloadWaitingArr.count != 0) {
                        [weakSelf.downControManager.downloadWaitingArr removeObjectAtIndex:0];
                    }
                    // ** 之前下载的item在本界面  \
                    取到当前下载的那个,将其置成暂停的就行了
                    // ** 之前下载的item不在本界面 >>> 不需要特殊处理,因为进入界面进行数据初始化的时候,已经分类别处理了  \
                    正在进行的     在队列里面的      不在队列里面的
                    if (weakSelf.currentIndexPath != nil && weakSelf.isDownloading == YES) {
                        ZJCTreeModel * model = weakSelf.tableView.displayArray[weakSelf.currentIndexPath.row];
                        if (model.depth == 0) {
                            ZJCFirstLevelModel * oldFirstlevelMode = model.data;
                            if (oldFirstlevelMode.treeModelStatus == ZJCTreeModelStatusDownloading) {
                                oldFirstlevelMode.treeModelStatus = ZJCTreeModelStatusPause;
                            }
                            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:weakSelf.currentIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                        }else if(model.depth == 2){
                            ZJCThirdLevelModel * oldThirdlevelMode = model.data;
                            if (oldThirdlevelMode.treeModelStatus == ZJCTreeModelStatusDownloading) {
                                oldThirdlevelMode.treeModelStatus = ZJCTreeModelStatusPause;
                            }
                            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:weakSelf.currentIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                        }
                    }
                    
                    // 4.改变当前model的状态
                    thirdlevelmodel.treeModelStatus = ZJCTreeModelStatusDownloading;
                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
                    
                    // ****添加 改变全部按钮的状态
                    weakSelf.topStartBackView.selected = YES;
                    weakSelf.topStartLabel.text = @"全部暂停";
                    weakSelf.topStartImageView.image = [UIImage imageNamed:@"pauseAll"];
                    
                    
                    // 5.从总队列里面找出来对应的 已暂停的item,加入下载队列最开始的位置,开始下载\
                    下载方法会自动从"可用的队列"里面找到当前需要下载的item来下载,所以只需要传入一个myid就行了
                    for (ZJCDownItem * item in weakSelf.downControManager.arraySumUseful) {
                        if ([item.myid isEqualToString:thirdlevelmodel.myid]) {
                            [weakSelf.downControManager.downloadWaitingArr insertObject:item atIndex:0];
                            break;
                        }
                    }
                    [weakSelf.downControManager startWithMyid:thirdlevelmodel.myid];
                    
                    // 6.阻塞计时器计时,等待下载重新开始以后,再打开计时器重新下载
                    [weakSelf pauseTimer];
                    weakSelf.isTimerGoing = NO;
                }
                    break;
                case ZJCTreeModelStatusWait:
                {
                    logdebug(@"等待中 准备下载");
                    // 3.暂停之前的类,如果是在下载队里里面,就从队里里面删除掉
                    // ** 之前还有item在下载
                    // ** 已经没有item在队列
                    [weakSelf.downControManager.downloader pause];
                    if (weakSelf.downControManager.downloadWaitingArr.count != 0) {
                        [weakSelf.downControManager.downloadWaitingArr removeObjectAtIndex:0];
                    }
                    // ** 之前下载的item在本界面  \
                    取到当前下载的那个,将其置成暂停的就行了
                    // ** 之前下载的item不在本界面 >>> 不需要特殊处理,因为进入界面进行数据初始化的时候,已经分类别处理了  \
                    正在进行的     在队列里面的      不在队列里面的
                    if (weakSelf.currentIndexPath != nil && weakSelf.isDownloading == YES) {
                        ZJCTreeModel * model = weakSelf.tableView.displayArray[weakSelf.currentIndexPath.row];
                        if (model.depth == 0) {
                            ZJCFirstLevelModel * oldFirstlevelMode = model.data;
                            oldFirstlevelMode.treeModelStatus = ZJCTreeModelStatusPause;
                            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:weakSelf.currentIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                        }else if(model.depth == 2){
                            ZJCThirdLevelModel * oldThirdlevelMode = model.data;
                            oldThirdlevelMode.treeModelStatus = ZJCTreeModelStatusPause;
                            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:weakSelf.currentIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                        }
                    }
                    
                    // 4.改变当前model的状态
                    thirdlevelmodel.treeModelStatus = ZJCTreeModelStatusDownloading;
                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
                    
                    // ****添加 改变全部按钮的状态
                    weakSelf.topStartBackView.selected = YES;
                    weakSelf.topStartLabel.text = @"全部暂停";
                    weakSelf.topStartImageView.image = [UIImage imageNamed:@"pauseAll"];
                    
                    
                    // 5.开始下载当前类  因为之前的状态是wait,说明当前item是在下载队列里面的,所以省去了加入到下载队列的操作
                    [weakSelf.downControManager startWithMyid:thirdlevelmodel.myid];
                    
                    // 6.阻塞计时器计时,等待下载重新开始以后,再打开计时器重新下载
                    [weakSelf pauseTimer];
                    weakSelf.isTimerGoing = NO;
                }
                    break;
                case ZJCTreeModelStatusFinish:
                {
                    logdebug(@"已完成 不做操作");
                    // 已完成的暂时先不做操作,随后需要进行播放本地视频的操作
                    
                }
                    break;
                case ZJCTreeModelStatusDownloading:
                {
                    logdebug(@"下载中 准备暂停");
                    // 3.当前的下载器的设置成暂停,当前下载的item可能有两种情况\
                    一种是自动下载的下载队列的最先一个\
                    一种是没有下载队列了,本item是点击了开始下载,才加入到下载队列的,只有一个在下载的
                    [weakSelf.downControManager.downloader pause];
                    if (weakSelf.downControManager.downloadWaitingArr.count != 0) {
                        [weakSelf.downControManager.downloadWaitingArr removeObjectAtIndex:0];
                    }
                    
                    // 4.改变当前model的状态
                    thirdlevelmodel.treeModelStatus = ZJCTreeModelStatusPause;
                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
                    
                    
                    // 5.继续下载下一个
                    if (weakSelf.downControManager.downloadWaitingArr.count != 0) {
                        ZJCDownItem * item = weakSelf.downControManager.downloadWaitingArr[0];
                        [weakSelf.downControManager startWithMyid:item.myid];
                    }else{
                        // ****添加 改变全部按钮的状态
                        weakSelf.topStartBackView.selected = NO;
                        weakSelf.topStartLabel.text = @"全部开始";
                        weakSelf.topStartImageView.image = [UIImage imageNamed:@"startAll"];
                    }
                    
                    
                    // 6.阻塞计时器计时,等待下载重新开始以后,再打开计时器重新下载
                    [weakSelf pauseTimer];
                    weakSelf.isTimerGoing = NO;
                }
                    break;
                default:
                    break;
            }
        }
    };
    
    
    
    
    
    
    
    ////////////////////////////////////////////
    // cell编辑状态 选中按钮点击Block
    _tableView.cellDeleteButtonClicked = ^(UITableView * tableView,NSIndexPath * indexPath){
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[ZJCFirstLevelTableViewCell class]]) {
            loginfo(@"一级列表选择按钮被点击了");
            ZJCTreeModel * model = weakSelf.dataSource[indexPath.row];
            ZJCFirstLevelTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
            ZJCFirstLevelModel * firstLevelModel = model.data;
            if (cell.editButton.selected == NO) {
                model.isSelected = NO;
                firstLevelModel.isSelected = NO;
                weakSelf.seletedNumber--;
                for (int i = 0; i < weakSelf.dataSource.count ; i++) {
                    ZJCTreeModel * modelTemp = weakSelf.dataSource[i];
                    // 寻找子节点
                    if (modelTemp.parentId == model.nodeId) {
                        ZJCThirdLevelModel * thirsLevelModel = modelTemp.data;
                        thirsLevelModel.isSelected = NO;
                        modelTemp.isSelected = NO;
                        ZJCThirdLevelTableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                        if (cell.editButton.selected == YES) {
                            weakSelf.seletedNumber--;
                            cell.editButton.selected = NO;
                        }else{
                            cell.editButton.selected = NO;
                        }
                        cell.editImageView.image = [UIImage imageNamed:@"select_normal"];
                    }
                }
                if (weakSelf.seletedNumber == 0) {
                    [weakSelf.deleteButton setTitle:@"删  除" forState:UIControlStateNormal];
                }else{
                    [weakSelf.deleteButton setTitle:[NSString stringWithFormat:@"删  除(%lu)",(long)weakSelf.seletedNumber] forState:UIControlStateNormal];
                }
                
            }else{
                model.isSelected = YES;
                firstLevelModel.isSelected = YES;
                weakSelf.seletedNumber++;
                for (int i = 0; i < weakSelf.dataSource.count ; i++) {
                    ZJCTreeModel * modelTemp = weakSelf.dataSource[i];
                    
                    if (modelTemp.parentId == model.nodeId) {
                        ZJCThirdLevelModel * thirsLevelModel = modelTemp.data;
                        thirsLevelModel.isSelected = YES;
                        modelTemp.isSelected = YES;
                        ZJCThirdLevelTableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                        if (cell.editButton.selected == NO) {
                            weakSelf.seletedNumber++;
                            cell.editButton.selected = YES;
                        }else{
                            cell.editButton.selected = YES;
                        }
                        cell.editImageView.image = [UIImage imageNamed:@"select_select"];
                    }
                }
                [weakSelf.deleteButton setTitle:[NSString stringWithFormat:@"删  除(%lu)",(long)weakSelf.seletedNumber] forState:UIControlStateNormal];
            }
            
            
            
        }else if ([cell isKindOfClass:[ZJCSecondLevelTableViewCell class]]){
            loginfo(@"二级列表选择按钮被点击了");
            
            
            
            
        }else if ([cell isKindOfClass:[ZJCThirdLevelTableViewCell class]]){
            loginfo(@"三级级列表选择按钮被点击了");
            ZJCTreeModel * model = weakSelf.dataSource[indexPath.row];
            ZJCThirdLevelModel * thirdLevelModel = model.data;
            ZJCThirdLevelTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
            if (cell.editButton.selected == NO) {
                model.isSelected = NO;
                thirdLevelModel.isSelected = NO;
                weakSelf.seletedNumber--;
                
                // 如果有取消掉的子节点,那么父节点的也要取消掉
                for (int i = 0; i < weakSelf.dataSource.count ; i++) {
                    ZJCTreeModel * parentModel = weakSelf.dataSource[i];
                    if (parentModel.nodeId == model.parentId) {
                        ZJCFirstLevelModel * firstLevelModel = parentModel.data;
                        ZJCFirstLevelTableViewCell * parentcell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                        if (parentcell.editButton.selected == YES) {
                            parentModel.isSelected = NO;
                            firstLevelModel.isSelected = NO;
                            parentcell.editButton.selected = NO;
                            parentcell.editImageView.image = [UIImage imageNamed:@"select_normal"];
                            weakSelf.seletedNumber--;
                            break;
                        }
                    }
                }
                
                if (weakSelf.seletedNumber == 0) {
                    [weakSelf.deleteButton setTitle:@"删  除" forState:UIControlStateNormal];
                }else{
                    [weakSelf.deleteButton setTitle:[NSString stringWithFormat:@"删  除(%lu)",(long)weakSelf.seletedNumber] forState:UIControlStateNormal];
                }
            }else{
                model.isSelected = YES;
                thirdLevelModel.isSelected = YES;
                weakSelf.seletedNumber++;
                
                // 如果全部选中了,那么父节点的也要变成选中状态
                BOOL isSelectAll = NO;
                for (ZJCTreeModel * childModel in weakSelf.dataSource) {
                    if (childModel.parentId == model.parentId) {
                        if (childModel.isSelected == NO) {
                            isSelectAll = NO;
                            break;
                        }else{
                            isSelectAll = YES;
                        }
                    }
                }
                
                if (isSelectAll == YES) {
                    for (int i = 0 ; i < weakSelf.dataSource.count ; i++) {
                        ZJCTreeModel * parentModel = weakSelf.dataSource[i];
                        if (parentModel.nodeId == model.parentId) {
                            ZJCFirstLevelModel * firstLevelModel = parentModel.data;
                            ZJCFirstLevelTableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                            if (cell.editButton.selected == YES) {
                                
                            }else{
                                parentModel.isSelected = YES;
                                firstLevelModel.isSelected = YES;
                                cell.editButton.selected = YES;
                                cell.editImageView.image = [UIImage imageNamed:@"select_select"];
                                weakSelf.seletedNumber++;
                            }
                        }
                    }
                }else{
                    
                }
                [weakSelf.deleteButton setTitle:[NSString stringWithFormat:@"删  除(%lu)",(long)weakSelf.seletedNumber] forState:UIControlStateNormal];
            }
            
        }
    };
    
}















#pragma mark - 底部删除按钮
- (void)creatDeleteView{
    // 底板
    _deleteBackView = [[UIView alloc] init];
    [self.view insertSubview:_deleteBackView aboveSubview:_tableView];
    _deleteBackView.hidden = YES;
    _deleteBackView.backgroundColor = [UIColor whiteColor];
    __weak __typeof(self) weakSelf = self; 
    [_deleteBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset([ZJCFrameControl GetControl_X:0]);
        make.bottom.equalTo(weakSelf.view).offset([ZJCFrameControl GetControl_Y:0]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:1080], [ZJCFrameControl GetControl_height:106]));
    }];
    
    // 全选按钮
    _selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteBackView addSubview:_selectAllButton];
    [_selectAllButton addTarget:self action:@selector(selectAllButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_selectAllButton setTitle:@"全  选" forState:UIControlStateNormal];
    [_selectAllButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_selectAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.deleteBackView).offset([ZJCFrameControl GetControl_X:0]);
        make.top.equalTo(weakSelf.deleteBackView).offset([ZJCFrameControl GetControl_Y:0]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:1080/2], [ZJCFrameControl GetControl_height:106]));
    }];
    
    // 删除按钮
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteBackView addSubview:_deleteButton];
    [_deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_deleteButton setTitle:@"删  除" forState:UIControlStateNormal];
    [_deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.deleteBackView.mas_right).offset(-[ZJCFrameControl GetControl_X:1080/2]);
        make.top.equalTo(weakSelf.deleteBackView).offset([ZJCFrameControl GetControl_Y:0]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:1080/2], [ZJCFrameControl GetControl_height:106]));
    }];
    
    // 分割线 (横 竖)
    UILabel * labelHeng = [[UILabel alloc] init];
    [_deleteBackView addSubview:labelHeng];
    labelHeng.backgroundColor = ZJCGetColorWith(219, 219, 219, 1);
    [labelHeng mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.deleteBackView).offset([ZJCFrameControl GetControl_X:0]);
        make.top.equalTo(weakSelf.deleteBackView).offset([ZJCFrameControl GetControl_Y:0]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:1080], [ZJCFrameControl GetControl_height:2]));
    }];
    
    UILabel * labelShu = [[UILabel alloc] init];
    [_deleteBackView addSubview:labelShu];
    labelShu.backgroundColor = ZJCGetColorWith(219, 219, 219, 1);
    [labelShu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.deleteBackView).offset([ZJCFrameControl GetControl_X:1080/2]);
        make.top.equalTo(weakSelf.deleteBackView).offset([ZJCFrameControl GetControl_Y:0]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:2], [ZJCFrameControl GetControl_height:106]));
    }];
}




- (void)selectAllButtonClicked:(UIButton *)button{
    if (_selectAllButton.selected == YES) {
        _selectAllButton.selected = NO;
        [_selectAllButton setTitle:@"全  选" forState:UIControlStateNormal];
        [_deleteButton setTitle:@"删  除" forState:UIControlStateNormal];
        for (int i = 0 ; i < _dataSource.count ; i++) {
            // 数据源
            ZJCTreeModel * model = _dataSource[i];
            model.isSelected = NO;
            if (model.depth == 0) {
                ZJCFirstLevelModel * firstLevelModel = model.data;
                firstLevelModel.isSelected = NO;
            }else if (model.depth == 2){
                ZJCThirdLevelModel * thirdLevelModel = model.data;
                thirdLevelModel.isSelected = NO;
            }
            // 界面处理
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if ([cell isKindOfClass:[ZJCFirstLevelTableViewCell class]]) {
                [[(ZJCFirstLevelTableViewCell *)cell editButton] setSelected:NO];
                [[(ZJCFirstLevelTableViewCell *)cell editImageView] setImage:[UIImage imageNamed:@"select_normal"]];
            }else if ([cell isKindOfClass:[ZJCThirdLevelTableViewCell class]]){
                [[(ZJCThirdLevelTableViewCell *)cell editButton] setSelected:NO];
                [[(ZJCThirdLevelTableViewCell *)cell editImageView] setImage:[UIImage imageNamed:@"select_normal"]];
            }
        }
        _seletedNumber = 0 ;
        [_tableView reloadData];
        
    }else{
        _selectAllButton.selected = YES;
        [_selectAllButton setTitle:@"取消全选" forState:UIControlStateNormal];
        [_deleteButton setTitle:[NSString stringWithFormat:@"删  除(%lu)",(unsigned long)_dataSource.count] forState:UIControlStateNormal];
        for (int i = 0 ; i < _dataSource.count ; i++) {
            ZJCTreeModel * model = _dataSource[i];
            model.isSelected = YES;
            if (model.depth == 0) {
                ZJCFirstLevelModel * firstLevelModel = model.data;
                firstLevelModel.isSelected = YES;
            }else if (model.depth == 2){
                ZJCThirdLevelModel * thirdLevelModel = model.data;
                thirdLevelModel.isSelected = YES;
            }
            // 界面处理
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if ([cell isKindOfClass:[ZJCFirstLevelTableViewCell class]]) {
                [[(ZJCFirstLevelTableViewCell *)cell editButton] setSelected:YES];
                [[(ZJCFirstLevelTableViewCell *)cell editImageView] setImage:[UIImage imageNamed:@"select_select"]];
            }else if ([cell isKindOfClass:[ZJCThirdLevelTableViewCell class]]){
                [[(ZJCThirdLevelTableViewCell *)cell editButton] setSelected:YES];
                [[(ZJCThirdLevelTableViewCell *)cell editImageView] setImage:[UIImage imageNamed:@"select_select"]];
            }
        }
        _seletedNumber = _dataSource.count;
        [_tableView reloadData];
    }
}


- (void)deleteButtonClicked:(UIButton *)button{
    ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
    [self.downControManager pause];
    [self pauseTimer];
    
    // 1.删除本地数据源 (并没有删除,而是把不需要删除的放到新的数组里面,然后把新的数组赋值给"列表数据源")
    NSMutableArray * tempArray = [NSMutableArray array];
    for (int i = 0; i < _dataSource.count; i++) {
        ZJCTreeModel * model = _dataSource[i];
        if (model.isSelected == NO) {
            [tempArray addObject:model];
        }
    }
    
    // 2.删除数据库内容
    //   删除下载队列
    for (int i = 0 ; i < _dataSource.count ; i++) {
        ZJCTreeModel * model = _dataSource[i];
        if (model.isSelected == YES) {
            if (model.depth == 0) {
                ZJCFirstLevelModel * firstModel = model.data;
                // 删除数据库
                [manager deleteRecordWithMyid:firstModel.myid];
                [manager deleteRecordWithMyParentId:firstModel.myid];
                // 删除下载器队列
                [self.downControManager removeItemWithItsMyid:firstModel.myid];
                [self.downControManager removeItemWithItsParentID:firstModel.myid];
                
            }else if (model.depth == 2){
                // 删除数据库
                ZJCThirdLevelModel * thirdModel = model.data;
                [manager deleteRecordWithMyid:thirdModel.myid];
                // 删除下载器队列
                [self.downControManager removeItemWithItsMyid:thirdModel.myid];
            }
        }
    }
    
    // 3.复健
    if (self.downControManager.downloadWaitingArr != 0) {
        ZJCDownItem * item = [self.downControManager.downloadWaitingArr firstObject];
        if ([item.myid isEqualToString:self.downControManager.currentItem.myid]) {
            // 之前在下载的item没有删除
            [self.downControManager.downloader resume];
        }else{
            // 之前在下载的item删除了
            [self.downControManager startWithMyid:item.myid];
        }
    }
    
    // 4.重置
    _dataSource = [NSMutableArray arrayWithArray:tempArray];
    [_deleteButton setTitle:@"删  除" forState:UIControlStateNormal];
    [_selectAllButton setTitle:@"全  选" forState:UIControlStateNormal];
    _seletedNumber = 0;
    _tableView.displayArray = _dataSource;
    [_tableView reloadData];
    
    // 打开计时器继续跑动
    [self startTimer];
}








#pragma mark - 获取Block回调
- (void)getDownControlBlock{
    // 获取下载管理类
    _downControManager = [ZJCDownControl defaultControl];
    // 下载管理类的回调
    /**
     *  @brief 1.进度回调
     */
    __block typeof(self)weakSelf = self;
    _downControManager.progerssBlock = ^(float progress, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite,ZJCDownItem * currentItem){
        // 当前项目的进度
        weakSelf.progress = progress;
        weakSelf.totalBytesExpectedToWrite = totalBytesExpectedToWrite;
        weakSelf.totalBytesWritten = totalBytesWritten;
        weakSelf.currentItem = currentItem;
        
        
        // 更新数据库
        ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
        [manager updateRecordWithMyid:weakSelf.currentItem.myid useIsover:[NSString stringWithFormat:@"%f",progress]];
        
        
        // 打开计时器,刷新界面
        if (weakSelf.isTimerGoing == NO) {
            [weakSelf startTimer];
            weakSelf.isTimerGoing = YES;
        }
    };
    
    
    
    
    
    
    
    /**
     *  @brief 2.完成回调
     */
    _downControManager.finishBlock = ^(){
        [weakSelf pauseTimer];
        weakSelf.isTimerGoing = NO;
        
        // 将当前完成的项目,刷新到完成
        for (int i = 0 ; i < self.tableView.displayArray.count ; i++) {
            ZJCTreeModel * modelBig = weakSelf.tableView.displayArray[i];
            if (modelBig.depth == 0) {
                ZJCFirstLevelModel * firstLevelModel = modelBig.data;
                if ([firstLevelModel.myid isEqualToString:weakSelf.downControManager.currentItem.myid]) {
                    firstLevelModel.isover = @"1";
                    firstLevelModel.treeModelStatus = ZJCTreeModelStatusFinish;
                    NSIndexPath * indexpath = [NSIndexPath indexPathForRow:i inSection:0];
                    [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
                    
                    // 这个时候,如果下载的是当前界面的最后一个,需要"全部开始"改成开始状态
                    if (i == self.tableView.displayArray.count - 1) {
                        weakSelf.topStartBackView.selected = NO;
                        weakSelf.topStartImageView.image = [UIImage imageNamed:@"startAll"];
                        weakSelf.topStartLabel.text = @"全部开始";
                    }
                    
                    
                    break;
                }
            }else if (modelBig.depth == 2){
                ZJCThirdLevelModel * thirdLevelModel = modelBig.data;
                if ([thirdLevelModel.myid isEqualToString:weakSelf.downControManager.currentItem.myid]) {
                    thirdLevelModel.isover = @"1";
                    thirdLevelModel.treeModelStatus = ZJCTreeModelStatusFinish;
                    NSIndexPath * indexpath = [NSIndexPath indexPathForRow:i inSection:0];
                    [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
                    
                    // 这个时候,如果下载的是当前界面的最后一个,需要"全部开始"改成开始状态
                    if (i == self.tableView.displayArray.count - 1) {
                        weakSelf.topStartBackView.selected = NO;
                        weakSelf.topStartImageView.image = [UIImage imageNamed:@"startAll"];
                        weakSelf.topStartLabel.text = @"全部开始";
                    }
                    
                    break;
                }
            }
        }
        
        
        // 更新数据库
        ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
        [manager updateRecordWithMyid:weakSelf.downControManager.currentItem.myid useIsover:weakSelf.downControManager.currentItem.isover];
        
        
        // 继续下载下一个
        if (weakSelf.downControManager.downloadWaitingArr.count != 0) {
            ZJCDownItem * item = weakSelf.downControManager.downloadWaitingArr[0];
            [weakSelf.downControManager startWithMyid:item.myid];
        }else{
            weakSelf.downControManager.downloader = nil;
            weakSelf.downControManager.currentItem = nil;
            
            // 这里可以尝试修改全部开始和全部暂停的按钮
            weakSelf.topStartBackView.selected = NO;
            weakSelf.topStartImageView.image = [UIImage imageNamed:@"startAll"];
            weakSelf.topStartLabel.text = @"全部开始";
        }
    };
    
    
    
    
    
    
    
    
    
    /**
     *  @brief 3.出错回调
     */
    _downControManager.errorBlock = ^(NSError * error){
        [weakSelf pauseTimer];
        weakSelf.isTimerGoing = NO;
        
        // 当前进行的项目,设置成暂停状态
        for (int i = 0 ; i < self.tableView.displayArray.count ; i++) {
            ZJCTreeModel * modelBig = weakSelf.tableView.displayArray[i];
            if (modelBig.depth == 0) {
                ZJCFirstLevelModel * firstLevelModel = modelBig.data;
                if ([firstLevelModel.myid isEqualToString:weakSelf.downControManager.currentItem.myid]) {
                    firstLevelModel.treeModelStatus = ZJCTreeModelStatusPause;
                    NSIndexPath * indexpath = [NSIndexPath indexPathForRow:i inSection:0];
                    [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
                    break;
                }
            }else if (modelBig.depth == 2){
                ZJCThirdLevelModel * thirdLevelModel = modelBig.data;
                if ([thirdLevelModel.myid isEqualToString:weakSelf.downControManager.currentItem.myid]) {
                    thirdLevelModel.treeModelStatus = ZJCTreeModelStatusPause;
                    NSIndexPath * indexpath = [NSIndexPath indexPathForRow:i inSection:0];
                    [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
                    break;
                }
            }
        }
        
        
        // 更新数据库
        ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
        [manager updateRecordWithMyid:weakSelf.downControManager.currentItem.myid useIsover:weakSelf.downControManager.currentItem.isover];
        
        
        // 继续下载下一个
        weakSelf.currentItem = nil;
        if (weakSelf.downControManager.downloadWaitingArr.count != 0) {
            ZJCDownItem * item = weakSelf.downControManager.downloadWaitingArr[0];
            [weakSelf.downControManager startWithMyid:item.myid];
        }else{
            weakSelf.downControManager.downloader = nil;
            weakSelf.downControManager.currentItem = nil;
        }
    };
}




























#pragma mark - 计时器
- (void)addTimer{
    // 开始定时器
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerGo) userInfo:nil repeats:YES];
    [_timer setFireDate:[NSDate distantFuture]];
}


// ***定时器运作方法
- (void)timerGo{
    // 获取当前每秒钟下载了多少
    _speedProgress = _totalBytesWritten - _oldSpeedProgress;
    _oldSpeedProgress = _totalBytesWritten;
    if (_speedProgress < 0) {
        _speedProgress = 0;
    }
    
    // 获取当前下载的item的位置,通过父类的id是否是本界面的父类id来判断
    NSString * currentMyid = self.downControManager.currentItem.myid;
    ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
    NSArray * tempArr = [NSArray arrayWithArray:[manager selectRecordWithMyid:currentMyid]];
    if (tempArr != nil) {
        NSString * parentId = [tempArr firstObject][@"myparentid"];
        NSArray * tempArr2 = [NSArray arrayWithArray:[manager selectRecordWithMyid:parentId]];
        if (tempArr != nil) {
            NSString * parentId2 = [tempArr2 firstObject][@"myparentid"];
            
            
            // 判断是否在当前界面下载了
            if ([parentId isEqualToString:self.myParentId] || [parentId2 isEqualToString:self.myParentId]) {
                logdebug(@"跑计时器");
                // 是否更换了indexpath
                if ([self.oldItem.myid isEqual:self.currentItem.myid]) {
                    NSInteger row = self.currentIndexPath.row;
                    ZJCTreeModel * modelBig = self.tableView.displayArray[row];
                    if (modelBig.depth == 0) {
                        ZJCFirstLevelModel * firstLevelModel = modelBig.data;
                        firstLevelModel.isover = self.currentItem.isover;
                        firstLevelModel.speed = self.speedProgress;
                        firstLevelModel.treeModelStatus = ZJCTreeModelStatusDownloading;
                    }else if (modelBig.depth == 2){
                        ZJCThirdLevelModel * thirdLevelModel = modelBig.data;
                        thirdLevelModel.isover = self.currentItem.isover;
                        thirdLevelModel.speed = self.speedProgress;
                        thirdLevelModel.treeModelStatus = ZJCTreeModelStatusDownloading;
                    }
                    
                }else{
                    // 更新本地的indexpath
                    for (int i = 0 ; i < self.tableView.displayArray.count ; i++) {
                        ZJCTreeModel * modelBig = self.tableView.displayArray[i];
                        if (modelBig.depth == 0) {
                            ZJCFirstLevelModel * firstLevelModel = modelBig.data;
                            if ([firstLevelModel.myid isEqualToString:self.currentItem.myid]) {
                                firstLevelModel.isover = self.currentItem.isover;
                                firstLevelModel.speed = self.speedProgress;
                                
                                // 更新本地储存的indexpath
                                self.currentIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                                
                                break;
                            }
                        }else if (modelBig.depth == 2){
                            ZJCThirdLevelModel * thirdLevelModel = modelBig.data;
                            if ([thirdLevelModel.myid isEqualToString:self.currentItem.myid]) {
                                thirdLevelModel.isover = self.currentItem.isover;
                                thirdLevelModel.speed = self.speedProgress;
                                
                                self.currentIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                                
                                break;
                            }
                        }
                        
                        
                    }
                    
                    // 更新记录的item
                    self.oldItem = [[ZJCDownItem alloc] initWithItem:self.currentItem];
                }
                
                // 3.刷新某一行
                if (self.currentIndexPath != nil) {
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.currentIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
                
                
                logdebug(@"在当前界面下载");
                if (self.isDownloading == YES) {
                    // ****添加 改变全部按钮的状态
                    self.topStartBackView.selected = YES;
                    self.topStartLabel.text = @"全部暂停";
                    self.topStartImageView.image = [UIImage imageNamed:@"pauseAll"];
                }
                
            }else{
                logdebug(@"不在当前界面下载了");
                self.isDownloading = NO;
                // ****添加 改变全部按钮的状态
                self.topStartBackView.selected = NO;
                self.topStartLabel.text = @"全部开始";
                self.topStartImageView.image = [UIImage imageNamed:@"startAll"];
            }
        }
    }
}



// 干掉定时器
- (void)removeTimer{
    [_timer invalidate];
}


// 暂停定时器
- (void)pauseTimer{
    [_timer setFireDate:[NSDate distantFuture]];
}


// 开始定时器
- (void)startTimer{
    [_timer setFireDate:[NSDate distantPast]];
}



@end

