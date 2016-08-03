//
//  ZJCDownloadListViewController.m
//  CCRA
//
//  Created by htkg on 16/3/30.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCDownloadListViewController.h"
#import "ZJCDownloadListHeader.h"
#import "ZJCDownListModel.h"
#import "AppDelegate.h"

// 下载列表
#import "ZJCMineDownloadRecordViewController.h"
// 下载管理对象
#import "ZJCDownItem.h"

// 刷新视图
#import "LPRefresh.h"






@interface ZJCDownloadListViewController ()

@end








@implementation ZJCDownloadListViewController

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化
    [self selfInitDownloadListVC];
    // 搭建UI
    [self creatDownloadListUI];
    // 请求数据
    [self loadDownloadListData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //
    self.automaticallyAdjustsScrollViewInsets = NO;
    // 始终不隐藏navigationBar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    // 隐藏tabbar
    [self.tabBarController.tabBar setHidden:YES];
    // 刷新一下表格,因为需要时刻计算缓存数量
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 始终不隐藏navigationBar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    // 隐藏tabbar
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - 初始化
- (void)selfInitDownloadListVC{
    // 标题
    self.title = @"下载列表";
    // Navigation左item
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    // Navigation右item
    [self addRightBarbutton];
}

- (void)addRightBarbutton{
    UIButton * view = [[UIButton alloc] initWithFrame:CGRectMake(IPhone6Plus_SCREEN_WIDTH*20/1080.0, 0, IPhone6Plus_SCREEN_WIDTH*235/1080.0, IPhone6Plus_SCREEN_WIDTH*128/1080.0)];
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(IPhone6Plus_SCREEN_WIDTH*170/1080.0, IPhone6Plus_SCREEN_WIDTH*39/1080.0, IPhone6Plus_SCREEN_WIDTH*45/1080.0, IPhone6Plus_SCREEN_WIDTH*45/1080.0)];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, IPhone6Plus_SCREEN_WIDTH*39/1080.0, IPhone6Plus_SCREEN_WIDTH*170/1080.0, IPhone6Plus_SCREEN_WIDTH*50/1080.0)];
    imageView.image = [UIImage imageNamed:@"navigationbar_right"];
    [view addSubview:imageView];
    label.text = @"缓冲列表";
    label.font = [UIFont systemFontOfSize:18];
    label.adjustsFontSizeToFitWidth = YES;
    label.textColor = [UIColor whiteColor];
    [view addSubview:label];
    [view addTarget:self action:@selector(rightBarButtonItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:view];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (void)rightBarButtonItemClicked:(UIBarButtonItem *)barbutton{
    ZJCMineDownloadRecordViewController * mineDownLoadVC = [[ZJCMineDownloadRecordViewController alloc] init];
    [self.navigationController pushViewController:mineDownLoadVC animated:YES];
}





#pragma mark - 请求数据
- (void)loadDownloadListData{
    // 1.拼接请求URL
#if 1
    AppDelegate * appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString * codeId = [NSString stringWithFormat:@"%@_ios",appdelegate.codeId];
    NSString * username = [ZJCNSUserDefault getDataUsingNSUserDefaultWithDataType:ZJCUserInfor andKey:UserLoadInfor_LoadName];
    //下载列表接口
    NSString * urlString = [NSString stringWithFormat:@"http://app.ccs163.net/downlist/%@/%@",codeId,username];
#else
    NSString * urlString = @"http://app.ccs163.net/downlist/2016041302215900_ios/pjb123";
#endif
    
    // 添加菊花视图
    ZJCLoadingView * loadingView = [[ZJCLoadingView alloc] initWithFrame:SCREEN_BOUNDS];
    [loadingView showLoading];
    [AFHTTPRequestOperationManager GET:urlString parameter:nil success:^(id responseObject) {
        // 干掉菊花视图
        [loadingView dismissLoading];
        
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        // 获得数据成功后,处理数据(变成本地需要的模型格式)
        if ([dic[@"bl"] isEqualToNumber:@1]) {
            NSArray * arr = [self handleReceiveDataWithData:dic[@"data"]];
            _dateArray = [NSMutableArray arrayWithArray:arr];
            
            [self reloadDataForDisplayArray];
        }
        
    } failure:^(NSError *error) {
        // 干掉菊花视图
        [loadingView dismissLoading];
        
        // 添加网络出错的图片
        ZJCHttpRequestErrorViews * errorViews = [[ZJCHttpRequestErrorViews alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:errorViews];
        __block ZJCHttpRequestErrorViews * blockErrorViews = errorViews;
        errorViews.requestRepetButtonClicked = ^(UIButton * button){
            [self loadDownloadListData];
            [blockErrorViews removeFromSuperview];
        };
    }];
}



// 后台数据类型  转接  本地数据类型
- (NSArray *)handleReceiveDataWithData:(NSMutableArray *)dataArr{
    NSMutableArray * sumArray = [[NSMutableArray alloc] init];
    // 三层数据结构的赋值
    for (int i = 0; i < dataArr.count; i++) {
        ZJCDownListModel * baseModelTempFirst = [[ZJCDownListModel alloc] init];
        baseModelTempFirst.nodeLevel= 0;
        baseModelTempFirst.type     = 0;
        baseModelTempFirst.sonNodes = nil;
        baseModelTempFirst.isExpanded = NO;
        ZJC_LEVEL0_Model * firstLevelModel = [[ZJC_LEVEL0_Model alloc] init];
        NSDictionary * dicTempFirst = dataArr[i];
        firstLevelModel.name        = dicTempFirst[@"name"];
        firstLevelModel.sumlessons  = [dicTempFirst[@"sumlessons"] stringValue];
        if ([dicTempFirst[@"cover"] isKindOfClass:[NSNull class]]) {
            firstLevelModel.cover   =  @"";
        }else{
            firstLevelModel.cover   =  dicTempFirst[@"cover"];
        }
        firstLevelModel.myid        = [dicTempFirst[@"id"] stringValue];
        firstLevelModel.parentid    = @"-1";
        firstLevelModel.headImgPath = @"banner";
        baseModelTempFirst.nodeData = firstLevelModel;
        NSMutableArray * firstNodes = [[NSMutableArray alloc] init];
        
        for (int j = 0; j < [dicTempFirst[@"son"] count] ; j++) {
            ZJCDownListModel * baseModelTempSecond = [[ZJCDownListModel alloc] init];
            baseModelTempSecond.nodeLevel  = 1;
            baseModelTempSecond.type       = 1;
            baseModelTempSecond.sonNodes   = nil;
            baseModelTempSecond.isExpanded = NO;
            ZJC_LEVEL1_Model * secondLevelModel = [[ZJC_LEVEL1_Model alloc] init];
            NSDictionary * dicTempSecond = dicTempFirst[@"son"][j];
            secondLevelModel.parentid      =  [dicTempFirst[@"id"] stringValue];
            secondLevelModel.myid          =  [dicTempSecond[@"id"] stringValue];
            secondLevelModel.name          =  dicTempSecond[@"name"];
            if ([dicTempSecond[@"cover"] isKindOfClass:[NSNull class]]) {
                secondLevelModel.cover     =  @"";
            }else{
                secondLevelModel.cover     =  dicTempSecond[@"cover"];
            }
            secondLevelModel.eid           =  [dicTempSecond[@"eid"] stringValue];
            secondLevelModel.ispaper       =  [dicTempSecond[@"ispaper"] stringValue];
            secondLevelModel.studybar      =  [dicTempSecond[@"studybar"] stringValue];
            secondLevelModel.videoduration =  dicTempSecond[@"videoduration"];
            secondLevelModel.videoid       =  dicTempSecond[@"videoid"];
            secondLevelModel.sonCnt        =  [NSString stringWithFormat:@"%lu",[dicTempSecond[@"son"] count]];
            baseModelTempSecond.nodeData = secondLevelModel;
            NSMutableArray * secondNodes = [[NSMutableArray alloc] init];
            
            
            for (int q = 0 ; q < [dicTempSecond[@"son"] count] ; q++) {
                ZJCDownListModel * baseModelTempThird = [[ZJCDownListModel alloc] init];
                baseModelTempThird.nodeLevel  = 2;
                baseModelTempThird.type       = 2;
                baseModelTempThird.orderNumber= q + 1;
                baseModelTempThird.sonNodes   = nil;
                baseModelTempThird.isExpanded = NO;
                ZJC_LEVEL2_Model * thirdLevelModel = [[ZJC_LEVEL2_Model alloc] init];
                NSDictionary * dictempThird = dicTempSecond[@"son"][q];
                thirdLevelModel.parentid      =  [dicTempSecond[@"id"] stringValue];
                thirdLevelModel.myid          =  [dictempThird[@"id"] stringValue];
                thirdLevelModel.name          =  dictempThird[@"name"];
                if ([dictempThird[@"cover"] isKindOfClass:[NSNull class]]) {
                    thirdLevelModel.cover     =  @"";
                }else{
                    thirdLevelModel.cover     =  dicTempFirst[@"cover"];
                }
                thirdLevelModel.eid           =  [dictempThird[@"eid"] stringValue];
                thirdLevelModel.ispaper       =  [dictempThird[@"ispaper"] stringValue];
                thirdLevelModel.studybar      =  [dictempThird[@"studybar"] stringValue];
                thirdLevelModel.videoduration =  dictempThird[@"videoduration"];
                thirdLevelModel.videoid       =  dictempThird[@"videoid"];
                baseModelTempThird.nodeData = thirdLevelModel;
                
                [secondNodes addObject:baseModelTempThird];
            }
            baseModelTempSecond.sonNodes = secondNodes;
            [firstNodes addObject:baseModelTempSecond];
        }
        baseModelTempFirst.sonNodes = firstNodes;
        [sumArray addObject:baseModelTempFirst];
    }
    NSArray * returnArr = [NSArray arrayWithArray:sumArray];
    return returnArr;
}


/**
 *  @brief 刷新界面
 */
- (void)reloadDownlistData{
    // 1.拼接请求URL
    AppDelegate * appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString * codeId = [NSString stringWithFormat:@"%@_ios",appdelegate.codeId];
    NSString * username = [ZJCNSUserDefault getDataUsingNSUserDefaultWithDataType:ZJCUserInfor andKey:UserLoadInfor_LoadName];
    //下载列表
    NSString * urlString = [NSString stringWithFormat:@"http://app.ccs163.net/downlist/%@/%@",codeId,username];
    
    [AFHTTPRequestOperationManager GET:urlString parameter:nil success:^(id responseObject) {
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        // 获得数据成功后,处理数据(变成本地需要的模型格式)
        if ([dic[@"bl"] isEqualToNumber:@1]) {
            // 更新刷新控件
            [_tableView endRefreshingSuccess];
            
            // 更新全选界面按钮
            [_selectAllButton setTitle:@"全  选" forState:UIControlStateNormal];
            
            // 刷新表格
            __block typeof(self)blockSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (_dateArray != nil) {
                    [_dateArray removeAllObjects];
                }
                NSArray * arr = [blockSelf handleReceiveDataWithData:dic[@"data"]];
                _dateArray = [NSMutableArray arrayWithArray:arr];
                [blockSelf reloadDataForDisplayArray];
            });
            
            
        }else{
            // 刷新失败
            [_tableView endRefreshingFail];
        }
        
        
        
    } failure:^(NSError *error) {
        // 刷新失败
        [_tableView endRefreshingFail];
        
        __block typeof(self)blockSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 干掉表格
            [blockSelf.displayDataArray removeAllObjects];
            [blockSelf.tableView reloadData];
            
            // 添加网络出错的图片
            ZJCHttpRequestErrorViews * errorViews = [[ZJCHttpRequestErrorViews alloc] initWithFrame:self.view.bounds];
            [self.view addSubview:errorViews];
            __block ZJCHttpRequestErrorViews * blockErrorViews = errorViews;
            errorViews.requestRepetButtonClicked = ^(UIButton * button){
                [blockSelf loadDownloadListData];
                [blockErrorViews removeFromSuperview];
            };
        });
    }];
}


















