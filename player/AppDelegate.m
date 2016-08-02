//
//  AppDelegate.m
//  player
//
//  Created by htkg on 16/8/2.
//  Copyright © 2016年 Vincent. All rights reserved.
//

#import "AppDelegate.h"
#import "ZJCFMDBManager.h"
#import "ZJCCourseViewController.h"
@interface AppDelegate ()

@property (nonatomic ,strong) ZJCFMDBManager * manager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor =[UIColor whiteColor];
    // Override point for customization after application launch.

    // 1.配置基本设置状态
    self.isAllowDownloadOnlyWifi = YES;
    self.isAllowWatchOnlyWifi = YES;
    
    // 2.初始化数据库(没有就初始化,有就单纯调用一下而已)
    _manager = [ZJCFMDBManager defaultManager];
    
    // 3.每次打开应用都需要登陆
    /*
     
     */
#if 1
  
    // 定制启动codeId
    _codeId = [self getCodeId];
    
#else
    _codeId = @"2016041302215900";
 
#endif
    
    
    // 4.关闭CCDWPlayer的网络监听log
    [DWLog setIsDebugHttpLog:NO];
    
    
    // 5.检测网络的状态变化(通过监听回调方法,改变本身的属性值,来给其他界面需要的时候使用)
    AFNetworkReachabilityManager * manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:              // 不可用
            {
                self.netWorkStatus = NetworkStatusNotReachable;
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:          // wifi无线
            {
                self.netWorkStatus = NetworkStatusReachableViaWiFi;
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:          // 移动网络
            {
                self.netWorkStatus = NetworkStatusReachableViaWWAN;
            }
                break;
            case AFNetworkReachabilityStatusUnknown:                   // 未知
            {
                self.netWorkStatus = NetworkStatusUnknown;
            }
                break;
            default:
                break;
        }
    }];
    ZJCCourseViewController * zjc = [[ZJCCourseViewController alloc]init];
    self.window.rootViewController=zjc;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    // 1.关闭cc视频的DRM加密server
    [self.drmServer stop];
    
    // 2.关闭数据库
    ZJCFMDBManager * FMDBManager = [ZJCFMDBManager defaultManager];
    [FMDBManager closeFMDB];
    
    // 3.清空下载队列
    ZJCDownControl * downManager = [ZJCDownControl defaultControl];
    [downManager.downloader pause];
    [downManager.downloadWaitingArr removeAllObjects];
    
    // 4.关闭网络检测
    AFNetworkReachabilityManager * netManager = [AFNetworkReachabilityManager sharedManager];
    [netManager stopMonitoring];
    
    
    
}
// 定制codeid
- (NSString *)getCodeId{
    NSDate * date = [NSDate date];
    NSString * string = [NSString stringWithFormat:@"%@",date];
    NSArray * arrayTemp = [string componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" -:+"]];
    return [[arrayTemp componentsJoinedByString:@""] substringToIndex:16];
    
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // 1.启动cc视频的DRM加密Server
    self.drmServer = [[DWDrmServer alloc] initWithListenPort:20140];
    BOOL success = [self.drmServer start];
    if (!success) {
        logerror(@"drmServer 启动失败");
    }
    
    // 2.打开FMDB
    ZJCFMDBManager * FMDBManager = [ZJCFMDBManager defaultManager];
    [FMDBManager openFMDB];
    
    // 3.初始化下载控制器的队列  (需要到界面手动开始下载)
    ZJCDownControl * downManager = [ZJCDownControl defaultControl];
    [downManager getAvailableDataFromFMDB];
    
    // 4.开启网络检测
    AFNetworkReachabilityManager * netManager = [AFNetworkReachabilityManager sharedManager];
    [netManager startMonitoring];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (_allowRotation == 1) {
        return UIInterfaceOrientationMaskLandscape;
    }
    else
    {
        return (UIInterfaceOrientationMaskPortrait);
    }
}
@end
