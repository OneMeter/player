
//
//  ZJCCourseIntroductionViewController.m
//  CCRA
//
//  Created by htkg on 16/3/29.
//  Copyright © 2016年 htkg. All rights reserved.
//
#import "ZJCCourseViewController.h"

#import "ZJCDownloadListViewController.h"

//#import "ZJCPracticeTestsViewController.h"
//#import "ZJCNewPracticeTestsViewController.h"  // 新版练习题界面


#import "ZJCDWPlayerView.h"                // 小屏播放器
#import "DWCustomPlayerViewController.h"   // 大屏播放器
#import "DWSDK.h"                          // 视屏SDK

#import "ZJCCourceCatalogueView.h"      // 课程目录
#import "ZJCCourceInforView.h"          // 课程简介

#import <GPUImage/GPUImage.h>           // 虚化框架

#import "AppDelegate.h"
#import "ZJCCourceCatalogueModel.h"
#import "ZJCCourceCatalogueSmallModel.h"

#import "ZJCButtonWithEdgeBottomLine.h"
#import "ZJCCourceCatelogueTableViewCell.h"

/*
 
 
 */


///**
// *  @brief 屏幕状态 枚举
// */
//typedef enum {
//    ZJCInterfaceStatusPortrait,
//    ZJCInterfaceStatusLandscapeLeft,
//    ZJCInterfaceStatusLandscapeRight
//}ZJCInterfaceStatus;

///**
// *  @brief 屏幕控件参数 结构体
// */
//typedef struct {
//    BOOL isFullScreen;
//    BOOL isCourCateOrCourInforDisplay;
//    CGRect playerNowRect;
//}ZJCControlsStatusInfor;

/**
 *  @brief 记录竖屏界面原生状态 显示哪个底部视图
 */
typedef enum {
    DisplayCourseCatelogueView = 1,
    DisPlayCourseInforView
}DisPlayWhichView;
@interface ZJCCourseViewController ()

@property (nonatomic ,strong) UIButton * backButton;                          // 返回按钮

@property (nonatomic ,strong) ZJCDWPlayerView * playerView;                   // 小屏播放器(视图)
@property (nonatomic ,strong) DWCustomPlayerViewController * player;          // 大屏播放器(播放器)
@property (nonatomic ,strong) NSString * videoIds;                            // 待播放视频的id
@property (nonatomic ,strong) NSString * lessonId;                            // 待播放视频的章节id
@property (nonatomic ,copy) NSString * localPath;                             // 待播放视频的本地路径

@property (nonatomic ,strong) UIView * headerMVPlayerView;                    // 底板
@property (nonatomic ,strong) UIButton * bigPlayerButton;                     // 播放按钮
@property (nonatomic ,strong) UILabel * playerCourseNameLabel;                // 章节名称
@property (nonatomic ,strong) UIImageView * bannerImageView;                  // 占位图
@property (nonatomic ,strong) GPUImageView * placeholderImageView;            // 播放器的占位图片
@property (nonatomic ,strong) GPUImageiOSBlurFilter * blurFilter;             // 虚化滤镜
@property (nonatomic ,strong) GPUImagePicture * picture;                      // 虚化图板
@property (nonatomic ,strong) UIImage *blurImage;                             // 虚化图片

@property (nonatomic ,strong) UILabel * middleTitleLabel;                     // 中间标题按钮
@property (nonatomic ,strong) UIButton * downListButton;                      // 下载列表按钮

@property (nonatomic ,strong) UIView * pagerView;                             // 分栏控制器
@property (nonatomic ,strong) UIButton * button1;                             // 选项卡1 >>> 简介
@property (nonatomic ,strong) UIButton * button2;                             // 选项卡2 >>> 目录
@property (nonatomic ,strong) UIButton * button3;                             // 选项卡3 >>> 课后练习
@property (nonatomic ,strong) UIView * lineView;                              // 地板条
@property (nonatomic ,strong) UIView * seperateLine;                          // 分割线
@property (nonatomic ,strong) ZJCCourceCatalogueView * courseCatelogueView;   // 课程目录
@property (nonatomic ,strong) ZJCCourceInforView * courseInforView;           // 课程简介

@property (nonatomic ,assign) BOOL isFullScreenOfViewCon;                     // 控制器是否全屏
@property (nonatomic ,assign) DisPlayWhichView displayWhichFolg;              // 记录竖屏界面的时候显示哪个视图
//@property (nonatomic ,assign) ZJCInterfaceStatus interFaceStatus;           // 屏幕方向状态   >>>   因为项目需要仅支持三种
//@property (nonatomic ,assign) ZJCControlsStatusInfor interFaceStatusInfor;  // 对应屏幕状态下的状态结构体   >>>   1.不同屏幕需要不同的界面参数等

@end



@implementation ZJCCourseViewController

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化
    [self selfInitCourseIntroductionVC];
    // 请求数据
    [self loadCourseIntroductionData];
    // 搭建UI
    [self creatCourseIntroductionUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES];
    // 隐藏tabbar
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}



- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 隐藏导航栏
    [self.navigationController setNavigationBarHidden:NO];
    // 隐藏tabbar
    [self.tabBarController.tabBar setHidden:NO];
    // 视频播放器的处理
    
    // 切换大屏
    [self.playerView.player cancelRequestPlayInfo];
    self.playerView.player.contentURL = nil;
    [self.playerView.player stop];
    [self.playerView removeTimer];
    [self.playerView removeAllObserver];
    [self.playerView removeFromSuperview];
    // 干掉通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


#pragma mark - 初始化
- (void)selfInitCourseIntroductionVC{
    // 背景色
    self.view.backgroundColor = [UIColor whiteColor];
    // 待播放的id
    //    _videoIds = @"E6BEDEE9DA9AF5509C33DC5901307461";
    // 返回按钮隐藏文字
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    // 数据结构
    if (_receiveDataSource == nil) {
        _receiveDataSource = [NSDictionary dictionary];
    }
    if (_nextDataSource == nil) {
        _nextDataSource = [NSMutableArray array];
    }
    // 赋新值
    ZJCPassValueControlManager * manager = [ZJCPassValueControlManager defaultManager];
    manager.isSection = NO;
    manager.selectSection = LONG_MAX;
    manager.selectRow = LONG_MAX;
}