#pragma mark - 搭建UI
- (void)creatDownloadListUI{
    // 1.搭建表格
    [self createTableView];
    // 3.底部按钮
    [self creatDeleteView];
    // 加载数据,刷新表格
    [self reloadDataForDisplayArray];
}






#pragma mark - 搭建UITableView
- (void)createTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height - [ZJCFrameControl GetControl_height:106] - 64) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    
    // 添加刷新控件
    __weak typeof(self)weakSelf = self;
    [_tableView addRefreshWithBlock:^{
        // 刷新方法
        [weakSelf reloadDownlistData];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _displayDataArray.count;
}





/*---------------------------------------
 cell自定制函数
 --------------------------------------- */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // static NSString *ID = @"ID";
    static NSString *indentifier = @"level0cell";
    static NSString *indentifier1 = @"level1cell";
    static NSString *indentifier2 = @"level2cell";
    ZJCDownListModel * model = [_displayDataArray objectAtIndex:indexPath.row];
    if (model.type == 0) {
        ZJC_LEVEL0_TableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
        if (cell == nil) {
            cell = [[ZJC_LEVEL0_TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
        }
        [self loadDataForTreeViewCell:cell with:model andIndexPath:indexPath];
        [cell setNeedsDisplay];   // 重绘cell
        // 选中回调
        __weak typeof(self)weakSelf = self;
        cell.cell0SelectBlock = ^(ZJC_LEVEL0_TableViewCell * returnCell,UIButton * button){
            [weakSelf reloadCellsStatusWithButton:button andIndexPath:indexPath];
        };
        return cell;
        
        
        
    }else if(model.type == 1){
        ZJC_LEVEL1_TableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:indentifier1];
        if (cell == nil) {
            cell = [[ZJC_LEVEL1_TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier1];
        }
        [self loadDataForTreeViewCell:cell with:model andIndexPath:indexPath];
        [cell setNeedsDisplay];
        // 选中回调
        __weak typeof(self)weakSelf = self;
        cell.cell1SelectBlock = ^(ZJC_LEVEL1_TableViewCell * returnCell,UIButton * button){
            [weakSelf reloadCellsStatusWithButton:button andIndexPath:indexPath];
        };
        return cell;
        
        
        
        
    }else{
        ZJC_LEVEL2_TableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:indentifier2];
        if (cell == nil) {
            cell = [[ZJC_LEVEL2_TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier2];
        }
        [self loadDataForTreeViewCell:cell with:model andIndexPath:indexPath];
        [cell setNeedsDisplay];
        // 选中回调
        __weak typeof(self)weakSelf = self;
        cell.cell2SelectBlock = ^(ZJC_LEVEL2_TableViewCell * returnCell,UIButton * button){
            [weakSelf reloadCellsStatusWithButton:button andIndexPath:indexPath];
        };
        return cell;
    }
}

/**
 *  @brief 刷新表格(更新选中状态)
 */
- (void)reloadCellsStatusWithButton:(UIButton *)button andIndexPath:(NSIndexPath *)indexPath{
    // 1.刷新数据
    if (button.selected == YES) {
        ZJCDownListModel * firstModel = [self.displayDataArray objectAtIndex:indexPath.row];
        firstModel.isSelected = YES;
        for (int i = 0 ; i < firstModel.sonNodes.count ; i++) {
            ZJCDownListModel * secondModel = firstModel.sonNodes[i];
            secondModel.isSelected = YES;
            for (int j = 0; j< secondModel.sonNodes.count ; j++) {
                ZJCDownListModel * thirdModel = secondModel.sonNodes[j];
                thirdModel.isSelected = YES;
            }
        }
        
        // 2.真是见了鬼了...
        for (ZJCDownListModel * firstModel in self.displayDataArray) {
            for (ZJCDownListModel * secondModel in firstModel.sonNodes) {
                for (ZJCDownListModel * thirdModel in secondModel.sonNodes) {
                    if (thirdModel.isSelected == NO) {
                        secondModel.isSelected = NO;
                        break;
                    }
                    secondModel.isSelected = YES;
                }
                if (secondModel.isSelected == NO) {
                    firstModel.isSelected = NO;
                    break;
                }
                firstModel.isSelected = YES;
            }
        }
        
    }else{
        ZJCDownListModel * firstModel = [self.displayDataArray objectAtIndex:indexPath.row];
        firstModel.isSelected = NO;
        for (int i = 0 ; i < firstModel.sonNodes.count ; i++) {
            ZJCDownListModel * secondModel = firstModel.sonNodes[i];
            secondModel.isSelected = NO;
            for (int j = 0; j< secondModel.sonNodes.count ; j++) {
                ZJCDownListModel * thirdModel = secondModel.sonNodes[j];
                thirdModel.isSelected = NO;
            }
        }
        
        // 2.真是见了鬼了...
        for (ZJCDownListModel * firstModel in self.displayDataArray) {
            for (ZJCDownListModel * secondModel in firstModel.sonNodes) {
                for (ZJCDownListModel * thirdModel in secondModel.sonNodes) {
                    if (thirdModel.isSelected == NO) {
                        secondModel.isSelected = NO;
                        break;
                    }
                }
                if (secondModel.isSelected == NO) {
                    firstModel.isSelected = NO;
                    break;
                }
            }
        }
    }
    
    
    // 3.更新表格
    [self.tableView reloadData];
    
    // 4.更新下面的全选
    for (ZJCDownListModel * firstModel in self.displayDataArray) {
        for (ZJCDownListModel * secondModel in firstModel.sonNodes) {
            for (ZJCDownListModel * thirdModel in secondModel.sonNodes) {
                if (thirdModel.isSelected == NO) {
                    [_selectAllButton setTitle:@"全  选" forState:UIControlStateNormal];
                    break;
                }
                [_selectAllButton setTitle:@"取消全选" forState:UIControlStateNormal];
            }
            if (secondModel.isSelected == NO) {
                [_selectAllButton setTitle:@"全  选" forState:UIControlStateNormal];
                break;
            }
            [_selectAllButton setTitle:@"取消全选" forState:UIControlStateNormal];
        }
        if (firstModel.isSelected == NO) {
            [_selectAllButton setTitle:@"全  选" forState:UIControlStateNormal];
            break;
        }
        [_selectAllButton setTitle:@"取消全选" forState:UIControlStateNormal];
    }
}










/*---------------------------------------
 为不同类型cell填充数据
 --------------------------------------- */
#pragma mark - 不同类型的cell填充数据  >>>  其实是根据数据源里面的数据结构进行的判断,当前的cell需要填充什么数据
- (void)loadDataForTreeViewCell:(UITableViewCell *)cell with:(ZJCDownListModel *)sumModel andIndexPath:(NSIndexPath *)indexPath{
    if (sumModel.type == 0) {         // 说明这是一级列表
        ZJC_LEVEL0_Model * firstModel = sumModel.nodeData;
        ((ZJC_LEVEL0_TableViewCell *)cell).myTitleLabel.text = firstModel.name;
        ((ZJC_LEVEL0_TableViewCell *)cell).courseNumberLabel.text = [NSString stringWithFormat:@"%@节课",firstModel.sumlessons];
        // 获取已经缓存的数量
        NSInteger downLoadCount = [ZJCFMDBManager selectDownloadRecordCountsWithMyid:firstModel.myid];
        
        ((ZJC_LEVEL0_TableViewCell *)cell).downNumberLabel.text = [NSString stringWithFormat:@"已缓存(%ld/%@)",(long)downLoadCount,firstModel.sumlessons];
        [((ZJC_LEVEL0_TableViewCell *)cell).themeImageView sd_setImageWithURL:[NSURL URLWithString:firstModel.cover] placeholderImage:[UIImage imageNamed:@"banner"]];
        
        
        if (sumModel.isSelected == YES) {
            ((ZJC_LEVEL0_TableViewCell *)cell).selectImageView.image = [UIImage imageNamed:@"select_select"];
            ((ZJC_LEVEL0_TableViewCell *)cell).selectButton.selected = YES;
        }else{
            ((ZJC_LEVEL0_TableViewCell *)cell).selectImageView.image = [UIImage imageNamed:@"selectbutton_nor"];
            ((ZJC_LEVEL0_TableViewCell *)cell).selectButton.selected = NO;
        }
        if (sumModel.isExpanded == YES) {
            ((ZJC_LEVEL0_TableViewCell *)cell).arrowImageView.image = [UIImage imageNamed:@"cour_arrow_down"];
        }else{
            ((ZJC_LEVEL0_TableViewCell *)cell).arrowImageView.image = [UIImage imageNamed:@"cour_arrow_up"];
        }
        
        
    }else if (sumModel.type == 1){    // 二级列表
        ZJC_LEVEL1_Model * secondModel = sumModel.nodeData;
        ((ZJC_LEVEL1_TableViewCell *)cell).myTitleLabel.text = secondModel.name;
        if (sumModel.isSelected == YES) {
            ((ZJC_LEVEL1_TableViewCell *)cell).selectImageView.image = [UIImage imageNamed:@"select_select"];
            ((ZJC_LEVEL1_TableViewCell *)cell).selectButton.selected = YES;
        }else{
            ((ZJC_LEVEL1_TableViewCell *)cell).selectImageView.image = [UIImage imageNamed:@"selectbutton_nor"];
            ((ZJC_LEVEL1_TableViewCell *)cell).selectButton.selected = NO;
        }
        
        
    }else if (sumModel.type == 2){    // 三级列表
        ZJC_LEVEL2_Model * thirdModel = sumModel.nodeData;
        // 定位标题量
        ((ZJC_LEVEL2_TableViewCell *)cell).myTitleLabel.text = [NSString stringWithFormat:@"%.2ld %@",(long)sumModel.orderNumber,thirdModel.name];
        NSString * timeHor = [thirdModel.videoduration componentsSeparatedByString:@":"][0];
        NSString * timeMin = [thirdModel.videoduration componentsSeparatedByString:@":"][1];
        ((ZJC_LEVEL2_TableViewCell *)cell).timeLabel.text = [NSString stringWithFormat:@"%d分钟",[timeMin intValue] + [timeHor intValue]*60];
        if (sumModel.isSelected == YES) {
            ((ZJC_LEVEL2_TableViewCell *)cell).selectImageView.image = [UIImage imageNamed:@"select_select"];
            ((ZJC_LEVEL2_TableViewCell *)cell).selectButton.selected = YES;
        }else{
            ((ZJC_LEVEL2_TableViewCell *)cell).selectImageView.image = [UIImage imageNamed:@"selectbutton_nor"];
            ((ZJC_LEVEL2_TableViewCell *)cell).selectButton.selected = NO;
        }
    }
}




/*---------------------------------------
 cell高度默认为50
 ----------------------------------------*/
#pragma mark - 不同的cell类型对应不同的高度
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath{
    ZJCDownListModel * model = _displayDataArray[indexPath.row];
    int height = 0;
    if (model.type == 0) {
        height = [ZJCFrameControl GetControl_Y:260] + 1; 
        return height;
    }else if (model.type == 1){
        height = [ZJCFrameControl GetControl_Y:120] + 1;
        return height;
    }else{
        height = [ZJCFrameControl GetControl_Y:186] + 1;
        return height;
    }
}



/*--------------------------------------------------------------------------
 初始化将要显示的cell的数据  (其实就是从创建的data里面挑选出isExtend的选项  然后添加到
 实际的数据源里面,也就是disPlayDataSource  然后刷新表格)
 ---------------------------------------------------------------------------*/
#pragma mark - 给数据源加载数据
- (void)reloadDataForDisplayArray{
    NSMutableArray * tempArr = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < _dateArray.count; i++) {
        ZJCDownListModel * modelFirst = _dateArray[i];
        [tempArr addObject:modelFirst];
        if (modelFirst.isExpanded) {
            for (int j = 0 ; j < modelFirst.sonNodes.count; j++) {
                ZJCDownListModel * secondModel = modelFirst.sonNodes[j];
                [tempArr addObject:secondModel];
                if (secondModel.isExpanded) {
                    for (int q = 0; q < secondModel.sonNodes.count; q++) {
                        ZJCDownListModel * thirdModel = secondModel.sonNodes[q];
                        [tempArr addObject:thirdModel];
                    }
                }
            }
        }
    }
    
    _displayDataArray = [NSMutableArray arrayWithArray:tempArr];
    [self.tableView reloadData];
}




/*---------------------------------------
 处理cell选中事件，需要自定义的部分
 --------------------------------------- */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    // 刷新展开关闭的方法
    [self reloadDataForDisplayArrayChangeAt:indexPath.row];
}



