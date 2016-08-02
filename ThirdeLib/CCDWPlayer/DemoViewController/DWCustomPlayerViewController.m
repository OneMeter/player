

/*
 
 */


#import "DWCustomPlayerViewController.h"
#import "DWPlayerMenuView.h"
#import "DWTableView.h"
#import "DWTools.h"
#import "DWMediaSubtitle.h"

#import "AppDelegate.h"
#import "ZJCDownloadListView.h"
#import "ZJCCourseListView.h"


static int hideViewTime = 10;


enum {
    DWPlayerScreenSizeModeFill=1,
    DWPlayerScreenSizeMode100,
    DWPlayerScreenSizeMode75,
    DWPlayerScreenSizeMode50
};

typedef NSInteger DWPLayerScreenSizeMode;






@interface DWCustomPlayerViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic)UIView *headerView;
@property (strong, nonatomic)UIView *footerView;

@property (strong, nonatomic)UIButton *backButton;

@property (strong, nonatomic)UIButton *screenSizeButton;
@property (strong, nonatomic)DWPlayerMenuView *screenSizeView;
@property (assign, nonatomic)NSInteger currentScreenSizeStatus;
@property (strong, nonatomic)DWTableView *screenSizeTable;

@property (strong, nonatomic)UIButton *subtitleButton;
@property (strong, nonatomic)DWPlayerMenuView *subtitleView;
@property (assign, nonatomic)NSInteger currentSubtitleStatus;
@property (strong, nonatomic)DWTableView *subtitleTable;
@property (strong, nonatomic)UILabel *movieSubtitleLabel;
@property (strong, nonatomic)DWMediaSubtitle *mediaSubtitle;

@property (strong, nonatomic)UIButton *qualityButton;    //画面质量
@property (strong, nonatomic)DWPlayerMenuView *qualityView;
@property (assign, nonatomic)NSInteger currentQualityStatus;
@property (strong, nonatomic)DWTableView *qualityTable;
@property (strong, nonatomic)NSArray *qualityDescription;
@property (strong, nonatomic)NSString *currentQuality;

@property (strong, nonatomic)UIButton *playbackButton;

@property (strong, nonatomic)UISlider *durationSlider;
@property (strong, nonatomic)UILabel *currentPlaybackTimeLabel;
@property (strong, nonatomic)UILabel *durationLabel;

@property (strong, nonatomic)UIView *volumeView;
@property (strong, nonatomic)UISlider *volumeSlider;

@property (strong, nonatomic)UIView *overlayView;
@property (strong, nonatomic)UIView *videoBackgroundView;
@property (strong, nonatomic)UITapGestureRecognizer *signelTap;
@property (strong, nonatomic)UILabel *videoStatusLabel;

@property (strong, nonatomic)DWMoviePlayerController  *player;
@property (strong, nonatomic)NSDictionary *playUrls;
@property (strong, nonatomic)NSDictionary *currentPlayUrl;
@property (assign, nonatomic)NSTimeInterval historyPlaybackTime;

@property (strong, nonatomic)NSTimer *timer;

@property (assign, nonatomic)BOOL hiddenAll;
@property (assign, nonatomic)NSInteger hiddenDelaySeconds;

@property (nonatomic ,strong) UILabel * titleLabel;            // 标题
@property (nonatomic ,strong) UIButton * courseButton;         // 课节列表 按钮
@property (nonatomic ,strong) UIButton * downloadListButton;   // 下载列表 按钮

@property (nonatomic ,strong) ZJCDownloadListView * downlistPopView;  // 下载列表
@property (nonatomic ,strong) UIView * downlistPopBackground;          
@property (nonatomic ,strong) UIButton * exitButton;                  
@property (nonatomic ,strong) ZJCCourseListView * courseListPopView;  // 课节列表
@property (nonatomic ,strong) UIButton * courseListPopBackground;

@end



@implementation DWCustomPlayerViewController

#pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>初始化方法
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _qualityDescription = @[@"普通", @"清晰", @"高清"];
        
        _player = [[DWMoviePlayerController alloc] initWithUserId:DWACCOUNT_USERID key:DWACCOUNT_APIKEY];
        
        _currentQuality = [_qualityDescription objectAtIndex:0];
        
        [self addObserverForMPMoviePlayController];
        [self addTimer];
    }
    return self;
}




















#pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>加载视图
- (void)viewDidLoad{
    [super viewDidLoad];
    /**
     播放器配置
     */
    // 1.设置 DWMoviePlayerController 的 drmServerPort 用于drm加密视频的播放
    self.player.drmServerPort = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).drmServer.listenPort;
    logdebug(@"drmSeerverPort: %d", self.player.drmServerPort);
    
    // 2.如果是竖屏的就不需要转屏,如果不是就需要转屏  >>> 这里只需要作为大屏来播放,所以强转
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    [self doForceScreenRotate];
    
    // 3.加载播放器 必须第一个加载  (放在最底层)
    [self loadPlayer];
    
    
    /**
     加载播放器的主视图
     */
    // 1.加载播放器覆盖视图，它作为所有控件的父视图。
    self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.overlayView.backgroundColor = [UIColor clearColor];
    CGRect frame = CGRectZero;
    if (IsIOS7) {
        frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    } else {
        frame = CGRectMake(-20, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    self.overlayView.frame = frame;
    [self.view addSubview:self.overlayView];
    logdebug(@"self.view.frame: %@ self.overlayView frame: %@", NSStringFromCGRect(self.view.frame), NSStringFromCGRect(self.overlayView.frame));
    
    
    // 2.顶部工具条
    [self loadHeaderView];
    
    
    // 3.底部工具条
    [self loadFooterView];
    
    
    // 4.音量控制条 (w.t.  暂时先不加音量按钮)
//    [self loadVolumeView];
    
    
    // 5.播放状态显示label(e.g. 正在加载...、加载失败、暂停)
    [self loadVideoStatusLabel];
    
    
    // 6. 全局点击手势
    self.signelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSignelTap:)];
    self.signelTap.numberOfTapsRequired = 1;
    self.signelTap.delegate = self;
    [self.overlayView addGestureRecognizer:self.signelTap];
    
    
    // 7.区分加载播放的视频
    if (self.videoId) {
        // 获取videoId的播放url
        [self loadPlayUrls];
    }else if (self.videoLocalPath) {
        // 播放本地视频
        [self playLocalVideo];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有可以播放的视频" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    // 8.自动隐藏所有的窗口的时间
    self.hiddenDelaySeconds = hideViewTime;
}


