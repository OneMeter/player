//
//  ZJCMineDownloadRecordDetailViewController.h
//  CCRA
//
//  Created by htkg on 16/4/1.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCSecondLeaveBaseViewController.h"

@interface ZJCMineDownloadRecordDetailViewController : ZJCSecondLeaveBaseViewController

@property (nonatomic ,copy) NSString * myParentId;   // 父节点的id
@property (nonatomic ,assign) BOOL isDownloading;    // 是否正在下载
@property (nonatomic ,assign) BOOL isAllDownload;    // 已经下载完成全部

@end
