//
//  ZJCDownItem.h
//  CCRA
//
//  Created by htkg on 16/5/4.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @brief 下载控制模型(Item) 下载状态枚举
 */
typedef enum {
    ZJCDownLoaderStatusWait = 1,       // 等待
    ZJCDownLoaderStatusStart,          // 开始
    ZJCDownLoaderStatusDownloading,    // 下载中
    ZJCDownLoaderStatusPause,          // 暂停
    ZJCDownLoaderStatusFinish,         // 完成
    ZJCDownLoaderStatusError           // 出错
}ZJCDownLoaderStatus;



@interface ZJCDownItem : NSObject

@property (nonatomic ,strong) NSString * myid;
@property (nonatomic ,strong) NSString * myparentid;
@property (nonatomic ,strong) NSString * vedioid;
@property (nonatomic ,strong) NSString * name;
@property (nonatomic ,strong) NSString * maxcount;
@property (nonatomic ,strong) NSString * imageurl;
@property (nonatomic ,strong) NSString * isover;

@property (nonatomic ,strong) NSString * destination;               // 下载地址
@property (nonatomic ,assign) ZJCDownLoaderStatus downloadStatus;   // 下载状态
@property (nonatomic ,strong) DWDownloader * downloader;            // 下载器

- (instancetype)initWithDictionary:(NSDictionary *)dic;
- (instancetype)initWithItem:(ZJCDownItem *)item;

@end