// 强制转屏方法
- (void)doForceScreenRotate{
    // 强制调整屏幕方向
    CGRect frame = self.view.frame;
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
    [self.view setTransform:CGAffineTransformMakeRotation(M_PI/2)];
    
    if (IsIOS7) {
        self.view.frame = CGRectMake(0, 0, frame.size.height, frame.size.width);
    } else {
        self.view.frame = CGRectMake(-20, 0, frame.size.height + 20, frame.size.width - 20);
    }
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // 隐藏 navigationController
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    // 隐藏 statusbar
    [self setNeedsStatusBarAppearanceUpdate];
    // 隐藏 tabbar
    [self.tabBarController.tabBar setHidden:YES];
    
    // 设置 DWMoviePlayerController 的 drmServerPort 用于drm加密视频的播放
    self.player.drmServerPort = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).drmServer.listenPort;
    logdebug(@"drmSeerverPort: %d", self.player.drmServerPort);
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    logdebug(@"stop movie");
    // 停止请求播放信息
    [self.player cancelRequestPlayInfo];
    
    // 播放器的当前播放时间置 为当前的进度
    self.player.currentPlaybackTime = self.player.duration;
    self.player.contentURL = nil;
    [self.player stop];
    
    // 去掉各种监听,定时器也关掉
    [self removeAllObserver];
    [self removeTimer];
    
    // 回传播放进度
    if (self.playerCurrentDurationBlock) {
        self.playerCurrentDurationBlock(self.videoId,self.player.duration,self.titleLabel.text);
    }
    
    
    
    /**
     *  NOTE: 顺序必须为：
     *      调整屏幕方向 -> 显示 状态栏 -> 显示 navigationController
     *  否则返回播放列表页面时，导航栏的尺寸会发生变化。
     */
    
    // 调整屏幕方向
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    self.view.transform = CGAffineTransformMakeRotation(-M_PI/2);
    
    // 显示 状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    // 显示 navigationController
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // 显示 tabbar
    [self.tabBarController.tabBar setHidden:NO];
}





#pragma mark - 加载播放器
- (void)loadPlayer{
    CGRect frame = CGRectZero;
    frame = self.view.frame;
    if (IsIOS7) {
        frame.origin.x = 0;
        frame.origin.y = 0;
    } else {
        frame.size.height += 20; //加上状态栏的高度
    }
    
    // 1.黑色的播放底板
    self.videoBackgroundView = [[UIView alloc] initWithFrame:frame];
    self.videoBackgroundView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.videoBackgroundView];
    logdebug(@"self.view.frame: %@ self.videoBackgroundView.frame: %@", NSStringFromCGRect(self.view.frame), NSStringFromCGRect(self.videoBackgroundView.frame));
    
    // 2.播放器
    self.player.scalingMode = MPMovieScalingModeAspectFill;
    self.player.controlStyle = MPMovieControlStyleNone;
    self.player.view.backgroundColor = [UIColor clearColor];
    self.player.view.frame = self.videoBackgroundView.bounds;
    [self.videoBackgroundView addSubview:self.player.view];
    logdebug(@"self.player.view.frame: %@", NSStringFromCGRect(self.player.view.frame));
}





#pragma mark - 播放视频
- (void)loadPlayUrls{
    self.player.videoId = self.videoId;
    self.player.timeoutSeconds = 10;
    
    __weak DWCustomPlayerViewController *blockSelf = self;
    self.player.failBlock = ^(NSError *error) {
        loginfo(@"error: %@", [error localizedDescription]);
        blockSelf.videoStatusLabel.hidden = NO;
        blockSelf.videoStatusLabel.text = @"加载失败";
    };
    
    self.player.getPlayUrlsBlock = ^(NSDictionary *playUrls) {
        // [必须]判断 status 的状态，不为"0"说明该视频不可播放，可能正处于转码、审核等状态。
        NSNumber *status = [playUrls objectForKey:@"status"];
        if (status == nil || [status integerValue] != 0) {
            NSString *message = [NSString stringWithFormat:@"%@ %@:%@",
                                 blockSelf.videoId,
                                 [playUrls objectForKey:@"status"],
                                 [playUrls objectForKey:@"statusinfo"]];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        
        blockSelf.playUrls = playUrls;
        
        [blockSelf resetViewContent];
    };
    
    [self.player startRequestPlayInfo];
}




















#pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>headerView顶部工具条
- (void)loadHeaderView{
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.overlayView.width, self.overlayView.height*167/1080.0)];
    self.headerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    [self.overlayView addSubview:self.headerView];
    
    /**
     *  NOTE: 由于各个view之间的坐标有约束依赖关系，所以修饰界面的时候需要注意
     *  qualityView -> subtitleView -> backButton
     */
    // 1.标题
    [self creatTitleLabel];
    
    // 2.课节按钮
    [self creatCourseTable];
    
    // 3.返回按钮
    [self loadBackButton];
}





#pragma mark - 播放的标题
- (void)creatTitleLabel{
    _titleLabel = [[UILabel alloc] init];
    [self.headerView addSubview:_titleLabel];
    __weak __typeof(self) weakSelf = self; 
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.headerView.mas_centerX);
        make.centerY.equalTo(weakSelf.headerView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(weakSelf.headerView.width,weakSelf.headerView.height));
    }];
    _titleLabel.text = self.titleLabelString;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
}





