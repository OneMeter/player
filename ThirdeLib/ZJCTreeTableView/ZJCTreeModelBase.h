//
//  ZJCTreeModelBase.h
//  CCRA
//
//  Created by htkg on 16/5/10.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <JSONModel/JSONModel.h>


/**
 *  @brief 下载控制模型(Item) 下载状态枚举
 */
typedef enum {
    ZJCTreeModelStatusWait = 1,       // 等待
    ZJCTreeModelStatusStart,          // 开始
    ZJCTreeModelStatusDownloading,    // 下载中
    ZJCTreeModelStatusPause,          // 暂停
    ZJCTreeModelStatusFinish,         // 完成
    ZJCTreeModelStatusError           // 出错
}ZJCTreeModelStatus;


@interface ZJCTreeModelBase : JSONModel

@property (nonatomic ,assign) ZJCTreeModelStatus treeModelStatus;   // 下载状态

@end
