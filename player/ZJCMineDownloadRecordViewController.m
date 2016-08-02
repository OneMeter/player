//
//  ZJCMineDownloadRecordViewController.m
//  CCRA
//
//  Created by htkg on 16/3/31.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCMineDownloadRecordViewController.h"
#import "ZJCMineDownloadModel.h"
#import "ZJCMineDownloadTableViewCell.h"
#import "ZJCMineDownloadRecordDetailViewController.h"
#import "ZJCTableView.h"


@interface ZJCMineDownloadRecordViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,strong) ZJCTableView * tableView;
@property (nonatomic ,strong) NSMutableArray * dataSource;
@property (nonatomic ,strong) UIImageView * deleteImage;           // 右上角编辑按钮
@property (nonatomic ,strong) UIBarButtonItem * rightBarButton;
@property (nonatomic ,strong) UILabel * deleteLabel;

@property (nonatomic ,strong) UIButton  * topStartBackView;        // 顶部全部开始按钮  底板
@property (nonatomic ,strong) UIImageView * topStartImageView;     // 开始图片
@property (nonatomic ,strong) UILabel * topStartLabel;             // 开始字体

@property (nonatomic ,strong) UIView * deleteBackView;             // 下部删除的底板
@property (nonatomic ,strong) UIButton * deleteButton;             // 删除按钮
@property (nonatomic ,strong) UIButton * selectAllButton;          // 全选按钮

@property (nonatomic ,assign) BOOL isEdit; 
@property (nonatomic ,assign) NSInteger seletedNumber;

@property (nonatomic ,strong) NSTimer * timer;                     // 计时器
@property (nonatomic ,assign) CGFloat sumRecordCount;              // 计数
@property (nonatomic ,assign) CGFloat sumProgress;                 // 总进度

@property (nonatomic ,strong) ZJCDownControl * downControManager;  // 下载控制器
@property (nonatomic ,assign) float progress;
@property (nonatomic ,assign) NSInteger totalBytesWritten;
@property (nonatomic ,assign) NSInteger totalBytesExpectedToWrite;
@property (nonatomic ,assign) NSInteger currentProgress;
@property (nonatomic ,assign) NSInteger oldProgress;
@property (nonatomic ,assign) NSInteger speedProgress;

@property (nonatomic ,strong) NSMutableArray * downloadStatusArray;  // 下载状态储存类

@end




@implementation ZJCMineDownloadRecordViewController

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化
    [self selfInitDownloadRecordVC];
    // 请求数据
    [self loadDownloadRecordData];
    // 搭建UI
    //    [self creatDownloadRecordUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 出现导航栏
    self.navigationController.navigationBarHidden = NO;
    // 隐藏tabbar
    self.tabBarController.tabBar.hidden = YES;
    // 设置状态栏的类型
    [self setNeedsStatusBarAppearanceUpdate];
    // 初始化下载进度
    self.progress = 0;
    self.totalBytesExpectedToWrite = 0;
    self.totalBytesWritten = 0;
    // 获取下载器回调
    [self getDownControlBlock];
    // 打开计时器
    [self startTimer];
    // 刷新界面
    [self reloadTableView];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    
    // 初始化
    self.progress = 0;
    self.totalBytesExpectedToWrite = 0;
    self.totalBytesWritten = 0;
    
    // 关闭计时器
    [self pauseTimer];
}


