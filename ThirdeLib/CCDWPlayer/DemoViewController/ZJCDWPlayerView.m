//
//  ZJCDWPlayerView.m
//  HR
//
//  Created by htkg on 16/3/16.
//  Copyright © 2016年 htkg. All rights reserved.
//  
//  //////////////
//  // 层次结构图 //
//  //////////////
//
//
//                                                       ----------------  "当前时间"
//                                                       ----------------  "总时间"
//                                                       ----------------  "进度条"
//                                                       ----------------  "开始播放按钮"
//  __________  顶部控件条    _____ 声音  ______ 状态(正中)  ________________  底部控件条                      ( 屏幕 下 )
//
//  _____________________________________________________________________  (播放器视图
//  ---------------------------------------------------------------------  播放器底板)
//
//  ---------------------------------------------------------------------  所有空间的底板(覆盖在播放器上)
//
//

#import "ZJCDWPlayerView.h"

#define Self_Frame self.frame
#define Self_Bounds self.bounds



@interface ZJCDWPlayerView () <UIGestureRecognizerDelegate>

@end





@implementation ZJCDWPlayerView
#pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>初始化方法
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        _qualityDescription = @[@"普通", @"清晰", @"高清"];
        _currentQuality = [_qualityDescription objectAtIndex:0];
        
        // 1.初始化播放器
        _player = [[DWMoviePlayerController alloc] initWithUserId:DWACCOUNT_USERID key:DWACCOUNT_APIKEY];
        
        
        // 2.配置加密功能  (这里需要说明一下,只有使用自己的视频才行,因为付钱了具有加密功能)
        _player.drmServerPort = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).drmServer.listenPort;
        
        // 3.各种通知
        [self addObserverForMPMoviePlayView];
        
        // 4.初始化 10 秒后隐藏所有窗口
        _hiddenDelaySeconds = DWControls_Hidden_Time;
        _hiddenAll = NO;
        
        // 5.时间控制器
        [self addTimer];
        [self addPlayerTimer];
        
        // 6.加载播放器
        [self loadPlayer];
        
        // 7.界面初始化  (集成到方法里面)
        [self initSelfSubViewsAndConfiguration];
    }
    return self;
}






#pragma mark - 播放视频的VideoID   (因为视图没有出现和消失对应的代理方法,所以这里需要做的是利用给  必要条件  videoID  赋值的过程来开启播放器的播放)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 给播放链接,开始播放
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setVideoId:(NSString *)videoId{
    _videoId = videoId;
    // 1.初始播放视频id
    [self initVideoID];
}


- (void)setVideoLocalPath:(NSString *)videoLocalPath{
    _videoLocalPath = videoLocalPath;
    // 初始化播放视频id
    [self initLocalPath];
}








#pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>加载视图
- (void)initSelfSubViewsAndConfiguration{
    // 2.播放器的覆盖视图 (作为所有控件的父视图)
    [self loadOverlayview];
    
    // 3.顶部控件条
    [self loadHeaderView];
    
    // 4.底部控件条
    [self loadFooterView];
    
    // 5.音量控制条
    //    [self loadVolumeView];
    
    // 6.播放状态显示条 (屏幕正中间那个显示框)
    [self loadVideoStatusLabel];
    
    // 7.边界外的课节列表和下载列表
    //    [self loadTwoListViews];
}











#pragma mark - 加载播放器
- (void)loadPlayer{
    // 1.播放器底板
    _videoBackgroundView = [[UIView alloc] initWithFrame:Self_Frame];
    _videoBackgroundView.backgroundColor = [UIColor blackColor];
    [self addSubview:_videoBackgroundView];
    
    // 2.播放器初始化配置  (因为该播放器继承自系统的播放器,所以其含有系统播放器含有的功能)
    _player.scalingMode = MPMovieScalingModeAspectFill;   // 填充模式
    _player.controlStyle = MPMovieControlStyleNone;       // 控制模式(自定制  None)
    _player.view.backgroundColor = [UIColor clearColor];  // 背景
    _player.view.frame = _videoBackgroundView.frame;      // 背景大小
    [_videoBackgroundView addSubview:_player.view];     
}











#pragma mark - 覆盖用底板  (各种控制按钮的容器)
- (void)loadOverlayview{
    // 覆盖底板
    _overlayView = [[UIView alloc] initWithFrame:Self_Bounds];
    _overlayView.backgroundColor = [UIColor clearColor];
    _overlayView.clipsToBounds = NO;
    [self addSubview:_overlayView];
    
    // 全屏手势
    _signelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSignelTap:)];
    _signelTap.numberOfTapsRequired = 1;
    _signelTap.delegate = self;
    [_overlayView addGestureRecognizer:_signelTap];
}


// 全局手势响应
- (void)handleSignelTap:(UITapGestureRecognizer *)tap{
    if (_hiddenAll == YES) {
        [self showBasicViews];
        _hiddenDelaySeconds = 5;
        
    }else if(_hiddenAll == NO) {
        [self hiddenAllView];
        _hiddenDelaySeconds = 0;
    }
}


// 展示所有的视图
- (void)showBasicViews{    
    _playbackButton.hidden = NO;
    _currentPlaybackTimeLabel.hidden = NO;
    _durationLabel.hidden = NO;
    _durationSlider.hidden = NO;
    if (_isFullScreen == YES) {
        _fullScreenButton.hidden = YES;
        _headerView.hidden = NO;
    }else{
        _fullScreenButton.hidden = NO;
        _headerView.hidden = YES;
    }
    
    _volumeSlider.hidden = NO;
    _volumeView.hidden = NO;
    
    _footerView.hidden = NO;
    // 改变控制flog状态
    _hiddenAll = NO;
}

// 隐藏所有的视图
- (void)hiddenAllView{    
    _playbackButton.hidden = YES;
    _currentPlaybackTimeLabel.hidden = YES;
    _durationLabel.hidden = YES;
    _durationSlider.hidden = YES;
    _qualityView.hidden = YES;
    if (_isFullScreen == YES) {
        _fullScreenButton.hidden = YES;
        _headerView.hidden = YES;
    }else{
        _fullScreenButton.hidden = YES;
        _headerView.hidden = YES;
    }
    
    _volumeSlider.hidden = YES;
    _volumeView.hidden = YES;
    
    _footerView.hidden = YES;
    // 改变控制flog状态
    _hiddenAll = YES;
}














#pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>headerView顶部工具条
- (void)loadHeaderView{
    // 1.顶部控制条
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _overlayView.frame.size.width, CCDWPlayer_HeaderHeight)];
    [_overlayView addSubview:_headerView];
    //    __weak __typeof(self) weakSelf = self;
    //    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(weakSelf.overlayView).offset(0);
    //        make.left.equalTo(weakSelf.overlayView).offset(0);
    //        make.right.equalTo(weakSelf.overlayView).offset(0);
    //        make.size.mas_equalTo(CGSizeMake(weakSelf.overlayView.width, CCDWPlayer_HeaderHeight));
    //    }];
    _headerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    
    // 1.标题
    [self creatTitleLabel];
    
    // 2.课节按钮
    [self creatCourseTable];
    
    // 3.返回按钮
    [self loadBackButton];
}



#pragma mark - 播放视频标题
- (void)creatTitleLabel{
    _titleLabel = [[UILabel alloc] init];
    [_headerView addSubview:_titleLabel];
    __weak __typeof(self) weakSelf = self;
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        //        make.centerX.equalTo(weakSelf.headerView.mas_centerX);
        //        make.centerY.equalTo(weakSelf.headerView.mas_centerY);
        make.top.and.bottom.and.left.and.right.equalTo(weakSelf.headerView);
        //        make.size.mas_equalTo(CGSizeMake(weakSelf.headerView.width,weakSelf.headerView.height));
    }];
    _titleLabel.text = _titleLabelString;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
}





#pragma mark - 课节列表按钮
- (void)creatCourseTable{
    // 课节列表按钮
    _courseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_headerView addSubview:_courseButton];
    _courseButton.selected = NO;
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
    _courseButton.backgroundColor = [UIColor clearColor];
    [_courseButton addTarget:self action:@selector(courseButtonClicked:)
            forControlEvents:UIControlEventTouchUpInside];
    logdebug(@"self.backButton.frame: %@", NSStringFromCGRect(_courseButton.frame));
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








#pragma mark - 返回按钮  (大屏返回按钮 用作 小屏的全屏按钮作用)
- (void)loadBackButton{
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_headerView addSubview:_backButton];
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

// 做成全屏返回按钮
- (void)backButtonAction:(UIButton *)button{
    // 这里需要做成全屏返回用的按钮
    if (_isFullScreen == YES) {       // 全屏状态
        _fullScreenButton.selected = !_fullScreenButton.selected;
        self.fullScreecButtonClickedBlock(button,_player.currentPlaybackTime);
    }else{                            // 小屏状态
        
    }
}


#pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>底部控件条相关
- (void)loadFooterView {
    // 1.底部控件条视图
    _footerView = [[UIView alloc] init];
    [_overlayView addSubview:_footerView];
    __weak __typeof(self) weakSelf = self; 
    [_footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.overlayView).offset(0);
        make.bottom.equalTo(weakSelf.overlayView).offset(0);
        make.right.equalTo(weakSelf.overlayView).offset(0);
        make.size.mas_equalTo(CGSizeMake(weakSelf.overlayView.width, weakSelf.overlayView.width/10.0));
    }];
    _footerView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2];
    
    /**
     *  NOTE: 由于各个view之间的坐标有依赖关系，所以以下view的加载顺序必须为：
     *  
     */
    // 2.播放按钮
    [self loadPlaybackButton];
    
    // 3.当前播放时间
    [self loadCurrentPlaybackTiemLabel];
    
    // 3.清晰度按钮
    //    [self loadQualityView];
    
    // 6.全屏按钮
    [self loadFullScreenButton];
    
    // 7.下载列表
    //    [self loadDownloadListButton];
    
    // 5.视频总时间
    [self loadDurationLabel];
    
    // 4.时间滑动条
    [self loadPlaybackSlider];
}


#pragma mark - 播放按钮
- (void)loadPlaybackButton{
    _playbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_footerView addSubview:_playbackButton];
    //    _playbackButton.frame = CGRectMake(_footerView.frame.origin.x + 22, _footerView.frame.origin.y+4, CCDWPlayer_FooterHeight-10, CCDWPlayer_FooterHeight-10);
    __weak __typeof(self) weakSelf = self;
    [_playbackButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.footerView).offset([ZJCFrameControl GetControl_X:44]);
        make.centerY.equalTo(weakSelf.footerView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(CCDWPlayer_FooterHeight, CCDWPlayer_FooterHeight));
    }];
    UIImage * image1 = [UIImage imageNamed:@"playSm"];
    UIImage * image2 = [UIImage imageNamed:@"pauseSm"];
    [_playbackButton setImage:image1 forState:UIControlStateNormal];
    [_playbackButton setImage:image2 forState:UIControlStateSelected];
    [_playbackButton addTarget:self action:@selector(playbackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)playbackButtonClicked:(UIButton *)button{
    _hiddenDelaySeconds = 5;
    if (!_playUrls || _playUrls.count == 0) {
        [self loadPlayUrls];
        return;
    }
    // 播放控制
    if (_player.playbackState == MPMoviePlaybackStatePlaying) {
        // 暂停播放
        _playbackButton.selected = YES;
        [_player pause];
    } else {
        // 继续播放
        _playbackButton.selected = NO;
        [_player play];
    }
}


#pragma mark - 当前播放时间
- (void)loadCurrentPlaybackTiemLabel{
    //    WithFrame:CGRectMake(CGRectGetMaxX(_playbackButton.frame) + 5, CGRectGetMinY(_playbackButton.frame), 60, 25)
    _currentPlaybackTimeLabel = [[UILabel alloc] init];
    [_footerView addSubview:_currentPlaybackTimeLabel];
    __weak __typeof(self) weakSelf = self; 
    [_currentPlaybackTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.playbackButton.mas_right).offset([ZJCFrameControl GetControl_X:15]);
        make.top.equalTo(weakSelf.footerView).offset([ZJCFrameControl GetControl_X:10]);
        make.bottom.equalTo(weakSelf.footerView).offset(-[ZJCFrameControl GetControl_X:10]);
        make.size.mas_equalTo(CGSizeMake(60, CGRectGetHeight(weakSelf.playbackButton.frame)));
    }];
    _currentPlaybackTimeLabel.text = @"00:00:00";
    _currentPlaybackTimeLabel.textColor = [UIColor orangeColor];
    _currentPlaybackTimeLabel.font = [UIFont systemFontOfSize:12];
    _currentPlaybackTimeLabel.backgroundColor = [UIColor clearColor];
    
}



