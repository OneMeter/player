//
//  ZJCPublicDefine.h
//  HR
//
//  Created by htkg on 15/12/30.
//  Copyright © 2015年 htkg. All rights reserved.
//

#ifndef ZJCPublicDefine_h
#define ZJCPublicDefine_h


// 1.自定制系统常用方法、定制类
#define ZJCGetColorWith(Red,Green,Blue,Alpha) [UIColor colorWithRed:(Red)/255. green:(Green)/255. blue:(Blue)/255. alpha:(Alpha)]   // 获取颜色
#define AppDelegate_Public (AppDelegate *)[[UIApplication sharedApplication] delegate]                                              // AppDelegate全局代理


// 2.系统默认尺寸相关
#define SCREEN_BOUNDS [[UIScreen mainScreen] bounds]
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define IPhone6Plus_SCREEN_WIDTH 414
#define IPhone6Plus_SCREEN_HEIGHT 736
#define IPhone6Plus_SCREEN_BOUNDS CGRectMake(0, 0, 414, 736)

#define THEME_BACKGROUNDCOLOR ZJCGetColorWith(94, 151, 227, 1)                        // 系统主色调  (淡蓝色)
#define KEYBOARD_UP_TIME 0.25                                                         // 键盘上升时间  (系统)
#define LineColor 207.0 / 255.0, 207.0 / 255.0, 207.0 / 255.0, 1.0                    // 系统画线色调 (80%黑)


// 3.IPhone不同设备的屏幕尺寸
#define IPhone4s ((SCREEN_WIDTH == 320) && (SCREEN_HEIGHT == 480))                    // 4s尺寸
#define IPhone5s ((SCREEN_WIDTH == 320) && (SCREEN_HEIGHT == 568))                    // 5s尺寸
#define IPhone6 ((SCREEN_WIDTH == 375) && (SCREEN_HEIGHT == 667))                     // 6 尺寸
#define IPhone6Plus ((SCREEN_WIDTH == 414) && (SCREEN_HEIGHT == 736))                 // 6P尺寸


// 4.ZJCNSUserDefault缓存类标识
#define AccountUserDefault @"isFirst"                   // 用户"首次登陆"判断
#define AllUserInfor_Key @"allUserInfor"                // 缓存的所有的用户信息 主KEY
#define Remember_UserAndPassword @"isRemember"          // 记住用户名密码

#define UserLoadInfor_Key @"userLoadInfor"              // "登陆"相关信息
#define UserLoadInfor_Name @"Name"                      // "用户名"
#define UserLoadInfor_LoadName @"LoadName"              // "登录名"
#define UserLoadInfor_Password @"Password"              // "用户密码"
#define UserLoadInfor_ApplyLevel @"ApplyLevel"          // "报考级别"

#define SearchHistory  @"searchHisroty"                 // 历史信息   >>>   并没用上...


// 5.全局缓存的有效时间
#define Cache_Exit_Timeinterval 1                       // 缓存时间   >>>   1秒


// 6.验证码获取倒计总时间
#define CodeGetFullTime 60                              // 验证码获取时间   >>>   60秒


// 7."首页"
#define HomePage_CourseTableView_Cell_Identifier @"HomepageCourseTableViewCell"        // "首页"展示表格cell identifier


// 8."模拟考试"
#define Font_Size 16.f                                  // 模拟考试 字体
#define TabButton_Width 48.f                            // TabBar 宽度


// 9."登陆页"
#define TextFieldLeftWidthPlaceHolder 40                // 输入框  光标左边距


// 10.视频播放器   >>>   1.用户名  2.APIKEY  3.AppDelegate宏
#define DWACCOUNT_USERID @"1F0962D7423CDB56"                                           // cc视频播放 >>> 用户id
#define DWACCOUNT_APIKEY @"VAlbogkKrBv5zXnqTEIiOfdsZ4z2ap0E"                           // cc视频播放 >>> ApiKey

#define DWPlayer_Key_VideoId                @"videoId"                    // 视频id
#define DWPlayer_Key_Definition             @"definition"                 // 清晰度
#define DWPlayer_Key_VideoPath              @"videoPath"                  // 下载路径
#define DWPlayer_Key_VideoDownloadProgress  @"videoDownloadProgress"      // 下载进度
#define DWPlayer_Key_VideoFileSize          @"VideoFileSize"              // 文件大小
#define DWPlayer_Key_VideoDownloadSize      @"VideoDownloadSize"          // 已下载量
#define DWPlayer_Key_VideoDownloadStatus    @"VideoDownloadStatus"        // 下载状态

#define DWPlayer_Destion [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]          // 下载视频 默认根路径
#define DWPlayer_RequestOutTime 10                                                                                                  // 请求超时 限制时间


// 11.播放器控件尺寸相关
#define CCDWPlayer_HeaderHeight 30                     // 顶部控件条 高度
#define CCDWPlayer_FooterHeight 30                     // 底部控件条 高度
#define CCDWPlayer_VolumeSliderWidth 20                // 音量控制条 宽度
#define CCDWPlayer_VolumeSliderLength 100              // 音量控制条 长度

#define CCDWPlayer_PlayStatusView_Width   100          // 播放状态条 宽度
#define CCDWPlayer_PlayStatusView_Height  40           // 播放状态条 高度

#define DWControls_Hidden_Time 10                      // 控件自动隐藏时间


// 12.全局  分隔线
#define SINGLE_LINE_WIDTH           (1 / [UIScreen mainScreen].scale)                  // 像素线 适应性宽度
#define SINGLE_LINE_ADJUST_OFFSET   ((1 / [UIScreen mainScreen].scale) / 2)            // 像素线 偏移度


#endif /* ZJCPublicDefine_h */



