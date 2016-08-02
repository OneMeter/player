//
//  ZJCFMDBManager.h
//  CCRA
//
//  Created by htkg on 16/4/14.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDatabase.h>

///**
// 数据库建表类型
// */
//typedef enum {
//    ZJCFMDBFormTypeCourse = 1,     // 课程 表   >>> 大表
//    ZJCFMDBFormTypeSection         // 章节 表   >>> 小表
//}ZJCFMDBFormType;


@interface ZJCFMDBManager : NSObject

@property (nonatomic ,strong) FMDatabase * myDateBase;
@property (nonatomic ,strong) NSMutableArray * returnDataArray;

// 全局单例
+ (ZJCFMDBManager *)defaultManager;
- (BOOL)openFMDB;
- (BOOL)closeFMDB;


// 增
- (void)insertRecordWithMyid:(NSString *)myid andMyParentId:(NSString *)parentID andVedioId:(NSString *)vedioId andName:(NSString *)name andMaxCount:(NSString *)maxCount andImageUrl:(NSString *)imageUrl andIsOver:(NSString *)isOver;

// 删
- (void)deleteRecordWithMyid:(NSString *)myid;
- (void)deleteRecordWithMyParentId:(NSString *)myParentId;

// 改
- (void)exchangeRecordWithMyid:(NSString *)myid andMyParentId:(NSString *)parentID andVedioId:(NSString *)vedioId andName:(NSString *)name andMaxCount:(NSString *)maxCount andImageUrl:(NSString *)imageUrl andIsOver:(NSString *)isOver;
- (void)updateRecordWithMyid:(NSString *)myid useIsover:(NSString *)isover;

// 查
- (NSArray *)selectAllRecord;
- (NSArray *)selectRecordWithMyid:(NSString *)myid;
- (NSArray *)selectRecordWithMyParentid:(NSString *)parentId;
- (BOOL)isdownloadCompleteWithMyid:(NSString *)myid;

// 查询返回多少节课的方法
+ (NSInteger)selectDownloadRecordCountsWithMyid:(NSString *)myid;

@end