/*---------------------------------------
 修改cell的状态(关闭或打开)
 --------------------------------------- */
- (void)reloadDataForDisplayArrayChangeAt:(NSInteger)row{
    NSMutableArray * temp = [[NSMutableArray alloc] init];
    NSInteger cnt = 0;
    for (ZJCDownListModel * modelFirst in _dateArray) {
        // 第一级列表肯定是存在的
        [temp addObject:modelFirst];
        if (cnt == row) {
            modelFirst.isExpanded = !modelFirst.isExpanded;
        }
        ++cnt;
        // 第二级列表  在第一级列表是否展开的基础上  判断是否添加
        if (modelFirst.isExpanded) {
            for (ZJCDownListModel * modelSecond in modelFirst.sonNodes) {
                [temp addObject:modelSecond];
                if (cnt == row) {
                    modelSecond.isExpanded = !modelSecond.isExpanded;
                }
                ++cnt;
                // 第三极列表  在第二级列表是否展开是基础上  判断是否添加
                if (modelSecond.isExpanded) {
                    for (ZJCDownListModel * modelThird in modelSecond.sonNodes) {
                        [temp addObject:modelThird];
                        ++cnt;
                    }
                }
            }
        }
    }
    
    // 添加给数据源
    _displayDataArray  = [NSMutableArray arrayWithArray:temp];
    [self.tableView reloadData];
}









