//
//  ZJCThirdLevelModel.h
//  CCRA
//
//  Created by htkg on 16/4/4.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCTreeModelBase.h"

@interface ZJCThirdLevelModel : ZJCTreeModelBase

@property (nonatomic ,copy) NSString * title;
@property (nonatomic ,copy) NSString * timeNumber;
@property (nonatomic ,copy) NSString * ispaper;
@property (nonatomic ,copy) NSString * eid;
@property (nonatomic ,copy) NSString * myCountNumber;    // 用来编号的标志量,并没有什么特别的用处


@property (nonatomic ,assign) BOOL isSelected;           // 编辑选中状态

@property (nonatomic ,copy) NSString * myid;
@property (nonatomic ,copy) NSString * myparentid;
@property (nonatomic ,copy) NSString * maxcount;
@property (nonatomic ,copy) NSString * imageurl;
@property (nonatomic ,copy) NSString * name;
@property (nonatomic ,copy) NSString * vedioid;
@property (nonatomic ,copy) NSString * isover;

@property (nonatomic ,assign) NSInteger speed;

@end
