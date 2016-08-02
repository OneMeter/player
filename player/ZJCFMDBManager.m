//
//  ZJCFMDBManager.m
//  CCRA
//
//  Created by htkg on 16/4/14.
//  Copyright © 2016年 htkg. All rights reserved.
//
//////////////////////////////
//
//  数据库基本功能
//      //增
//      //删
//      //改
//      //查
//////////////////////////////
// NSArray * pathsArr = [manager contentsOfDirectoryAtPath:NSHomeDirectory() error:nil];
// logdebug(@"NSHomeDirectory--------%@,pathsArr---------%@",NSHomeDirectory(),pathsArr);
#import "ZJCFMDBManager.h"




@implementation ZJCFMDBManager

///////////////////
// 数据库单例
+ (ZJCFMDBManager *)defaultManager{
    static ZJCFMDBManager * manager = nil;
    if (manager == nil) {
        manager = [[ZJCFMDBManager alloc] init];
    }
    return manager;
}


///////////////////
// 初始化数据库
- (instancetype)init{
    if (self = [super init]) {
        // 1.设置存储路径
        NSFileManager * manager = [NSFileManager defaultManager];
        
        // 2.获取需要存储的文件路径
        NSString * dataPath = [NSString stringWithFormat:@"%@/Documents/ZJCFMDB.rdb",NSHomeDirectory()];
        logdebug(@"FMDB--------------%@",dataPath);
        
        // * 判断是否存在数据库文件
        BOOL isExit = [manager fileExistsAtPath:dataPath];
        if (isExit == YES) {
            logdebug(@"数据库已存在");
        }else{
            logdebug(@"数据库不存在");
        }
        
        // 3.创建数据库文件,并且打开数据库(如果没有会自动创建一个数据库)
        _myDateBase = [FMDatabase databaseWithPath:dataPath];
        
        // 4.打开数据库(必须要打开,否则无法使用)
        if ([self openFMDB]) {
            logdebug(@"打开数据库成功");
            [self creatFMDBForm];
        }else{
            logdebug(@"打开数据库失败");
        }
    }
    return self;
}


////////////////
// 创建表格
- (void)creatFMDBForm{
    // 1.创建命令
    NSString * creatTable = @"CREATE TABLE IF NOT EXISTS courseForm(myid varchar(100),myparentid varchar(100),vedioid varchar(100),name varchar(100),maxcount varchar(100),imageurl varchar(200),isover varchar(100))";
    
    // 2.创建表格
    BOOL isSuc = [_myDateBase executeUpdate:creatTable];
    if (isSuc) {
        logdebug(@"创建表格成功");
    }else{
        logdebug(@"创建表格失败");
    }
}


/////////////////// 
// 打开数据库
- (BOOL)openFMDB{
    return [_myDateBase open];
}


////////////////// 
// 关闭数据库
- (BOOL)closeFMDB{
    return [_myDateBase close];
}

















#pragma mark - 增加操作
- (void)insertRecordWithMyid:(NSString *)myid andMyParentId:(NSString *)parentID andVedioId:(NSString *)vedioId andName:(NSString *)name andMaxCount:(NSString *)maxCount andImageUrl:(NSString *)imageUrl andIsOver:(NSString *)isOver{
    // 第一步 检查是否存在本地项目了     1.存在 >>> 更新内容   2.不存在 >>> 那就存入
    NSArray * arrayTemp = [NSArray array];
    arrayTemp = [self selectRecordWithMyid:myid];
    
    // 第二步 是否存入新的内容
    if (arrayTemp.count == 0) {
        // 1.创建命令
        NSString * insertSql = @"INSERT INTO courseForm(myid,myparentid,vedioid,name,maxcount,imageurl,isover) values(?,?,?,?,?,?,?)";
        // 2.插入数据
        BOOL isSuc = [_myDateBase executeUpdate:insertSql,myid,parentID,vedioId,name,maxCount,imageUrl,isOver];
        if (isSuc) {
            logdebug(@"插入信息条目成功");
        }else{
            logdebug(@"系统抽风,插入信息条目失败");
        }
    }else{
        // 开始的时候调试的是更新该条内容
        // 但是后来考虑并不合适,因为查询的时候,可能内容数据已经改变,并且是接下来步骤所需要的数据改变,所以并不应该更新,直接忽略就行了
//        [self exchangeRecordWithMyid:myid andMyParentId:parentID andVedioId:vedioId andName:name andMaxCount:maxCount andImageUrl:imageUrl andIsOver:isOver];
        logdebug(@"已经存在,未插入");
    }
}