#pragma mark - 课节列表按钮
- (void)creatCourseTable{
    // 课节列表按钮
    self.courseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.overlayView addSubview:self.courseButton];
    self.courseButton.selected = NO;
    __weak __typeof(self) weakSelf = self; 
    [weakSelf.courseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.headerView.mas_right).offset(-[ZJCFrameControl GetControl_X:20]);
        make.centerY.equalTo(weakSelf.headerView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(weakSelf.headerView.height, weakSelf.headerView.height));
    }];
    UIImageView * imageView = [[UIImageView alloc] init];
    [_courseButton addSubview:imageView];
    [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.courseButton.mas_centerX); 
        make.centerY.equalTo(weakSelf.courseButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_X:80], [ZJCFrameControl GetControl_X:80]));
    }];
    imageView.image = [UIImage imageNamed:@"courseList"];    
    self.courseButton.backgroundColor = [UIColor clearColor];
    [self.courseButton addTarget:self action:@selector(courseButtonClicked:)
              forControlEvents:UIControlEventTouchUpInside];
    logdebug(@"self.backButton.frame: %@", NSStringFromCGRect(self.courseButton.frame));
    
    // 底板(截取事件)
    self.courseListPopBackground = [[UIButton alloc] initWithFrame:self.overlayView.bounds];
    self.courseListPopBackground.backgroundColor = [UIColor clearColor];
    self.courseListPopBackground.hidden = YES;
    [self.overlayView addSubview:self.courseListPopBackground];
    [self.courseListPopBackground addTarget:self action:@selector(tapbackGround:) forControlEvents:UIControlEventTouchUpInside];
    
    // 弹出课节列表
    self.courseListPopView = [[ZJCCourseListView alloc] initWithFrame:CGRectMake(self.overlayView.width, 0, self.overlayView.width*750/1920.0, self.overlayView.height)];
    self.courseListPopView.userInteractionEnabled = YES;
    [self.overlayView addSubview:self.courseListPopView];
}


// 课节列表   按钮
- (void)courseButtonClicked:(UIButton *)button{
    // 隐藏其他按钮
    [self hiddenAllView];
    
    // 区分 弹出 和 收起 的区别
    __weak typeof(self)weakSelf = self;
    if (button.selected == YES) {
        [UIView animateWithDuration:0.28 animations:^{
            weakSelf.courseListPopView.frame = CGRectMake(self.overlayView.width, 0, self.overlayView.width*750/1920.0, self.overlayView.height);
        }];
        button.selected = !button.selected;
        self.courseListPopBackground.hidden = YES;
    }else{
        [UIView animateWithDuration:0.28 animations:^{
            weakSelf.courseListPopView.frame = CGRectMake(self.overlayView.width - self.overlayView.width*750/1920.0, 0, self.overlayView.width*750/1920.0, self.overlayView.height);
        }];
        button.selected = !button.selected;
        self.courseListPopBackground.hidden = NO;
    }
}


- (void)tapbackGround:(UITapGestureRecognizer *)tap{
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.28 animations:^{
        weakSelf.courseListPopView.frame = CGRectMake(self.overlayView.width, 0, self.overlayView.width*750/1920.0, self.overlayView.height);
    }];
    self.courseButton.selected = !self.courseButton.selected;
    self.courseListPopBackground.hidden = YES;
}






#pragma mark - 返回按钮及视频标题
- (void)loadBackButton{
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.overlayView addSubview:self.backButton];
    //    CGRect frame;
    //    frame.origin.x = 16;
    //    frame.origin.y = self.headerView.frame.origin.y + 4;
    //    frame.size.width = 100;
    //    frame.size.height = 30;
    //    self.backButton.frame = frame;
    __weak __typeof(self) weakSelf = self; 
    [weakSelf.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.headerView).offset([ZJCFrameControl GetControl_Y:10]);
        make.centerY.equalTo(weakSelf.headerView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(weakSelf.headerView.height, weakSelf.headerView.height));
    }];
    UIImageView * imageView = [[UIImageView alloc] init];
    [_backButton addSubview:imageView];
    [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.backButton.mas_centerX); 
        make.centerY.equalTo(weakSelf.backButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_X:90], [ZJCFrameControl GetControl_X:90]));
    }];
    imageView.image = [UIImage imageNamed:@"navigationBack"];    
    self.backButton.backgroundColor = [UIColor clearColor];
    [self.backButton addTarget:self action:@selector(backButtonAction:)
              forControlEvents:UIControlEventTouchUpInside];
    logdebug(@"self.backButton.frame: %@", NSStringFromCGRect(self.backButton.frame));
}

- (void)backButtonAction:(UIButton *)button{
    self.downlistPopBackground.hidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
}










#pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>footerView底部工具条
- (void)loadFooterView{
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.overlayView.height-[ZJCFrameControl GetControl_weight:167], self.overlayView.frame.size.width, [ZJCFrameControl GetControl_weight:167])];
    self.footerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    [self.overlayView addSubview:self.footerView];
    logdebug(@"footerView: %@", NSStringFromCGRect(self.footerView.frame));
    
    /**
     *  NOTE: 由于各个view之间的坐标有约束依赖关系，所以要注意界面控件的修改
     *  
     */
    
    // 1.播放按钮
    [self loadPlaybackButton];
    
    // 2.当前播放时间
    [self loadCurrentPlaybackTimeLabel];
    
    // 3.清晰度按钮
    if (self.videoId) {
        // 清晰度
        [self loadQualityView];
    }
    
    // 4.下载列表按钮
    [self loadDownloadListButton];
    
    // 5.视频总时间
    [self loadDurationLabel];
    
    // 6.进度条
    [self loadPlaybackSlider];
}





#pragma mark - 播放按钮
- (void)loadPlaybackButton{
    self.playbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.overlayView addSubview:self.playbackButton];
    __weak __typeof(self) weakSelf = self; 
    [weakSelf.playbackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.footerView).offset([ZJCFrameControl GetControl_Y:0]);
        make.centerY.equalTo(weakSelf.footerView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:167], [ZJCFrameControl GetControl_weight:167]));
    }];
    UIImageView * imageView = [[UIImageView alloc] init];
    [self.playbackButton addSubview:imageView];
    [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.playbackButton.mas_centerX); 
        make.centerY.equalTo(weakSelf.playbackButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_X:80], [ZJCFrameControl GetControl_X:80]));
    }];
    imageView.tag = 1000;
    imageView.image = [UIImage imageNamed:@"play"];
    
