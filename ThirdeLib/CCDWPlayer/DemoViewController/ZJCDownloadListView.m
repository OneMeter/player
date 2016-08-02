//
//  ZJCDownloadListView.m
//  CCRA
//
//  Created by htkg on 16/4/12.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCDownloadListView.h"
#import "ZJCTabBarViewController.h"
#import "ZJCNavigationViewController.h"
#import "AppDelegate.h"



@implementation ZJCDownloadListView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        // 背景色
        self.backgroundColor = [UIColor clearColor];
        // 配置属性
        [self configSelf];
    }
    return self;
}


// 配置属性
- (void)configSelf{
    // 头视图
    [self creatHeaderView];
    // 表格
    [self createTableView];
}





#pragma mark - 全选、下载
- (void)creatHeaderView{
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:0], [ZJCFrameControl GetControl_Y:0], self.width, 40)];
    [self addSubview:self.headerView];
    
    // 标题
    self.headerTitleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width*2/3.0 , 40)];
    [self addSubview:self.headerTitleView];
    self.headerTitleView.textColor = [UIColor whiteColor];
    self.headerTitleView.textAlignment = NSTextAlignmentLeft;
    
    // 确认下载
    self.ensureLoadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.ensureLoadButton.frame = CGRectMake(self.width*2/3.0, 0, self.width*1/6.0, 40);
    [self.headerView addSubview:self.ensureLoadButton];
    [self.ensureLoadButton setTitle:@"下载" forState:UIControlStateNormal];
    [self.ensureLoadButton setTitleColor:[UIColor colorWithHue:94 saturation:149 brightness:225 alpha:1] forState:UIControlStateNormal];
    [self.ensureLoadButton addTarget:self action:@selector(ensureLoadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // 全选
    self.selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.selectAllButton.frame = CGRectMake(self.width*5/6.0, 0, self.width*1/6.0, 40);
    [self.headerView addSubview:self.selectAllButton];
    [self.selectAllButton setTitle:@"全选" forState:UIControlStateNormal];
    [self.selectAllButton setTitle:@"取消" forState:UIControlStateSelected];
    [self.selectAllButton addTarget:self action:@selector(selectAllButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 分割线
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.headerView.height-2, self.headerView.width, 1)];
    label.backgroundColor = ZJCGetColorWith(230, 230, 230, 1);
    [self.headerView addSubview:label];
}





/**
 *  @brief 全选按钮
 */
- (void)selectAllButtonClicked:(UIButton *)button{
    button.selected = !button.selected;
    if (button.selected == YES) {
        for (ZJCPopDownloadListViewModel * model in self.dataSource) {
            model.isselected = YES;
        }
        [self.tableView reloadData];
    }else{
        for (ZJCPopDownloadListViewModel * model in self.dataSource) {
            model.isselected = NO;
        }
        [self.tableView reloadData];
    }
}



/**
 *  @brief 确认下载按钮
 */
- (void)ensureLoadButtonClicked:(UIButton *)button{
    BOOL checkFlog = [self checkIsChoseingSomeone];
    if (checkFlog == YES) {
        // 检测网络状态,状态符合条件就进行下载
        [self checkNetworkStatu];
    }else{
        [ZJCAlertView presentAlertWithAlertTitle:@"提示" andAlertMessage:@"请您选择需要下载的课程~^_^~" andAlertStyle:UIAlertControllerStyleAlert andSupportController:_currentController completion:nil andDelay:1.5];
    }
}




// 检测当前是否选中了项目
- (BOOL)checkIsChoseingSomeone{
    BOOL isChosed = NO;
    for (ZJCPopDownloadListViewModel * model in self.dataSource) {
        if (model.isselected == YES) {
            isChosed = YES;
            break;
        }
    }
    return isChosed;
}





// 检测网络状态
- (void)checkNetworkStatu{
    // 1.根据AppDelegate检测到的网络状态判断当前是否需要下载
    AppDelegate * appdelegate = AppDelegate_Public;
    switch (appdelegate.netWorkStatus) {
        case NetworkStatusReachableViaWiFi:           // 无线
        {
            // 2.提示用户已经添加到缓存列表
            [self popAlert];
            
            // 1.根据数据结构的内容,添加到数据库里面
            [self insertIntoFMDB];
            
            // 2.添加到缓存列表开始下载
            [self insertIntoDownloadList];
        }
            break;
        case NetworkStatusReachableViaWWAN:           // 移动数据
        {
            if (appdelegate.isAllowDownloadOnlyWifi == YES) {           // 只允许无线下载
                [ZJCAlertView presentAlertWithAlertTitle:@"温馨提示" andAlertMessage:@"当前为移动网络,请关闭<我的设置>中\"只允许Wifi下载选项\"后重试" andAlertStyle:UIAlertControllerStyleAlert andSupportController:_currentController completion:nil andDelay:2];
                
            }else if (appdelegate.isAllowDownloadOnlyWifi == NO){       // 可以移动网络下载
                UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                UIAlertAction * actionEnsure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    // 2.提示用户已经添加到缓存列表
                    [self popAlert];
                    
                    // 1.根据数据结构的内容,添加到数据库里面
                    [self insertIntoFMDB];
                    
                    // 2.添加到缓存列表开始下载
                    [self insertIntoDownloadList];
                }];
                [ZJCAlertView presentAlertWithAlertTitle:@"温馨提示" andAlertMessage:@"检测到您当前使用移动数据!\n下载会消耗流量,确认缓存?" andAlertStyle:UIAlertControllerStyleAlert andAlertActionArray:@[actionEnsure,actionCancel] andSupportController:_currentController completion:nil];
            }
        }
            break;
        case NetworkStatusNotReachable:               // 不可用
        {
            [ZJCAlertView presentAlertWithAlertTitle:@"温馨提示" andAlertMessage:@"请打开网络后重试!" andAlertStyle:UIAlertControllerStyleAlert andSupportController:_currentController completion:nil andDelay:2];
        }
            break;
        case NetworkStatusUnknown:                    // 未知
        {
            [ZJCAlertView presentAlertWithAlertTitle:@"温馨提示" andAlertMessage:@"未检测到当前网络状态,请检查网络设置后重试..." andAlertStyle:UIAlertControllerStyleAlert andSupportController:_currentController completion:nil andDelay:2];
        }
            break;
        default:
            break;
    }
}