#pragma mark - 时间滑动条
- (void)loadPlaybackSlider{
    //    WithFrame:CGRectMake(CGRectGetMaxX(_currentPlaybackTimeLabel.frame) + 5, CGRectGetMinY(_currentPlaybackTimeLabel.frame), 200, 30)
    _durationSlider = [[UISlider alloc] init];
    [_footerView addSubview:_durationSlider];
    __weak __typeof(self) weakSelf = self; 
    [_durationSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.currentPlaybackTimeLabel.mas_right).offset([ZJCFrameControl GetControl_X:5]);
        make.top.equalTo(weakSelf.footerView).offset([ZJCFrameControl GetControl_X:20]);
        make.bottom.equalTo(weakSelf.footerView).offset(-[ZJCFrameControl GetControl_X:20]);
        make.right.equalTo(weakSelf.durationLabel.mas_left).offset(-[ZJCFrameControl GetControl_X:10]);
    }];
    _durationSlider.value = 0.0f;
    _durationSlider.minimumValue = 0.0f;
    _durationSlider.maximumValue = 1.0f;
    [_durationSlider setThumbImage:[UIImage imageNamed:@"dot"]
                          forState:UIControlStateNormal];
    _durationSlider.minimumTrackTintColor = [UIColor orangeColor];
    _durationSlider.maximumTrackTintColor = [UIColor whiteColor];
    
    [_durationSlider addTarget:self action:@selector(durationSliderMoving:) forControlEvents:UIControlEventValueChanged];
    [_durationSlider addTarget:self action:@selector(durationSliderDone:) forControlEvents:UIControlEventTouchUpInside];
}


// 拖动滚动条    滚动的时候需要的操作
- (void)durationSliderMoving:(UISlider *)slider{
    logdebug(@"self.durationSlider.value: %ld", (long)slider.value);
    if (_player.playbackState != MPMoviePlaybackStatePaused) {
        [_player pause];
    }
    // 获取当前播放时间  >>> 更新相关的UI
    _player.currentPlaybackTime = slider.value;
    _currentPlaybackTimeLabel.text = [DWTools formatSecondsToString:_player.currentPlaybackTime];
    _historyPlaybackTime = _player.currentPlaybackTime;
    
}


// 拖动滚动条    松手的时候需要的操作
- (void)durationSliderDone:(UISlider *)slider{
    logdebug(@"slider touch");
    if (_player.playbackState != MPMoviePlaybackStatePlaying) {
        [_player play];
    }
    // 获取当前时间 >>> 更新相关的UI
    _currentPlaybackTimeLabel.text = [DWTools formatSecondsToString:_player.currentPlaybackTime];
    _historyPlaybackTime = _player.currentPlaybackTime;
    
}


#pragma mark - 视频总时间
- (void)loadDurationLabel{
    _durationLabel = [[UILabel alloc] init];
    [_footerView addSubview:_durationLabel];
    __weak __typeof(self) weakSelf = self; 
    [_durationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.fullScreenButton);
        make.right.equalTo(weakSelf.fullScreenButton.mas_left).offset(-[ZJCFrameControl GetControl_X:5]);
        make.bottom.equalTo(weakSelf.fullScreenButton);
        make.size.mas_equalTo(CGSizeMake(60, CGRectGetHeight(weakSelf.playbackButton.frame)));
    }];
    _durationLabel.text = @"00:00:00";
    _durationLabel.textColor = [UIColor whiteColor];
    _durationLabel.backgroundColor = [UIColor clearColor];
    _durationLabel.font = [UIFont systemFontOfSize:12];
}





