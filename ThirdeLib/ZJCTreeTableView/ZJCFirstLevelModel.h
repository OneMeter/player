//
//  ZJCFirstLevelModel.h
//  CCRA
//
//  Created by htkg on 16/4/4.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCTreeModelBase.h"

@interface ZJCFirstLevelModel : ZJCTreeModelBase

@property (nonatomic ,copy) NSString * title;         // 标题
@property (nonatomic ,copy) NSString * courseNumber;  // 课时数
@property (nonatomic ,copy) NSString * downNumber;    // 缓冲数量
@property (nonatomic ,copy) NSString * islooker;      // 是否结课

@property (nonatomic ,assign) BOOL isSelected;        // 编辑选中状态

@property (nonatomic ,copy) NSString * myid;
@property (nonatomic ,copy) NSString * myparentid;
@property (nonatomic ,copy) NSString * maxcount;
@property (nonatomic ,copy) NSString * imageurl;
@property (nonatomic ,copy) NSString * name;
@property (nonatomic ,copy) NSString * vedioid;
@property (nonatomic ,copy) NSString * isover;

@property (nonatomic ,assign) NSInteger speed;

@property (strong,nonatomic) NSString *headImgPath;     // 本地图片名,若不为空则优先于远程图片加载
@property (strong,nonatomic) NSURL *headImgUrl;         // 远程图片链接

@end
