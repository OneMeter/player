//
//  ZJCDownControl.m
//  CCRA
//
//  Created by htkg on 16/5/4.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCDownControl.h"

@implementation ZJCDownControl

// 下载管理类单例
+ (ZJCDownControl *)defaultControl{
    static ZJCDownControl * defaultControl = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultControl = [[ZJCDownControl alloc] init];
    });
    return defaultControl;
}













#pragma mark - 获取队列相关
// 从数据库读取可用数据加载到本地队列,供给给界面使用
- (BOOL)getAvailableDataFromFMDB{
    if (_arraySumUseful == nil) {
        _arraySumUseful = [[NSMutableArray alloc] init];
    }else{
        [_arraySumUseful removeAllObjects];
    }
    ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
    
    // 1.获取所有数据库需要下载的数据
    NSArray * arrayFirst = [NSArray arrayWithArray:[manager selectAllRecord]];
    for (int i = 0; i < arrayFirst.count ; i++) {
        // 一级
        NSDictionary * firstDic = arrayFirst[i];
        if ([firstDic[@"myparentid"] isEqualToString:@"-1"]) {
            // 二级
            NSArray * arraySecond = [NSArray arrayWithArray:[manager selectRecordWithMyParentid:firstDic[@"myid"]]];
            for (int j = 0 ; j < arraySecond.count ; j++) {
                // 三级
                NSArray * arrayThird = [NSArray arrayWithArray:[manager selectRecordWithMyParentid:arraySecond[j][@"myid"]]];
                // 判断三级是否存在,如果存在那么不需要操作,如果不存在那么该级别下面肯定有视频
                if (arrayThird.count == 0) {
                    ZJCDownItem * itemTemp = [[ZJCDownItem alloc] initWithDictionary:arraySecond[j]];
                    [_arraySumUseful addObject:itemTemp];
                }else{
                    for (int k = 0 ; k < arrayThird.count ; k++) {
                        ZJCDownItem * itemTemp = [[ZJCDownItem alloc] initWithDictionary:arrayThird[k]];
                        [_arraySumUseful addObject:itemTemp];
                    }
                }
            }
        }
    }
    return YES;
}


// 批量添加到下载队列
- (void)addToDownloadQueue{
    // 2.数据结构开辟空间
    if (_downloadWaitingArr == nil) {
        _downloadWaitingArr = [[NSMutableArray alloc] init];
    }else{
        [_downloadWaitingArr removeAllObjects];
    }
    
    // 3.保存到自己的数据结构
    for (int i = 0 ; i < _arraySumUseful.count ; i++) {
        ZJCDownItem * item = _arraySumUseful[i];
        if ([item.isover isEqualToString:@"1"]) {              // 完成    数组
            item.downloadStatus = ZJCDownLoaderStatusFinish;
            
        }else{                                                 // 待下载   数组  (下载队列)
            item.downloadStatus = ZJCDownLoaderStatusWait;
            [_downloadWaitingArr addObject:item];
        }
    }
}



// 添加单个 item 到队列中去
- (void)insertIntoQueueWithItem:(ZJCDownItem *)newItem{
    if (_downloadWaitingArr == nil) {
        _downloadWaitingArr = [[NSMutableArray alloc] init];
        [_downloadWaitingArr addObject:newItem];
    }else{
        [_downloadWaitingArr addObject:newItem];
    }
}













#pragma mark - 开始相关----------------------------------------------------
/**
 *  @brief 开始相关
 */