#pragma mark - 全屏按钮
- (void)loadFullScreenButton{
    _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_footerView addSubview:_fullScreenButton];
    _fullScreenButton.selected = NO;
    __weak __typeof(self) weakSelf = self; 
    [_fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.footerView.mas_top);
        make.right.equalTo(weakSelf.footerView.mas_right).offset(-[ZJCFrameControl GetControl_X:5]);
        make.bottom.equalTo(weakSelf.footerView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(CCDWPlayer_FooterHeight, CCDWPlayer_FooterHeight));
    }];
    [_fullScreenButton setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
    [_fullScreenButton setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateSelected];
    [_fullScreenButton setBackgroundColor:[UIColor clearColor]];
    [_fullScreenButton addTarget:self action:@selector(fullScreenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
}


// 全屏按钮点击事件
- (void)fullScreenButtonClicked:(UIButton *)button{
    button.selected = !button.selected;
    self.fullScreecButtonClickedBlock(button,_player.currentPlaybackTime);
}







#pragma mark - 下载列表按钮
/*
 全屏播放的底部下载按钮
 
 */
- (void)loadDownloadListButton{
    _downloadListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_footerView addSubview:_downloadListButton];
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
        //原来
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_X:45], [ZJCFrameControl GetControl_X:45]));
//        //隐藏下载按钮
//        make.size.mas_equalTo(CGSizeMake(0,0));

    }];
    imageView.image = [UIImage imageNamed:@"downList"];
    self.downloadListButton.selected = NO;
    self.downloadListButton.backgroundColor = [UIColor clearColor];
    [self.downloadListButton addTarget:self action:@selector(downLoadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    logdebug(@"self.backButton.frame: %@", NSStringFromCGRect(self.downloadListButton.frame));
    
    
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








#pragma mark - 清晰度按钮
- (void)loadQualityView{
    // 1.清晰度按钮
    self.qualityButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.footerView addSubview:self.qualityButton];
    __weak __typeof(self) weakSelf = self; 
    [weakSelf.qualityButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.footerView.mas_right).offset(-[ZJCFrameControl GetControl_X:30]);
        make.centerY.equalTo(weakSelf.footerView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(CCDWPlayer_FooterHeight, CCDWPlayer_FooterHeight));
    }];
    self.qualityButton.backgroundColor = [UIColor clearColor];
    [self.qualityButton setTitle:self.currentQuality forState:UIControlStateNormal];
    [self.qualityButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.qualityButton addTarget:self action:@selector(qualityButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 2.列表底板
    NSInteger triangleHeight = 8;
    CGRect frame = CGRectZero;
    frame.size.width = 60;
    frame.size.height = self.qualityDescription.count*30 + triangleHeight;
    frame.origin.x = self.overlayView.frame.size.width - frame.size.width/2 - [ZJCFrameControl GetControl_X:30] - CCDWPlayer_FooterHeight/2;
    frame.origin.y = self.overlayView.frame.size.height - weakSelf.overlayView.height*132/1080.0 + triangleHeight - frame.size.height;
    self.qualityView = [[DWPlayerMenuView alloc] initWithFrame:frame andTriangelHeight:triangleHeight upsideDown:YES FillColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    self.qualityView.hidden = YES;
    self.qualityView.backgroundColor = [UIColor clearColor];
    [self.overlayView addSubview:self.qualityView];
    
    // 3.清晰度选项卡列表
    //  包含各种block回调事件
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
    
    // 默认选中的cell是第一个的cell
    self.currentQualityStatus = 0; 
    
    __weak typeof(self)blockSelf = self;
    //>>>>>>>>>>>>>>>>>
    // 行数
    self.qualityTable.tableViewNumberOfRowsInSection = ^NSInteger(UITableView *tableView, NSInteger section) {
        return blockSelf.qualityDescription.count;
    };
    
    
    //>>>>>>>>>>>>>>>>>
    // cell模型
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
    
    
    
    //>>>>>>>>>>>>>>>>>
    // cell点击事件
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
        
        if (self.qualityDescription.count == 2) {
            if (indexPath.row == 0) {
                logdebug(@"清晰度切换为清晰");
                [blockSelf switchQuality:0];
                
            } else if (indexPath.row == 1) {
                logdebug(@"清晰度切换为高清");
                [blockSelf switchQuality:1];
            }
        }else if(self.qualityDescription.count == 3){
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
    NSInteger currentQualityIndex =  [[self.playUrls objectForKey:@"qualities"] indexOfObject:self.currentPlayUrl];
    logdebug(@"index: %ld %ld", (long)index, (long)currentQualityIndex);
    if (index == currentQualityIndex) {
        // 不需要切换
        logdebug(@"current quality: %ld %@", (long)currentQualityIndex, self.currentPlayUrl);
        return;
    }
    loginfo(@"switch %@ -> %@", self.currentPlayUrl, [[self.playUrls objectForKey:@"qualities"] objectAtIndex:index]);
    
    _historyPlaybackTime = _player.currentPlaybackTime;
    [self.player stop];
    
    
    self.currentPlayUrl = [[self.playUrls objectForKey:@"qualities"] objectAtIndex:index];
    self.currentQuality = [self.currentPlayUrl objectForKey:@"desp"];
    [self.qualityButton setTitle:self.currentQuality forState:UIControlStateNormal];
    

    
    [self resetPlayer];
}


// 隐藏各类选项卡  (基础demo的功能)
- (void)hiddenTableViewsExcept:(UIView *)view{
    if (view != self.qualityView) {
        self.qualityView.hidden = YES;
    }
}


/**
 重置播放器--切换清晰度
 */ 
- (void)resetPlayer{
    
    [self.player cancelRequestPlayInfo];
//    self.player.initialPlaybackTime = self.historyPlaybackTime;
    
    self.player.contentURL = [NSURL URLWithString:[self.currentPlayUrl objectForKey:@"playurl"]];
    
    self.videoStatusLabel.hidden = NO;
    self.videoStatusLabel.text = @"正在加载...";

    
    [self.player prepareToPlay];
    self.player.currentPlaybackTime = self.historyPlaybackTime;

//    [NSThread sleepForTimeInterval:4];
    [self.player play];

    logdebug(@"play url: %@", self.player.originalContentURL);
}








#pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>下载列表 课节列表
- (void)loadTwoListViews{
    /**
     *  @brief 章节列表相关
     */
    // 底板(截取事件)
    _courseListPopBackground = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _overlayView.width, _overlayView.height)];
    _courseListPopBackground.backgroundColor = [UIColor clearColor];
    _courseListPopBackground.hidden = YES;
    [_overlayView addSubview:_courseListPopBackground];
    [_courseListPopBackground addTarget:self action:@selector(tapbackGround:) forControlEvents:UIControlEventTouchUpInside];
    
    // 弹出课节列表
    _courseListPopView = [[ZJCCourseListView alloc] initWithFrame:CGRectMake(_overlayView.width, 0, _overlayView.width*750/1920.0, _overlayView.height)];
    _courseListPopView.userInteractionEnabled = YES;
    [_overlayView addSubview:_courseListPopView];
    // 课节列表的点击回调,更新播放状态
    __weak typeof(self) weakSelf = self;
    _courseListPopView.cellDidSelected = ^(id sender,NSString * videoId,NSString * title,NSString * lessonid,BOOL isSection,NSInteger selectSeciton,NSInteger selectRow){
        // 防止出乱子,这里就什么也不做了,直接交给controller去做...
        if (weakSelf.passCarBlock) {
            weakSelf.passCarBlock(sender,videoId,title,lessonid, isSection, selectSeciton, selectRow);
        }
    };
    
    
    
    
    
    /**
     *  @brief 下载列表相关
     */
    // 底板
    self.downlistPopBackground = [[UIView alloc] initWithFrame:CGRectMake(0, -self.overlayView.height, self.overlayView.width, self.overlayView.height)];
    self.downlistPopBackground.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.downlistPopBackground.userInteractionEnabled = YES;
    [self insertSubview:self.downlistPopBackground aboveSubview:[self.subviews lastObject]];
    
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
















#pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>volumeSlider音量
- (void)loadVolumeÁView {
    // 1.音量底板
    _volumeView = [[UIView alloc] init];
    _volumeView.alpha = 0.5;
    _volumeView.backgroundColor = [UIColor orangeColor];
    [_overlayView addSubview:_volumeView];
    __weak __typeof(self) weakSelf = self; 
    [_volumeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.headerView.mas_bottom).offset([ZJCFrameControl GetControl_X:10]);
        make.bottom.equalTo(weakSelf.footerView.mas_top).offset(-[ZJCFrameControl GetControl_Y:10]);
        make.right.equalTo(weakSelf.overlayView).offset(-[ZJCFrameControl GetControl_X:60]);
        make.width.mas_equalTo([ZJCFrameControl GetControl_X:60]);
    }];
    
    // 2.音量背景图片
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:_volumeView.bounds];
    imageView.image = [UIImage imageNamed:@"player-volume-box"];
    [_volumeView addSubview:imageView];
    
    
    // 2.音量滚动条
    _volumeSlider = [[UISlider alloc] init];
    [_volumeView addSubview:_volumeSlider];
    [_volumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.headerView.mas_bottom).offset([ZJCFrameControl GetControl_X:10]);
        make.bottom.equalTo(weakSelf.footerView.mas_top).offset(-[ZJCFrameControl GetControl_Y:10]);
        make.right.equalTo(weakSelf.overlayView).offset(-[ZJCFrameControl GetControl_X:60]);
        make.width.mas_equalTo([ZJCFrameControl GetControl_X:60]);
    }];
    _volumeSlider.transform = CGAffineTransformMakeRotation(-M_PI/2);
    _volumeSlider.minimumValue = 0;
    _volumeSlider.maximumValue = 1.0;
    _volumeSlider.value = [MPMusicPlayerController applicationMusicPlayer].volume;
    [_volumeSlider setThumbImage:[UIImage imageNamed:@"dot"]
                        forState:UIControlStateNormal];
    _volumeSlider.minimumTrackTintColor = [UIColor orangeColor];
    _volumeSlider.maximumTrackTintColor = [UIColor whiteColor];
    [_volumeSlider addTarget:self action:@selector(volumeSliderMoved:) forControlEvents:UIControlEventValueChanged];
    [_volumeSlider addTarget:self action:@selector(volumeSliderTouchDone:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)volumeSliderMoved:(UISlider *)slider{
    // 改变播放器的音量状态
    [MPMusicPlayerController applicationMusicPlayer].volume = slider.value;
}


- (void)volumeSliderTouchDone:(UISlider *)slider{
    loginfo(@"这里不需要做什么");
}









#pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>videoStatusLabel视频播放状态显示框
- (void)loadVideoStatusLabel {
    //    WithFrame:CGRectMake(_overlayView.frame.size.width/2 - 100/2, _overlayView.frame.size.height/2 - 40/2, 100, 40)
    _videoStatusLabel = [[UILabel alloc] init];
    [_overlayView addSubview:_videoStatusLabel];
    __weak __typeof(self) weakSelf = self; 
    [_videoStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.overlayView.mas_centerX);
        make.centerY.equalTo(weakSelf.overlayView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:400], [ZJCFrameControl GetControl_height:80]));
    }];
    _videoStatusLabel.text = @"正在加载...";
    _videoStatusLabel.textAlignment = NSTextAlignmentCenter;
    _videoStatusLabel.textColor = [UIColor orangeColor];
    _videoStatusLabel.backgroundColor = [UIColor clearColor];
    _videoStatusLabel.font = [UIFont boldSystemFontOfSize:14];
}