#pragma mark - 请求数据
- (void)loadCourseIntroductionData{
#if 1
    // 拼接链接请求数据
    AppDelegate * appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _codeID = [NSString stringWithFormat:@"%@_ios",appdelegate.codeId];
    _userName = [ZJCNSUserDefault getDataUsingNSUserDefaultWithDataType:ZJCUserInfor andKey:UserLoadInfor_LoadName];
    NSString * detailURL = @"http://app.ccs163.net/course/2016080206371100_ios/15650161112/2342";//[NSString stringWithFormat:@"http://app.ccs163.net/course/%@/%@/%@",_codeID,_userName,_courseID];
#else
    NSString * detailURL = @"";
    detailURL = @"http://app.ccs163.net/course/2016041302215900_ios/pjb123/1132";
#endif
    
    
    // 添加菊花视图
    ZJCLoadingView * loadingView = [[ZJCLoadingView alloc] initWithFrame:SCREEN_BOUNDS];
    [loadingView showLoading];
    [AFHTTPRequestOperationManager GET:detailURL parameter:nil success:^(id responseObject) {
        // 干掉菊花视图
        [loadingView dismissLoading];
        
        NSDictionary * dicTemp = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        _receiveDataSource = [NSDictionary dictionaryWithDictionary:dicTemp];
        _nextDataSource = [ZJCCourceCatalogueModel arrayOfModelsFromDictionaries:_receiveDataSource[@"data"]];
        
        //[_receiveDataSource objectForKey:@"ispaper"] 是一个nsnumber型的数据
        
        if ([[_receiveDataSource objectForKey:@"ispaper"]isEqual:[NSNumber numberWithInteger:1]] ) {
            [self createDoneImageView];
        }
        
        if (_nextDataSource.count == 0) {
            return;
        }
        
        // 配置UI
        ZJCCourceCatalogueModel * model = _nextDataSource[0];
        _playerCourseNameLabel.text = _receiveDataSource[@"name"];
        
        if ([model.son count] == 0) {
            // 播放视频的id
            _videoIds = [model.videoid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            _lessonId = [model.id stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            // 播放视频的标题
            _playerCourseNameLabel.text = model.name;
            
            // 添加虚化图片
            if (model.cover == nil || [model.cover isEqualToString:@""] || [model.cover isKindOfClass:[NSNull class]]) {
                _blurImage  = [UIImage imageNamed:@"banner"];
            }else{
                _blurImage = [self getImageFromURL:model.cover];   
            }
            _picture = [[GPUImagePicture alloc] initWithImage:_blurImage];
            [_picture addTarget:_blurFilter];
            [_blurFilter addTarget:_placeholderImageView];
            [_picture processImageWithCompletionHandler:^{
                [_blurFilter removeAllTargets];
            }];
        }else{
            // 播放视频的id
            _videoIds = [[model.son[0] videoid] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            _lessonId = [[model.son[0] id] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            // 播放视频的标题
            _playerCourseNameLabel.text = [model.son[0] name];
            
            // 添加虚化图片
            if ([model.son[0] cover] == nil || [[model.son[0] cover] isEqualToString:@""] || [[model.son[0] cover] isKindOfClass:[NSNull class]]) {
                _blurImage  = [UIImage imageNamed:@"banner"];
            }else{
                _blurImage = [self getImageFromURL:model.cover];   
            }
            _picture = [[GPUImagePicture alloc] initWithImage:_blurImage];
            [_picture addTarget:_blurFilter];
            [_blurFilter addTarget:_placeholderImageView];
            [_picture processImageWithCompletionHandler:^{
                [_blurFilter removeAllTargets];
            }];
        }
        
        
        // 得到了数据了以后,给分栏界面
        _courseCatelogueView.dataSource = _nextDataSource;
        _courseInforView.urlString = _receiveDataSource[@"introduce"];
        
        // ****特殊用途的block,自行研究吧...
        if (self.alreadyGetData) {
            self.alreadyGetData(YES);
        }
        
    } failure:^(NSError *error) {
        // 干掉菊花视图
        [loadingView dismissLoading];
        
        // 添加网络出错的图片
        ZJCHttpRequestErrorViews * errorViews = [[ZJCHttpRequestErrorViews alloc] initWithFrame:CGRectMake(0, [ZJCFrameControl GetControl_Y:677+600-527] - 1 +[ZJCFrameControl GetControl_Y:114] , SCREEN_WIDTH, SCREEN_HEIGHT - [ZJCFrameControl GetControl_Y:677+600-527] + 1 - [ZJCFrameControl GetControl_Y:114])];
        [self.view addSubview:errorViews];
        __block ZJCHttpRequestErrorViews * blockErrorViews = errorViews;
        errorViews.requestRepetButtonClicked = ^(UIButton * button){
            [self loadCourseIntroductionData];
            [blockErrorViews removeFromSuperview];
        };
        
    }];
}



-(UIImage *)getImageFromURL:(NSString *)fileURL {
    //    /images/course3.png
    UIImage * result;
    NSString * urlString = [NSString stringWithFormat:@"%@",fileURL];
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
    if (data == nil) {
        result = [UIImage imageNamed:@"banner"];
    }else{
        result = [UIImage imageWithData:data];
    }
    
    if (result == nil) {
        result = [UIImage imageNamed:@"banner"];
    }
    
    return [result resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch];
}



//判断是否已完成练习
-(void)createDoneImageView
{
    
        _finishPratiace=[[UIImageView alloc]initWithFrame:CGRectMake(_button3.frame.size.width, _button3.frame.size.height/2, [ZJCFrameControl GetControl_weight:25], [ZJCFrameControl GetControl_weight:25])];
        _finishPratiace.image=[UIImage imageNamed:@"isex"];
        [_button3 addSubview:_finishPratiace];
    
}

#pragma mark - 搭建UI
- (void)creatCourseIntroductionUI{
    // 顶部播放器
    [self creatMVPlyerView];
    // 返回按钮
    [self creatBackButton];
//    // 中间标题
//    [self creatMiddleTitle];
//    // 下载列表按钮
//    [self createDownListButton];
//    // 分栏控制器
//    [self creatPagerViews];
}



#pragma mark - 返回按钮
- (void)creatBackButton{
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view insertSubview:self.backButton aboveSubview:self.headerMVPlayerView];
    [self.backButton addTarget:self action:@selector(navigetionBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    __weak __typeof(self) weakSelf = self; 
    [weakSelf.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset([ZJCFrameControl GetControl_X:38]);
        make.top.equalTo(weakSelf.view).offset([ZJCFrameControl GetControl_Y:69]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:120], [ZJCFrameControl GetControl_weight:120]));
    }];
    UIImageView * imageView = [[UIImageView alloc] init];
    [self.backButton addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.backButton.mas_centerX);
        make.centerY.equalTo(weakSelf.backButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:80], [ZJCFrameControl GetControl_weight:80]));
    }];
    imageView.image = [UIImage imageNamed:@"navigationBack"];
}