#pragma mark - 删除操作
// myid
- (void)deleteRecordWithMyid:(NSString *)myid{
    // 1.创建命令
    NSString * deleteSql = @"DELETE FROM courseForm WHERE myid = ?";
    // 2.执行操作
    BOOL isSuc = [_myDateBase executeUpdate:deleteSql,myid];
    if (isSuc) {
        logdebug(@"删除信息条目成功--myid");
    }else{
        logdebug(@"系统抽风,删除信息条目失败--myid");
    }
}


// myparentid
- (void)deleteRecordWithMyParentId:(NSString *)myParentId{
    // 1.创建命令
    NSString * deleteSql = @"DELETE FROM courseForm WHERE myparentid = ?";
    // 2.执行操作
    BOOL isSuc = [_myDateBase executeUpdate:deleteSql,myParentId];
    if (isSuc) {
        logdebug(@"删除信息条目成功--myparentid");
    }else{
        logdebug(@"系统抽风,删除信息条目失败--myparentid");
    }
}















#pragma mark - 修改操作
// all
- (void)exchangeRecordWithMyid:(NSString *)myid andMyParentId:(NSString *)parentID andVedioId:(NSString *)vedioId andName:(NSString *)name andMaxCount:(NSString *)maxCount andImageUrl:(NSString *)imageUrl andIsOver:(NSString *)isOver{
    // 1.创建命令
    NSString * exchangeSql = @"UPDATE courseForm SET myparentid = ? , vedioid = ? , name = ? , maxcount = ? , imageurl = ? , isover = ? WHERE myid = ?";
    // 2.执行操作
    BOOL isSuc = [_myDateBase executeUpdate:exchangeSql,parentID,vedioId,name,maxCount,imageUrl,isOver,myid];
    if (isSuc) {
        NSLog(@"信息条目修改成功--all");
    }else{
        NSLog(@"系统抽风,信息条目修改失败--all");
    }
}


// isover下载进度
- (void)updateRecordWithMyid:(NSString *)myid useIsover:(NSString *)isover{
    // 1.创建命令行
    NSString * updateSql = @"UPDATE courseForm SET isover = ? WHERE myid = ?";
    // 2.执行操作
    BOOL isSuc = [_myDateBase executeUpdate:updateSql,isover,myid];
    if (isSuc) {
        logdebug(@"信息条目修改成功--isover");
    }else{
        logdebug(@"系统抽风,信息条目修改失败--isover");
    }
}


















