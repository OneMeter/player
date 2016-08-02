//
//  ZJCDownControl.h
//  CCRA
//
//  Created by htkg on 16/5/4.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZJCDownItem.h"


/**
 *  @brief 视频下载进度回调
 */
typedef void(^DownloadProgressBlock)(float progress, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite,ZJCDownItem * item);

/**
 *  @brief 视频下载完成回调
 */
typedef void(^DownloadFinishiBlock)();

/**
 *  @brief 视频下载出错回调
 */
typedef void(^DownloadErrorBlock)(NSError *error);





@interface ZJCDownControl : NSObject

@property (nonatomic ,strong) DWDownloader * downloader;              // 下载器
@property (nonatomic ,copy) DownloadProgressBlock progerssBlock;      // 进度 Block
@property (nonatomic ,copy) DownloadFinishiBlock finishBlock;         // 完成 Block
@property (nonatomic ,copy) DownloadErrorBlock errorBlock;            // 出错 Block

@property (nonatomic ,strong) NSMutableArray * downloadWaitingArr;    // 待下载     数组
@property (nonatomic ,strong) NSMutableArray * arraySumUseful;        // 所有items  数组
@property (nonatomic ,strong) ZJCDownItem * currentItem;              // 当前正在下载的item

+ (ZJCDownControl *)defaultControl;            // 单例

- (void)start;                                 // 开始
- (void)pause;                                 // 暂停
- (void)resume;                                // 恢复

- (BOOL)getAvailableDataFromFMDB;                         // 初始化 从数据库 初始化队列
- (void)addToDownloadQueue;                               // 初始化 初始化下载队列
- (void)insertIntoQueueWithItem:(ZJCDownItem *)newItem;   // 初始化 插入队列

- (void)removeItemAtIndex:(NSInteger)index;               // 删除 指定位置 item
- (void)removeItemWithItsMyid:(NSString *)myid;           // 删除 指定myid item
- (void)removeItemWithItsParentID:(NSString *)parentId;   // 删除 指定parentid item

- (void)startWithMyid:(NSString *)myid;                   // 开始 按照某一个item的myid开始下载

@end