- (void)navigetionBackButtonClicked:(UIButton *)button{
    [self.navigationController popViewControllerAnimated:YES];
    ZJCPassValueControlManager * manager = [ZJCPassValueControlManager defaultManager];
    manager.isSection = NO;
    manager.selectSection = MAXFLOAT;
    manager.selectRow = MAXFLOAT;
}


#pragma mark - 顶部播放器
- (void)creatMVPlyerView{
    // 设置顶部的视频播放器   底板
    _headerMVPlayerView = [[UIView alloc] init];
    _headerMVPlayerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_headerMVPlayerView];
    __weak __typeof(self) weakSelf = self; 
    [_headerMVPlayerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset([ZJCFrameControl GetControl_X:0]);
        make.top.equalTo(weakSelf.view).offset([ZJCFrameControl GetControl_Y:0]);
        make.right.equalTo(weakSelf.view);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:1080], [ZJCFrameControl GetControl_height:600]));
    }];
    
    // 占位图片(虚化效果)
    [self addBlurView];
    
    // 播放按钮
    _bigPlayerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_headerMVPlayerView insertSubview:_bigPlayerButton aboveSubview:_placeholderImageView];
    [_bigPlayerButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.headerMVPlayerView.mas_centerX);
        make.centerY.equalTo(weakSelf.headerMVPlayerView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:120], [ZJCFrameControl GetControl_weight:120]));
    }];
    [_bigPlayerButton setBackgroundImage:[UIImage imageNamed:@"CC_play"] forState:UIControlStateNormal];
    [_bigPlayerButton addTarget:self action:@selector(playerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    // 章节内容标题
    _playerCourseNameLabel = [[UILabel alloc] init];
    [_headerMVPlayerView addSubview:_playerCourseNameLabel];
    _playerCourseNameLabel.backgroundColor = [UIColor clearColor];
    _playerCourseNameLabel.textColor = [UIColor whiteColor];
    _playerCourseNameLabel.textAlignment = NSTextAlignmentCenter;
    _playerCourseNameLabel.font = [UIFont systemFontOfSize:16];
    [_playerCourseNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.headerMVPlayerView);
        make.top.equalTo(weakSelf.bigPlayerButton.mas_bottom).offset([ZJCFrameControl GetControl_Y:60]);
        make.right.equalTo(weakSelf.headerMVPlayerView);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:1080], [ZJCFrameControl GetControl_height:60]));
    }];
}



// 播放器按钮点击事件
- (void)playerButtonClicked:(UIButton *)button{
    // 只有点击了播放按钮才初始化,不然的话就不需要初始化的
    // 当然了,只有请求到了播放视频的id才会播放
    if ((_videoIds == nil || [_videoIds isEqualToString:@""]) && (_localPath == nil || [_localPath isEqualToString:@""])) {
        
    }else if (_localPath != nil){
        // 播放本地视频
        [self initDWMoviePlayerwithVideoId:nil orLocalPath:_localPath];
        
    }else{
        // 播放网络视频
        [self initDWMoviePlayerwithVideoId:_videoIds orLocalPath:nil];
        // 同时选中当前播放的行
        [self courseCatelogueViewSelectCurrentMovie];
    }
}