#pragma mark - 搭建底部底部"全选"按钮
- (void)creatDeleteView{
    // 底板
    _confirmBackView = [[UIView alloc] initWithFrame:CGRectMake( 0, self.view.height - [ZJCFrameControl GetControl_height:106], self.view.width, [ZJCFrameControl GetControl_height:106])];
    [self.view addSubview:_confirmBackView];
    _confirmBackView.backgroundColor = [UIColor whiteColor];
    
    // "全选" 按钮
    _selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_confirmBackView addSubview:_selectAllButton];
    [_selectAllButton addTarget:self action:@selector(selectAllButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_selectAllButton setTitle:@"全  选" forState:UIControlStateNormal];
    [_selectAllButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    __weak __typeof(self) weakSelf = self; 
    [_selectAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.confirmBackView).offset([ZJCFrameControl GetControl_X:0]);
        make.top.equalTo(weakSelf.confirmBackView).offset([ZJCFrameControl GetControl_Y:0]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:1080/2], [ZJCFrameControl GetControl_height:106]));
    }];
    
    // "确认缓存" 按钮
    _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_confirmBackView addSubview:_confirmButton];
    [_confirmButton addTarget:self action:@selector(confirmButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_confirmButton setTitle:@"确认缓存" forState:UIControlStateNormal];
    [_confirmButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.confirmBackView.mas_right).offset(-[ZJCFrameControl GetControl_X:1080/2]);
        make.top.equalTo(weakSelf.confirmBackView).offset([ZJCFrameControl GetControl_Y:0]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:1080/2], [ZJCFrameControl GetControl_height:106]));
    }];
    
    // 分割线 (横 竖)
    UILabel * labelHeng = [[UILabel alloc] init];
    [_confirmBackView addSubview:labelHeng];
    labelHeng.backgroundColor = ZJCGetColorWith(219, 219, 219, 1);
    [labelHeng mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.confirmBackView).offset([ZJCFrameControl GetControl_X:0]);
        make.top.equalTo(weakSelf.confirmBackView).offset([ZJCFrameControl GetControl_Y:0]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:1080], [ZJCFrameControl GetControl_height:2]));
    }];
    
    // 分割线
    UILabel * labelShu = [[UILabel alloc] init];
    [_confirmBackView addSubview:labelShu];
    labelShu.backgroundColor = ZJCGetColorWith(219, 219, 219, 1);
    [labelShu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.confirmBackView).offset([ZJCFrameControl GetControl_X:1080/2]);
        make.top.equalTo(weakSelf.confirmBackView).offset([ZJCFrameControl GetControl_Y:0]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:2], [ZJCFrameControl GetControl_height:106]));
    }];
}