- (void)popAlert{
    [ZJCAlertView presentAlertWithAlertTitle:@"提示" andAlertMessage:@"已经为您添加到缓存列表!" andAlertStyle:UIAlertControllerStyleAlert andSupportController:_currentController completion:nil andDelay:2];
}







// 添加到数据库
- (void)insertIntoFMDB{
    // 添加到数据库的顺序是按照课程的层级结构  课程->章->小节  这样的层级结构来添加的
    ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
    for (int i = 0 ; i < self.dataSource.count ; i ++) {
        ZJCPopDownloadListViewModel * model = self.dataSource[i];
        // 分组头
        if (model.cellType == ZJCDownloadListTableViewCellTypeSection) {
            if (model.isselected == YES) {
                // 一级 课程
                [manager insertRecordWithMyid:[NSString stringWithFormat:@"%@",_dicOfFirstLevelCourse[@"id"]] andMyParentId:@"-1" andVedioId:@"" andName:_dicOfFirstLevelCourse[@"name"] andMaxCount:[NSString stringWithFormat:@"%@",_dicOfFirstLevelCourse[@"sumlessons"]] andImageUrl:_dicOfFirstLevelCourse[@"cover"] andIsOver:@"0"];
                // 二级 章
                [manager insertRecordWithMyid:model.id andMyParentId:[NSString stringWithFormat:@"%@",_dicOfFirstLevelCourse[@"id"]] andVedioId:model.videoid andName:model.name andMaxCount:[NSString stringWithFormat:@"%lu",(unsigned long)model.son.count] andImageUrl:model.cover andIsOver:@"0"];
            }else{
                
            }
            
        }
        // row行
        else if (model.cellType == ZJCDownloadListTableViewCellTypeRow){
            if (model.isselected == YES) {
                // 一级 课程
                [manager insertRecordWithMyid:[NSString stringWithFormat:@"%@",_dicOfFirstLevelCourse[@"id"]] andMyParentId:@"-1" andVedioId:@"" andName:_dicOfFirstLevelCourse[@"name"] andMaxCount:[NSString stringWithFormat:@"%@",_dicOfFirstLevelCourse[@"sumlessons"]] andImageUrl:_dicOfFirstLevelCourse[@"cover"] andIsOver:@"0"];
                // 二级 章
                [manager insertRecordWithMyid:model.parentModel.id andMyParentId:[NSString stringWithFormat:@"%@",_dicOfFirstLevelCourse[@"id"]] andVedioId:model.parentModel.videoid andName:model.parentModel.name andMaxCount:[NSString stringWithFormat:@"%lu",(unsigned long)model.parentModel.son.count] andImageUrl:model.parentModel.cover andIsOver:@"0"];
                
                // 三级 节
                [manager insertRecordWithMyid:model.id andMyParentId:model.parentModel.id andVedioId:model.videoid andName:model.name andMaxCount:[NSString stringWithFormat:@"%lu",(unsigned long)model.son.count] andImageUrl:model.cover andIsOver:@"0"];
            }else{
                
            }
        }
    }
}