- (void)courseCatelogueViewSelectCurrentMovie{
    // 判断当前是 "组" 还是 "行"
    ZJCCourceCatalogueModel * model = _nextDataSource[0];
    if ([model.son count] == 0) {         // 只有章
        ZJCPassValueControlManager * manager = [ZJCPassValueControlManager defaultManager];
        manager.isSection = YES;
        manager.selectSection = 0;
        manager.selectRow = 0;
        
        // 
        UIView * sectionView = [_courseCatelogueView.tableView viewWithTag:manager.selectSection];
        UIView * sectionMatte = [sectionView viewWithTag:manager.selectSection + 100];
        sectionMatte.hidden = NO;
        
    }else if([model.son count] != 0) {    // 除了章 还有节
        ZJCPassValueControlManager * manager = [ZJCPassValueControlManager defaultManager];
        manager.isSection = NO;
        manager.selectSection = 0;
        manager.selectRow = 0;
        
        //
        NSIndexPath * myindexpath = [NSIndexPath indexPathForRow:manager.selectRow inSection:manager.selectSection];
        [_courseCatelogueView.tableView selectRowAtIndexPath:myindexpath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}




#pragma mark - ******特殊处理方法  异界面跳转视频播放界面的代码实现 + 播放本地视频的实现
- (void)playNewVedioWithVideoId:(NSString *)videoid andLessonid:(NSString *)lessonid andTitle:(NSString *)title andDepth:(NSInteger)depth andSectionId:(NSString *)sectionId{
    // 播放器
    self.videoIds = videoid;
    self.lessonId = lessonid;
    self.playerCourseNameLabel.text = title;
    [self initDWMoviePlayerwithVideoId:self.videoIds orLocalPath:nil];
    [self.playerView.courseListPopView.tableView reloadData];
    
    // 表格选中
    if (depth == 1) {             // 章
        for (int i = 0 ; i < _nextDataSource.count; i++) {
            ZJCCourceCatalogueModel * model = _nextDataSource[i];
            if ([sectionId isEqualToString:model.id]) {
                // 定位数据给传参用的单例
                ZJCPassValueControlManager * manager = [ZJCPassValueControlManager defaultManager];
                manager.isSection = YES;
                manager.selectSection = i;
                manager.selectRow = 0;
                
                // 刷新表格
                UIView * sectionView = [_courseCatelogueView.tableView viewWithTag:manager.selectSection];
                UIView * sectionMatte = [sectionView viewWithTag:manager.selectSection + 100];
                sectionMatte.hidden = NO;
                
                break;
            }
        }
        
    }else if (depth == 2){        // 小节
        for (int i = 0 ; i < _nextDataSource.count; i++) {
            ZJCCourceCatalogueModel * model = _nextDataSource[i];
            if ([sectionId isEqualToString:[_nextDataSource[i] id]]) {
                for (int k = 0 ; k < model.son.count; k++) {
                    ZJCCourceCatalogueSmallModel * smallModel = model.son[k];
                    if ([smallModel.id isEqualToString:lessonid]) {
                        // 定位数据给传参用的单例
                        ZJCPassValueControlManager * manager = [ZJCPassValueControlManager defaultManager];
                        manager.isSection = NO;
                        manager.selectSection = i;
                        manager.selectRow = k;
                        
                        // 刷新表格
                        NSIndexPath * myindexpath = [NSIndexPath indexPathForRow:manager.selectRow inSection:manager.selectSection];
                        [_courseCatelogueView.tableView selectRowAtIndexPath:myindexpath animated:YES scrollPosition:UITableViewScrollPositionNone];
                        break;
                    }
                }
                break;
            }
        }
        
    }
}


// 播放本地视频
- (void)playNewVedioWithLocalPath:(NSString *)localPath andLessonid:(NSString *)lessonid andTitle:(NSString *)title andDepth:(NSInteger)depth andSectionId:(NSString *)sectionId{
    // 播放器
    //    self.videoIds = videoid;
    self.lessonId = lessonid;
    self.playerCourseNameLabel.text = title;
    [self initDWMoviePlayerwithVideoId:nil orLocalPath:localPath];
    [self.playerView.courseListPopView.tableView reloadData];
    
    // 表格选中
    if (depth == 1) {             // 章
        for (int i = 0 ; i < _nextDataSource.count; i++) {
            ZJCCourceCatalogueModel * model = _nextDataSource[i];
            if ([sectionId isEqualToString:model.id]) {
                // 定位数据给传参用的单例
                ZJCPassValueControlManager * manager = [ZJCPassValueControlManager defaultManager];
                manager.isSection = YES;
                manager.selectSection = i;
                manager.selectRow = 0;
                
                // 刷新表格
                UIView * sectionView = [_courseCatelogueView.tableView viewWithTag:manager.selectSection];
                UIView * sectionMatte = [sectionView viewWithTag:manager.selectSection + 100];
                sectionMatte.hidden = NO;
                
                break;
            }
        }
        
    }else if (depth == 2){        // 小节
        for (int i = 0 ; i < _nextDataSource.count; i++) {
            ZJCCourceCatalogueModel * model = _nextDataSource[i];
            if ([sectionId isEqualToString:[_nextDataSource[i] id]]) {
                for (int k = 0 ; k < model.son.count; k++) {
                    ZJCCourceCatalogueSmallModel * smallModel = model.son[k];
                    if ([smallModel.id isEqualToString:lessonid]) {
                        // 定位数据给传参用的单例
                        ZJCPassValueControlManager * manager = [ZJCPassValueControlManager defaultManager];
                        manager.isSection = NO;
                        manager.selectSection = i;
                        manager.selectRow = k;
                        
                        // 刷新表格
                        NSIndexPath * myindexpath = [NSIndexPath indexPathForRow:manager.selectRow inSection:manager.selectSection];
                        [_courseCatelogueView.tableView selectRowAtIndexPath:myindexpath animated:YES scrollPosition:UITableViewScrollPositionNone];
                        break;
                    }
                }
                break;
            }
        }
        
    }
}


// 初始化视频播放器
- (void)initDWMoviePlayerwithVideoId:(NSString *)videoid orLocalPath:(NSString *)localPath{
    // 小屏播放
    _playerView = [[ZJCDWPlayerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [ZJCFrameControl GetControl_height:600])];
    [_headerMVPlayerView addSubview:_playerView];
    _playerView.supportController = self;
    _playerView.userWantPlaybackTime = self.currentPlayerDuration;
    _playerView.titleLabelString = _playerCourseNameLabel.text;
    _playerView.courPopViewTitleString = self.middelname;
    _playerView.courListDataSource = _nextDataSource;
    
    _playerView.lessonId = _lessonId;
    if (videoid != nil) {
        _playerView.videoId = videoid;
    }else{
        _playerView.videoLocalPath = localPath;
    }
    _playerView.isFullScreen = NO;
    
    
    __weak __typeof(self) weakSelf = self;
    // 过路车回调
    _playerView.passCarBlock = ^(id sender,NSString * videoId,NSString * title,NSString * lessonid,BOOL isSection,NSInteger selectSeciton,NSInteger selectRow){
        // 1.干掉之前的选中项目
        if (isSection == YES) {
            for (ZJCButtonWithEdgeBottomLine * section in weakSelf.courseCatelogueView.tableView.subviews) {
                UIView * view = [section viewWithTag:section.tag + 100];
                view.hidden = YES;
            }
        }else if(isSection == NO){
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:selectRow inSection:selectSeciton];
            [weakSelf.courseCatelogueView.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
        
        
        // 2.更新的状态
        ZJCPassValueControlManager * manager = [ZJCPassValueControlManager defaultManager];
        // 根据之前的状态,操作categoryViw的内容
        if (manager.isSection == YES) {
            // 模仿点击了section
            ZJCButtonWithEdgeBottomLine * section = [weakSelf.courseCatelogueView.tableView viewWithTag:manager.selectSection];
            UIView * view = [section viewWithTag:manager.selectSection + 100];
            view.hidden = NO;
            
        }else{
            // 模仿点击cell
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:manager.selectRow inSection:manager.selectSection];
            [weakSelf.courseCatelogueView.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        
        
        // 3.更新播放器状态
        [weakSelf.playerView.player pause];
        weakSelf.videoIds = videoId;
        weakSelf.lessonId = lessonid;
        
        weakSelf.playerCourseNameLabel.text = title;
        weakSelf.playerView.lessonId = lessonid;
        weakSelf.playerView.titleLabel.text = title;
        weakSelf.playerView.titleLabelString = title;
        weakSelf.playerView.videoId = videoId;
    };
    
    // 全屏回调
    _playerView.fullScreecButtonClickedBlock = ^(UIButton * button,NSInteger playerBacktime){
        /**
         *  @brief 之前使用 新建控制器显示大屏
         */
        // 切换大屏
        //        [blockPlayerView.player cancelRequestPlayInfo];
        //        [blockPlayerView.player stop];
        //        [blockPlayerView removeTimer];
        //        [blockPlayerView removeAllObserver];
        //        [blockPlayerView removeFromSuperview];
        //        DWCustomPlayerViewController * playerController = [[DWCustomPlayerViewController alloc] init];
        //        playerController.videoId = weakSelf.videoIds;
        //        playerController.titleLabelString = weakSelf.playerCourseNameLabel.text;
        //        playerController.userWantTimePlayBackTime = playerBacktime;
        //        // 回传值播放新的视频
        //        playerController.playerCurrentDurationBlock = ^(NSString * currentVideoID,NSInteger currentDuration,NSString * title){
        //            weakSelf.videoIds = currentVideoID;
        //            weakSelf.playerCourseNameLabel.text = title;
        //            weakSelf.currentPlayerDuration = currentDuration;
        //            [weakSelf initDWMoviePlayer];
        //        };
        //        
        //        [weakSelf.navigationController pushViewController:playerController animated:YES];
        
#pragma mark - 全屏
        /**
         *  @brief 现在使用 系统屏幕旋转功能
         */
        switch (button.selected) {
            case YES:      // 全屏
            {
                // 1.打开转屏
                AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                appDelegate.allowRotation = 1;
                // 2.监听通知
                [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
                // 3.全屏标志
                weakSelf.isFullScreenOfViewCon = YES;
                if (weakSelf.courseCatelogueView.hidden == YES && weakSelf.courseInforView.hidden == NO) {
                    weakSelf.displayWhichFolg = DisPlayCourseInforView;
                }else if (weakSelf.courseCatelogueView.hidden == NO && weakSelf.courseInforView.hidden == YES){
                    weakSelf.displayWhichFolg = DisplayCourseCatelogueView;
                }
                
                // 4.主动转屏
                //控制屏幕旋转方向 
                //UIInterfaceOrientationLandscapeLeft
                NSNumber * value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
                [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
            }
                break;
            case NO:       // 小屏
            {
                // 1.关闭转屏
                AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                appDelegate.allowRotation = 0;
                // 2.配置各种屏幕的参数
                weakSelf.isFullScreenOfViewCon = NO;
                
                // 3.主动转屏
                NSNumber * value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
                [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
                // 4.注销 监听者
                [[NSNotificationCenter defaultCenter] removeObserver:weakSelf];
            }
                break;    
            default:
                break;
        }    
    };
}



/**
 虚化图片获取方法
 */
- (void)addBlurView{
    // 底板
    _placeholderImageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*600/1920.0)];
    _placeholderImageView.clipsToBounds = YES;
    _placeholderImageView.fillMode = kGPUImageFillModeStretch;
    _bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*600/1920.0)];
    _bannerImageView.image = [UIImage imageNamed:@"banner"];
    [_headerMVPlayerView addSubview:_bannerImageView];
    [_headerMVPlayerView addSubview:_placeholderImageView];
    
    // 初始化滤镜
    if (_blurFilter == nil) {
        _blurFilter = [[GPUImageiOSBlurFilter alloc] init];
        _blurFilter.blurRadiusInPixels = 2.0f;
        _blurFilter.downsampling = 2;
    }
}




















#pragma mark - 中间标题 + 下载列表按钮
- (void)creatMiddleTitle{
    self.middleTitleLabel = [[UILabel alloc] init];
    [self.view addSubview:self.middleTitleLabel];
    self.middleTitleLabel.text = self.middelname;
    self.middleTitleLabel.textColor = ZJCGetColorWith(66, 66, 66, 1);
    self.middleTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.middleTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.middleTitleLabel.userInteractionEnabled = YES;
    __weak __typeof(self) weakSelf = self; 
    [self.middleTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset([ZJCFrameControl GetControl_X:40]);
        make.top.equalTo(weakSelf.view).offset([ZJCFrameControl GetControl_Y:600+64]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:1080-100-60-40], [ZJCFrameControl GetControl_height:45]));
    }];
}


