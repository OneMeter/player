//
//  ZJCDWPlayerView.h
//  HR
//
//  Created by htkg on 16/3/16.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWPlayerMenuView.h"
#import "DWTableView.h"
#import "DWTools.h"
#import "DWMediaSubtitle.h"
#import "DWMoviePlayerController.h"
#import "AppDelegate.h"

#import "ZJCDownloadListView.h"
#import "ZJCCourseListView.h"

/**
 *  @brief 全屏回调按钮
 */
typedef void(^fullScreenButtonBlock)(UIButton * button,NSInteger playbackTime);


/**
 *  @brief 传值Block (过路车*^_^*)
 */
typedef void(^passCar)(id sender,NSString * videoId,NSString * title,NSString * lessonid,BOOL isSection,NSInteger selectSection,NSInteger selectRow);








@interface ZJCDWPlayerView : UIView
/**
 *  @brief 播放器相关
 */
@property (strong, nonatomic) UIView *overlayView;                                 // 覆盖板
@property (strong, nonatomic) UIView *videoBackgroundView;                         // 播放器底板
@property (strong, nonatomic) UITapGestureRecognizer *signelTap;                   // 底板 手势
@property (strong, nonatomic) UILabel *videoStatusLabel;                           // 中间播放状态 文本框
@property (assign, nonatomic) BOOL hiddenAll;                                      // 隐藏所有视图
@property (assign, nonatomic) NSInteger hiddenDelaySeconds;                        // 自动隐藏时间

@property (strong, nonatomic) UIView *headerView;                                  // 顶条
@property (strong, nonatomic) UIView *footerView;                                  // 底条

@property (strong, nonatomic)UIButton *backButton;                                 // 返回按钮

@property (strong, nonatomic) UIButton *playbackButton;                            // 播放按钮
@property (strong, nonatomic) UISlider *durationSlider;                            // 进度条
@property (strong, nonatomic) UILabel *currentPlaybackTimeLabel;                   // 当前播放时间
@property (strong, nonatomic) UILabel *durationLabel;                              // 进度label
@property (nonatomic ,strong) UIButton * fullScreenButton;                         // 全屏按钮

@property (strong, nonatomic)UIButton *qualityButton;                              // 清晰度按钮
@property (strong, nonatomic)DWPlayerMenuView *qualityView;
@property (assign, nonatomic)NSInteger currentQualityStatus;
@property (strong, nonatomic)DWTableView *qualityTable;
@property (strong, nonatomic)NSArray *qualityDescription;
@property (strong, nonatomic)NSString *currentQuality;


@property (nonatomic ,strong) UILabel * titleLabel;                                // 标题
@property (nonatomic ,copy) NSString * titleLabelString;                           // 标题接口
@property (nonatomic ,strong) UIButton * courseButton;                             // 课节列表 按钮
@property (nonatomic ,strong) UIButton * downloadListButton;                       // 下载列表 按钮

@property (nonatomic ,strong) ZJCDownloadListView * downlistPopView;               // 下载列表
@property (nonatomic ,strong) UIView * downlistPopBackground;          
@property (nonatomic ,strong) UIButton * exitButton;                  
@property (nonatomic ,strong) ZJCCourseListView * courseListPopView;               // 课节列表
@property (nonatomic ,strong) UIButton * courseListPopBackground;

@property (strong, nonatomic) UIView *volumeView;                                  // 声音底板
@property (strong, nonatomic) UISlider *volumeSlider;                              // 声音条

@property (strong, nonatomic) NSTimer *timer;                                      // 计时器
@property (nonatomic ,strong) NSTimer * playerTimer;                               // 播放计时器

/**
 *  @brief 控制相关
 */
@property (nonatomic ,strong) UIViewController * supportController;               // 所属控制器
@property (copy, nonatomic) NSString * videoId;                                   // 在线视频id
@property (nonatomic ,copy) NSString * lessonId;                                  // 章节id
@property (copy, nonatomic) NSString * videoLocalPath;                            // 本地视频路径
@property (nonatomic ,strong) NSNumber * oldTime;                                 // 旧的观看时间
@property (nonatomic ,assign) NSInteger isForwardOrBackWard;                      // 是否快进

@property (nonatomic ,strong) DWMoviePlayerController * player;                   // 播放器
@property (nonatomic ,strong) NSDictionary * playUrls;                            // 播放链接
@property (nonatomic ,strong) NSDictionary * currentPlayUrl;                      // 当前播放链接
@property (nonatomic ,assign) NSTimeInterval historyPlaybackTime;                 // 进度
@property (nonatomic ,assign) NSInteger userWantPlaybackTime;                     // 回调用的时间
@property (nonatomic ,assign) BOOL isFullScreen;                                  // 全屏flog

@property (nonatomic ,copy) fullScreenButtonBlock fullScreecButtonClickedBlock;   // 全屏回调Block
@property (nonatomic ,copy) passCar passCarBlock;


/**
 *  @brief 给弹出界面使用的数据
 */
@property (nonatomic ,strong) NSMutableArray * courListDataSource;                // 弹出列表数据源
@property (nonatomic ,copy) NSString * courPopViewTitleString;                    // 弹出列表标题

//@property (nonatomic ,assign) BOOL isSectionBack;
//@property (nonatomic ,assign) NSInteger selectSection;
//@property (nonatomic ,assign) NSInteger selectRow;

- (void)removeAllObserver;            // 干掉通知
- (void)stopTimer;                    // 关掉定时器
- (void)startTimer;                   // 打开定时器
- (void)removeTimer;                  // 干掉定时器

@end