// 添加到下载队列
- (void)insertIntoDownloadList{
    // 获取下载管理类 从新的数据库里面添加到下载队列
    ZJCDownControl * downManager = [ZJCDownControl defaultControl];
    [downManager getAvailableDataFromFMDB];
    [downManager addToDownloadQueue];
    
    
    // 获取当前需要下载的item
    if (downManager.downloadWaitingArr.count != 0) {
        ZJCDownItem * item = downManager.downloadWaitingArr[0];
        [downManager startWithMyid:item.myid];
    }
    
    // 完成后继续下一个
    __block ZJCDownControl * downManagerBlock = downManager;
    downManager.finishBlock =^(){
        // 更新数据库
        ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
        [manager updateRecordWithMyid:downManagerBlock.currentItem.myid useIsover:[NSString stringWithFormat:@"1"]];
        // 继续下一个
        if (downManager.downloadWaitingArr.count != 0) {
            ZJCDownItem * item = downManagerBlock.downloadWaitingArr[0];
            [downManagerBlock startWithMyid:item.myid];
        }
    };
    
    // 出错了就跳过当前的item,继续下一个item
    downManager.errorBlock = ^(NSError * error){
        
        
        
        if (downManager.downloadWaitingArr.count != 0) {
            ZJCDownItem * item = downManagerBlock.downloadWaitingArr[0];
            [downManagerBlock startWithMyid:item.myid];
        }
    };
    
    // 下载进度
    downManager.progerssBlock = ^(float progress, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite,ZJCDownItem * item){
        // 更新数据库
        ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
        [manager updateRecordWithMyid:downManagerBlock.currentItem.myid useIsover:[NSString stringWithFormat:@"%f",progress]];
    };
    
}




