//小屏幕播放时播放器下面的下载按钮
- (void)createDownListButton{
    self.downListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_downListButton];
    __weak __typeof(self) weakSelf = self; 
    [weakSelf.downListButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset([ZJCFrameControl GetControl_X:1080-100-60]);
        make.top.equalTo(weakSelf.view).offset([ZJCFrameControl GetControl_Y:600+40]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:100], [ZJCFrameControl GetControl_height:100]));
    }];
    UIImageView * imageView = [[UIImageView alloc] init];
    [_downListButton addSubview:imageView];
    [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.downListButton.mas_centerX); 
        make.centerY.equalTo(weakSelf.downListButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_X:60], [ZJCFrameControl GetControl_X:60]));
    }];
    imageView.image = [UIImage imageNamed:@"down_ing"];
    [_downListButton addTarget:self action:@selector(downListButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)downListButtonClicked:(UIButton *)button{
    ZJCDownloadListViewController * downListVC = [[ZJCDownloadListViewController alloc] init];
    [self.navigationController pushViewController:downListVC animated:YES];
}




















#pragma mark - 下部 分栏控制器
- (void)creatPagerViews{
    // 底板
    _pagerView = [[UIView alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:40], [ZJCFrameControl GetControl_Y:677+600-527]- 1, [ZJCFrameControl GetControl_weight:640], [ZJCFrameControl GetControl_height:114])];
    [self.view addSubview:_pagerView];
    
    // 两个选项卡按钮
    // 简介
    _button1 = [[UIButton alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:0], [ZJCFrameControl GetControl_Y:0], [ZJCFrameControl GetControl_weight:200], [ZJCFrameControl GetControl_height:114])];
    _button1.tag = 11;
    _button1.selected = NO;
    _button1.titleLabel.font = [UIFont systemFontOfSize:14];
    [_button1 setTitle:@"详细" forState:UIControlStateNormal];
    [_button1 setTitle:@"详细" forState:UIControlStateSelected];
    [_button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button1 setTitleColor:THEME_BACKGROUNDCOLOR forState:UIControlStateSelected];
    [_button1 setTitleColor:THEME_BACKGROUNDCOLOR forState:UIControlStateHighlighted];
    [_button1 addTarget:self action:@selector(pageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_pagerView addSubview:_button1];
    // 目录
    _button2 = [[UIButton alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:200], [ZJCFrameControl GetControl_Y:0], [ZJCFrameControl GetControl_weight:200], [ZJCFrameControl GetControl_height:114])];
    _button2.tag = 12;
    _button2.selected = YES;
    _button2.titleLabel.font = [UIFont systemFontOfSize:14];
    [_button2 setTitle:@"目录" forState:UIControlStateSelected];
    [_button2 setTitle:@"目录" forState:UIControlStateNormal];
    [_button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button2 setTitleColor:THEME_BACKGROUNDCOLOR forState:UIControlStateSelected];
    [_button2 setTitleColor:THEME_BACKGROUNDCOLOR forState:UIControlStateHighlighted];
    [_button2 addTarget:self action:@selector(pageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_pagerView addSubview:_button2];
    // 课后练习
    _button3 = [[UIButton alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:440], [ZJCFrameControl GetControl_Y:0], [ZJCFrameControl GetControl_weight:200], [ZJCFrameControl GetControl_height:114])];
    _button3.tag = 13;
    _button3.selected = NO;
    _button3.titleLabel.font = [UIFont systemFontOfSize:14];
    [_button3 setTitle:@"下载" forState:UIControlStateSelected];
    [_button3 setTitle:@"下载" forState:UIControlStateNormal];
    [_button3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button3 setTitleColor:THEME_BACKGROUNDCOLOR forState:UIControlStateSelected];
    [_button3 setTitleColor:THEME_BACKGROUNDCOLOR forState:UIControlStateHighlighted];
    [_button3 addTarget:self action:@selector(pageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_pagerView addSubview:_button3];
   
 
    
    

    
    
    // 滚动底条
    _lineView = [[UIView alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:200], CGRectGetHeight(_pagerView.frame)-SINGLE_LINE_ADJUST_OFFSET, [ZJCFrameControl GetControl_weight:200], 1)];
    _lineView.backgroundColor = THEME_BACKGROUNDCOLOR;
    [_pagerView addSubview:_lineView];
    
    // 分割线
    _seperateLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_pagerView.frame)+SINGLE_LINE_ADJUST_OFFSET, SCREEN_WIDTH, SINGLE_LINE_WIDTH)];
    _seperateLine.backgroundColor = ZJCGetColorWith(170, 170, 170, 1);
    [self.view addSubview:_seperateLine];
    
    
    
    
    /**
     课程目录
     */
    _courseCatelogueView = [[ZJCCourceCatalogueView alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:0], CGRectGetMaxY(_pagerView.frame)+1, SCREEN_WIDTH, SCREEN_HEIGHT-CGRectGetMaxY(_pagerView.frame))];
    _courseCatelogueView.hidden = NO;
    [self.view addSubview:_courseCatelogueView];
    __weak typeof(self) blockSelf = self;
    
    
    // 练习题按钮点击回调
    _courseCatelogueView.pushPraBlock = ^(UIButton * button,NSString * testId,BOOL isDown){
//        ZJCPracticeTestsViewController * practiceVC = [[ZJCPracticeTestsViewController alloc] init];
//        practiceVC.returnBlock = ^(BOOL isDown){
//            [blockSelf loadCourseIntroductionData];
//        };
//        practiceVC.testId = testId;
//        practiceVC.isDown = isDown;
//        [blockSelf.navigationController pushViewController:practiceVC animated:YES];
        
        // 新版练习题界面
//        ZJCNewPracticeTestsViewController * newPracticeVC = [[ZJCNewPracticeTestsViewController alloc] init];
//        newPracticeVC.testId = testId;
//        newPracticeVC.isdown = isDown;
//        [blockSelf.navigationController pushViewController:newPracticeVC animated:YES];
    };
    
    
    
    
    // cell点击回调
    _courseCatelogueView.cellClicked = ^(id sender,NSString * videoId,NSString * title,NSString * lessonId,BOOL isSection,NSInteger selectSection,NSInteger selectRow){
        // 判断当前是否存在播放器,然后更新状态
        if (blockSelf.playerView != nil) {                    // 播放新的视频
            [blockSelf.playerView.player pause];
            // 查询是否存在已经下载完成的本地文件,如果有的的话,就初始化播放器播放本地文件~
            ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
            NSArray * currentItem = [manager selectRecordWithMyid:lessonId];
            if (currentItem.count != 0) {
                NSString * currentIsover = [currentItem firstObject][@"isover"];
                if ([currentIsover isEqualToString:@"1"]) {
                    // 当前下载进度是1 说明该项目已经下载完成了,可以播放本地视频了
                    NSString * localPath = [NSString stringWithFormat:@"%@/%@%@.pcm",DWPlayer_Destion,lessonId,videoId];
                    blockSelf.localPath = localPath;
                    blockSelf.videoIds = videoId;
                    blockSelf.lessonId = lessonId;
                    blockSelf.playerCourseNameLabel.text = title;
                    blockSelf.playerView.lessonId = lessonId;
                    blockSelf.playerView.titleLabel.text = title;
                    blockSelf.playerView.titleLabelString = title;
                    [blockSelf.playerView.courseListPopView.tableView reloadData];
                    blockSelf.playerView.videoLocalPath = localPath;
                }else{
                    // 当前下载进度不是1 说明该项目需要播放网络视频
                    blockSelf.videoIds = videoId;
                    blockSelf.lessonId = lessonId;
                    blockSelf.playerCourseNameLabel.text = title;
                    blockSelf.playerView.lessonId = lessonId;
                    blockSelf.playerView.titleLabel.text = title;
                    blockSelf.playerView.titleLabelString = title;
                    [blockSelf.playerView.courseListPopView.tableView reloadData];
                    blockSelf.playerView.videoId = videoId;
                }
            }else{
                // 当前下载进度不是1 说明该项目需要播放网络视频
                blockSelf.videoIds = videoId;
                blockSelf.lessonId = lessonId;
                blockSelf.playerCourseNameLabel.text = title;
                blockSelf.playerView.lessonId = lessonId;
                blockSelf.playerView.titleLabel.text = title;
                blockSelf.playerView.titleLabelString = title;
                [blockSelf.playerView.courseListPopView.tableView reloadData];
                blockSelf.playerView.videoId = videoId;
            }
        }else{                                         // 创建一个播放器,播放当前对应视频
            // 查询是否存在已经下载完成的本地文件,如果有的的话,就初始化播放器播放本地文件~
            ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
            NSArray * currentItem = [manager selectRecordWithMyid:lessonId];
            if (currentItem.count != 0 ) {
                NSString * currentIsover = [currentItem firstObject][@"isover"];
                if ([currentIsover isEqualToString:@"1"]) {
                    // 当前下载进度是1 说明该项目已经下载完成了,可以播放本地视频了
                    NSString * localPath = [NSString stringWithFormat:@"%@/%@%@.pcm",DWPlayer_Destion,lessonId,videoId];
                    blockSelf.localPath = localPath;
                    blockSelf.videoIds = videoId;
                    blockSelf.lessonId = lessonId;
                    blockSelf.playerCourseNameLabel.text = title;
                    blockSelf.playerView.lessonId = lessonId;
                    blockSelf.playerView.titleLabel.text = title;
                    blockSelf.playerView.titleLabelString = title;
                    [blockSelf initDWMoviePlayerwithVideoId:nil orLocalPath:localPath];
                    [blockSelf.playerView.courseListPopView.tableView reloadData];
                    
                }else{
                    // 当前下载进度不是1 说明该项目需要播放网络视频
                    blockSelf.videoIds = videoId;
                    blockSelf.lessonId = lessonId;
                    blockSelf.playerCourseNameLabel.text = title;
                    [blockSelf initDWMoviePlayerwithVideoId:blockSelf.videoIds orLocalPath:nil];
                    [blockSelf.playerView.courseListPopView.tableView reloadData];
                }
            }else{
                // 当前下载进度不是1 说明该项目需要播放网络视频
                blockSelf.videoIds = videoId;
                blockSelf.lessonId = lessonId;
                blockSelf.playerCourseNameLabel.text = title;
                [blockSelf initDWMoviePlayerwithVideoId:blockSelf.videoIds orLocalPath:nil];
                [blockSelf.playerView.courseListPopView.tableView reloadData];
            }
            
            
            
        }
    };
    
    
    /**
     课程简介
     */
    _courseInforView = [[ZJCCourceInforView alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:0], CGRectGetMaxY(_pagerView.frame)+1, SCREEN_WIDTH, SCREEN_HEIGHT-CGRectGetMaxY(_pagerView.frame))];
    _courseInforView.hidden = YES;
    [self.view addSubview:_courseInforView];
}