- (void)startWithMyid:(NSString *)myid{
    // 之前正在下载的对象需要暂停
    if (_downloader != nil) {
        [_downloader pause];
        _downloader = nil;
        _currentItem = nil;
    }
    
    // 1.找到当前需要进行下载的那个对象
    for (ZJCDownItem * item in _arraySumUseful) {
        if ([item.myid isEqualToString:myid]) {
            _downloader = item.downloader;
            _currentItem = item;
            break;
        }
    }
    
    
    
    
    
    // 2.开始下载该对象
    if (_currentItem.downloadStatus == ZJCDownLoaderStatusPause) {
        [self.downloader resume];
    }else{
        [self.downloader start];
    }
    
    
    
    
    
    
    // 3.回调各种状态
    __weak typeof(self) weakSelf = self;
    // 完成-------------------------------------
    self.downloader.finishBlock = ^(){
        logdebug(@"视频:%@--------下载完成!!!",weakSelf.currentItem.myid);
        // 1.完成了的项目,修改当前状态为完成,从当前下载队列里面删除,更新其进度到   "1"
        weakSelf.currentItem.downloadStatus = ZJCDownLoaderStatusFinish;
        weakSelf.currentItem.isover = [NSString stringWithFormat:@"%@",@"1"];
        [weakSelf.downloadWaitingArr removeObject:weakSelf.currentItem];
        
        // 2.回调下载完成
        if (weakSelf.finishBlock) {
            weakSelf.finishBlock();
        }
    };
    
    
    
    
    
    
    // 出错-------------------------------------
    self.downloader.failBlock = ^(NSError * error){
        
        logdebug(@"视频:%@--------出错原因:%@",weakSelf.currentItem.myid,[error localizedDescription]);
        // 下载出错了,当前的item状态置错误,并且从下载队里中移除
        weakSelf.currentItem.downloadStatus = ZJCDownLoaderStatusError;
        [weakSelf.downloadWaitingArr removeObject:weakSelf.currentItem];
        
        // 回到Block
        if (weakSelf.errorBlock) {
            weakSelf.errorBlock(error);
        }
    };
    
    
    
    
    
    // 进度-------------------------------------
    self.downloader.progressBlock = ^(float progress, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite){
        logdebug(@"视频:%@--------正在下载...下载进度:%f,已下载%ld,总量%ld",weakSelf.currentItem.myid,progress,(long)totalBytesWritten,(long)totalBytesExpectedToWrite);
        weakSelf.currentItem.downloadStatus = ZJCDownLoaderStatusDownloading;
        weakSelf.currentItem.isover = [NSString stringWithFormat:@"%f",progress];
        
        if (weakSelf.progerssBlock) {
            weakSelf.progerssBlock(progress,totalBytesWritten,totalBytesExpectedToWrite,weakSelf.currentItem);
        }
    };
}






















#pragma mark - 删除相关----------------------------------------------------
/**
 *  @brief 删除相关
 */
- (void)removeItemAtIndex:(NSInteger)index{
    
}


- (void)removeItemWithItsMyid:(NSString *)myid{
    NSFileManager * manager = [NSFileManager defaultManager];
    NSError * fileRemoveError = nil;
    // 下载队列
    for (ZJCDownItem * itemTemp2 in _downloadWaitingArr) {
        if ([itemTemp2.myid isEqualToString:myid]) {
            [_downloadWaitingArr removeObject:itemTemp2];
            break;
        }
    }
    // 总队列 本地文件
    for (ZJCDownItem * itemTemp in _arraySumUseful) {
        if ([itemTemp.myid isEqualToString:myid]) {
            [manager removeItemAtPath:itemTemp.destination error:&fileRemoveError];
            [_arraySumUseful removeObject:itemTemp];
            break;
        }
    }
    // 容错处理
    if (fileRemoveError != nil) {
        logerror(@"%@",[fileRemoveError localizedDescription]);
    }
}


- (void)removeItemWithItsParentID:(NSString *)parentId{
    NSFileManager * manager = [NSFileManager defaultManager];
    NSError * fileRemoveError = nil;
    // 倒着删除
    // 下载队列
    for (int i = (int)(_downloadWaitingArr.count - 1) ; i >= 0 ; i--) {
        ZJCDownItem * item = _downloadWaitingArr[i];
        if ([item.myparentid isEqualToString:parentId]) {
            [_downloadWaitingArr removeObject:item];
        }
    }
    // 总队列 本地文件
    for (int i = (int)(_arraySumUseful.count - 1) ; i >= 0 ; i--) {
        ZJCDownItem * item = _arraySumUseful[i];
        if ([item.myparentid isEqualToString:parentId]) {
            [manager removeItemAtPath:item.destination error:&fileRemoveError];
            [_arraySumUseful removeObject:item];
        }
    }
    // 容错处理
    if (fileRemoveError != nil) {
        logerror(@"%@",[fileRemoveError localizedDescription]);
    }
}