#pragma mark - 搭建表格
- (void)createTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, self.width,self.height-40) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    // 注册cell
    [self.tableView registerClass:[ZJCDownloadListTableViewCell class] forCellReuseIdentifier:@"downloadListTableViewCell"];
    
    [self addSubview:self.tableView];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZJCDownloadListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"downloadListTableViewCell"];
    if (!cell) {
        cell = [[ZJCDownloadListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"downloadListTableViewCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.model = _dataSource[indexPath.row];
    /**
     *  @brief 选中按钮回调Block
     */
    __weak typeof(self)weakSelf = self;
    cell.buttonClickedBlock = ^(UIButton * seleceteButton){
        seleceteButton.selected = !seleceteButton.selected;
        ZJCPopDownloadListViewModel * model = weakSelf.dataSource[indexPath.row];
        model.isselected = !model.isselected;
        [self.tableView reloadData];
    };
    return cell;
}








#pragma mark - 懒加载
- (void)setDataSource:(NSMutableArray *)dataSource{
    // 加载数据 (dataSourcel里面是主界面分栏"课程简介"模型)
    [self handleDataSourceWithReceiveData:dataSource];
    
    // 刷新界面
    self.headerTitleView.text = self.titleString;
    
    [self.tableView reloadData];
}

// 处理数据
- (void)handleDataSourceWithReceiveData:(NSMutableArray *)dataSource{
    // 1.比较麻烦,获取到courseViewController   为了弹窗
    ZJCTabBarViewController * tabbar = (ZJCTabBarViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    ZJCNavigationViewController * navContro = tabbar.viewControllers[0];
    _currentController = (ZJCCourseViewController *)navContro.topViewController;
    
    
    // 2.获取到当前的课程信息,存入数据库需要课程打头,所以需要请求课程列表的信息存放到本地
    AppDelegate * appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString * codeId = [NSString stringWithFormat:@"%@_ios",appdelegate.codeId];
    NSString * username = [ZJCNSUserDefault getDataUsingNSUserDefaultWithDataType:ZJCUserInfor andKey:UserLoadInfor_LoadName];
    NSString * urlString = [NSString stringWithFormat:[NSString stringWithFormat:@"http://app.ccs163.net/downlist/%@/%@"],codeId,username];
    [AFHTTPRequestOperationManager GET:urlString parameter:nil success:^(id responseObject) {
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([dic[@"bl"] isEqualToNumber:@1]) {
            // 3.获取当前课程的信息
            NSArray * courseArr = [NSArray arrayWithArray:dic[@"data"]];
            _dicOfFirstLevelCourse = [[NSDictionary alloc] init];
            for (NSDictionary * dic in courseArr) {
                if ([[dic[@"id"] stringValue] isEqualToString:_currentController.courseID]) {
                    _dicOfFirstLevelCourse = [NSDictionary dictionaryWithDictionary:dic];
                    break;
                }
            }
            
            
            // 添加到本地数据源机构
            NSMutableArray * sumArray = [[NSMutableArray alloc] init];
            NSArray * arrayOfFirstLevel = [NSArray arrayWithArray:_dicOfFirstLevelCourse[@"son"]];
            for (int i = 0 ; i < arrayOfFirstLevel.count ; i++ ) {
                NSDictionary * secondDicTemp = arrayOfFirstLevel[i];
                ZJCPopDownloadListViewModel * rowModel = [[ZJCPopDownloadListViewModel alloc] init];
                rowModel.id            = [NSString stringWithFormat:@"%@",secondDicTemp[@"id"]];
                rowModel.name          = [NSString stringWithFormat:@"%@",secondDicTemp[@"name"]];
                rowModel.cover         = [NSString stringWithFormat:@"%@",secondDicTemp[@"cover"]];
                rowModel.videoid       = [NSString stringWithFormat:@"%@",secondDicTemp[@"videoid"]];
                rowModel.videoduration = [NSString stringWithFormat:@"%@",secondDicTemp[@"videoduration"]];
                rowModel.studybar      = [NSString stringWithFormat:@"%@",secondDicTemp[@"studybar"]];
                rowModel.eid           = [NSString stringWithFormat:@"%@",secondDicTemp[@"eid"]];
                rowModel.ispaper       = [NSString stringWithFormat:@"%@",secondDicTemp[@"ispaper"]];
                rowModel.son           = [NSArray arrayWithArray:secondDicTemp[@"son"]];
                rowModel.cellType      = ZJCDownloadListTableViewCellTypeSection;
                rowModel.parentModel   = nil;
                NSArray * arrSon = secondDicTemp[@"son"];
                if (arrSon.count != 0) {
                    rowModel.isHaveSepereter = NO;
                    rowModel.isHaveSelectButton = NO;
                }else{
                    rowModel.isHaveSepereter = YES;
                    rowModel.isHaveSelectButton = YES;
                }
                
                [sumArray addObject:rowModel];
                
                for (int j = 0 ; j < arrSon.count ; j ++) {
                    NSDictionary * thirdDicTemp = arrSon[j];
                    ZJCPopDownloadListViewModel * rowSmallModel = [[ZJCPopDownloadListViewModel alloc] init];
                    rowSmallModel.id            = [NSString stringWithFormat:@"%@",thirdDicTemp[@"id"]];;
                    rowSmallModel.name          = [NSString stringWithFormat:@"%@",thirdDicTemp[@"name"]];
                    rowSmallModel.cover         = [NSString stringWithFormat:@"%@",thirdDicTemp[@"cover"]];
                    rowSmallModel.videoid       = [NSString stringWithFormat:@"%@",thirdDicTemp[@"videoid"]];
                    rowSmallModel.videoduration = [NSString stringWithFormat:@"%@",thirdDicTemp[@"videoduration"]];
                    rowSmallModel.studybar      = [NSString stringWithFormat:@"%@",thirdDicTemp[@"studybar"]];
                    rowSmallModel.eid           = [NSString stringWithFormat:@"%@",thirdDicTemp[@"eid"]];
                    rowSmallModel.ispaper       = [NSString stringWithFormat:@"%@",thirdDicTemp[@"ispaper"]];
                    rowSmallModel.son           = [NSArray arrayWithArray:thirdDicTemp[@"son"]];
                    rowSmallModel.parentModel   = rowModel;
                    rowSmallModel.cellType      = ZJCDownloadListTableViewCellTypeRow;
                    rowSmallModel.isHaveSepereter = NO;
                    rowSmallModel.isHaveSelectButton = YES;
                    if (j == arrSon.count - 1) {
                        rowSmallModel.isHaveSepereter = YES;
                    }
                    [sumArray addObject:rowSmallModel];
                }
            }
            
            // 数据添加完毕,准备刷新界面
            _dataSource = [NSMutableArray arrayWithArray:sumArray];
            [self.tableView reloadData];
        }
        
    } failure:^(NSError *error) {
        [ZJCAlertView presentAlertWithAlertTitle:@"提示" andAlertMessage:@"网络出现问题,请检查" andAlertStyle:UIAlertControllerStyleAlert andSupportController:_currentController completion:nil andDelay:2];
    }];
}




@end