- (void)pageButtonClicked:(UIButton *)button{
    if (button.tag == 11) {
        if (button.selected == YES) {
            return;
        }else{
            button.selected = YES;
            _button2.selected = NO;
            _courseCatelogueView.hidden = YES;
            _courseInforView.hidden = NO;
            
            
            [UIView animateWithDuration:0.1 animations:^{
                _lineView.frame = CGRectMake([ZJCFrameControl GetControl_X:0], CGRectGetHeight(_pagerView.frame)-SINGLE_LINE_ADJUST_OFFSET, [ZJCFrameControl GetControl_weight:200], 1);
            }];
        }
        
    }else if(button.tag == 12){
        if (button.selected == YES) {
            return;
        }else{
            button.selected = YES;
            _button1.selected = NO;
            _courseCatelogueView.hidden = NO;
            _courseInforView.hidden = YES;
            
            
            [UIView animateWithDuration:0.1 animations:^{
                _lineView.frame = CGRectMake([ZJCFrameControl GetControl_X:200], CGRectGetHeight(_pagerView.frame)-SINGLE_LINE_ADJUST_OFFSET, [ZJCFrameControl GetControl_weight:200], 1);
            }];
        }
    }else if(button.tag == 13){
//        // 课后习题
//        ZJCPracticeTestsViewController * practiceVC = [[ZJCPracticeTestsViewController alloc] init];
//        practiceVC.returnBlock = ^(BOOL isDown){
//            [self loadCourseIntroductionData];
//        };
//        NSString * testId = [_receiveDataSource[@"eid"] stringValue];
//        BOOL isDown = [_receiveDataSource[@"ispaper"] boolValue];
//        if (!(testId == nil || [testId isEqualToString:@"0"])) {
//            practiceVC.testId = testId;
//            practiceVC.isDown = isDown;
//            [self.navigationController pushViewController:practiceVC animated:YES];
//        }else{
//            [ZJCAlertView presentAlertWithAlertTitle:@"提示" andAlertMessage:@"试卷不存在" andAlertStyle:UIAlertControllerStyleAlert andSupportController:self completion:nil andDelay:1.5];
//        }
        
        
        // 新版练习题界面
        NSString * testId = [_receiveDataSource[@"eid"] stringValue];
        BOOL isDown = [_receiveDataSource[@"ispaper"] boolValue];
        if (!(testId == nil || [testId isEqualToString:@"0"])) {
//            ZJCNewPracticeTestsViewController * newPracticeVC = [[ZJCNewPracticeTestsViewController alloc] init];
//            newPracticeVC.testId = testId;
//            newPracticeVC.isdown = isDown;
//            [self.navigationController pushViewController:newPracticeVC animated:YES];
        }else{
            [ZJCAlertView presentAlertWithAlertTitle:@"提示" andAlertMessage:@"试卷不存在" andAlertStyle:UIAlertControllerStyleAlert andSupportController:self completion:nil andDelay:1.5];
        }
    }
}