- (void)selectAllButtonClicked:(UIButton *)button{
    //
    button.selected = !button.selected;
    
    // 1.刷新表格
    BOOL isSelected = button.selected;
    for (int i = 0 ; i < self.displayDataArray.count ; i++) {
        ZJCDownListModel * firstModel = self.displayDataArray[i];
        firstModel.isSelected = isSelected;
        for (int k = 0 ; k < firstModel.sonNodes.count ; k++) {
            ZJCDownListModel * secondModel = firstModel.sonNodes[k];
            secondModel.isSelected = isSelected;
            for (int j = 0; j< secondModel.sonNodes.count ; j++) {
                ZJCDownListModel * thirdModel = secondModel.sonNodes[j];
                thirdModel.isSelected = isSelected;
            }
        }
    }
    [self.tableView reloadData];
    
    
    // 2.更新"全选状态"
    if (isSelected == YES) {
        [_selectAllButton setTitle:@"取消全选" forState:UIControlStateNormal];
    }else{
        [_selectAllButton setTitle:@"全  选" forState:UIControlStateNormal];
    }
}


- (void)confirmButtonClicked:(UIButton *)button{
    // 1.1 检测当前是否有文件
    BOOL choseSomething = [self checkIfHaveChoseSomething];
    if (choseSomething == YES) {
        // 1.2 检测当前的网络状态,提醒用户是否需要缓存
        [self checkNetworkStatu];
    }else{
        [ZJCAlertView presentAlertWithAlertTitle:@"提示" andAlertMessage:@"请您选择需要下载的课程~^_^~" andAlertStyle:UIAlertControllerStyleAlert andSupportController:self completion:nil andDelay:1.5];
    }
}













