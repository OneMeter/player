//
//  AppDelegate.h
//  player
//
//  Created by htkg on 16/8/2.
//  Copyright © 2016年 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWDrmServer.h"

/**
 *  @brief 视频清晰度枚举
 */
typedef enum {
    MovieDefinationTypeHigh = 1,    // 高清
    MovieDefinationTypeNormal       // 标清
}MovieDefinationType;

/**
 *  @brief 网络状态枚举
 */
typedef enum {
    NetworkStatusUnknown          = -1,   // 未检测到
    NetworkStatusNotReachable     = 0,    // 不可用
    NetworkStatusReachableViaWWAN = 1,    // 移动数据
    NetworkStatusReachableViaWiFi = 2     // wifi
}NetworkStatus;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DWDrmServer *drmServer;                         // CC视频播放器 加密服务
@property (nonatomic ,strong) NSString * codeId;                              // 启动 标识符
@property (nonatomic ,assign) NSInteger allowRotation;                        // 转屏 标识符
@property (nonatomic ,assign) BOOL isAllowDownloadOnlyWifi;                   // wifi下载 标识符
@property (nonatomic ,assign) BOOL isAllowWatchOnlyWifi;                      // wifi观看 标识符
@property (nonatomic ,assign) MovieDefinationType defaultDownloadDefinition;  // 默认 "缓存清晰度"
@property (nonatomic ,assign) NetworkStatus netWorkStatus;                    // 网络状态

@property (nonatomic ,strong) DWDownloader * downloader;      // 下载器
@property (nonatomic ,strong) NSArray * downloadWaitingArr;   // 待下载的数组
@property (nonatomic ,strong) NSArray * downloadFinishiArr;   // 下载完成的数组


@end