#pragma mark - 旋转屏幕相关
- (void)orientChange:(NSNotification *)noteInfor{
    //1.获取 当前设备 实例
    UIDevice *device = [UIDevice currentDevice] ;
    /**
     *  1.取得当前Device的方向，Device的方向类型为Integer
     *
     *  必须调用beginGeneratingDeviceOrientationNotifications方法后，此orientation属性才有效，否则一直是0。orientation用于判断设备的朝向，与应用UI方向无关
     *
     *  @param device.orientation
     *
     */
    switch (device.orientation) {
            
        case UIDeviceOrientationFaceUp:
            logdebug(@"屏幕朝上平躺");
            break;
            
        case UIDeviceOrientationFaceDown:
            logdebug(@"屏幕朝下平躺");
            break;
            
            //系統無法判斷目前Device的方向，有可能是斜置
        case UIDeviceOrientationUnknown:
            logdebug(@"未知方向");
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            logdebug(@"屏幕向左横置");
            [self handleDeviceOrientationLandscapeLeft];
            break;
            
        case UIDeviceOrientationLandscapeRight:
            logdebug(@"屏幕向右橫置");
            [self handleDeviceOrientationLandscapeRight];
            break;
            
        case UIDeviceOrientationPortrait:
            logdebug(@"屏幕直立");
            [self handleDeviceOrientationPortrait];
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            logdebug(@"屏幕直立，上下顛倒");
            break;
            
        default:
            logdebug(@"无法辨识");
            break;
    }
}