#pragma mark - &&&&&&&&&&&    检测当前是否选中了内容
- (BOOL)checkIfHaveChoseSomething{
    for (ZJCDownListModel * firstModel in self.displayDataArray) {
        
        if (firstModel.isSelected == YES) {
            _isChoseSomething = YES;
            return _isChoseSomething;
        }
        _isChoseSomething = NO;
        for (ZJCDownListModel * secondModel in firstModel.sonNodes) {
            if (secondModel.isSelected == YES) {
                _isChoseSomething = YES;
                return _isChoseSomething;
            }
            _isChoseSomething = NO;
            for (ZJCDownListModel * thirdModel in secondModel.sonNodes) {
                if (thirdModel.isSelected == YES) {
                    _isChoseSomething = YES;
                    return _isChoseSomething;
                }
                _isChoseSomething = NO;
            }
        }
    }
    return _isChoseSomething;
}







#pragma mark - &&&&&&&&&&&   检测网络状态
- (void)checkNetworkStatu{
    // 1.根据AppDelegate检测到的网络状态判断当前是否需要下载
    AppDelegate * appdelegate = AppDelegate_Public;
    switch (appdelegate.netWorkStatus) {
            
        case NetworkStatusReachableViaWiFi:           // 无线
        {
            // 2.提示用户已经添加到缓存列表
            [self popInformationAlert];
            
            // 3.添加到本地的数据库
            [self insertIntoFMDB];
            
            // ***4.同时就开始后台下载了
            [self startDownload];
        }
            break;
        case NetworkStatusReachableViaWWAN:           // 移动数据
        {
            if (appdelegate.isAllowDownloadOnlyWifi == YES) {           // 只允许无线下载  <= 我的设置"仅WiFi下载"
                [ZJCAlertView presentAlertWithAlertTitle:@"温馨提示" andAlertMessage:@"当前为移动网络,请关闭<我的设置>中\"只允许Wifi下载选项\"后重试" andAlertStyle:UIAlertControllerStyleAlert andSupportController:self completion:nil andDelay:2];
                
            }else if (appdelegate.isAllowDownloadOnlyWifi == NO){       // 可以移动网络下载
                UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                UIAlertAction * actionEnsure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    // 2.提示用户已经添加到缓存列表
                    [self popInformationAlert];
                    
                    // 3.添加到本地的数据库
                    [self insertIntoFMDB];
                    
                    // *4.同时就开始后台下载了
                    [self startDownload];
                }];
                [ZJCAlertView presentAlertWithAlertTitle:@"温馨提示" andAlertMessage:@"检测到您当前使用移动数据!\n下载会消耗流量,确认缓存?" andAlertStyle:UIAlertControllerStyleAlert andAlertActionArray:@[actionEnsure,actionCancel] andSupportController:self completion:nil];
            }
        }
            break;
        case NetworkStatusNotReachable:               // 不可用
        {
            [ZJCAlertView presentAlertWithAlertTitle:@"温馨提示" andAlertMessage:@"请打开网络后重试!" andAlertStyle:UIAlertControllerStyleAlert andSupportController:self completion:nil andDelay:2];
        }
            break;
        case NetworkStatusUnknown:                    // 未知
        {
            [ZJCAlertView presentAlertWithAlertTitle:@"温馨提示" andAlertMessage:@"未检测到当前网络状态,请检查网络设置后重试..." andAlertStyle:UIAlertControllerStyleAlert andSupportController:self completion:nil andDelay:2];
        }
            break;
        default:
            break;
    }
}