//    [self.playbackButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
//    [self.playbackButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
    [self.playbackButton addTarget:self action:@selector(playbackButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)playbackButtonAction:(UIButton *)button{
    self.hiddenDelaySeconds = 5;
    
    if (!self.playUrls || self.playUrls.count == 0) {
        [self loadPlayUrls];
        return;
    }
    
    if (self.player.playbackState == MPMoviePlaybackStatePlaying) {
        // 暂停播放
        self.playbackButton.selected = YES;
        UIImageView * imageView = [self.playbackButton viewWithTag:1000];
        imageView.image = [UIImage imageNamed:@"play"];
        [self.player pause];
        
    } else {
        // 继续播放
        self.playbackButton.selected = NO;
        UIImageView * imageView = [self.playbackButton viewWithTag:1000];
        imageView.image = [UIImage imageNamed:@"pause"];
        [self.player play];
    }
}





#pragma mark - 当前播放时间
- (void)loadCurrentPlaybackTimeLabel{
    self.currentPlaybackTimeLabel = [[UILabel alloc] init];
    [self.overlayView addSubview:self.currentPlaybackTimeLabel];
    __weak __typeof(self) weakSelf = self; 
    [weakSelf.currentPlaybackTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.playbackButton.mas_right).offset([ZJCFrameControl GetControl_X:10]);
        make.centerY.equalTo(weakSelf.footerView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:180], [ZJCFrameControl GetControl_height:40]));
    }];
    self.currentPlaybackTimeLabel.text = @"00:00:00";
    self.currentPlaybackTimeLabel.textColor = [UIColor whiteColor];
    self.currentPlaybackTimeLabel.textAlignment = NSTextAlignmentRight;
    self.currentPlaybackTimeLabel.font = [UIFont systemFontOfSize:12];
    self.currentPlaybackTimeLabel.backgroundColor = [UIColor clearColor];
    
    logdebug(@"currentPlaybackTimeLabel frame: %@", NSStringFromCGRect(self.currentPlaybackTimeLabel.frame));
}






