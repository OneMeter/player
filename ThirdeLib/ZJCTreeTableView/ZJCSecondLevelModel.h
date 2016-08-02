//
//  ZJCSecondLevelModel.h
//  CCRA
//
//  Created by htkg on 16/4/4.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCTreeModelBase.h"

@interface ZJCSecondLevelModel : ZJCTreeModelBase

@property (nonatomic ,copy) NSString * title;    // 章 标题
@property (copy,nonatomic) NSString * sonCnt;    // 含有的 节 数量
@property (nonatomic ,copy) NSString * eid;      // 试卷eid
@property (nonatomic ,copy) NSString * ispaper;  // 是否做过练习题

@property (nonatomic ,assign) BOOL isSelected;   // 编辑选中状态

@property (nonatomic ,copy) NSString * myid;
@property (nonatomic ,copy) NSString * myparentid;
@property (nonatomic ,copy) NSString * maxcount;
@property (nonatomic ,copy) NSString * imageurl;
@property (nonatomic ,copy) NSString * name;
@property (nonatomic ,copy) NSString * vedioid;
@property (nonatomic ,copy) NSString * isover;

@property (nonatomic ,assign) NSInteger speed;

@end