#pragma mark - &&&&&&&&&&&   提示已经添加到缓存列表
- (void)popInformationAlert{
    [ZJCAlertView presentAlertWithAlertTitle:@"提示" andAlertMessage:@"已经为您添加到缓存列表!" andAlertStyle:UIAlertControllerStyleAlert andSupportController:self completion:nil andDelay:2];
}


#pragma mark - &&&&&&&&&&&   加到数据库 
- (void)insertIntoFMDB{
    // 一、数据库管理类
    ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
    // 二、挨个存入数据库
    //   1.按层级往里面推进去  
    //   2.最里面的一层级如果有选中,那么上两个层级都要储存到数据库里面去
    //   3.最里面的层级都没有选中的项目,说明这节课就没有选中项目,上两个层级都不需要储存
    for (int i = 0 ; i < _displayDataArray.count ; i++) {
        ZJCDownListModel * modelFirstLevel = _displayDataArray[i];
        ZJC_LEVEL0_Model * firstMD = modelFirstLevel.nodeData;
        // 定位到一级列表层次 (diplaydata里面是全部的所有层级)
        if (modelFirstLevel.nodeLevel == 0) {
            for (int j = 0 ; j < modelFirstLevel.sonNodes.count ; j++) {
                //根据子节点的个数遍历二级目录 这里是一级目录
                ZJCDownListModel * modelSecondLevel = modelFirstLevel.sonNodes[j];
                ZJC_LEVEL1_Model * secondMD = modelSecondLevel.nodeData;
                // 如果没有三级列表 说明二级列表本身就是个视频,那就不需要继续判断是否需要存入三级列表了  (根据二级列表是否选中,依次存入对应的一级列表 => 二级列表)
                if (modelSecondLevel.sonNodes.count == 0) {
                    if (modelSecondLevel.isSelected == YES) {
                        [manager insertRecordWithMyid:firstMD.myid andMyParentId:firstMD.parentid andVedioId:firstMD.videoid andName:firstMD.name andMaxCount:firstMD.sumlessons andImageUrl:firstMD.cover andIsOver:@"0"];
                        [manager insertRecordWithMyid:secondMD.myid andMyParentId:secondMD.parentid andVedioId:secondMD.videoid andName:secondMD.name andMaxCount:secondMD.sonCnt andImageUrl:secondMD.cover andIsOver:@"0"];
                    }
                }
                // 如果有三级列表,说明二级列表本身是占位导航三级列表用的  (根据三级列表是否选中,依次存入对应的一级列表 => 二级列表 => 三级列表)
                else{
                    for (int k = 0 ; k < modelSecondLevel.sonNodes.count ; k++) {
                        ZJCDownListModel * modelThirdLevel = modelSecondLevel.sonNodes[k];
                        ZJC_LEVEL2_Model * thirdMD = modelThirdLevel.nodeData;
                        if (modelThirdLevel.isSelected == YES) {
                            // 最内层有选中  
                            // 先储存第一层级 再储存第二层级 最后储存当前层级
                            // 这样才不会出现漏选中某一个层级的状况
                            [manager insertRecordWithMyid:firstMD.myid andMyParentId:firstMD.parentid andVedioId:firstMD.videoid andName:firstMD.name andMaxCount:firstMD.sumlessons andImageUrl:firstMD.cover andIsOver:@"0"];
                            [manager insertRecordWithMyid:secondMD.myid andMyParentId:secondMD.parentid andVedioId:secondMD.videoid andName:secondMD.name andMaxCount:secondMD.sonCnt andImageUrl:secondMD.cover andIsOver:@"0"];
                            [manager insertRecordWithMyid:thirdMD.myid andMyParentId:thirdMD.parentid andVedioId:thirdMD.videoid andName:thirdMD.name andMaxCount:@"0" andImageUrl:thirdMD.cover andIsOver:@"0"];
                        }
                    }
                }
            }
        }
    }
}