/**
 *  @brief 竖屏
 */
- (void)handleDeviceOrientationPortrait{
    if (self.isFullScreenOfViewCon == YES) {
        
    }else{
        // 展开视图
        _middleTitleLabel.hidden = NO;
        _pagerView.hidden = NO;
        _downListButton.hidden = NO;
        _seperateLine.hidden = NO;
        _bannerImageView.hidden = NO;
        _backButton.hidden = NO;
        if (self.displayWhichFolg == DisPlayCourseInforView) {
            _courseCatelogueView.hidden = YES;
            _courseInforView.hidden = NO;
        }else if (self.displayWhichFolg == DisplayCourseCatelogueView){
            _courseCatelogueView.hidden = NO;
            _courseInforView.hidden = YES;
        }
        
        // 调整界面
        __weak typeof(self)weakSelf = self;
        [_headerMVPlayerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.view).offset([ZJCFrameControl GetControl_X:0]);
            make.top.equalTo(weakSelf.view).offset([ZJCFrameControl GetControl_Y:0]);
            make.right.equalTo(weakSelf.view);
            make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:1080], [ZJCFrameControl GetControl_height:600]));
        }];
        
        _playerView.isFullScreen = NO;
        [_playerView setBounds:CGRectMake(0, 0, SCREEN_WIDTH, [ZJCFrameControl GetControl_height:600])];
    } 
}


/**
 *  @brief 左横屏
 */
- (void)handleDeviceOrientationLandscapeLeft{
    // 隐藏视图
    _middleTitleLabel.hidden = YES;
    _pagerView.hidden = YES;
    _downListButton.hidden = YES;
    _seperateLine.hidden = YES;
    _courseCatelogueView.hidden = YES;
    _courseInforView.hidden = YES;
    _bannerImageView.hidden = YES;
    _backButton.hidden = YES;
    
    // 调整界面
    __weak typeof(self)weakSelf = self;
    [_headerMVPlayerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(weakSelf.view);
    }];
    
    _playerView.isFullScreen = YES;
    
}



/**
 *  @brief 右横屏
 */
- (void)handleDeviceOrientationLandscapeRight{
    // 隐藏视图
    _middleTitleLabel.hidden = YES;
    _pagerView.hidden = YES;
    _downListButton.hidden = YES;
    _seperateLine.hidden = YES;
    _courseCatelogueView.hidden = YES;
    _courseInforView.hidden = YES;
    _bannerImageView.hidden = YES;
    _backButton.hidden = YES;
    
    // 调整界面
    __weak typeof(self)weakSelf = self;
    [_headerMVPlayerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(weakSelf.view);
    }];
    
    _playerView.isFullScreen = YES;
}


@end
