#pragma mark - 初始化播放链接开始播放  >>>本地  >>>网络
// 网络
- (void)initVideoID{
    if (_videoId ) {
        // 获取videoId的播放url
        [self loadPlayUrls];
        
    } else if (_videoLocalPath) {
        // 播放本地视频
        [self playLocalVideo];
        
    } else {
        [ZJCAlertView presentAlertWithAlertTitle:@"提示" andAlertMessage:@"没有可以播放的视频" andAlertStyle:UIAlertControllerStyleAlert andSupportController:_supportController completion:^{
            logerror(@"没有可以播放的视频");
        } andDelay:1.5];
    }
}

// 本地
- (void)initLocalPath{
    if (_videoLocalPath) {
        // 播放本地视频
        [self playLocalVideo];
        
    } else if (_videoId) {
        // 获取videoId的播放url
        [self loadPlayUrls];
        
    } else {
        [ZJCAlertView presentAlertWithAlertTitle:@"提示" andAlertMessage:@"没有可以播放的视频" andAlertStyle:UIAlertControllerStyleAlert andSupportController:_supportController completion:^{
            logerror(@"没有可以播放的视频");
        } andDelay:1.5];
    }
}











// 网络视频
- (void)loadPlayUrls{
    // 配置视屏id  请求超时时间
    _player.videoId = _videoId;
    _player.timeoutSeconds = 10;
    
    // 请求网络视频的播放链接
    __weak ZJCDWPlayerView * blockSelf = self;
    // 请求出错 界面提示
    self.player.failBlock = ^(NSError * error){
        logdebug(@"error:%@",[error localizedDescription]);
        blockSelf.videoStatusLabel.hidden = NO;
        blockSelf.videoStatusLabel.text = @"加载失败";
    };
    // 请求成功 更新本地的链接信息
    self.player.getPlayUrlsBlock = ^(NSDictionary * playUrls) {
        logdebug(@"%@",playUrls);
        
        // 判断当前视频的播放状态   >>>   "0"说明是视频不可播放状态,可能原因是正在处于转码、审核等状态
        NSNumber * status = [playUrls objectForKey:@"status"];
        if (status == nil || [status integerValue] != 0) {
            NSString * message = [NSString stringWithFormat:@"%@ %@:%@",blockSelf.videoId,[playUrls objectForKey:@"status"],[playUrls objectForKey:@"statusinfo"]];
            [ZJCAlertView presentAlertWithAlertTitle:@"提示" andAlertMessage:message andAlertStyle:UIAlertControllerStyleAlert andSupportController:blockSelf.supportController completion:^{
                // 一旦当前的视频在审核的时候,就给出崩溃提示,然后返回不做操作
                return;
            } andDelay:1.5];
        }
        // 将请求到的视频信息 存到本地数据结构
        blockSelf.playUrls = playUrls;
        // 手动刷新界面信息
        [blockSelf resetViewContent];
    };
    // 检查完毕,开始请求视频信息进行加载
    [self.player startRequestPlayInfo];
}