#pragma mark - 基本方法
// 开始
- (void)start{
    [_downloader start];
}


// 暂停
- (void)pause{
    [_downloader pause];
}


// 恢复
- (void)resume{
    [_downloader resume];
}



@end



//#pragma mark - 获取队列相关
//// 总队列 (从数据库存储的数据获得)
//- (BOOL)getAvailableDataFromFMDB{
//    // 因为存在 选中新的项目需要添加到下载队列中 的可能性,所以需要判断当前下载队列中是否存在对应的下载项目,存在的话就不需要再创建,而是直接把原来的项目拿过来,放到下载总队列中去就对了
//    if (_arraySumUseful == nil) {
//        // 如果是第一次,那就开辟空间
//        _arraySumUseful = [[NSMutableArray alloc] init];
//        // 获取数据库管理单例类
//        ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
//        // 一级
//        NSArray * arrayFirst = [NSArray arrayWithArray:[manager selectRecordWithMyParentid:@"-1"]];
//        for (int i = 0 ; i < arrayFirst.count ; i++) {
//            NSDictionary * firstDic = arrayFirst[i];
//            // 二级
//            NSArray * arraySecond = [NSArray arrayWithArray:[manager selectRecordWithMyParentid:firstDic[@"myid"]]];
//            for (int j = 0 ; j < arraySecond.count ; j++) {
//                NSDictionary * secondDic = arraySecond[j];
//                // 三级
//                // 判断三级是否存在\
//                如果存在    那么对应二级就不需要进行储存\
//                如果不存在  那么该二级就是需要下载的视频
//                if ([secondDic[@"maxcount"] floatValue] == 0) {
//                    ZJCDownItem * itemTemp = [[ZJCDownItem alloc] initWithDictionary:secondDic];
//                    [_arraySumUseful addObject:itemTemp];
//                }else{
//                    NSArray * arrayThird = [NSArray arrayWithArray:[manager selectRecordWithMyParentid:secondDic[@"myid"]]];
//                    for (int k = 0 ; k < arrayThird.count ; k++) {
//                        ZJCDownItem * itemTemp = [[ZJCDownItem alloc] initWithDictionary:arrayThird[k]];
//                        [_arraySumUseful addObject:itemTemp];
//                    }
//                }
//            }
//        }
//        
//        
//        
//    }else{
//        NSMutableArray * tempArray = [[NSMutableArray alloc] init];
//        // 获取数据库管理单例类
//        ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
//        // 一级
//        NSArray * arrayFirst = [NSArray arrayWithArray:[manager selectRecordWithMyParentid:@"-1"]];
//        for (int i = 0 ; i < arrayFirst.count ; i++) {
//            NSDictionary * firstDic = arrayFirst[i];
//            // 二级
//            NSArray * arraySecond = [NSArray arrayWithArray:[manager selectRecordWithMyParentid:firstDic[@"myid"]]];
//            for (int j = 0 ; j < arraySecond.count ; j++) {
//                NSDictionary * secondDic = arraySecond[j];
//                // 三级
//                // 判断三级是否存在\
//                如果存在    那么对应二级就不需要进行储存\
//                如果不存在  那么该二级就是需要下载的视频
//                if ([secondDic[@"maxcount"] floatValue] == 0) {
//                    // 判断之前的总队列之中是否已经含有该item\
//                    有,就直接拿过来存入\
//                    没有,就新建一个存入
//                    BOOL ishave = NO;
//                    for (ZJCDownItem * item in _arraySumUseful) { 
//                        if ([item.myid isEqualToString:secondDic[@"myid"]]) {
//                            //                            ZJCDownItem * itemTempOne = [[ZJCDownItem alloc] initWithItem:item];
//                            [tempArray addObject:item];
//                            ishave = YES;
//                            break;
//                        }else{
//                            ishave = NO;
//                        }
//                    }
//                    
//                    if (ishave == NO) {
//                        ZJCDownItem * itemTempTwo = [[ZJCDownItem alloc] initWithDictionary:secondDic];
//                        [tempArray addObject:itemTempTwo];
//                    }
//                }else{
//                    NSArray * arrayThird = [NSArray arrayWithArray:[manager selectRecordWithMyParentid:secondDic[@"myid"]]];
//                    for (int k = 0 ; k < arrayThird.count ; k++) {
//                        BOOL ishave = NO;
//                        for (ZJCDownItem * item in _arraySumUseful) {
//                            if ([item.myid isEqualToString:arrayThird[k][@""]]) {
//                                //                                ZJCDownItem * itemTempThree = [[ZJCDownItem alloc] initWithItem:item];
//                                [tempArray addObject:item];
//                                ishave = YES;
//                                break;
//                            }else{
//                                ishave = NO;
//                            }
//                        }
//                    }
//                    
//                }
//            }
//        }
//        
//        // 干掉原来的队列,换成新的队列
//        [_arraySumUseful removeAllObjects];
//        _arraySumUseful = tempArray;
//    }
//    return YES;
//}
//
//
//
//
//
//// 下载队列  (从总队列获得)
//- (void)addToDownloadQueue{
//    // 1.数据结构开辟空间
//    if (_downloadWaitingArr == nil) {
//        // 之前下载队列是没有的,初始化了,直接从总队列里面拿出来就行了
//        _downloadWaitingArr = [[NSMutableArray alloc] init];
//        // 2.从总队列里面拿出来items放到下载队列里面去
//        for (int i = 0 ; i < _arraySumUseful.count ; i++) {
//            ZJCDownItem * item = _arraySumUseful[i];
//            if ([item.isover isEqualToString:@"1"]) {              // 完成    数组
//                item.downloadStatus = ZJCDownLoaderStatusFinish;
//                
//            }else{                                                 // 待下载   数组  (下载队列)
//                item.downloadStatus = ZJCDownLoaderStatusWait;
//                [_downloadWaitingArr addObject:item];
//            }
//        }
//    }else{
//        // 之前下载队列可能是有item的,那么如果有新添加的item,就添加到里面,原来有的直接拿过来放进去就行了
//        NSMutableArray * tempArray = [[NSMutableArray alloc] init];
//        for (int i = 0 ; i < _arraySumUseful.count ; i++) {
//            ZJCDownItem * item = _arraySumUseful[i];
//            if ([item.isover isEqualToString:@"1"]) {
//                item.downloadStatus = ZJCDownLoaderStatusFinish;
//                
//            }else{
//                item.downloadStatus = ZJCDownLoaderStatusWait;
//                BOOL isHave = NO;
//                for (ZJCDownItem * itemWaitingTemp in _downloadWaitingArr) {
//                    if ([itemWaitingTemp.myid isEqualToString:item.myid]) {
//                        isHave = YES;
//                        [tempArray addObject:itemWaitingTemp];
//                        break;
//                    }else{
//                        isHave = NO;
//                    }
//                }
//                if (isHave == NO) {
//                    [tempArray addObject:item];
//                }
//            }
//        }
//        // 干掉原来的东西,现在是已经加进来的新的东西了
//        [_downloadWaitingArr removeAllObjects];
//        _downloadWaitingArr = tempArray;
//    }
//    
//    
//}
//
//
//
//
//
//// 添加单个 item 到队列中去
//- (void)insertIntoQueueWithItem:(ZJCDownItem *)newItem{
//    if (_downloadWaitingArr == nil) {
//        _downloadWaitingArr = [[NSMutableArray alloc] init];
//        [_downloadWaitingArr addObject:newItem];
//    }else{
//        [_downloadWaitingArr addObject:newItem];
//    }
//}