#pragma mark - 清晰度按钮
- (void)loadQualityView{
    // 1.清晰度按钮
    self.qualityButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.overlayView addSubview:self.qualityButton];
    __weak __typeof(self) weakSelf = self; 
    [weakSelf.qualityButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.footerView.mas_right).offset(-[ZJCFrameControl GetControl_X:30]);
        make.centerY.equalTo(weakSelf.footerView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:167], [ZJCFrameControl GetControl_weight:167]));
    }];
    self.qualityButton.backgroundColor = [UIColor clearColor];
    [self.qualityButton setTitle:self.currentQuality forState:UIControlStateNormal];
    [self.qualityButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.qualityButton addTarget:self action:@selector(qualityButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 2.清晰度 选项卡列表
    // 包括各种Block回调方法
    NSInteger triangleHeight = 8;
    CGRect frame = CGRectZero;
    frame.size.width = 60;
    frame.size.height = self.qualityDescription.count*30 + triangleHeight;
    frame.origin.x = self.overlayView.frame.size.width - frame.size.width/2 - [ZJCFrameControl GetControl_X:30] - [ZJCFrameControl GetControl_weight:167]/2;
    frame.origin.y = self.footerView.frame.origin.y + triangleHeight - frame.size.height;
    self.qualityView = [[DWPlayerMenuView alloc] initWithFrame:frame andTriangelHeight:triangleHeight upsideDown:YES FillColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    self.qualityView.hidden = YES;
    self.qualityView.backgroundColor = [UIColor clearColor];
    [self.overlayView addSubview:self.qualityView];
    
    frame = CGRectZero;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = self.qualityView.frame.size.width;
    frame.size.height = self.qualityView.frame.size.height - triangleHeight;
    self.qualityTable = [[DWTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.qualityTable.rowHeight = 30;
    self.qualityTable.backgroundColor = [UIColor clearColor];
    [self.qualityTable resetDelegate];
    self.qualityTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.qualityTable.scrollEnabled = NO;
    logdebug(@"qualityTable frame: %@", NSStringFromCGRect(self.qualityTable.frame));
    
    self.currentQualityStatus = 0; // 默认普通
    
    __weak DWCustomPlayerViewController *blockSelf = self;
    self.qualityTable.tableViewNumberOfRowsInSection = ^NSInteger(UITableView *tableView, NSInteger section) {
        return blockSelf.qualityDescription.count;
    };
    
    self.qualityTable.tableViewCellForRowAtIndexPath = ^UITableViewCell*(UITableView *tableView, NSIndexPath *indexPath) {
        static NSString *cellId = @"qualityTableCellId";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            [cell.textLabel sizeToFit];
            cell.backgroundColor = [UIColor clearColor];
        }
        
        if (indexPath.row == 0) {
            // 清晰度：普通
            cell.textLabel.text = [blockSelf.qualityDescription objectAtIndex:0];
            
        } else if (indexPath.row == 1) {
            // 清晰度：清晰
            cell.selected = YES;
            cell.textLabel.text = [blockSelf.qualityDescription objectAtIndex:1];
            
        } else if (indexPath.row == 2) {
            // 清晰度：高清
            cell.textLabel.text = [blockSelf.qualityDescription objectAtIndex:2];
        }
        
        if (indexPath.row == blockSelf.currentQualityStatus) {
            cell.textLabel.textColor = [UIColor orangeColor];
            
        } else {
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        
        return cell;
    };
    
    self.qualityTable.tableViewDidSelectRowAtIndexPath = ^void(UITableView *tableView, NSIndexPath *indexPath) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
        blockSelf.currentQualityStatus = indexPath.row;
        
        // 更新表格文字颜色，已选中行为橘色，为选中行为白色。
        UITableViewCell *cell = [blockSelf.qualityTable cellForRowAtIndexPath:indexPath];
        NSArray *cells = [blockSelf.qualityTable visibleCells];
        for (UITableViewCell *cl in cells) {
            if (cl == cell) {
                cl.textLabel.textColor = [UIColor orangeColor];
                
            } else {
                cl.textLabel.textColor = [UIColor whiteColor];
            }
        }
        
        if (indexPath.row == 0) {
            logdebug(@"清晰度切换为普通");
            [blockSelf switchQuality:0];
            
        } else if (indexPath.row == 1) {
            logdebug(@"清晰度切换为清晰");
            [blockSelf switchQuality:1];
            
        } else if (indexPath.row == 2) {
            logdebug(@"清晰度切换为高清");
            [blockSelf switchQuality:2];
        }
    };
    [self.qualityView addSubview:self.qualityTable];
}


- (void)reloadQualityView{
    [self.qualityButton removeFromSuperview];
    self.qualityButton.hidden = YES;
    self.qualityButton = nil;
    
    [self.qualityTable removeFromSuperview];
    self.qualityTable.hidden = YES;
    self.qualityTable = nil;
    
    [self.qualityView removeFromSuperview];
    self.qualityView.hidden = YES;
    self.qualityView = nil;
    
    [self loadQualityView];
}


- (void)qualityButtonAction:(UIButton *)button{
    self.hiddenDelaySeconds = 5;
    if (self.qualityView.hidden) {
        self.qualityView.hidden = NO;
        [self hiddenTableViewsExcept:self.qualityView];
        
    } else {
        self.qualityView.hidden = YES;
    }
}


/**
 切换清晰度的方法  
 1.比较当前清晰度是否改变
 2.如果需要改变,作如下操作
   2.1暂停当前的播放器
   2.2获取到需要切换的清晰度
   2.3改变清晰度按钮标题
   2.4记录播放器的播放进度
   2.5重置播放器
 */
- (void)switchQuality:(NSInteger)index{
    NSInteger currentQualityIndex =  [[self.playUrls objectForKey:@"playurls"] indexOfObject:self.currentPlayUrl];
    logdebug(@"index: %ld %ld", (long)index, (long)currentQualityIndex);
    if (index == currentQualityIndex) {
        // 不需要切换
        logdebug(@"current quality: %ld %@", (long)currentQualityIndex, self.currentPlayUrl);
        return;
    }
    loginfo(@"switch %@ -> %@", self.currentPlayUrl, [[self.playUrls objectForKey:@"qualities"] objectAtIndex:index]);
    
    [self.player stop];
    self.currentPlayUrl = [[self.playUrls objectForKey:@"qualities"] objectAtIndex:index];
    self.currentQuality = [self.currentPlayUrl objectForKey:@"desp"];
    [self.qualityButton setTitle:self.currentQuality forState:UIControlStateNormal];
    
    self.player.currentPlaybackTime = self.historyPlaybackTime;
    self.player.initialPlaybackTime = self.historyPlaybackTime;
    [self resetPlayer];
}





#pragma mark - 下载列表按钮
- (void)loadDownloadListButton{
    self.downloadListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.overlayView addSubview:self.downloadListButton];
    __weak __typeof(self) weakSelf = self;
    [weakSelf.downloadListButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.qualityButton.mas_left).offset(-[ZJCFrameControl GetControl_X:30]);
        make.centerY.equalTo(weakSelf.footerView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(weakSelf.footerView.height, weakSelf.footerView.height));
    }];
    UIImageView * imageView = [[UIImageView alloc] init];
    [_downloadListButton addSubview:imageView];
    [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.downloadListButton.mas_centerX); 
        make.centerY.equalTo(weakSelf.downloadListButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_X:80], [ZJCFrameControl GetControl_X:80]));
    }];
    imageView.image = [UIImage imageNamed:@"downList"];
    self.downloadListButton.selected = NO;
    self.downloadListButton.backgroundColor = [UIColor clearColor];
    [self.downloadListButton addTarget:self action:@selector(downLoadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    logdebug(@"self.backButton.frame: %@", NSStringFromCGRect(self.downloadListButton.frame));
    
    // 搭建下载列表
    [self creatDownlistView];
}


- (void)downLoadButtonClicked:(UIButton *)button{
    // 添加动画,弹出底框
    if (button.selected == YES) {    // 隐藏
        [UIView animateWithDuration:0.28 animations:^{
            self.downlistPopBackground.frame = CGRectMake(0, -self.overlayView.height, self.overlayView.width, self.overlayView.height);
        }];
        button.selected = !button.selected;
    }else{                           // 出现
        [UIView animateWithDuration:0.28 animations:^{
            self.downlistPopBackground.frame = CGRectMake(0, 0, self.overlayView.width, self.overlayView.height);
        }];
        button.selected = !button.selected;
    }
}


- (void)creatDownlistView{
    // 底板
    self.downlistPopBackground = [[UIView alloc] initWithFrame:CGRectMake(0, -self.overlayView.height, self.overlayView.width, self.overlayView.height)];
    self.downlistPopBackground.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.downlistPopBackground.userInteractionEnabled = YES;
    [self.view insertSubview:self.downlistPopBackground aboveSubview:[self.view.subviews lastObject]];
    
    // 下载列表
    self.downlistPopView = [[ZJCDownloadListView alloc] initWithFrame:CGRectMake(self.downlistPopBackground.width/6.0, 0, self.downlistPopBackground.width*2/3, self.downlistPopBackground.height)];
    [self.downlistPopBackground addSubview:self.downlistPopView];
    
    // 退出按钮
    self.exitButton = [[UIButton alloc] initWithFrame:CGRectMake(self.downlistPopBackground.width-20-40, 20, 20, 20)];
    [self.exitButton setBackgroundImage:[UIImage imageNamed:@"exit"] forState:UIControlStateNormal];
    [self.downlistPopBackground addSubview:self.exitButton];
    [self.exitButton addTarget:self action:@selector(exitButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)exitButtonClicked:(UIButton *)button{
    [UIView animateWithDuration:0.28 animations:^{
        self.downlistPopBackground.frame = CGRectMake(0, -self.overlayView.height, self.overlayView.width, self.overlayView.height);
    }];
    self.downloadListButton.selected = !self.downloadListButton.selected;
}





#pragma mark - 视频总时间
- (void)loadDurationLabel{
    self.durationLabel = [[UILabel alloc] init];
    [self.overlayView addSubview:self.durationLabel];
    __weak __typeof(self) weakSelf = self; 
    [weakSelf.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.downloadListButton.mas_left).offset(-[ZJCFrameControl GetControl_X:10]);
        make.centerY.equalTo(weakSelf.footerView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:200], [ZJCFrameControl GetControl_weight:40]));
    }];
    self.durationLabel.text = @"00:00:00";
    self.durationLabel.textColor = [UIColor whiteColor];
    self.durationLabel.backgroundColor = [UIColor clearColor];
    self.durationLabel.font = [UIFont systemFontOfSize:12];
}