// 本地视频
- (void)playLocalVideo{
    //    self.playUrls = [NSDictionary dictionaryWithObject:self.videoLocalPath forKey:@"playurl"];
    self.player.contentURL = [[NSURL alloc] initFileURLWithPath:self.videoLocalPath];
    
    [self.player prepareToPlay];
    [self.player play];
    logdebug(@"play url: %@", self.player.originalContentURL);
}












#pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>根据播放链接更新涉及的视图
- (void)resetViewContent{
    // 获取默认清晰度播放url
    NSNumber * defaultquality = [self.playUrls objectForKey:@"defaultquality"];
    for (NSDictionary * playurl in [self.playUrls objectForKey:@"qualities"]) {
        if (defaultquality == [playurl objectForKey:@"quality"]) {
            self.currentPlayUrl = playurl;
            break;
        }
    }
    
    // 如果没有没有获取到清晰到,那么就是用默认第一个清晰度
    if (!self.currentPlayUrl) {
        self.currentPlayUrl = [[self.playUrls objectForKey:@"qualities"] objectAtIndex:0];
    }
    
    // 播放id
    if (self.videoId) {
        [self resetQualityView];
    }
    
    // 开始播放
    [self.player prepareToPlay];
    [self.player play];
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
    
    //    // 由于每个视频的清晰度种类不同，所以这里需要重新加载
    //    [self reloadQualityView];
}












#pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>视频播放器的各种通知事件
- (void)addObserverForMPMoviePlayView{
    // 获取本地通知中心
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    
    
    // 将要播放
    [notificationCenter addObserver:self selector:@selector(myPlayerDurationAvailable) name:MPMovieDurationAvailableNotification object:self.player];
    
    // 准备渲染
    [notificationCenter addObserver:self selector:@selector(myPlayerReadyForDisplayerDidChange:) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:self.player];
    
    // 将要播放
    [notificationCenter addObserver:self selector:@selector(myPlayerDidPlay) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:self.player];
    
    // 视频状态
    [notificationCenter addObserver:self selector:@selector(myPlayerLoadStateDidChange) name:MPMoviePlayerLoadStateDidChangeNotification object:self.player];
    
    // 播放终止
    [notificationCenter addObserver:self selector:@selector(myPlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];
    
    // 播放状态
    [notificationCenter addObserver:self selector:@selector(myPlayerPlaybackStateDidChange) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.player];
}

- (void)myPlayerDidPlay{
    [_player setCurrentPlaybackTime:_historyPlaybackTime];
}




// 准备播放
- (void)myPlayerDurationAvailable{
    _isForwardOrBackWard = 0;
    // 总播放时间   置零
    self.durationLabel.text = [DWTools formatSecondsToString:self.player.duration];
    // 当前播放时间 置零
    self.currentPlaybackTimeLabel.text = [DWTools formatSecondsToString:0];
    // 进度条      最小值置零
    self.durationSlider.minimumValue = 0.0;
    // 进度条      最大值置为总时间
    self.durationSlider.maximumValue = self.player.duration;
    logdebug(@"seconds %f maximumValue %f %@", self.player.duration, self.durationSlider.maximumValue, self.durationLabel.text);
}


//  视频状态
- (void)myPlayerLoadStateDidChange{
    switch (self.player.loadState) {
        case MPMovieLoadStatePlayable:
            // 可播放
            logdebug(@"%@ 可播放", self.player.originalContentURL);
            self.videoStatusLabel.hidden = YES;
            break;
            
        case MPMovieLoadStatePlaythroughOK:
            // 状态为缓冲几乎完成，可以连续播放
            logdebug(@"%@ 缓冲完成,可以播放了", self.player.originalContentURL);
            self.videoStatusLabel.hidden = YES;
            break;
            
        case MPMovieLoadStateStalled:
            // 缓冲中
            logdebug(@"%@ 缓冲中", self.player.originalContentURL);
            self.videoStatusLabel.hidden = NO;
            self.videoStatusLabel.text = @"正在加载...";
            break;
            
        default:
            break;
    }
}


// 播放终止
- (void)myPlayerPlaybackDidFinish:(NSNotification *)notification{
    logdebug(@"accessLog %@", self.player.accessLog);
    logdebug(@"errorLog %@", self.player.errorLog);
    NSNumber *n = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    switch ([n intValue]) {
        case MPMovieFinishReasonPlaybackEnded:
            logdebug(@"播放结束");
            self.videoStatusLabel.hidden = YES;
            _isForwardOrBackWard = 0;
            break;
            
        case MPMovieFinishReasonPlaybackError:
            logdebug(@"播放出错");
            self.videoStatusLabel.hidden = NO;
            self.videoStatusLabel.text = @"加载失败";
            break;
            
        case MPMovieFinishReasonUserExited:
            logdebug(@"用户主动退出");
            break;
            
        default:
            break;
    }
}



// 播放状态改变－－
- (void)myPlayerPlaybackStateDidChange{
    logdebug(@"这个链接:%@ 播放状态: %ld", self.player.originalContentURL, (long)self.player.playbackState);
    
    switch ([self.player playbackState]) {
        case MPMoviePlaybackStateStopped:
            logdebug(@"停止播放");
            [self.playbackButton setSelected:NO];
            // 每次播放停止的时候,都需要记录当前视频的播放时间
            [self postCurrentMoviePlayDuration];
            break;
            
        case MPMoviePlaybackStatePlaying:
            [self.playbackButton setSelected:YES];
            logdebug(@"将要播放");
            self.videoStatusLabel.hidden = YES;
            break;
            
        case MPMoviePlaybackStatePaused:
            [self.playbackButton setSelected:NO];
            logdebug(@"播放暂停");
            self.videoStatusLabel.hidden = NO;
            self.videoStatusLabel.text = @"暂停";
            // 每次播放暂停的时候,都需要记录当前视频的播放时间
            if (_isForwardOrBackWard == 0) {
                [self postCurrentMoviePlayDuration];
            }
            break;
            
        case MPMoviePlaybackStateInterrupted:
            [self.playbackButton setSelected:NO];
            logdebug(@"播放中断");
            self.videoStatusLabel.hidden = NO;
            self.videoStatusLabel.text = @"加载中...";
            break;
            
        case MPMoviePlaybackStateSeekingForward:
            logdebug(@"快进");
            _isForwardOrBackWard++;
            self.videoStatusLabel.hidden = YES;
            break;
            
        case MPMoviePlaybackStateSeekingBackward:
            logdebug(@"快退");
            _isForwardOrBackWard++;
            self.videoStatusLabel.hidden = YES;
            break;
            
        default:
            break;
    }
}


// 视频界面开始渲染的方法
- (void)myPlayerReadyForDisplayerDidChange:(NSNotification *)notification{
    //    [_player setCurrentPlaybackTime:_historyPlaybackTime];
    logdebug(@"开始渲染的方法");
}

















#pragma mark - 记录播放时间
/**
 *  @brief 记录播放时间
 */
- (void)postCurrentMoviePlayDuration{
    // 拼接请求链接
    NSString * userName = [ZJCNSUserDefault getDataUsingNSUserDefaultWithDataType:ZJCUserInfor andKey:UserLoadInfor_LoadName];
    NSString * lessonId = _lessonId;
    NSNumber * videoDuration = [NSNumber numberWithInt:(int)_player.currentPlaybackTime];
    NSString * stringUrl = [NSString stringWithFormat:@"http://app.ccs163.net/reclook/%@/%@/%@",userName,videoDuration,lessonId];
    
    // 只有时间不同的时候,才会重新发送请求并记录
    if ([_oldTime isEqualToNumber:videoDuration]) {
        
    }else{
        _oldTime = videoDuration;
        _isForwardOrBackWard = 0;
        
        [AFHTTPRequestOperationManager GET:stringUrl parameter:nil success:^(id responseObject) {
            NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            logdebug(@"%@",dic[@"msg"]);
        } failure:^(NSError *error) {
            [ZJCAlertView presentAlertWithAlertTitle:@"" andAlertMessage:@"" andAlertStyle:UIAlertControllerStyleAlert andSupportController:self.supportController completion:^{
                NSLog(@"网络错误!");
            } andDelay:1.5];
        }];
    }
}


- (void)removeAllObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}













#pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>timer定时器相关
- (void)addTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timertHandler) userInfo:nil repeats:YES];
}


// 一旦开始就一直在跑的定时器
- (void)timertHandler{
    _currentPlaybackTimeLabel.text = [DWTools formatSecondsToString:self.player.currentPlaybackTime];
    _durationSlider.value = self.player.currentPlaybackTime;
    
    // 倒计时,如果隐藏时间到了1  就调用隐藏所有视图的方法
    if (_hiddenAll == NO) {
        // 视图都还展示中
        NSLog(@"view show");
        if (_hiddenDelaySeconds > 0) {
            NSLog(@"time > 0");
            if (_hiddenDelaySeconds == 1) {
                NSLog(@"view hidden");
                [self hiddenAllView];
            }
            NSLog(@"time --");
            _hiddenDelaySeconds--;
        }
    }
}

- (void)removeTimer{
    [_timer invalidate];
}

- (void)stopTimer{
    [_timer setFireDate:[NSDate distantFuture]];
}

- (void)startTimer{
    [_timer setFireDate:[NSDate distantPast]];
}



- (void)addPlayerTimer{
    
}





#pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>全局手势区别
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    // 屏蔽手势  >>> 各种视图的手势都要屏蔽
    if (gestureRecognizer == _signelTap) {
        if ([touch.view isKindOfClass:[UIButton class]]) {
            return NO;
        }
        if ([touch.view isKindOfClass:[UISlider class]]) {
            return NO;
        }
        if ([touch.view isKindOfClass:[UIImageView class]]) {
            return NO;
        }
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










#pragma mark - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>FullScreen全屏切换方法  (通过某个参数来进行全屏计算和转换)
- (void)setIsFullScreen:(BOOL)isFullScreen{
    _isFullScreen = isFullScreen;
    
    logdebug(@"这里需要进行全屏操作");
    if (isFullScreen == YES) {
        // 展开各个东西的尺寸
        // 底板控件操作
        [self handleFullScreenFullBase];
        // 切换全屏 控件操作
        [self handleFullScreenFullMore];
        
        
    }else{
        // 收回各个空间的尺寸
        // 底板控件操作
        [self handleFullScreenSmallBase];
        // 切换小屏 控件操作
        [self handleFullScreenSmallMore];
    }
}

// 全屏 底板控件操作
- (void)handleFullScreenFullBase{
    [self setBounds:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self setCenter:self.window.center];
    // 
    [self.videoBackgroundView setBounds:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.videoBackgroundView setCenter:self.window.center];
    //
    [self.player.view setBounds:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.player.view setCenter:self.window.center];
    // 
    [self.overlayView setBounds:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.overlayView setCenter:self.window.center];
    //
    __weak typeof(self)weakSelf = self;
    [_headerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.overlayView).offset(0);
        make.left.equalTo(weakSelf.overlayView).offset(0);
        make.right.equalTo(weakSelf.overlayView).offset(0);
        make.size.mas_equalTo(CGSizeMake(weakSelf.overlayView.width, weakSelf.overlayView.height*132/1080.0));
        make.width.mas_equalTo(60);
    }];
    _headerView.hidden = NO;
    //
    [_footerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.overlayView).offset(0);
        make.bottom.equalTo(weakSelf.overlayView).offset(0);
        make.right.equalTo(weakSelf.overlayView).offset(0);
        make.size.mas_equalTo(CGSizeMake(weakSelf.overlayView.width, weakSelf.overlayView.height*132/1080.0));
    }];
    //
    if (_qualityButton == nil || _downloadListButton == nil) {
        [self loadQualityView];
        [self loadDownloadListButton];
        
    }else{
        _qualityButton.hidden = NO;
        _downloadListButton.hidden = NO;
    }
    
    // *调整界面约束
    [_durationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.downloadListButton);
        make.right.equalTo(weakSelf.downloadListButton.mas_left).offset(-[ZJCFrameControl GetControl_X:5]);
        make.bottom.equalTo(weakSelf.downloadListButton);
        make.size.mas_equalTo(CGSizeMake(60, CGRectGetHeight(weakSelf.playbackButton.frame)));
    }];
}

