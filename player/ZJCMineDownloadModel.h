//
//  ZJCMineDownloadModel.h
//  CCRA
//
//  Created by htkg on 16/4/5.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <JSONModel/JSONModel.h>

// 当前的下载状态
typedef enum {
    ZJCMineDownloadModelStstusPause = 100,
    ZJCMineDownloadModelStstusDownloading,
    ZJCMineDownloadModelStstusWait,
    ZJCMineDownloadModelStstusFinish
}ZJCMineDownloadModelStstus;




@interface ZJCMineDownloadModel : JSONModel

@property (nonatomic ,assign) BOOL isSelected;

@property (nonatomic ,copy) NSString * myid;
@property (nonatomic ,copy) NSString * myparentid;
@property (nonatomic ,copy) NSString * maxcount;
@property (nonatomic ,copy) NSString * imageurl;
@property (nonatomic ,copy) NSString * name;
@property (nonatomic ,copy) NSString * vedioid;
@property (nonatomic ,copy) NSString * isover;

@property (nonatomic ,assign) NSInteger speed;
@property (nonatomic ,assign) ZJCMineDownloadModelStstus isDownloading;

@end