#pragma mark - 进度条
- (void)loadPlaybackSlider{
    // *不晓得为啥约束怎么也不管用,简单划一下好了
    CGSize sizeToFit = CGSizeZero;
    if (IPhone4s) {
        sizeToFit = CGSizeMake(180, 20);
    }else if (IPhone5s){
        sizeToFit = CGSizeMake(270, 20);
    }else if (IPhone6){
        sizeToFit = CGSizeMake(320, 20);
    }else if (IPhone6Plus){
        sizeToFit = CGSizeMake(350, 20);
    }
    self.durationSlider = [[UISlider alloc] init];
    [self.overlayView addSubview:self.durationSlider];
    __weak __typeof(self) weakSelf = self; 
    [weakSelf.durationSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.currentPlaybackTimeLabel.mas_right).offset([ZJCFrameControl GetControl_X:30]);
        make.right.equalTo(weakSelf.durationLabel.mas_left).offset(-[ZJCFrameControl GetControl_Y:30]);
        make.centerY.equalTo(weakSelf.footerView.mas_centerY);
        make.size.mas_equalTo(sizeToFit);
    }];
    
    self.durationSlider.value = 0.0f;
    self.durationSlider.minimumValue = 0.0f;
    self.durationSlider.maximumValue = 1.0f;
    [self.durationSlider setThumbImage:[UIImage imageNamed:@"dot"]
                              forState:UIControlStateNormal];
    self.durationSlider.minimumTrackTintColor = [UIColor orangeColor];
    self.durationSlider.maximumTrackTintColor = [UIColor whiteColor];
    [self.durationSlider addTarget:self action:@selector(durationSliderMoving:) forControlEvents:UIControlEventValueChanged];
    [self.durationSlider addTarget:self action:@selector(durationSliderDone:) forControlEvents:UIControlEventTouchUpInside];
    
    logdebug(@"self.durationSlider.frame: %@", NSStringFromCGRect(self.durationSlider.frame));
}


- (void)durationSliderMoving:(UISlider *)slider{
    logdebug(@"self.durationSlider.value: %ld", (long)slider.value);
    if (self.player.playbackState != MPMoviePlaybackStatePaused) {
        [self.player pause];
    }
    
    self.player.currentPlaybackTime = slider.value;
    self.currentPlaybackTimeLabel.text = [DWTools formatSecondsToString:self.player.currentPlaybackTime];
    self.historyPlaybackTime = self.player.currentPlaybackTime;
}

- (void)durationSliderDone:(UISlider *)slider{
    logdebug(@"slider touch");
    if (self.player.playbackState != MPMoviePlaybackStatePlaying) {
        [self.player play];
    }
    self.currentPlaybackTimeLabel.text = [DWTools formatSecondsToString:self.player.currentPlaybackTime];
    self.historyPlaybackTime = self.player.currentPlaybackTime;
}




