// 隐藏状态栏
- (BOOL)prefersStatusBarHidden{
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc{
    [_timer invalidate];
}








#pragma mark - 初始化
- (void)selfInitDownloadRecordVC{
    // 编辑状态
    _isEdit = NO;
    _seletedNumber = 0;
    
    // 背景色
    self.view.backgroundColor = ZJCGetColorWith(219, 219, 219, 1);
    
    // 标题
    self.title = @"缓存列表";
    // 右边的那个按钮
    [self creatDelegateButton];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 数据模型初始化
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    if (_downloadStatusArray == nil) {
        _downloadStatusArray = [[NSMutableArray alloc] init];
    }
    
    // 计时器相关
    [self creatTimer];
    _sumRecordCount = 0.0f;
    _sumProgress = 0.0f;
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


- (void)deleteBarButtonClicked:(UITapGestureRecognizer *)tap{
    [_tableView removeFromSuperview];
    loginfo(@"删除按钮点击了");
    if (_isEdit == YES) {        // 结束编辑
        _rightBarButton.customView = _deleteImage;  
        _deleteBackView.hidden = YES;
        _isEdit = !_isEdit;
        
        // 重置选中参数
        for (ZJCMineDownloadModel * model in _dataSource) {
            model.isSelected = NO;
        }
        _seletedNumber = 0;
        [_deleteButton setTitle:@"删  除" forState:UIControlStateNormal];
        
        [self createTableView];
        
    }else if(_isEdit == NO){    // 开始编辑
        _rightBarButton.customView = _deleteLabel;
        _deleteBackView.hidden = NO;
        _isEdit = !_isEdit;
        [self createTableView];
    }
}












#pragma mark - 请求数据
- (void)loadDownloadRecordData{
    // 1.请求数据库,结合本地的数据类型
    ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
    // 2.凡是数据库里面的父节点是-1的就是根节点  (这个是自定义的...)
    NSArray * array = [manager selectRecordWithMyParentid:@"-1"];
    if (array != nil) {
        NSMutableArray * changeArr = [ZJCMineDownloadModel arrayOfModelsFromDictionaries:array];
        for (ZJCMineDownloadModel * model in changeArr) {
            model.isSelected = NO;
            model.speed = 0;
            model.isDownloading = NO;
        }
        
        _dataSource = [NSMutableArray arrayWithArray:changeArr];
        if (_dataSource.count>0) {
            // 搭建UI
            [self creatDownloadRecordUI];
        }
        else{
            [self createNullUI];
        }
            
     
    }
}


- (void)reloadTableView{
    // 1.请求数据库,结合本地的数据类型
    ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
    NSMutableArray * arrayTemp = [[NSMutableArray alloc] init];
    
    // 2.凡是数据库里面的父节点是-1的就是根节点  (这个是自定义的...)
    NSArray * array = [manager selectRecordWithMyParentid:@"-1"];
    for (NSDictionary * dic in array) {
        NSArray * arr = [manager selectRecordWithMyParentid:dic[@"myid"]];
        if (arr.count != 0) {
            [arrayTemp addObject:dic];
        }
    }
    NSArray * arrModels = [ZJCMineDownloadModel arrayOfModelsFromDictionaries:arrayTemp];
    _dataSource = [NSMutableArray arrayWithArray:arrModels];
    [self.tableView reloadData];
}









#pragma mark - 搭建UI
- (void)creatDownloadRecordUI{
    // 顶部的全部开始按钮
    [self creatTopStartView];
    // 搭建底部删除面板
    [self creatDeleteView];
    // 搭建表格
    [self createTableView];
}


-(void)createNullUI{

    self.view.backgroundColor=[UIColor whiteColor];
    
    UIImage * image=[UIImage imageNamed:@"net_bad"];
    
    UIImageView * imageview=[[UIImageView alloc]initWithImage:image];
    imageview.size=CGSizeMake(159, 102);
    imageview.center=CGPointMake(self.view.frame.size.width/2, 225);
    [self.view addSubview:imageview];
   
    
    UILabel * label =[[UILabel alloc]initWithFrame:CGRectMake(imageview.frame.origin.x, imageview.frame.origin.y+imageview.frame.size.height+20, imageview.frame.size.width, 30)];
    [self.view addSubview:label];
    label.textAlignment=NSTextAlignmentCenter;
    label.text=@"暂时没有数据";
    
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
    ZJCDownControl * manager = [ZJCDownControl defaultControl];
    if (manager.downloadWaitingArr.count == 0) {
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
        
        
        // 判断当前是否还需要开始下载
        for (ZJCMineDownloadModel * model in _dataSource) {
            if ([model.isover floatValue] == 1) {
                _isAllDownloadOver = YES;
            }else{
                _isAllDownloadOver = NO;
                break;
            }
        }
        if (_isAllDownloadOver == YES) {
            [ZJCAlertView presentAlertWithAlertTitle:@"" andAlertMessage:@"已经下载完毕!" andAlertStyle:UIAlertControllerStyleAlert andSupportController:self completion:nil andDelay:1.5];
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
    
    // 2.处理模型
    ZJCDownControl * manager = [ZJCDownControl defaultControl];
    NSArray * sumArray = [NSArray arrayWithArray:manager.arraySumUseful];
    for (int i = 0 ; i < sumArray.count ; i++ ) {
        ZJCDownItem * item = sumArray[i];
        if (item.downloadStatus != ZJCDownLoaderStatusFinish) {
            [manager.downloadWaitingArr addObject:sumArray[i]];
        }
    }
    
    // 3.刷新界面
    [self.tableView reloadData];
    
    // 4.处理好了下载列表,拿出下载列表的第一个item开始下载
    if (self.downControManager.downloadWaitingArr.count != 0) {
        ZJCDownItem * item = [self.downControManager.downloadWaitingArr firstObject];
        [self.downControManager startWithMyid:item.myid];
    }
    
    // 5.打开计时器
    [self startTimer];
}







/**
 *  @brief 全部暂停的方法
 */
- (void)stopAllItems{
    // 1.暂停下载,暂停定时器
    [self.downControManager.downloader pause];
    [self pauseTimer];
    
    
    // 2.处理模型
    ZJCDownControl * manager = [ZJCDownControl defaultControl];
    [manager.downloadWaitingArr removeAllObjects];
    for (ZJCMineDownloadModel * mineModel in self.dataSource) {
        mineModel.isDownloading = ZJCMineDownloadModelStstusPause;
    }
    manager.downloader = nil;
    manager.currentItem = nil;
    
    // 3.刷新界面
    [self.tableView reloadData];
    
    // 5.打开计时器
    [self startTimer];
}


















#pragma mark - 搭建表格
- (void)createTableView{
    CGRect frame = CGRectZero;
    if (_isEdit == NO) {
        frame = CGRectMake(0, 64 + [ZJCFrameControl GetControl_Y:156+28], self.view.width, self.view.height-64 - [ZJCFrameControl GetControl_Y:156+28]);
    }else{
        frame = CGRectMake(0, 64 + [ZJCFrameControl GetControl_Y:156+28], self.view.width, self.view.height-64 - [ZJCFrameControl GetControl_Y:156+28] - [ZJCFrameControl GetControl_height:106]);
    }
    _tableView = [[ZJCTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view insertSubview:_tableView belowSubview:_deleteBackView];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ZJCFrameControl GetControl_Y:256];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // static NSString *ID = @"ID";
    ZJCMineDownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"aCell"];
    
    // cell编辑状态
    ZJCMineDownloadTableViewCellEditStatus cellEditStatus;
    if (_isEdit == YES) {
        cellEditStatus = ZJCMineDownloadTableViewCellEditStatusEdit;
    }else if(_isEdit == NO){
        cellEditStatus = ZJCMineDownloadTableViewCellEditStatusNono;
    }
    if (!cell) {
        cell = [[ZJCMineDownloadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"aCell" andEditStatus:cellEditStatus];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // cell类型
    if (indexPath.row < 5) {
        cell.cellType = ZJCMineDownloadTableViewCellNow;
    }else if (indexPath.row == 5) {
        cell.cellType = ZJCMineDownloadTableViewCellDoneNotWatch;
    }else{
        cell.cellType = ZJCMineDownloadTableViewCellDone;
    }
    cell.model = _dataSource[indexPath.row];
    
    // 回调相关
    __weak typeof(self)WeakSelf = self;
    cell.editButtonClickedBlock = ^(UIButton * button,ZJCMineDownloadTableViewCell * cell){
        ZJCMineDownloadModel * model = WeakSelf.dataSource[indexPath.row];
        if (button.selected == NO) {
            model.isSelected = NO;
            _seletedNumber--;
            if (_seletedNumber == 0) {
                [_deleteButton setTitle:@"删  除" forState:UIControlStateNormal];
            }else{
                [_deleteButton setTitle:[NSString stringWithFormat:@"删  除(%lu)",(long)_seletedNumber] forState:UIControlStateNormal];
            }
        }else{
            model.isSelected = YES;
            _seletedNumber++;
            [_deleteButton setTitle:[NSString stringWithFormat:@"删  除(%lu)",(long)_seletedNumber] forState:UIControlStateNormal];
        }
    };
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isEdit == YES) {    // 编辑状态下        
        
        
    }else{                   // 正常状态下
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        ZJCMineDownloadRecordDetailViewController * detailVC = [[ZJCMineDownloadRecordDetailViewController alloc] init];
        ZJCMineDownloadModel * model = _dataSource[indexPath.row];
        detailVC.myParentId = model.myid;
        detailVC.title = model.name;
        detailVC.isDownloading = model.isDownloading;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}













#pragma mark - 底部删除按钮
- (void)creatDeleteView{
    // 底板
    _deleteBackView = [[UIView alloc] init];
    [self.view addSubview:_deleteBackView];
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



// 全选按钮
- (void)selectAllButtonClicked:(UIButton *)button{
    if (_selectAllButton.selected == YES) {
        _selectAllButton.selected = NO;
        [_selectAllButton setTitle:@"全  选" forState:UIControlStateNormal];
        [_deleteButton setTitle:@"删  除" forState:UIControlStateNormal];
        for (int i = 0 ; i < _dataSource.count ; i++) {
            ZJCMineDownloadModel * model = _dataSource[i];
            model.isSelected = NO;
        }
        
        [_tableView reloadData];
        
    }else{
        _selectAllButton.selected = YES;
        [_selectAllButton setTitle:@"取消全选" forState:UIControlStateNormal];
        [_deleteButton setTitle:[NSString stringWithFormat:@"删  除(%lu)",(unsigned long)_dataSource.count] forState:UIControlStateNormal];
        for (int i = 0 ; i < _dataSource.count ; i++) {
            ZJCMineDownloadModel * model = _dataSource[i];
            model.isSelected = YES;
        }
        
        [_tableView reloadData];
    }
}




// 删除按钮
- (void)deleteButtonClicked:(UIButton *)button{
    // 
    [self.downControManager.downloader pause];
    
    
    // 1.删除 本地的数据源操作
    NSMutableArray * tempArray = [NSMutableArray array];
    for (int i = 0; i < _dataSource.count; i++) {
        ZJCMineDownloadModel * model = _dataSource[i];
        if (model.isSelected == NO) {
            [tempArray addObject:model];
        }
    }
    
    // 2.删除 数据库数据删除操作 (从最里层往外挨个干掉)
    ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
    ZJCDownControl * downManager = [ZJCDownControl defaultControl];
    for (int i = 0 ; i < _dataSource.count; i++) {
        ZJCMineDownloadModel * model = _dataSource[i];
        if (model.isSelected == YES) {
            NSArray * tempArr = [manager selectRecordWithMyParentid:model.myid];
            for (int j = 0 ; j < tempArr.count ; j++) {
                [manager deleteRecordWithMyParentId:[tempArr[j] objectForKey:@"myid"]];       // 先干掉　　"课节"
                [downManager removeItemWithItsParentID:[tempArr[j] objectForKey:@"myid"]];    // 先干掉　　"课节"
            }
            [manager deleteRecordWithMyParentId:model.myid];       // 接着干掉　　　"章节"
            [downManager removeItemWithItsParentID:model.myid];
            [manager deleteRecordWithMyid:model.myid];             // 最后干掉　　　"课程"
            
        }
    }
    
    
    // 重置
    _dataSource = [NSMutableArray arrayWithArray:tempArray];
    [_deleteButton setTitle:@"删  除" forState:UIControlStateNormal];
    [_selectAllButton setTitle:@"全  选" forState:UIControlStateNormal];
    _seletedNumber = 0;
    [_tableView reloadData];
    
    
    // 下载器是否需要继续下载
    if (self.downControManager.downloadWaitingArr  != 0) {
        ZJCDownItem * item = [self.downControManager.downloadWaitingArr firstObject];
        if ([self.downControManager.currentItem.myid isEqualToString:item.myid]) {
            [self.downControManager.downloader resume];
        }else{
            [self.downControManager startWithMyid:item.myid];
        }
    }
}












#pragma mark - 获取Block回调
- (void)getDownControlBlock{
    // 获取下载管理类
    _downControManager = [ZJCDownControl defaultControl];
    // 下载管理类的回调
    // 1.进度回调
    __weak typeof(self)weakSelf = self;
    _downControManager.progerssBlock = ^(float progress, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite,ZJCDownItem * currentItem){
        weakSelf.progress = progress;
        weakSelf.totalBytesExpectedToWrite = totalBytesExpectedToWrite;
        weakSelf.totalBytesWritten = totalBytesWritten;
        logdebug(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
    };
}















#pragma mark - 计时器相关
- (void)creatTimer{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerForward:) userInfo:nil repeats:YES];
    [_timer setFireDate:[NSDate distantFuture]];
}


// 计时器计步
- (void)timerForward:(NSTimer *)timer{
    // 1.如果当前正在下载的话
    self.speedProgress = self.totalBytesWritten - self.oldProgress;
    self.oldProgress = self.totalBytesWritten;
    if (self.speedProgress < 0) {
        self.speedProgress = 0;
    }
    
    
    // 2.计算当前每个cell下对应的数据库模型的进度
    ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
    for (ZJCMineDownloadModel * model in self.dataSource) {
        // 获取二级列表 集合
        NSString * firstModelId = model.myid;
        NSArray * arrayOfSecond = [NSArray arrayWithArray:[manager selectRecordWithMyParentid:firstModelId]];
        // 获取三级列表 集合
        for (NSDictionary * dicSecond in arrayOfSecond) {
            NSString * secondModelId = [NSString stringWithFormat:@"%@",dicSecond[@"myid"]];
            NSArray * arrayOfThird = [NSArray arrayWithArray:[manager selectRecordWithMyParentid:secondModelId]];
            // 是否有三级列表
            if (arrayOfThird.count == 0) {  // 没有  加上 该章进度
                _sumRecordCount++;
                _sumProgress += [dicSecond[@"isover"] floatValue];
            }else{                          // 有    加上 该节进度
                for (NSDictionary * dicThird in arrayOfThird) {
                    _sumRecordCount++;
                    _sumProgress += [dicThird[@"isover"] floatValue];
                }  
            }
        }
        
        // 上面都加完了 把结果加载到当前model中
        model.isover = [NSString stringWithFormat:@"%f",_sumProgress/_sumRecordCount];
        model.speed = self.speedProgress;
        
        
        
        // 更新数据库,重置下载进度
        [manager updateRecordWithMyid:model.myid useIsover:model.isover];
        _sumRecordCount = 0;
        _sumProgress = 0;
    }
    
    

    
    
    
    // 3.******根据当前下载控制类的数据状态  判断当前课程的状态(正在下载  暂停  等待)
    NSArray * arrTemp = [NSArray arrayWithArray:[manager selectRecordWithMyid:_downControManager.currentItem.myid]];  // 查询到当前正在下载项目对应的数据库"模型"
    if (arrTemp.count != 0) {
        // 获取当前下载item的父节点  获取其父亲节点id  以及对应的数据库"模型"
        NSString * parentid = [arrTemp firstObject][@"myparentid"];
        NSArray * arrTemp2 = [NSArray arrayWithArray:[manager selectRecordWithMyid:parentid]];
        if (arrTemp2.count != 0) {
            // 再次获取父节点的父节点  父亲节点id  以及对应的数据库"模型"
            NSString * parentid2 = [arrTemp2 firstObject][@"myparentid"];
            // 当前下载 是二级列表 (章)
            if ([parentid2 isEqualToString:@"-1"]) {
                for (ZJCMineDownloadModel * mineModel in self.dataSource) {
                    if ([mineModel.myid isEqualToString:parentid]) {
                        mineModel.isDownloading = ZJCMineDownloadModelStstusDownloading;
                    }else{
                        mineModel.isDownloading = ZJCMineDownloadModelStstusWait;
                    }
                }
                
            }
            // 当前下载 是三级列表 (节)
            else{
                for (ZJCMineDownloadModel * minemodel in self.dataSource) {
                    if ([minemodel.myid isEqualToString:parentid2]) {
                        minemodel.isDownloading = ZJCMineDownloadModelStstusDownloading;
                    }else{
                        minemodel.isDownloading = ZJCMineDownloadModelStstusWait;
                    }
                }
            }
        }
    }else{
        for (ZJCMineDownloadModel * modelPer in self.dataSource) {
            modelPer.isDownloading = ZJCMineDownloadModelStstusPause;
        }
    }
    
    
    
    
    
    
    
    
    
    
    // 4.更新当前model和界面进度
    [self.tableView reloadData];
    
    
    // 5.全部开始全部结束按钮
    ZJCDownControl * downloadControlManager = [ZJCDownControl defaultControl];
    if (downloadControlManager.downloadWaitingArr.count == 0) {
        self.topStartBackView.selected = NO;
        self.topStartImageView.image = [UIImage imageNamed:@"startAll"];
        self.topStartLabel.text = @"全部开始";
    }else{
        self.topStartBackView.selected = YES;
        self.topStartImageView.image = [UIImage imageNamed:@"pauseAll"];
        self.topStartLabel.text = @"全部暂停";
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