#pragma mark - &&&&&&&&&&&   开始后台下载
- (void)startDownload{
    // 获取下载管理类 从新的数据库里面添加到下载队列
    ZJCDownControl * downManager = [ZJCDownControl defaultControl];
    [downManager getAvailableDataFromFMDB];
    [downManager addToDownloadQueue];
    
    
    // 获取当前需要下载的item
    if (downManager.downloadWaitingArr.count != 0) {
        ZJCDownItem * item = downManager.downloadWaitingArr[0];
        [downManager startWithMyid:item.myid];
    }
    
      
    
    /**
     *  @brief 回调Block集群
     */
    // 完成回调         继续下一个
    __block ZJCDownControl * downManagerBlock = downManager;
    downManager.finishBlock =^(){
        // 更新数据库
        ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
        [manager updateRecordWithMyid:downManagerBlock.currentItem.myid useIsover:[NSString stringWithFormat:@"1"]];
        // 继续下一个
        if (downManagerBlock.downloadWaitingArr.count != 0) {
            ZJCDownItem * item = downManagerBlock.downloadWaitingArr[0];
            [downManagerBlock startWithMyid:item.myid];
        }else{
            downManagerBlock.currentItem = nil;
            downManagerBlock.downloader = nil;
        }
    };
    
    // 出错回调        出错了就跳过当前的item,继续下一个item
    downManager.errorBlock = ^(NSError * error){
        if (downManager.downloadWaitingArr.count != 0) {
            ZJCDownItem * item = downManagerBlock.downloadWaitingArr[0];
            [downManagerBlock startWithMyid:item.myid];
        }
    };
    
    // 下载进度回调
    downManager.progerssBlock = ^(float progress, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite,ZJCDownItem * item){
        // 更新数据库
        ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
        [manager updateRecordWithMyid:downManagerBlock.currentItem.myid useIsover:[NSString stringWithFormat:@"%f",progress]];
    };
    
}



@end