#pragma mark - 查询操作
// all
- (NSArray *)selectAllRecord{
    // 1.创建命令
    NSString * selectAllSql = @"SELECT * FROM courseForm";
    
    // 2.本地承载
    if (_returnDataArray == nil) {
        _returnDataArray = [[NSMutableArray alloc] init];
    }else{
        [_returnDataArray removeAllObjects];
    }
    
    // 3.执行操作
    // 是一个集合类,结果集合
    // 增删改都是executeUpdate
    // 查是     executeQuery
    FMResultSet * set = [_myDateBase executeQuery:selectAllSql];
    
    // 4.取出数据
    while ([set next]) {
        // (myid,myparentid,vedioid,name,maxcount,imageurl,isover)
        NSString * myid        = [set stringForColumn:@"myid"];
        NSString * myparentid  = [set stringForColumn:@"myparentid"];
        NSString * vedioid     = [set stringForColumn:@"vedioid"];
        NSString * name        = [set stringForColumn:@"name"];
        NSString * maxcount    = [set stringForColumn:@"maxcount"];
        NSString * imageurl    = [set stringForColumn:@"imageurl"];
        NSString * isover      = [set stringForColumn:@"isover"];
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        [dic setValue:myid forKey:@"myid"];
        [dic setValue:myparentid forKey:@"myparentid"];
        [dic setValue:vedioid forKey:@"vedioid"];
        [dic setValue:name forKey:@"name"];
        [dic setValue:maxcount forKey:@"maxcount"];
        [dic setValue:imageurl forKey:@"imageurl"];
        [dic setValue:isover forKey:@"isover"];
        [_returnDataArray addObject:dic];
    }
    NSArray * arrtemp = [NSArray arrayWithArray:_returnDataArray];
    return arrtemp;
}


// myid
- (NSArray *)selectRecordWithMyid:(NSString *)myid{
    // 1.创建命令
    NSString * selectSql = @"SELECT * FROM courseForm WHERE myid = ?";
    
    // 2.本地承载
    if (_returnDataArray == nil) {
        _returnDataArray = [[NSMutableArray alloc] init];
    }else{
        [_returnDataArray removeAllObjects];
    }
    
    // 2.执行操作
    // 是一个集合类,结果集合
    // 增删改都是executeUpdate
    // 查是     executeQuery
    FMResultSet * set = [_myDateBase executeQuery:selectSql,myid];
    
    // 3.取出数据
    while ([set next]) {
        // (myid,myparentid,vedioid,name,maxcount,imageurl,isover)
        NSString * myid        = [set stringForColumn:@"myid"];
        NSString * myparentid  = [set stringForColumn:@"myparentid"];
        NSString * vedioid     = [set stringForColumn:@"vedioid"];
        NSString * name        = [set stringForColumn:@"name"];
        NSString * maxcount    = [set stringForColumn:@"maxcount"];
        NSString * imageurl    = [set stringForColumn:@"imageurl"];
        NSString * isover      = [set stringForColumn:@"isover"];
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        [dic setValue:myid forKey:@"myid"];
        [dic setValue:myparentid forKey:@"myparentid"];
        [dic setValue:vedioid forKey:@"vedioid"];
        [dic setValue:name forKey:@"name"];
        [dic setValue:maxcount forKey:@"maxcount"];
        [dic setValue:imageurl forKey:@"imageurl"];
        [dic setValue:isover forKey:@"isover"];
        [_returnDataArray addObject:dic];
    }
    NSArray * arrtemp = [NSArray arrayWithArray:_returnDataArray];
    return arrtemp;
}


// myparentid
- (NSArray *)selectRecordWithMyParentid:(NSString *)parentId{
    // 1.创建命令
    NSString * selectSql = @"SELECT * FROM courseForm WHERE myparentid = ?";
    
    // 2.本地承载
    if (_returnDataArray == nil) {
        _returnDataArray = [[NSMutableArray alloc] init];
    }else{
        [_returnDataArray removeAllObjects];
    }
    
    // 2.执行操作
    // 是一个集合类,结果集合
    // 增删改都是executeUpdate
    // 查是     executeQuery
    FMResultSet * set = [_myDateBase executeQuery:selectSql,parentId];
    
    // 3.取出数据
    while ([set next]) {
        // (myid,myparentid,vedioid,name,maxcount,imageurl,isover)
        NSString * myid        = [set stringForColumn:@"myid"];
        NSString * myparentid  = [set stringForColumn:@"myparentid"];
        NSString * vedioid     = [set stringForColumn:@"vedioid"];
        NSString * name        = [set stringForColumn:@"name"];
        NSString * maxcount    = [set stringForColumn:@"maxcount"];
        NSString * imageurl    = [set stringForColumn:@"imageurl"];
        NSString * isover      = [set stringForColumn:@"isover"];
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        [dic setValue:myid forKey:@"myid"];
        [dic setValue:myparentid forKey:@"myparentid"];
        [dic setValue:vedioid forKey:@"vedioid"];
        [dic setValue:name forKey:@"name"];
        [dic setValue:maxcount forKey:@"maxcount"];
        [dic setValue:imageurl forKey:@"imageurl"];
        [dic setValue:isover forKey:@"isover"];
        [_returnDataArray addObject:dic];
    }
    NSArray * arrtemp = [NSArray arrayWithArray:_returnDataArray];
    return arrtemp;
}