// w.t. 功能等待 暂时先搁置这个功能
// e.g. 功能说明 缺少一个通知观察者,随时根据系统音量改变音量进度条的进度
#pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>volumeSlider音量
- (void)loadVolumeView{
    CGRect frame = CGRectZero;
    frame.origin.x = 16;
    frame.origin.y = self.headerView.frame.origin.y + self.headerView.frame.size.height + 22;
    frame.size.width = 30;
    frame.size.height = 170;
    
    self.volumeView = [[UIView alloc] initWithFrame:frame];
    self.volumeView.alpha = 0.5;
    [self.overlayView addSubview:self.volumeView];
    logdebug(@"self.volumeView frame: %@", NSStringFromCGRect(self.volumeView.frame));
    
    frame = CGRectZero;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = self.volumeView.frame.size.width;
    frame.size.height = self.volumeView.frame.size.height;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = [UIImage imageNamed:@"player-volume-box"];
    [self.volumeView addSubview:imageView];
    
    
    self.volumeSlider = [[UISlider alloc] init];
    self.volumeSlider.transform = CGAffineTransformMakeRotation(-M_PI/2);
    
    frame = CGRectZero;
    frame.origin.x = self.volumeView.frame.origin.x;
    frame.origin.y = self.volumeView.frame.origin.y + 10;
    frame.size.width = 30;
    frame.size.height = 140;
    self.volumeSlider.frame = frame;
    
    self.volumeSlider.minimumValue = 0;
    self.volumeSlider.maximumValue = 1.0;
    self.volumeSlider.value = [MPMusicPlayerController applicationMusicPlayer].volume;
    [self.volumeSlider setThumbImage:[UIImage imageNamed:@"dot"]
                              forState:UIControlStateNormal];
    self.volumeSlider.minimumTrackTintColor = [UIColor orangeColor];
    self.volumeSlider.maximumTrackTintColor = [UIColor whiteColor];
    
    [self.volumeSlider addTarget:self action:@selector(volumeSliderMoved:) forControlEvents:UIControlEventValueChanged];
    [self.volumeSlider addTarget:self action:@selector(volumeSliderTouchDone:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView addSubview:self.volumeSlider];
    
    logdebug(@"self.volumeSlider frame: %@", NSStringFromCGRect(self.volumeSlider.frame));
}

- (void)volumeSliderMoved:(UISlider *)slider{
    [MPMusicPlayerController applicationMusicPlayer].volume = slider.value;
}

- (void)volumeSliderTouchDone:(UISlider *)slider{
    
}


















# pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>videoStatusLabel视频播放状态显示框
- (void)loadVideoStatusLabel{
    CGRect frame = CGRectZero;
    frame.size.height = 40;
    frame.size.width = 100;
    frame.origin.x = self.overlayView.frame.size.width/2 - frame.size.width/2;
    frame.origin.y = self.overlayView.frame.size.height/2 - frame.size.height/2;
    
    self.videoStatusLabel = [[UILabel alloc] initWithFrame:frame];
    self.videoStatusLabel.text = @"正在加载...";
    self.videoStatusLabel.textColor = [UIColor orangeColor];
    self.videoStatusLabel.backgroundColor = [UIColor clearColor];
    self.videoStatusLabel.font = [UIFont systemFontOfSize:16];
    [self.overlayView addSubview:self.videoStatusLabel];
}




















#pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>UIGestureRecognizerDelegate手势识别
-(void)handleSignelTap:(UIGestureRecognizer*)gestureRecognizer{
    if (self.hiddenAll) {
        [self showBasicViews];
        self.hiddenDelaySeconds = 5;
        
    } else {
        [self hiddenAllView];
        self.hiddenDelaySeconds = 0;
    }
}


// 响应事件拦截
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (gestureRecognizer == self.signelTap) {
        if ([touch.view isKindOfClass:[UIButton class]]) {
            return NO;
        }
        if ([touch.view isKindOfClass:[DWTableView class]]) {
            return NO;
        }
        if ([touch.view isKindOfClass:[UISlider class]]) {
            return NO;
        }
        if ([touch.view isKindOfClass:[UIImageView class]]) {
            return NO;
        }
        if ([touch.view isKindOfClass:[UITableView class]]) {
            return NO;
        }
        if ([touch.view isKindOfClass:[UITableViewCell class]]) {
            return NO;
        }
        // UITableViewCellContentView => UITableViewCell
        if([touch.view.superview isKindOfClass:[UITableViewCell class]]) {
            return NO;
        }
        // UITableViewCellContentView => UITableViewCellScrollView => UITableViewCell
        if([touch.view.superview.superview isKindOfClass:[UITableViewCell class]]) {
            return NO;
        }
    }
    return YES;
}


// 隐藏各类选项卡  (基础demo的功能)
- (void)hiddenTableViewsExcept:(UIView *)view{
    if (view != self.qualityView) {
        self.qualityView.hidden = YES;
    }
}

- (void)hiddenTableViews{
    self.qualityView.hidden = YES;
}


// 全局手势  隐藏
- (void)hiddenAllView{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self hiddenTableViews];
    
    self.backButton.hidden = YES;
    self.qualityButton.hidden = YES;
    self.courseButton.hidden = YES;
    
    self.playbackButton.hidden = YES;
    self.currentPlaybackTimeLabel.hidden = YES;
    self.durationLabel.hidden = YES;
    self.durationSlider.hidden = YES;
    self.downloadListButton.hidden = YES;
    
    self.volumeSlider.hidden = YES;
    self.volumeView.hidden = YES;
    
    self.headerView.hidden = YES;
    self.footerView.hidden = YES;
    
    self.hiddenAll = YES;
    
}


// 全局手势  展示
- (void)showBasicViews{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    self.backButton.hidden = NO;
    self.courseButton.hidden = NO;
    
    self.playbackButton.hidden = NO;
    self.currentPlaybackTimeLabel.hidden = NO;
    self.durationLabel.hidden = NO;
    self.durationSlider.hidden = NO;
    self.downloadListButton.hidden = NO;
    self.qualityButton.hidden = NO;
    
    self.volumeSlider.hidden = NO;
    self.volumeView.hidden = NO;
    
    self.headerView.hidden = NO;
    self.footerView.hidden = NO;
    self.hiddenAll = NO;
}




















#pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>根据播放链接更新涉及的视图
- (void)resetViewContent{
    // 获取默认清晰度播放url
    NSNumber *defaultquality = [self.playUrls objectForKey:@"defaultquality"];
    for (NSDictionary *playurl in [self.playUrls objectForKey:@"qualities"]) {
        if (defaultquality == [playurl objectForKey:@"quality"]) {
            self.currentPlayUrl = playurl;
            break;
        }
    }
    
    // 当前播放清晰度
    if (!self.currentPlayUrl) {
        self.currentPlayUrl = [[self.playUrls objectForKey:@"qualities"] objectAtIndex:0];
    }
    loginfo(@"currentPlayUrl: %@", self.currentPlayUrl);
    
    // 播放id
    if (self.videoId) {
        [self resetQualityView];
    }
    [self.player prepareToPlay];
    [self.player play];
    logdebug(@"play url: %@", self.player.originalContentURL);
}


- (void)resetQualityView{
    self.qualityDescription = [self.playUrls objectForKey:@"qualityDescription"];
    
    // 设置当前清晰度
    NSNumber *defaultquality = [self.playUrls objectForKey:@"defaultquality"];
    for (NSDictionary *playurl in [self.playUrls objectForKey:@"qualities"]) {
        if (defaultquality == [playurl objectForKey:@"quality"]) {
            self.currentQuality = [playurl objectForKey:@"desp"];
            break;
        }
    }
    
    // 由于每个视频的清晰度种类不同，所以这里需要重新加载
    [self reloadQualityView];
}


/**
 重置播放器
 */ 
- (void)resetPlayer{
    self.player.contentURL = [NSURL URLWithString:[self.currentPlayUrl objectForKey:@"playurl"]];
    
    self.videoStatusLabel.hidden = NO;
    self.videoStatusLabel.text = @"正在加载...";
    
    [self.player prepareToPlay];
    [self.player play];
    logdebug(@"play url: %@", self.player.originalContentURL);
}












