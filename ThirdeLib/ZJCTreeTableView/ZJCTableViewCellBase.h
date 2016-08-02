//
//  ZJCTableViewCellBase.h
//  CCRA
//
//  Created by htkg on 16/4/4.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 cell编辑状态   >>>   "正在编辑" "未编辑"
 */
typedef enum {
    ZJCTableViewCellEditStatusEdit = 1,
    ZJCTableViewCellEditStatusNone
}ZJCTableViewCellEditStatus;


/**
 cell类型   >>>   "我的课程" "缓存列表" "下载列表"
 */
typedef enum {
    ZJCTableViewCellTypeFind = 1,
    ZJCTableViewCellTypeDownList,
    ZJCTableViewCellTypeMyCourse
}ZJCTableViewCellType;

@interface ZJCTableViewCellBase : UITableViewCell

@property (nonatomic ,assign) ZJCTableViewCellType cellType;
@property (nonatomic ,assign) ZJCTableViewCellEditStatus editStatus;

@end