// 是否已经下载完成了
- (BOOL)isdownloadCompleteWithMyid:(NSString *)myid{
    // 1.创建命令
    NSString * selectSql = @"SELECT * FROM courseForm WHERE myid = ?";
    
    // 2.本地承载
    if (_returnDataArray == nil) {
        _returnDataArray = [[NSMutableArray alloc] init];
    }else{
        [_returnDataArray removeAllObjects];
    }
    
    // 2.执行操作
    // 是一个集合类,结果集合
    // 增删改都是executeUpdate
    // 查是     executeQuery
    FMResultSet * set = [_myDateBase executeQuery:selectSql,myid];
    
    // 3.取出数据
    while ([set next]) {
        // (myid,myparentid,vedioid,name,maxcount,imageurl,isover)
        NSString * myid        = [set stringForColumn:@"myid"];
        NSString * myparentid  = [set stringForColumn:@"myparentid"];
        NSString * vedioid     = [set stringForColumn:@"vedioid"];
        NSString * name        = [set stringForColumn:@"name"];
        NSString * maxcount    = [set stringForColumn:@"maxcount"];
        NSString * imageurl    = [set stringForColumn:@"imageurl"];
        NSString * isover      = [set stringForColumn:@"isover"];
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        [dic setValue:myid forKey:@"myid"];
        [dic setValue:myparentid forKey:@"myparentid"];
        [dic setValue:vedioid forKey:@"vedioid"];
        [dic setValue:name forKey:@"name"];
        [dic setValue:maxcount forKey:@"maxcount"];
        [dic setValue:imageurl forKey:@"imageurl"];
        [dic setValue:isover forKey:@"isover"];
        [_returnDataArray addObject:dic];
    }
    
    // 是否查询到数据
    if (_returnDataArray.count == 0) {
        return NO;
    }else{
        return YES;
    }
}






#pragma mark - ***特殊分开放 缓冲数量查询
+ (NSInteger)selectDownloadRecordCountsWithMyid:(NSString *)myid{
    NSInteger downLoadCount = 0;
    ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
    
    // 区别一节列表下  二级列表下
    NSArray * secondRecordArr = [manager selectRecordWithMyParentid:myid];
    if (secondRecordArr.count != 0) {
        for (NSDictionary * dicSecond in secondRecordArr) {
            if ([dicSecond[@"isover"] isEqualToString:@"1"]) {
                downLoadCount++;
            }
            NSArray * thirdRecordArr = [manager selectRecordWithMyParentid:dicSecond[@"myid"]];
            if (thirdRecordArr.count != 0) {
                for (NSDictionary * dicThird in thirdRecordArr) {
                    if ([dicThird[@"isover"] isEqualToString:@"1"]) {
                        downLoadCount++;
                    }
                }
            }
        }
    }else{
        NSArray * thirdRecordArr = [manager selectRecordWithMyid:myid];
        if (thirdRecordArr.count != 0) {
            for (NSDictionary * dicThird in thirdRecordArr) {
                if ([dicThird[@"isover"] isEqualToString:@"1"]) {
                    downLoadCount++;
                }
            }
        }
    }
    
    // 返回结果
    return downLoadCount;
}






@end