#pragma mark - 播放本地文件
- (void)playLocalVideo{
    self.playUrls = [NSDictionary dictionaryWithObject:self.videoLocalPath forKey:@"playurl"];
    self.player.contentURL = [[NSURL alloc] initFileURLWithPath:self.videoLocalPath];
    
    [self.player prepareToPlay];
    [self.player play];
    logdebug(@"play url: %@", self.player.originalContentURL);
}


















#pragma mark - MPMoviePlayController Notifications播放器的各种通知事件
- (void)addObserverForMPMoviePlayController{
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    // MPMovieDurationAvailableNotification
    [notificationCenter addObserver:self selector:@selector(moviePlayerDurationAvailable) name:MPMovieDurationAvailableNotification object:self.player];
    
    // MPMovieNaturalSizeAvailableNotification
    
    // MPMoviePlayerLoadStateDidChangeNotification
    [notificationCenter addObserver:self selector:@selector(moviePlayerLoadStateDidChange) name:MPMoviePlayerLoadStateDidChangeNotification object:self.player];
    
    // MPMoviePlayerPlaybackDidFinishNotification
    [notificationCenter addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];
    
    // MPMoviePlayerPlaybackStateDidChangeNotification
    [notificationCenter addObserver:self selector:@selector(moviePlayerPlaybackStateDidChange) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.player];
    
    // MPMoviePlayerReadyForDisplayDidChangeNotification
    
}





- (void)moviePlayerDurationAvailable{
    self.durationLabel.text = [DWTools formatSecondsToString:self.player.duration];
    self.currentPlaybackTimeLabel.text = [DWTools formatSecondsToString:0];
	self.durationSlider.minimumValue = 0.0;
    self.durationSlider.maximumValue = self.player.duration;
    logdebug(@"seconds %f maximumValue %f %@", self.player.duration, self.durationSlider.maximumValue, self.durationLabel.text);
}



- (void)moviePlayerLoadStateDidChange{
    switch (self.player.loadState) {
        case MPMovieLoadStatePlayable:
            // 可播放
            logdebug(@"%@ playable", self.player.originalContentURL);
            self.videoStatusLabel.hidden = YES;
            break;
            
        case MPMovieLoadStatePlaythroughOK:
            // 状态为缓冲几乎完成，可以连续播放
            logdebug(@"%@ PlaythroughOK", self.player.originalContentURL);
            self.videoStatusLabel.hidden = YES;
            break;
            
        case MPMovieLoadStateStalled:
            // 缓冲中
            logdebug(@"%@ Stalled", self.player.originalContentURL);
            self.videoStatusLabel.hidden = NO;
            self.videoStatusLabel.text = @"正在加载...";
            break;
            
        default:
            break;
    }
}

- (void)moviePlayerPlaybackDidFinish:(NSNotification *)notification{
    logdebug(@"accessLog %@", self.player.accessLog);
    logdebug(@"errorLog %@", self.player.errorLog);
    NSNumber *n = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    switch ([n intValue]) {
        case MPMovieFinishReasonPlaybackEnded:
            logdebug(@"PlaybackEnded");
            self.videoStatusLabel.hidden = YES;
            break;
            
        case MPMovieFinishReasonPlaybackError:
            logdebug(@"PlaybackError");
            self.videoStatusLabel.hidden = NO;
            self.videoStatusLabel.text = @"加载失败";
            break;
            
        case MPMovieFinishReasonUserExited:
            logdebug(@"ReasonUserExited");
            break;
            
        default:
            break;
    }
}

- (void)moviePlayerPlaybackStateDidChange{
    logdebug(@"%@ playbackState: %ld", self.player.originalContentURL, (long)self.player.playbackState);
    
    switch ([self.player playbackState]) {
        case MPMoviePlaybackStateStopped:
            logdebug(@"movie stopped");
            [self.playbackButton setSelected:NO];
            break;
            
        case MPMoviePlaybackStatePlaying:
            [self.playbackButton setSelected:YES];
            logdebug(@"movie playing");
            self.videoStatusLabel.hidden = YES;
            break;
            
        case MPMoviePlaybackStatePaused:
            [self.playbackButton setSelected:NO];
            logdebug(@"movie paused");
            self.videoStatusLabel.hidden = NO;
            self.videoStatusLabel.text = @"暂停";
            break;
            
        case MPMoviePlaybackStateInterrupted:
            [self.playbackButton setSelected:NO];
            logdebug(@"movie interrupted");
            self.videoStatusLabel.hidden = NO;
            self.videoStatusLabel.text = @"加载中。。。";
            break;
            
        case MPMoviePlaybackStateSeekingForward:
            logdebug(@"movie seekingForward");
            self.videoStatusLabel.hidden = YES;
            break;
            
        case MPMoviePlaybackStateSeekingBackward:
            logdebug(@"movie seekingBackward");
            self.videoStatusLabel.hidden = YES;
            break;
            
        default:
            break;
    }
}

#pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>timer定时器相关
- (void)addTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerHandler) userInfo:nil repeats:YES];
}


- (void)removeTimer{
    [self.timer invalidate];
}

- (void)timerHandler{
    self.currentPlaybackTimeLabel.text = [DWTools formatSecondsToString:self.player.currentPlaybackTime];
    self.durationLabel.text = [DWTools formatSecondsToString:self.player.duration];
    self.durationSlider.value = self.player.currentPlaybackTime;
    self.historyPlaybackTime = self.player.currentPlaybackTime;
    self.userWantTimePlayBackTime = self.player.currentPlaybackTime;
    
    if (!self.hiddenAll) {
        if (self.hiddenDelaySeconds > 0) {
            if (self.hiddenDelaySeconds == 1) {
                [self hiddenAllView];
            }
            self.hiddenDelaySeconds--;
        }
    }
}








#pragma mark - 干掉监听事件
- (void)removeAllObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}






@end