// 全屏 富余控件操作
- (void)handleFullScreenFullMore{
    // 
    if (IPhone4s) {
        
    }else{
        UIImage * image1 = [UIImage imageNamed:@"play"];
        UIImage * image2 = [UIImage imageNamed:@"pause"];
        [_playbackButton setImage:image1 forState:UIControlStateNormal];
        [_playbackButton setImage:image2 forState:UIControlStateSelected];
    }
    // 
    _titleLabel.hidden = NO;
    _titleLabel.text = _titleLabelString;
    // 
    _courseButton.hidden = NO;
    // 
    _backButton.hidden = NO;
    // 
    _fullScreenButton.hidden = YES;
    // 
    _downloadListButton.hidden = NO;
    // 
    if (_downlistPopView == nil || _courseListPopView == nil) {
        // 新建
        [self loadTwoListViews];
        // 给数据源参数 (两个列表都需要给到参数  课程列表--管理视频播放  下载列表--管理视频下载)
        self.courseListPopView.titleString = self.courPopViewTitleString;
        self.courseListPopView.dataSource = self.courListDataSource;
        self.downlistPopView.titleString = self.courPopViewTitleString;
        self.downlistPopView.dataSource = self.courListDataSource;
        
    }else{
        // 更新位置信息
        _courseListPopBackground.hidden = NO;
        [_courseListPopBackground setFrame:CGRectMake(0, 0, _overlayView.width, _overlayView.height)];
        _courseListPopView.hidden = NO;
        [_courseListPopView setFrame:CGRectMake(_overlayView.width, 0, _overlayView.width*750/1920.0, _overlayView.height)];
        
        _downlistPopView.hidden = NO;
        [_downlistPopView setFrame:CGRectMake(self.downlistPopBackground.width/6.0, 0, self.downlistPopBackground.width*2/3, self.downlistPopBackground.height)];
        _downlistPopBackground.hidden = NO;
        [_downlistPopBackground setFrame:CGRectMake(0, -self.overlayView.height, self.overlayView.width, self.overlayView.height)];
    }
}











// 小屏 底板控件操作
- (void)handleFullScreenSmallBase{
    [self setBounds:CGRectMake(0, 0, SCREEN_WIDTH, [ZJCFrameControl GetControl_height:600])];
    [self setCenter:CGPointMake(SCREEN_WIDTH/2, [ZJCFrameControl GetControl_height:600]/2)];
    // 
    [self.videoBackgroundView setBounds:CGRectMake(0, 0, SCREEN_WIDTH, [ZJCFrameControl GetControl_height:600])];
    [self.videoBackgroundView setCenter:CGPointMake(SCREEN_WIDTH/2, [ZJCFrameControl GetControl_height:600]/2)];
    // 
    [self.player.view setBounds:CGRectMake(0, 0, SCREEN_WIDTH, [ZJCFrameControl GetControl_height:600])];
    [self.player.view setCenter:CGPointMake(SCREEN_WIDTH/2, [ZJCFrameControl GetControl_height:600]/2)];
    // 
    [self.overlayView setBounds:CGRectMake(0, 0, SCREEN_WIDTH, [ZJCFrameControl GetControl_height:600])];
    [self.overlayView setCenter:CGPointMake(SCREEN_WIDTH/2, [ZJCFrameControl GetControl_height:600]/2)];
    //
    __weak typeof(self)weakSelf = self;
    [_headerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.overlayView).offset(0);
        make.left.equalTo(weakSelf.overlayView).offset(0);
        make.right.equalTo(weakSelf.overlayView).offset(0);
        make.size.mas_equalTo(CGSizeMake(weakSelf.overlayView.width, CCDWPlayer_HeaderHeight));
    }];
    _headerView.hidden = YES;
    //
    [_footerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.overlayView).offset(0);
        make.bottom.equalTo(weakSelf.overlayView).offset(0);
        make.right.equalTo(weakSelf.overlayView).offset(0);
        make.size.mas_equalTo(CGSizeMake(weakSelf.overlayView.width, CCDWPlayer_FooterHeight));
    }];
    //
    [_durationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.fullScreenButton);
        make.right.equalTo(weakSelf.fullScreenButton.mas_left).offset(-[ZJCFrameControl GetControl_X:5]);
        make.bottom.equalTo(weakSelf.fullScreenButton);
        make.size.mas_equalTo(CGSizeMake(60, CGRectGetHeight(weakSelf.playbackButton.frame)));
    }];
}

// 小屏 富余控件操作
- (void)handleFullScreenSmallMore{
    // 
    UIImage * image1 = [UIImage imageNamed:@"playSm"];
    UIImage * image2 = [UIImage imageNamed:@"pauseSm"];
    [_playbackButton setImage:image1 forState:UIControlStateNormal];
    [_playbackButton setImage:image2 forState:UIControlStateSelected];
    // 
    _titleLabel.hidden = YES;
    // 
    _courseButton.hidden = YES;
    // 
    _backButton.hidden = YES;
    // 
    _qualityButton.hidden = YES;
    // 
    _fullScreenButton.hidden = NO;
    // 
    _downloadListButton.hidden = YES;
    // 
}






#pragma  mark - 特殊处理
- (void)setTitleLabelString:(NSString *)titleLabelString{
    _titleLabelString = titleLabelString;
}

- (void)setLessonId:(NSString *)lessonId{
    _lessonId = lessonId;
}

- (void)setCourListDataSource:(NSMutableArray *)courListDataSource{
    if (_courListDataSource == nil) {
        _courListDataSource = [NSMutableArray array];
        _courListDataSource = courListDataSource;
    }else{
        _courListDataSource = courListDataSource;
    }
}

@end








